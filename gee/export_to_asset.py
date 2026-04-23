#!/usr/bin/env python3
"""Export source GEE imagery to user-owned persistent assets.

Reads gee/layer_manifest.yaml, constructs the appropriate ee.Image per entry
under the manifest's reducer, and submits one ee.batch.Export.image.toAsset
task per layer. Writes per-layer metadata JSON to data/rendered/metadata/
once each task completes.

Usage:
  python gee/export_to_asset.py [--only ID [ID ...]] [--force] [--dry-run]

Design decisions (see specs/TODO_0001_GEE_Raster_Export.md §6):
  - Assets live under projects/murphys-deforisk/assets/ipcc-wildfires/<id>.
  - AOI is FAO/GAUL/2015/level0 filtered to Honduras.
  - Target CRS is EPSG:32616 (UTM zone 16N).
  - Tasks are queued in batches of at most 5 concurrent.
  - Idempotent: skip an asset that already exists unless --force is passed.
"""

from __future__ import annotations

import argparse
import json
import sys
import time
from dataclasses import dataclass
from pathlib import Path

import ee
import yaml

REPO_ROOT = Path(__file__).resolve().parent.parent
MANIFEST = REPO_ROOT / "gee" / "layer_manifest.yaml"
METADATA_DIR = REPO_ROOT / "data" / "rendered" / "metadata"

MAX_CONCURRENT = 5
POLL_INTERVAL_S = 30


@dataclass
class LayerSpec:
    id: str
    source: str
    source_type: str
    band: str | None
    bands: list[str] | None
    reducer: str
    date_range: dict | list | None
    scale_m: int
    dtype: str
    description: str
    display_only: bool
    bands_per_year: bool

    @classmethod
    def from_manifest(cls, entry: dict) -> "LayerSpec":
        dr = entry.get("date_range")
        return cls(
            id=entry["id"],
            source=entry["source"],
            source_type=entry.get("source_type", "image_collection"),
            band=entry.get("band"),
            bands=entry.get("bands"),
            reducer=entry["reducer"],
            date_range=dr,
            scale_m=int(entry["scale_m"]),
            dtype=entry.get("dtype", "uint8"),
            description=entry.get("description", ""),
            display_only=bool(entry.get("display_only", False)),
            bands_per_year=bool(entry.get("bands_per_year", False)),
        )


def load_manifest() -> tuple[dict, list[LayerSpec]]:
    data = yaml.safe_load(MANIFEST.read_text())
    layers = [LayerSpec.from_manifest(e) for e in data["layers"]]
    return data, layers


def get_aoi(manifest: dict) -> ee.Geometry:
    aoi_cfg = manifest["aoi"]
    fc = ee.FeatureCollection(aoi_cfg["source"]).filter(
        ee.Filter.eq("ADM0_NAME", "Honduras")
    )
    return fc.geometry()


def build_image(spec: LayerSpec, aoi: ee.Geometry) -> ee.Image:
    """Translate a manifest reducer recipe into an ee.Image."""
    if spec.source_type == "image":
        img = ee.Image(spec.source).clip(aoi)
        if spec.reducer == "clip":
            return img
        raise NotImplementedError(
            f"{spec.id}: source_type=image only supports reducer=clip"
        )

    coll = ee.ImageCollection(spec.source).filterBounds(aoi)

    if spec.date_range and isinstance(spec.date_range, list):
        start, end = spec.date_range
        coll = coll.filterDate(str(start), str(end))
    elif spec.date_range and isinstance(spec.date_range, dict):
        # handled below for dNBR
        pass

    if spec.reducer == "max_gt_zero":
        return coll.select(spec.band).max().gt(0).selfMask().clip(aoi).rename(spec.id)

    if spec.reducer == "per_year_max_gt_zero":
        start, end = spec.date_range
        years = list(range(int(str(start)[:4]), int(str(end)[:4]) + 1))
        bands = []
        for y in years:
            yearly = (
                coll.filterDate(f"{y}-01-01", f"{y}-12-31")
                .select(spec.band)
                .max()
                .gt(0)
                .rename(f"burn_{y}")
            )
            bands.append(yearly)
        return ee.Image.cat(bands).clip(aoi)

    if spec.reducer == "mean":
        return coll.select(spec.band).mean().clip(aoi).rename(spec.id)

    if spec.reducer == "max_gte_7":
        return (
            coll.select(spec.band).max().gte(7).selfMask().clip(aoi).rename(spec.id)
        )

    if spec.reducer == "first":
        return coll.select(spec.band or spec.bands).first().clip(aoi)

    if spec.reducer == "none" and spec.bands:
        return ee.Image(spec.source).select(spec.bands).clip(aoi)

    if spec.reducer == "dnbr_pre_post":
        dr = spec.date_range
        pre_start, pre_end = dr["pre"]
        post_start, post_end = dr["post"]

        def nbr(img):
            nir = img.select("SR_B5").multiply(0.0000275).add(-0.2)
            swir = img.select("SR_B7").multiply(0.0000275).add(-0.2)
            return nir.subtract(swir).divide(nir.add(swir)).rename("NBR")

        pre = coll.filterDate(pre_start, pre_end).map(nbr).median()
        post = coll.filterDate(post_start, post_end).map(nbr).median()
        return pre.subtract(post).rename("dNBR").clip(aoi)

    if spec.reducer == "mask_gt_30":
        return (
            ee.Image(spec.source)
            .select(spec.band)
            .gt(30)
            .selfMask()
            .clip(aoi)
            .rename(spec.id)
        )

    raise NotImplementedError(f"{spec.id}: reducer {spec.reducer!r} not implemented")


def submit_task(
    spec: LayerSpec,
    img: ee.Image,
    aoi: ee.Geometry,
    asset_root: str,
    target_crs: str,
) -> ee.batch.Task:
    asset_id = f"{asset_root}/{spec.id}"
    task = ee.batch.Export.image.toAsset(
        image=img,
        description=f"ipcc-wildfires-{spec.id}"[:100],
        assetId=asset_id,
        region=aoi,
        scale=spec.scale_m,
        crs=target_crs,
        maxPixels=int(1e10),
    )
    task.start()
    return task


def asset_exists(asset_id: str) -> bool:
    try:
        ee.data.getAsset(asset_id)
        return True
    except Exception:
        return False


def ensure_folder(asset_root: str) -> None:
    """Create the asset folder if missing. No-op if it already exists."""
    if asset_exists(asset_root):
        return
    print(f"[create-folder] {asset_root}")
    ee.data.createAsset({"type": "FOLDER"}, asset_root)


def write_metadata(spec: LayerSpec, asset_id: str, task_id: str) -> None:
    METADATA_DIR.mkdir(parents=True, exist_ok=True)
    out = METADATA_DIR / f"{spec.id}_{time.strftime('%Y%m%d')}.json"
    payload = {
        "id": spec.id,
        "asset_id": asset_id,
        "task_id": task_id,
        "source": spec.source,
        "reducer": spec.reducer,
        "scale_m": spec.scale_m,
        "dtype": spec.dtype,
        "description": spec.description,
        "display_only": spec.display_only,
        "export_timestamp_utc": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    }
    out.write_text(json.dumps(payload, indent=2))
    print(f"  wrote {out.relative_to(REPO_ROOT)}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--only", nargs="*", help="Layer IDs to export (default: all)")
    parser.add_argument(
        "--force", action="store_true", help="Overwrite existing assets"
    )
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    manifest, layers = load_manifest()
    asset_root = manifest["asset_root"]
    target_crs = manifest["aoi"]["target_crs"]
    ee.Initialize(project=manifest["asset_project"])
    aoi = get_aoi(manifest)

    selected = (
        [s for s in layers if s.id in set(args.only)] if args.only else layers
    )
    if not selected:
        print("no layers selected", file=sys.stderr)
        return 1

    if not args.dry_run:
        ensure_folder(asset_root)

    pending: list[tuple[LayerSpec, ee.batch.Task, str]] = []

    for spec in selected:
        asset_id = f"{asset_root}/{spec.id}"
        if asset_exists(asset_id) and not args.force:
            print(f"[skip] {spec.id} — asset already exists")
            continue

        img = build_image(spec, aoi)
        if args.dry_run:
            print(f"[dry-run] would export {spec.id} -> {asset_id}")
            continue

        while len([t for _, t, _ in pending if t.status()["state"] in {"READY", "RUNNING"}]) >= MAX_CONCURRENT:
            time.sleep(POLL_INTERVAL_S)

        task = submit_task(spec, img, aoi, asset_root, target_crs)
        print(f"[submit] {spec.id} -> {asset_id}  (task {task.id})")
        pending.append((spec, task, asset_id))

    if args.dry_run:
        return 0

    for spec, task, asset_id in pending:
        while task.status()["state"] in {"READY", "RUNNING"}:
            time.sleep(POLL_INTERVAL_S)
        state = task.status()["state"]
        print(f"[{state}] {spec.id}")
        if state == "COMPLETED":
            write_metadata(spec, asset_id, task.id)
        else:
            print(f"  ERROR: {task.status().get('error_message', 'unknown')}")

    return 0


if __name__ == "__main__":
    sys.exit(main())

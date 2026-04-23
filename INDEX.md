# Repository Index

*Source of truth for what exists, what is in progress, and what is pending.*

*Last updated: 2026-04-22*

----------------------------------------------------------------------------------------------------

## 1. Book content

| File                             | Role                        | Lines | Notes                              |
|----------------------------------|-----------------------------|-------|------------------------------------|
| `index.qmd`                      | Preface                     | 532   | 4 interactive maps, live GEE       |
| `01-burn-area/index.qmd`         | Chapter 1: Burn Area        | 1398  | 5 interactive maps, live GEE       |
| `02-fuel-stratification/index.qmd` | Chapter 2: Fuel Strata    | 1266  | 7 interactive maps, live GEE       |
| `03-fuel-consumption/index.qmd`  | Chapter 3: Fuel Consumption | 1148  | 2 interactive maps, live GEE       |
| `04-emission-factors/index.qmd`  | Chapter 4: Emission Factors | 1387  | up to 2 interactive maps, live GEE |

## 2. Committed data

| Path                                      | Role                                 | Size    | Provenance                       |
|-------------------------------------------|--------------------------------------|---------|----------------------------------|
| `data/raw/honduras_faostat_fires.csv`     | FAOSTAT validation series 1990–2024  | ~200 kB | FAOSTAT bulk download 2026-04-04 |
| `data/rendered/`                          | GEE-derived COG cache (see §3 below) | TBD     | Exported 2026-04-xx (in progress)|

## 3. GEE export infrastructure (TODO 0001)

| File                              | Role                                                                  |
|-----------------------------------|-----------------------------------------------------------------------|
| `gee/layer_manifest.yaml`         | Registry of GEE source assets and local COG targets                   |
| `gee/export_to_asset.py`          | Source imagery → persistent GEE asset under user's project            |
| `gee/download_cogs.R`             | GEE asset → local COG in `data/rendered/`                             |
| `R/palettes.R`                    | Shared colour palettes used by both export preview and book render    |
| `R/local_rasters.R`               | Loader mapping layer ID → `terra::SpatRaster` for render chunks       |

## 4. Static assets

| Path                                           | Role                                          |
|------------------------------------------------|-----------------------------------------------|
| `01-burn-area/AOI/aoi_burn_aa.png`             | Preface TOC banner, PDF fallback              |
| `02-fuel-stratification/assets/`               | Static PNG sidecars for printed PDF target    |
| `04-emission-factors/assets/`                  | Static PNG sidecars for printed PDF target    |

## 5. Standards (read on demand, never in full)

| Path                                         | Handling                       |
|----------------------------------------------|--------------------------------|
| `references/IPCC-2019-Refinement-Vol4-Ch2.md`| Read by section number         |
| `references/IPCC-2019-Refinement-Vol1-Ch3.md`| Read uncertainty sections only |
| `references/IPCC-AR6-WG1-GWP-Table.md`       | Read in full                   |

## 6. Tasks

### In progress

None.

### Handover (pending revert or migration)

- **Preface FAOSTAT update** — `specs/TODO_HANDOVER_Preface_FAOSTAT_Update.md`
  Draft edits applied to `index.qmd` re: FAOSTAT bulk data. Awaits user direction on whether to revert or branch.

### Completed

- **FEATURE 0001** — `specs/FEATURE_0001_GEE_Raster_Export.md`
  GEE raster export and offline map conversion. 11 source layers exported to `projects/murphys-deforisk/assets/ipcc-wildfires/`, 9 mirrored as local COGs, 21 map chunks rewritten. Book renders HTML end-to-end without depending on live GEE tile URLs for display. Branch `feature/gee-raster-export`.

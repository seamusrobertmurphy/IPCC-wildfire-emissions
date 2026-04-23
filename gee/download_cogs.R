#!/usr/bin/env Rscript
# Download GEE assets as local Cloud-Optimised GeoTIFFs.
#
# Reads gee/layer_manifest.yaml, pulls each asset's pixels via the computePixels
# endpoint (getDownloadURL), and writes a COG to data/rendered/<id>.tif.
# Metadata JSON written alongside.
#
# Usage:
#   Rscript gee/download_cogs.R [--only ID ...] [--force]
#
# Design decisions (see specs/TODO_0001_GEE_Raster_Export.md §6):
#   - Uses rgee::ee_as_raster(via = "getDownloadURL"); no Google Drive.
#   - Target CRS EPSG:32616 (UTM 16N). Book is indifferent to this once loaded.
#   - COGs compressed with DEFLATE + PREDICTOR=2, 256x256 blocks.
#   - Size reported per layer; anything >50 MB flagged for GitHub release.

suppressPackageStartupMessages({
  library(yaml)
  library(rgee)
  library(terra)
  library(sf)
  library(jsonlite)
})

repo_root   <- here::here()
manifest_fp <- file.path(repo_root, "gee", "layer_manifest.yaml")
rendered    <- file.path(repo_root, "data", "rendered")
metadata    <- file.path(rendered, "metadata")

dir.create(rendered, showWarnings = FALSE, recursive = TRUE)
dir.create(metadata, showWarnings = FALSE, recursive = TRUE)

args   <- commandArgs(trailingOnly = TRUE)
force  <- "--force" %in% args
only   <- if ("--only" %in% args) {
  idx <- which(args == "--only")
  args[(idx + 1):length(args)]
} else {
  NULL
}

manifest <- yaml::read_yaml(manifest_fp)

rgee::ee_Initialize(project = manifest$asset_project)

# AOI as ee$Geometry for clipping at download time.
aoi_ee <- ee$FeatureCollection(manifest$aoi$source)$
  filter(ee$Filter$eq("ADM0_NAME", "Honduras"))$
  geometry()

# One-off: export AOI as committed GPKG if missing.
aoi_gpkg <- file.path(repo_root, manifest$aoi$committed_path)
if (!file.exists(aoi_gpkg) || force) {
  message("Writing AOI GPKG...")
  aoi_sf <- sf::st_as_sf(rgee::ee_as_sf(aoi_ee))
  aoi_sf <- sf::st_transform(aoi_sf, 32616)
  sf::st_write(aoi_sf, aoi_gpkg, delete_dsn = TRUE, quiet = TRUE)
}

cog_options <- c(
  "COMPRESS=DEFLATE",
  "PREDICTOR=2",
  "TILED=YES",
  "BLOCKXSIZE=256",
  "BLOCKYSIZE=256",
  "COPY_SRC_OVERVIEWS=YES"
)

download_layer <- function(spec) {
  id       <- spec$id
  asset_id <- paste0(manifest$asset_root, "/", id)
  out_fp   <- file.path(rendered, paste0(id, ".tif"))

  if (file.exists(out_fp) && !force) {
    message(sprintf("[skip] %s — COG already exists", id))
    return(invisible(NULL))
  }

  message(sprintf("[pull] %s <- %s", id, asset_id))
  img <- ee$Image(asset_id)

  tmp_fp <- tempfile(fileext = ".tif")

  rgee::ee_as_raster(
    image   = img,
    region  = aoi_ee,
    dsn     = tmp_fp,
    scale   = spec$scale_m,
    via     = "getDownloadURL",
    maxPixels = 1e10
  )

  r <- terra::rast(tmp_fp)
  r <- terra::project(r, "EPSG:32616", method = if (grepl("display", id)) "bilinear" else "near")
  terra::writeRaster(
    r,
    filename  = out_fp,
    overwrite = TRUE,
    filetype  = "COG",
    gdal      = cog_options,
    datatype  = toupper(spec$dtype %||% "INT1U")
  )

  size_mb <- file.info(out_fp)$size / 1e6
  message(sprintf("  wrote %s (%.1f MB)", basename(out_fp), size_mb))

  meta <- list(
    id              = id,
    asset_id        = asset_id,
    local_cog       = basename(out_fp),
    size_mb         = round(size_mb, 2),
    over_50mb       = size_mb > 50,
    target_crs      = "EPSG:32616",
    scale_m         = spec$scale_m,
    display_only    = isTRUE(spec$display_only),
    download_utc    = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
    rgee_version    = as.character(packageVersion("rgee"))
  )
  jsonlite::write_json(
    meta,
    file.path(metadata, sprintf("%s_%s.json", id, format(Sys.Date(), "%Y%m%d"))),
    auto_unbox = TRUE, pretty = TRUE
  )

  if (size_mb > 50) {
    warning(sprintf(
      "%s exceeds 50 MB (%.1f MB). Move to GitHub release 'gee-exports-v1' with piggyback.",
      id, size_mb
    ))
  }
}

`%||%` <- function(x, y) if (is.null(x)) y else x

layers <- manifest$layers
if (!is.null(only)) {
  layers <- Filter(function(s) s$id %in% only, layers)
}

oversized <- character()
for (spec in layers) {
  size <- tryCatch(download_layer(spec), error = function(e) {
    message(sprintf("[fail] %s: %s", spec$id, conditionMessage(e)))
    NA_real_
  })
}

message("\nDone. Inspect data/rendered/ for COGs and data/rendered/metadata/ for per-layer JSON.")

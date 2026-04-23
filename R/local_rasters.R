# Loader and render helpers for GEE-derived COGs.
#
# Each .qmd map chunk calls local_raster("<layer_id>") to obtain a
# terra::SpatRaster ready for mapview / leaflet / tmap display.
# The loader resolves the path against data/rendered/ in the committed repo
# or, if the layer is flagged oversize, against a piggyback cache.

suppressPackageStartupMessages({
  library(terra)
  library(yaml)
})

.manifest_cache <- new.env(parent = emptyenv())

load_manifest <- function() {
  if (is.null(.manifest_cache$data)) {
    fp <- here::here("gee", "layer_manifest.yaml")
    .manifest_cache$data <- yaml::read_yaml(fp)
  }
  .manifest_cache$data
}

layer_spec <- function(id) {
  m <- load_manifest()
  hit <- Filter(function(s) s$id == id, m$layers)
  if (!length(hit)) stop(sprintf("Unknown layer id: %s", id), call. = FALSE)
  hit[[1]]
}

# Path resolver: committed COG first, piggyback cache fallback.
resolve_cog_path <- function(id) {
  local <- here::here("data", "rendered", paste0(id, ".tif"))
  if (file.exists(local)) return(local)

  cache <- here::here(".piggyback_cache", paste0(id, ".tif"))
  if (file.exists(cache)) return(cache)

  # Fetch from GitHub release if piggyback is set up.
  if (requireNamespace("piggyback", quietly = TRUE)) {
    dir.create(dirname(cache), showWarnings = FALSE, recursive = TRUE)
    try(piggyback::pb_download(
      file  = paste0(id, ".tif"),
      dest  = dirname(cache),
      tag   = "gee-exports-v1",
      repo  = "seamusrobertmurphy/TREES-wildfire-replications"
    ), silent = TRUE)
    if (file.exists(cache)) return(cache)
  }
  stop(sprintf(
    "COG not found for %s. Ran `Rscript gee/download_cogs.R --only %s`?",
    id, id
  ), call. = FALSE)
}

local_raster <- function(id, display_crs = "EPSG:4326") {
  fp <- resolve_cog_path(id)
  r  <- terra::rast(fp)
  if (!is.null(display_crs) && terra::crs(r, describe = TRUE)$code != sub("EPSG:", "", display_crs)) {
    method <- if (grepl("display", id)) "bilinear" else "near"
    r <- terra::project(r, display_crs, method = method)
  }
  r
}

# Vector AOI loader for country / subnational outlines.
local_aoi <- function(level = c("country", "states")) {
  level <- match.arg(level)
  fp <- here::here("data", "rendered", "aoi_honduras.gpkg")
  if (!file.exists(fp)) {
    stop("AOI GPKG missing. Run gee/download_cogs.R.", call. = FALSE)
  }
  suppressMessages(sf::st_read(fp, quiet = TRUE))
}

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

# Vector AOI loader. The GPKG written by gee/download_cogs.R is multilayer:
# `country` (GAUL level 0 dissolved) and `states` (GAUL level 1).
local_aoi <- function(level = c("country", "states")) {
  level <- match.arg(level)
  fp <- here::here("data", "rendered", "aoi_honduras.gpkg")
  if (!file.exists(fp)) {
    stop("AOI GPKG missing. Run gee/download_cogs.R.", call. = FALSE)
  }
  suppressMessages(sf::st_read(fp, layer = level, quiet = TRUE))
}

# --- tmap helpers ---------------------------------------------------------
#
# Every live-GEE map chunk is rewritten to use these. They take a manifest
# layer id and the palette from R/palettes.R and emit a tmap layer that
# renders identically in `tmap_mode("view")` (HTML leaflet) and in the
# static plot mode (PDF).

#' Categorical raster layer with a named palette (e.g. IGBP, IPCC climate).
#'
#' @param id           manifest layer id (resolved via local_raster())
#' @param palette      list with $colors, optionally $min/$max and $labels
#' @param title        legend title
#' @param group        leaflet group (defaults to title)
#' @param alpha        fill opacity; defaults to 0.7 to match original maps
tm_local_categorical <- function(id, palette, title, group = NULL, alpha = 0.7) {
  r <- local_raster(id)
  grp <- group %||% title
  tmap::tm_shape(r) +
    tmap::tm_raster(
      palette    = palette$colors,
      style      = "cat",
      title      = title,
      alpha      = alpha,
      group      = grp,
      labels     = palette$labels,
      showNA     = FALSE,
      colorNA    = NULL
    )
}

#' Single-colour mask layer (burn area overlays, active fire dots, etc.).
#' Treats value 0 / NA as transparent.
tm_local_mask <- function(id, colour, title, group = NULL, alpha = 0.7) {
  r <- local_raster(id)
  r[r == 0] <- NA
  grp <- group %||% title
  tmap::tm_shape(r) +
    tmap::tm_raster(
      palette = colour,
      style   = "cat",
      title   = title,
      alpha   = alpha,
      group   = grp,
      showNA  = FALSE,
      colorNA = NULL
    )
}

#' Continuous raster layer (dNBR, forest cover percent, etc.).
tm_local_continuous <- function(id, palette_colours, title,
                                breaks = NULL, group = NULL, alpha = 0.7) {
  r   <- local_raster(id)
  grp <- group %||% title
  tmap::tm_shape(r) +
    tmap::tm_raster(
      palette = palette_colours,
      style   = if (is.null(breaks)) "cont" else "fixed",
      breaks  = breaks,
      title   = title,
      alpha   = alpha,
      group   = grp,
      showNA  = FALSE,
      colorNA = NULL
    )
}

#' Compute the burn-edge mask locally from the binary burn composite.
#' Mirrors the original focal_max(1, "square") − burn operation done in GEE.
local_burn_edges <- function(id = "mcd64a1_burn_2000_2025_max") {
  r  <- local_raster(id)
  rb <- !is.na(r) & r > 0
  e  <- terra::focal(rb, w = 3, fun = "max", na.policy = "omit") - rb
  e[e <= 0] <- NA
  e
}

#' Reclassify IGBP 17-class to 3 IPCC fire categories (forest / savanna / other).
local_fire_categories <- function(id = "mcd12q1_igbp_2020") {
  r <- local_raster(id)
  rcl <- matrix(c(
     1,1,  2,1,  3,1,  4,1,  5,1,
     6,2,  7,2,  8,2,  9,2, 10,2,
    11,3, 12,3, 13,3, 14,3, 15,3, 16,3, 17,3
  ), ncol = 2, byrow = TRUE)
  terra::classify(r, rcl, others = NA)
}

#' Forest strata (tropical moist / dry / temperate / boreal) from IGBP + WorldClim.
local_forest_strata <- function() {
  igbp   <- local_raster("mcd12q1_igbp_2020")
  bio    <- local_raster("worldclim_bio01_bio12")
  temp   <- bio[[1]]         # bio01, °C × 10
  precip <- bio[[2]]         # bio12, mm
  forest <- igbp >= 1 & igbp <= 5
  trop   <- temp > 180
  trop_m <- forest & trop & precip > 1500
  trop_d <- forest & trop & precip <= 1500
  temp_z <- forest & temp > 0 & temp <= 180
  boreal <- forest & temp <= 0
  out    <- terra::init(igbp, 0L)
  out[trop_m] <- 1L
  out[trop_d] <- 2L
  out[temp_z] <- 3L
  out[boreal] <- 4L
  out[out == 0] <- NA
  out
}

# Shared colour palettes for the book.
#
# Centralising these so render chunks always match the original GEE visParams.
# Each list corresponds to one visualisation and is consumed by R/local_rasters.R
# and by the leaflet / tmap map-building code in the .qmd files.

ipcc_climate_palette <- list(
  min    = 1L,
  max    = 12L,
  colors = c(
    "#8B4513", "#1B9E77", "#66A61E", "#E6AB02",
    "#7570B3", "#A6761D", "#4682B4", "#87CEEB",
    "#006400", "#8FBC8F", "#B0B0B0", "#E0E0E0"
  ),
  labels = c(
    "1 Tropical Montane",  "2 Tropical Wet",
    "3 Tropical Moist",    "4 Tropical Dry",
    "5 Warm Temp. Moist",  "6 Warm Temp. Dry",
    "7 Cool Temp. Moist",  "8 Cool Temp. Dry",
    "9 Boreal Moist",      "10 Boreal Dry",
    "11 Polar Moist",      "12 Polar Dry"
  )
)

ipcc_soils_palette <- list(
  min    = 1L,
  max    = 13L,
  colors = c(
    "#E0E0E0", "#A66F03", "#FFD27F", "#FEBDBD", "#2A7200",
    "#D7D69D", "#676767", "#FFFFBD", "#9B9B9B", "#0083A8",
    "#8303A7", "#BDE7FF", "black"
  ),
  visible_colors = c(
    "#A66F03", "#FFD27F", "#2A7200", "#D7D69D",
    "#FFFFBD", "#0083A8", "#8303A7"
  ),
  visible_labels = c(
    "HAC — High activity clay", "LAC — Low activity clay",
    "ORG — Organic soils",      "POD — Spodic soils",
    "SAN — Sandy soils",        "VOL — Volcanic soils",
    "WET — Wetland soils"
  )
)

igbp_palette <- list(
  min    = 0L,
  max    = 17L,
  colors = c(
    "#05450a", "#086a10", "#54a708", "#78d203", "#009900",
    "#c6b044", "#dcd159", "#dade48", "#fbff13", "#b6ff05",
    "#27ff87", "#c24f44", "#a5a5a5", "#ff6d4c", "#69fff8",
    "#f9ffa4", "#1c0dff"
  )
)

fire_categories_palette <- list(
  min    = 1L,
  max    = 3L,
  colors = c("#006400", "#DAA520", "#D3D3D3"),
  labels = c(
    "Forest (IGBP 1–5)",
    "Savanna (IGBP 6–10)",
    "Other (IGBP 11–17, excluded)"
  )
)

forest_strata_palette <- list(
  min    = 1L,
  max    = 4L,
  colors = c("#006400", "#9ACD32", "#DAA520", "#4682B4"),
  labels = c(
    "Tropical Moist (M₂ 120–164 t/ha)",
    "Tropical Dry (M₂ 84 t/ha)",
    "Temperate (M₂ 50 t/ha)",
    "Boreal (M₂ 41 t/ha)"
  )
)

burn_palette <- list(
  fill       = "red",
  edge_fill  = "#FFFF00",
  min        = 0L,
  max        = 1L,
  label      = "Burn Area",
  title      = "MCD64A1 (2000–2025)"
)

filter_palette <- list(
  pre_fill  = "red",
  post_fill = "yellow",
  min       = 0L,
  max       = 1L
)

fire_agreement_palette <- list(
  overlap_fill = "green",
  ba_only_fill = "blue",
  af_only_fill = "red",
  min          = 0L,
  max          = 1L
)

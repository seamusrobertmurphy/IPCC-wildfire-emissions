# IPCC Tier 1 Fire Emissions

[![Quarto Publish](https://img.shields.io/badge/Quarto-Published-blue?logo=quarto)](https://seamusrobertmurphy.quarto.pub/ipcc-fire-emissions/) [![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/) [![ORCID](https://img.shields.io/badge/ORCID-0000--0002--1792--0351-green?logo=orcid)](https://orcid.org/0000-0002-1792-0351)

A reproducible, end-to-end implementation of the IPCC Tier 1 methodology for estimating greenhouse gas emissions from wildfire and prescribed burning. Built as an executable eBook in R and Python sourcing approved datasets in the Google Earth Engine Catalog to compute national level emissions and export outputs for local reporting.

[Read the full book =\>\>](https://seamusrobertmurphy.quarto.pub/ipcc-fire-emissions/)

------------------------------------------------------------------------

## Overview

This project implements Equation 2.27 from the 2006 IPCC Guidelines (as updated by the 2019 Refinement) to estimate fire emissions of CH~4~, N~2~O, and CO~2~ at national scale:

$$L_{fire} = A \times M_B \times C_f \times G_{ef} \times 10^{-3}$$

Each chapter corresponds to one component of the equation, progressing from burned area detection through to emission factor application and UNFCCC reporting. The workflow is demonstrated for Honduras (2010) using freely available global datasets.

### Key methodological features

-   Burned area: MODIS MCD64A1 Collection 6.1 with FAOSTAT-consistent quality filters
-   Land cover stratification: IGBP classification (MCD12Q1) into forest, savanna, and organic soil fire types, with WorldClim climate zone delineation
-   Fuel consumption: IPCC default values (Table 2.4) stratified by vegetation type and climate zone
-   Emission factors: Table 2.5 (2019 Refinement) for CH~4~ and N~2~O; Wetlands Supplement for organic soil CO~2~
-   C~2~ accounting: Correctly implements the IPCC treatment where forest CO~2~ is reported via carbon stock changes (not excluded), savanna CO~2~ is excluded at Tier 1 per the synchrony assumption, and organic soil CO~2~ is reported separately
-   Uncertainty: Error propagation and Monte Carlo simulation (10,000 iterations)
-   Reporting: Outputs formatted for UNFCCC Common Reporting Format (CRF) Tables 4.C and 4.F

------------------------------------------------------------------------

## Chapters

1.  [Burned Area](https://seamusrobertmurphy.quarto.pub/ipcc-fire-emissions/01-burn-area/): Extract and validate MODIS MCD64A1 burned area for Honduras 2010; apply uncertainty filters; compute annual burned area by land cover type
2.  [Fuel Stratification](https://seamusrobertmurphy.quarto.pub/ipcc-fire-emissions/02-fuel-stratification/): Classify burned pixels into IPCC fire and fuel categories (forest, savanna, organic soil) according to Tier 1 land cover, climate and agroecological zones.
3.  [Fuel Consumption](https://seamusrobertmurphy.quarto.pub/ipcc-fire-emissions/03-fuel-consumption/): Assign IPCC Tier 1 default fuel consumption values (M~B~ × C~f~ by vegetation type and climate zone.
4.  [Emission Factors](https://seamusrobertmurphy.quarto.pub/ipcc-fire-emissions/04-emission-factors/): Apply IPCC emission factors (G) to compute CH~4~, N~2~O, and CO~2~ emissions; convert to CO~2~-equivalents; format for CRF reporting.

------------------------------------------------------------------------

## Data Sources

| Dataset | Source | Use |
|---------------------|--------------------|-------------------------------|
| MCD64A1 C6.1 | [MODIS via GEE](https://developers.google.com/earth-engine/datasets/catalog/MODIS_061_MCD64A1) | Monthly burned area (500 m) |
| MCD12Q1 C6.1 | [MODIS via GEE](https://developers.google.com/earth-engine/datasets/catalog/MODIS_061_MCD12Q1) | IGBP land cover classification |
| WorldClim V1 | [WorldClim via GEE](https://developers.google.com/earth-engine/datasets/catalog/WORLDCLIM_V1_BIO) | Bioclimatic variables for climate zone delineation |
| FAO GAUL 2015 | [FAO via GEE](https://developers.google.com/earth-engine/datasets/catalog/FAO_GAUL_2015_level0) | Country and subnational administrative boundaries |
| IPCC Tables 2.4, 2.5 | 2019 Refinement, Vol. 4, Ch. 2 | Default fuel consumption and emission factors |
| IPCC Wetlands Supplement | 2013 Supplement | Organic soil emission factors |

------------------------------------------------------------------------

## IPCC Reference Documents

This implementation is based on the following IPCC methodological guidance:

-   2006 IPCC Guidelines for National Greenhouse Gas Inventories — Volume 4: Agriculture, Forestry and Other Land Use, Chapters 2 and 4
-   2019 Refinement to the 2006 IPCC Guidelines — Volume 4, Chapter 2 (Generic Methodologies) with updated Tables 2.4, 2.5, and 2.6
-   2013 Supplement to the 2006 Guidelines: Wetlands — Chapter 2 (Drained Inland Organic Soils), for peatland fire CO~2~ and CH~2~ emission factors
-   2013 Revised Supplementary Methods and Good Practice Guidance Arising from the Kyoto Protocol

------------------------------------------------------------------------

## Requirements

### Software

-   R ≥ 4.3
-   Quarto ≥ 1.4
-   Python 3.9+ (for `earthengine-api` via `reticulate`)
-   Google Earth Engine account with an authenticated project

### Key R packages

``` r
# Geospatial
sf, terra, stars, exactextractr, gdalcubes

# Earth Engine
reticulate  # with earthengine-api installed in Python env

# Visualization
tmap, leaflet, ggplot2, plotly

# Data
tidyverse, knitr
```

### Setup

``` bash
# Clone the repository
git clone https://github.com/seamusrobertmurphy/IPCC-wildfire-replications.git
cd IPCC-wildfire-replications

# Install R dependencies (from R console)
# install.packages("easypackages")
# easypackages::packages(<see index.qmd for full list>)

# Authenticate Earth Engine (from terminal)
earthengine authenticate

# Render the book
quarto render
```

------------------------------------------------------------------------

## CO~2~ Accounting Note

This project implements the correct IPCC treatment of CO~2~ from fire, which differs by fire type:

| Fire Type | CO~2~ Reported? | Method | IPCC Source |
|----------------|:--------------:|-----------------------|------------------|
| Forest | Yes | Carbon stock changes (Eq. 2.7–2.14) | 2006 GL, Vol. 4, §4.2.4 |
| Savanna | No | Synchrony assumed for non-woody grassland | 2019 Ref, Vol. 4, §2.4 |
| Organic Soil | Yes | Separate G~ef~ via Eq. 2.27 | 2013 Wetlands Supplement |

Forest fire CO<sub>2</sub> is not excluded from national inventories. It is captured through the carbon stock change framework because fire emissions and regrowth removals are not synchronous for woody biomass. The savanna synchrony assumption applies only to non-woody grassland at Tier 1, with explicit caveats for woody savannas in the 2019 Refinement.

------------------------------------------------------------------------

## Citation

``` bibtex
@online{murphy2026fire,
  author    = {Murphy, S},
  title     = {IPCC Tier 1 Fire Emissions: A Reproducible Workflow},
  year      = {2026},
  url       = {https://seamusrobertmurphy.quarto.pub/ipcc-fire-emissions/},
}
```

------------------------------------------------------------------------

## Additional Reading

#### IPCC Resources

| Resource | Description | Source |
|----------------|---------------------------------------|----------------|
| IPCC 2006, Vol. 4 |  |  |
| Ch.2 Generic Methodologies | Eq.2.9 Calculation of biomass retention & growth post-conversion | [Link](https://www.ipcc-nggip.iges.or.jp/public/2006gl/pdf/4_Volume4/V4_02_Ch2_Generic.pdf#page=15) |
| Ch.3 Representation of Lands | S.3.2 Six land-use categories recommended for estimating GHG emissions from LULC | [Link](https://www.ipcc-nggip.iges.or.jp/public/2006gl/pdf/4_Volume4/V4_03_Ch3_Representation.pdf#page=6.9) |
| IPCC 2019, Vol. 4 |  |  |
| Ch.2 Generic Methodologies | Eq 2.25 Annual SOC stock change in mineral soils | [Link](https://www.ipcc-nggip.iges.or.jp/public/2019rf/pdf/4_Volume4/19R_V4_Ch02_Generic%20Methods.pdf#page=33) |
|  | Tbl.2.3 Default reference condition of SOC stocks to soil & climate | [Link](https://www.ipcc-nggip.iges.or.jp/public/2019rf/pdf/4_Volume4/19R_V4_Ch02_Generic%20Methods.pdf#page=35) |
| Ch.3 Representation of Lands | Tb.3.1 List of IPCC categories: land, climate, soil, mgt, activity | [Link](https://www.ipcc-nggip.iges.or.jp/public/2019rf/pdf/4_Volume4/19R_V4_Ch03_Land%20Representation.pdf#page=11) |
|  | Pg.3.1 Tier 1 sampling approaches decision tree | [Link](https://www.ipcc-nggip.iges.or.jp/public/2019rf/pdf/4_Volume4/19R_V4_Ch03_Land%20Representation.pdf#page=21) |
|  | Tb.3.6X Approach 1-3 to IPCC land-use classification & sampling | [Link](https://www.ipcc-nggip.iges.or.jp/public/2019rf/pdf/4_Volume4/19R_V4_Ch03_Land%20Representation.pdf#page=20) |
|  | Tb.3.4 Approach 2 land change matrix to avoid double-counting | [Link](https://www.ipcc-nggip.iges.or.jp/public/2019rf/pdf/4_Volume4/19R_V4_Ch03_Land%20Representation.pdf#page=17) |
|  | Pg.3A5 Climate zone delineation & updated datasets | [Link](https://www.ipcc-nggip.iges.or.jp/public/2019rf/pdf/4_Volume4/19R_V4_Ch03_Land%20Representation.pdf#page=47) |
|  | Tb.3A.1 Global land-cover datasets listed by IPCC in 2017 | [Link](https://www.ipcc-nggip.iges.or.jp/public/2019rf/pdf/4_Volume4/19R_V4_Ch03_Land%20Representation.pdf#page=35) |
| Ch.4 Forest Land | Tb.4.4 R:S below to above-ground biomass ratio by climate & region | [Link](https://www.ipcc-nggip.iges.or.jp/public/2019rf/pdf/4_Volume4/19R_V4_Ch04_Forest%20Land.pdf#page=18) |
| Ch.5 Cropland | Tb.5.5 Relative stock change factors for mgt. activity in croplands | [Link](https://www.ipcc-nggip.iges.or.jp/public/2019rf/pdf/4_Volume4/19R_V4_Ch05_Cropland.pdf#page=27) |
|  | Tb.5.8 Default AGB carbon stocks retained on cropland in year 1 | [Link](https://www.ipcc-nggip.iges.or.jp/public/2019rf/pdf/4_Volume4/19R_V4_Ch05_Cropland.pdf#page=41.9) |
|  | Tb.5.10 Soil stock change factors for conversion to cropland | [Link](https://www.ipcc-nggip.iges.or.jp/public/2019rf/pdf/4_Volume4/19R_V4_Ch05_Cropland.pdf#page=45) |
| Ch.6 Grasslands | Tbl 6.4 Default biomass stocks on converted grasslands | [Link](https://www.ipcc-nggip.iges.or.jp/public/2006gl/pdf/4_Volume4/V4_06_Ch6_Grassland.pdf#page=27) |
| Ch.9 Other Land | Ch.9: Near-zero SOC retention assigned to mining in "Other Lands" | [Link](https://www.ipcc-nggip.iges.or.jp/public/2006gl/pdf/4_Volume4/V4_09_Ch9_Other_Land.pdf#page=7) |
| IPCC 2013 Wetland Supplement | Tb.1.1 Look-up table for wetlands by vegetation and soil type | [Link](https://www.ipcc.ch/site/assets/uploads/2018/03/Wetlands_Supplement_Entire_Report.pdf#page=30) |
| IPCC 2023 AR6 Updated GWPs | Tb.7.15 Updated GWPs for N₂O and fossil-specific CH₄ \*\*\* | [Link](https://www.ipcc.ch/report/ar6/wg1/downloads/report/IPCC_AR6_WGI_Chapter07.pdf#page=95) |

------------------------------------------------------------------------

## License

This work is licensed under a [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/). The IPCC methodologies referenced herein are the intellectual property of the Intergovernmental Panel on Climate Change.

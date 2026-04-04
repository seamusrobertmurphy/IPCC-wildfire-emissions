# IPCC Tier 1 Fire Emissions

[![Quarto
Publish](https://img.shields.io/badge/Quarto-Published-blue?logo=quarto)](https://seamusrobertmurphy.quarto.pub/ipcc-fire-emissions/)
[![License: CC BY
4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)
[![ORCID](https://img.shields.io/badge/ORCID-0000--0002--1792--0351-green?logo=orcid)](https://orcid.org/0000-0002-1792-0351)

A reproducible, end-to-end implementation of the IPCC Tier 1 methodology for estimating greenhouse
gas emissions from wildfire and prescribed burning. Built as an executable [Quarto
Book](https://quarto.org/docs/books/) in R with pixel-level spatial analysis via Google Earth
Engine.

[Read the full book =>>](https://seamusrobertmurphy.quarto.pub/ipcc-fire-emissions/)

----------------------------------------------------------------------------------------------------

## Overview

This project implements Equation 2.27 from the 2006 IPCC Guidelines (as updated by the 2019
Refinement) to estimate fire emissions of CH~4~, N~2~O, and CO~2~ at national scale:

$$L_{fire} = A \times M_B \times C_f \times G_{ef} \times 10^{-3}$$

Each chapter corresponds to one component of the equation, progressing from burned area detection
through to emission factor application and UNFCCC reporting. The workflow is demonstrated for
Honduras (2010) using freely available global datasets.

### Key methodological features

-   Burned area: MODIS MCD64A1 Collection 6.1 with FAOSTAT-consistent quality filters
-   Land cover stratification: IGBP classification (MCD12Q1) into forest, savanna, and organic soil
    fire types, with WorldClim climate zone delineation
-   Fuel consumption: IPCC default values (Table 2.4) stratified by vegetation type and climate zone
-   Emission factors: Table 2.5 (2019 Refinement) for CH~4~ and N~2~O; Wetlands Supplement for
    organic soil CO~2~
-   C~2~ accounting: Correctly implements the IPCC treatment where forest CO~2~ is reported via
    carbon stock changes (not excluded), savanna CO~2~ is excluded at Tier 1 per the synchrony
    assumption, and organic soil CO~2~ is reported separately
-   Uncertainty: Error propagation and Monte Carlo simulation (10,000 iterations)
-   Reporting: Outputs formatted for UNFCCC Common Reporting Format (CRF) Tables 4.C and 4.F

----------------------------------------------------------------------------------------------------

## Chapters

| \# | Chapter | Description |
|---------------------------------|---------------------------------|---------------------------------|
| 0 | [Preface](https://seamusrobertmurphy.quarto.pub/ipcc-fire-emissions/) | Project overview, IPCC framework, and GEE environment setup |
| 1 | [Burned Area](https://seamusrobertmurphy.quarto.pub/ipcc-fire-emissions/01-burn-area/) | Extract and validate MODIS MCD64A1 burned area for Honduras 2010; apply uncertainty filters; compute annual burned area by land cover type |
| 2 | [Fuel Stratification](https://seamusrobertmurphy.quarto.pub/ipcc-fire-emissions/02-fuel-stratification/) | Classify burned pixels into IPCC fire categories (forest, savanna, organic soil) using MODIS land cover and WorldClim climate zones |
| 3 | [Fuel Consumption](https://seamusrobertmurphy.quarto.pub/ipcc-fire-emissions/03-fuel-consumption/) | Assign IPCC Tier 1 default fuel consumption values (M~B~ × C~f~ by vegetation type and climate zone |
| 4 | [Emission Factors](https://seamusrobertmurphy.quarto.pub/ipcc-fire-emissions/04-emission-factors/) | Apply IPCC emission factors (G) to compute CH~4~, N~2~O, and CO~2~ emissions; convert to CO~2~-equivalents; format for CRF reporting |
| — | [References](https://seamusrobertmurphy.quarto.pub/ipcc-fire-emissions/references/) | Full bibliography of IPCC guidelines, methodological sources, and remote sensing references |

----------------------------------------------------------------------------------------------------

## Data Sources

| Dataset | Source | Use |
|---------------------------------|---------------------------------|---------------------------------|
| MCD64A1 C6.1 | [MODIS via GEE](https://developers.google.com/earth-engine/datasets/catalog/MODIS_061_MCD64A1) | Monthly burned area (500 m) |
| MCD12Q1 C6.1 | [MODIS via GEE](https://developers.google.com/earth-engine/datasets/catalog/MODIS_061_MCD12Q1) | IGBP land cover classification |
| WorldClim V1 | [WorldClim via GEE](https://developers.google.com/earth-engine/datasets/catalog/WORLDCLIM_V1_BIO) | Bioclimatic variables for climate zone delineation |
| FAO GAUL 2015 | [FAO via GEE](https://developers.google.com/earth-engine/datasets/catalog/FAO_GAUL_2015_level0) | Country and subnational administrative boundaries |
| IPCC Tables 2.4, 2.5 | 2019 Refinement, Vol. 4, Ch. 2 | Default fuel consumption and emission factors |
| IPCC Wetlands Supplement | 2013 Supplement | Organic soil emission factors |

----------------------------------------------------------------------------------------------------

## IPCC Reference Documents

This implementation is based on the following IPCC methodological guidance:

-   2006 IPCC Guidelines for National Greenhouse Gas Inventories — Volume 4: Agriculture, Forestry
    and Other Land Use, Chapters 2 and 4
-   2019 Refinement to the 2006 IPCC Guidelines — Volume 4, Chapter 2 (Generic Methodologies) with
    updated Tables 2.4, 2.5, and 2.6
-   2013 Supplement to the 2006 Guidelines: Wetlands — Chapter 2 (Drained Inland Organic Soils), for
    peatland fire CO~2~ and CH~2~ emission factors
-   2013 Revised Supplementary Methods and Good Practice Guidance Arising from the Kyoto Protocol

----------------------------------------------------------------------------------------------------

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
git clone https://github.com/seamusrobertmurphy/TREES-wildfire-replications.git
cd TREES-wildfire-replications

# Install R dependencies (from R console)
# install.packages("easypackages")
# easypackages::packages(<see index.qmd for full list>)

# Authenticate Earth Engine (from terminal)
earthengine authenticate

# Render the book
quarto render
```

----------------------------------------------------------------------------------------------------

## Project Structure

```         
.
├── index.qmd                    # Preface and environment setup
├── 01-burn-area/
│   └── index.qmd                # Ch 1: MODIS burned area extraction
├── 02-fuel-stratification/
│   └── index.qmd                # Ch 2: IGBP land cover + climate zones
├── 03-fuel-consumption/
│   ├── index.qmd                # Ch 3: IPCC fuel consumption defaults
│   ├── IPCC_fuel_consumption_defaults.csv
│   └── Honduras_FuelConsumption_2010.csv
├── 04-emission-factors/
│   ├── index.qmd                # Ch 4: Emission factors and reporting
│   ├── Honduras_FireEmissions_2010_detailed.csv
│   ├── Honduras_FireEmissions_2010_CO2eq.csv
│   └── Honduras_2010_CRF_Fires.csv
├── references/
│   ├── index.qmd                # Appendix: Bibliography
│   ├── references.bib
│   └── apa.csl
├── _quarto.yml                  # Quarto book configuration
├── styles.scss                  # Custom styling
└── README.md
```

----------------------------------------------------------------------------------------------------

## CO~2~ Accounting Note

This project implements the correct IPCC treatment of CO~2~ from fire, which differs by fire type:

| Fire Type    | CO~2~ Reported? | Method                                    | IPCC Source              |
|--------------|:---------------:|-------------------------------------------|--------------------------|
| Forest       |       Yes       | Carbon stock changes (Eq. 2.7–2.14)       | 2006 GL, Vol. 4, §4.2.4  |
| Savanna      |   No (Tier 1)   | Synchrony assumed for non-woody grassland | 2019 Ref, Vol. 4, §2.4   |
| Organic Soil |       Yes       | Separate G~ef~ via Eq. 2.27               | 2013 Wetlands Supplement |

Forest fire CO<sub>2</sub> is not excluded from national inventories. It is captured through the
carbon stock change framework because fire emissions and regrowth removals are not synchronous for
woody biomass. The savanna synchrony assumption applies only to non-woody grassland at Tier 1, with
explicit caveats for woody savannas in the 2019 Refinement.

----------------------------------------------------------------------------------------------------

## Citation

``` bibtex
@online{murphy2026fire,
  author    = {Murphy, S},
  title     = {IPCC Tier 1 Fire Emissions: A Reproducible Workflow},
  year      = {2026},
  url       = {https://seamusrobertmurphy.quarto.pub/ipcc-fire-emissions/},
  note      = {Quarto Book}
}
```

----------------------------------------------------------------------------------------------------

## Additional Reading

#### *Allometric Uncertainty:*

-   Aholoukpè, H. N. S., Dubos, B., Deleporte, P., Flori, A., Amadji, L. G., Chotte, J.-L., &
    Blavet, D. (2018). Allometric equations for estimating oil palm stem biomass in the ecological
    context of benin, west africa. *Trees*, *32*(6), 1669–1680.
-   Andersen, H.-E., Reutebuch, S. E., & McGaughey, R. J. (2006). A rigorous assessment of tree
    height measurements obtained using airborne lidar and conventional field methods. *Canadian
    Journal of Remote Sensing*, *32*(5), 355–366. <https://doi.org/10.5589/m06-030>
-   Baskerville, G. (1972). Use of logarithmic regression in the estimation of plant biomass.
    *Canadian Journal of Forest Research*, *2*(1), 49–53.
-   Duncanson, L., Disney, M., Armston, J., Nickeson, J., Minor, D., & Camacho, F. (2021).
    Aboveground woody biomass product validation good practices protocol.
    <https://doi.org/10.5067/DOC/CEOSWGCV/LPV/AGB.001>
-   Dutcă, I., Stăncioiu, P. T., Abrudan, I. V., & Ioraș, F. (2018). Using clustered data to develop
    biomass allometric models: The consequences of ignoring the clustered data structure. *PloS
    One*, *13*(8), e0200123.
-   Martin, A. (2022). Accuracy and precision in urban forestry tools for estimating total tree
    height. *Arboric. Urban For*, *48*(6), 319–332.
-   Martı́nez-Sánchez, J. L., Martı́nez-Garza, C., Cámara, L., & Castillo, O. (2020). Species-specific
    or generic allometric equations: Which option is better when estimating the biomass of mexican
    tropical humid forests? *Carbon Management*, *11*(3), 241–249.
-   McRoberts, R. E., & Westfall, J. A. (2016). Propagating uncertainty through individual tree
    volume model predictions to large-area volume estimates. *Annals of Forest Science*, *73*(ue 3),
    625–633. <https://doi.org/10.1007/s13595-015-0473-x>
-   Nickless, A., Scholes, R. J., & Archibald, S. (2011). A method for calculating the variance and
    confidence intervals for tree biomass estimates obtained from allometric equations. *South
    African Journal of Science*, *107*(5), 1–10.
-   Ojoatre, S., Zhang, C., Hussin, Y. A., Kloosterman, H. E., & Ismail, M. H. (2019). Assessing the
    uncertainty of tree height and aboveground biomass from terrestrial laser scanner and hypsometer
    using airborne LiDAR data in tropical rainforests. *IEEE Journal of Selected Topics in Applied
    Earth Observations and Remote Sensing*, *12*(10), 4149–4159.
-   Parresol, B. R. (1993). Modeling multiplicative error variance: An example predicting tree
    diameter from stump dimensions in baldcypress. *Forest Science*, *39*(4), 670–679.
-   Picard, N., Bosela, F. B., & Rossi, V. (2015). Reducing the error in biomass estimates strongly
    depends on model selection. Annals of Forest Science, 72(6), 811–823.
    <https://doi.org/10.1007/s13595-014-0434-9>
-   Picard N., Saint-André L., Henry M. 2012. Manual for building tree volume and biomass allometric
    equations: from field measurement to prediction. Food and Agricultural Organization of the
    United Nations, Rome, and Centre de Coopération Internationale en Recherche Agronomique pour le
    Développement, Montpellier, 215 pp.
-   Ploton, P., Mortier, F., Réjou-Méchain, M., Barbier, N., Picard, N., Rossi, V., Dormann, C.,
    Cornu, G., Viennois, G., Bayol, N., & al., et. (2020). Spatial validation reveals poor
    predictive performance of large-scale ecological mapping models. *Nature Communications*,
    *11*(1), 4540.
-   Roxburgh, S., Paul, K., Clifford, D., England, J., & Raison, R. (2015). Guidelines for
    constructing allometric models for the prediction of woody biomass: How many individuals to
    harvest? *Ecosphere (Washington, D.C)*, *6*(3), 1–27.
-   Shang, Y., Xia, Y., Ran, X., Zheng, X., Ding, H., & Fang, Y. (2025). Allometric equations for
    aboveground biomass estimation in natural forest trees: Generalized or species-specific?
    *Diversity*, *17*(7), 493.
-   Vorster, A. G., Evangelista, P. H., Stovall, A. E., & Ex, S. (2020). Variability and uncertainty
    in forest biomass estimates from the tree to landscape scale: The role of allometric equations.
    Carbon Balance and Management, 15(1), 8.
-   Wayson, C. A., Johnson, K. D., Cole, J. A., Olguín, M. I., Carrillo, O. I., & Birdsey, R. A.
    (2015). Estimating uncertainty of allometric biomass equations with incomplete fit error
    information using a pseudo-data approach: methods. Annals of Forest Science, 72(6), 825–834.
-   White, G. W., Yamamoto, J. K., Elsyad, D. H., Schmitt, J. F., Korsgaard, N. H., Hu, J. K.,
    Gaines III, G. C., Frescino, T. S., & McConville, K. S. (2025). Small area estimation of forest
    biomass via a two-stage model for continuous zero-inflated data. *Canadian Journal of Forest
    Research*, *55*, 1–19.
-   Yanai, R. D., Battles, J. J., Richardson, A. D., Blodgett, C. A., Wood, D. M., &
    Rastetter, E. B. (2010). Estimating uncertainty in ecosystem budget calculations. *Ecosystems
    (New York, N.Y.)*, *13*(ue 2), 239–248. <https://doi.org/10.1007/s10021-010-9315-8>
-   Yokelson, R.J., et al. (2013). Coupling field and laboratory measurements to estimate the
    emission factors of identified and unidentified trace gases for prescribed fires. Atmospheric
    Chemistry and Physics, 13, 89-116.
-   Zapata-Cuartas, M., Sierra, C. A., & Alleman, L. (2012). Probability distribution of allometric
    coefficients and bayesian estimation of aboveground tree biomass. *Forest Ecology and
    Management*, *277*, 173–179.

#### *Emission Factor Uncertainty:*

-   Andreae, M.O. (2019). Emission of trace gases and aerosols from biomass burning – an updated
    assessment. Atmospheric Chemistry and Physics, 19, 8523-8546. doi:10.5194/acp-19-8523-2019
-   Brown, J.K. (1974). Handbook for inventorying downed woody material. USDA Forest Service General
    Technical Report INT-16.
-   IPCC. (2019). 2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas
    Inventories (Agriculture, Forestry and Other Land Use, Vol. 4). Intergovernmental Panel on
    Climate Change. https://www.ipcc-nggip.iges.or.jp/public/2019rf/vol4.html
-   IPCC. (2006). 2006 IPCC Guidelines for National Greenhouse Gas Inventories, Volume 4:
    Agriculture, Forestry and Other Land Use. Intergovernmental Panel on Climate Change.
-   Köhler, P., & Huth, A. (2010). Towards ground-truthing of spaceborne estimates of above-ground
    life biomass and leaf area index in tropical rain forests. *Biogeosciences (Online)*, *7*(8),
    2531–2543.
-   Pelletier, J., Martin, D., & Potvin, C. (2013). REDD+ emissions estimation and reporting:
    Dealing with uncertainty. Environmental Research Letters, 8(3), 034009.
-   Pelletier, J., Busch, J., & Potvin, C. (2015). Addressing uncertainty upstream or downstream of
    accounting for emissions reductions from deforestation and forest degradation. *Climatic
    Change*, *130*(4), 635-648
-   Pelletier, N., Thiagarajan, A., Durnin-Vermette, F., Liang, B. C., Choo, D., Cerkowniak, D., ...
    & VandenBygaart, A. J. (2025). Approximate Bayesian inference for calibrating the IPCC tier-2
    steady-state soil organic carbon model for Canadian croplands using long-term experimental data.
    *Environmental Modelling & Software*, *190*, 106481
-   Seiler, W., & Crutzen, P.J. (1980). Estimates of gross and net fluxes of carbon between the
    biosphere and the atmosphere from biomass burning. Climatic Change, 2(3), 207-247.
-   van Leeuwen, T.T., & van der Werf, G.R. (2011). Spatial and temporal variability in the ratio of
    trace gases emitted from biomass burning. Atmospheric Chemistry and Physics, 11, 3611-3629.

#### *Activity Data Uncertainty:*

-   Butler, B. J., Sass, E. M., Gamarra, J. G., Campbell, J. L., Wayson, C., Olguín, M., Carrillo,
    O., & Yanai, R. D. (2024). Uncertainty in REDD+ carbon accounting: A survey of experts involved
    in REDD+ reporting. Carbon Balance and Management, 19(1), 22.
-   Chen, Q., Laurin, G. V., & Valentini, R. (2015). Uncertainty of remotely sensed aboveground
    biomass over an African tropical forest: Propagating errors from trees to plots to pixels.
    Remote Sensing of Environment, 160, 134–143. <https://doi.org/10.1016/j.rse.2015.01.009>
-   GOFC-GOLD (2016). Integration of remote-sensing and ground-based observations for estimation of
    emissions and removals of greenhouse gases in forests: Methods and Guidance from the Global
    Forest Observations Initiative. Edition 2.0. Rome: Food and Agriculture Organization.
-   GOFC-GOLD (2016). A sourcebook of methods and procedures for monitoring and reporting
    anthropogenic greenhouse gas emissions and removals associated with deforestation, gains and
    losses of carbon stocks in forests remaining forests, and forestation. GOFC-GOLD Report version
    COP22-1. Alberta, Canada: GOFC-GOLD Land Cover Project Office.
-   Köhler, P., & Huth, A. (2010). Towards ground-truthing of spaceborne estimates of above-ground
    life biomass and leaf area index in tropical rain forests. Biogeosciences, 7(8), 2531–2543.
-   Olofsson, P., Foody, G.M., Herold, M., Stehman, S.V., Woodcock, C.E., & Wulder, M.A. (2014).
    Good practices for estimating area and assessing accuracy of land change. Remote Sensing of
    Environment, 148, 42-57.
-   Pontius Jr., R.G., & Millones, M. (2011). Death to Kappa: birth of quantity disagreement and
    allocation disagreement for accuracy assessment. International Journal of Remote Sensing,
    32(15), 4407-4429.
-   Sheng, J., Zhou, W., & De Sherbinin, A. (2018). Uncertainty in estimates, incentives, and
    emission reductions in REDD+ projects. *International Journal of Environmental Research and
    Public Health*, *15*(7), 1544.
-   Stehman, S.V. (2014). Estimating area and map accuracy for stratified random sampling when the
    strata are different from the map classes. International Journal of Remote Sensing, 35(13),
    4923-4939.

#### *Monte Carlo Methods:*

-   Holdaway, R. J., McNeill, S. J., Mason, N. W. H., & Carswell, F. E. (2014). Propagating
    uncertainty in plot-based estimates of forest carbon stock and carbon stock change. *Ecosystems
    (New York, N.Y.)*, *17*(ue 4), 627–640. <https://doi.org/10.1007/s10021-014-9749-5>
-   Keller, M., Palace, M., & Hurtt, G. (2001). Biomass estimation in the tapajos national forest,
    brazil. *Forest Ecology and Management*, *154*(ue 3), 371–382.
-   Molto, Q., Rossi, V., & Blanc, L. (2013). Error propagation in biomass estimation in tropical
    forests. Methods in Ecology and Evolution, 4(2), 175–183.
    <https://doi.org/10.1111/j.2041-210x.2012.00266.x>
-   Yanai, R. D., Battles, J. J., Richardson, A. D., Blodgett, C. A., Wood, D. M., &
    Rastetter, E. B. (2010). Estimating uncertainty in ecosystem budget calculations. Ecosystems,
    13(2), 239–248. <https://doi.org/10.1007/s10021-010-9315-8>

#### *Biostatistical Theory:*

-   Buchanan, M. (2000). Ubiquity: Why Catastrophes Happen. Three Rivers Press.
-   Mandelbrot, B. B., & Hudson, R. L. (2004). The Misbehavior of Markets: A Fractal View of
    Financial Turbulence. Basic Books.
-   Strogatz, S. H. (2003). Sync: How Order Emerges from Chaos in the Universe, Nature, and Daily
    Life. Hyperion.
-   Taleb, N. N. (2007). The Black Swan: The Impact of the Highly Improbable. Random House.

#### IPCC Guidelines & Key Sections

| Resource | Description | Source |
|---------------------------------|---------------------------------|---------------------------------|
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

----------------------------------------------------------------------------------------------------

## License

This work is licensed under a [Creative Commons Attribution 4.0 International
License](https://creativecommons.org/licenses/by/4.0/). The IPCC methodologies referenced herein are
the intellectual property of the Intergovernmental Panel on Climate Change.

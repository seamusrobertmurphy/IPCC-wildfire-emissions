FAOSTAT
=======
[![CRAN
version](http://www.r-pkg.org/badges/version/FAOSTAT)](http://cran.rstudio.com/web/packages/FAOSTAT/index.html)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/FAOSTAT)](http://cran.r-project.org/web/packages/FAOSTAT/index.html)

This repository contains all the files to build the FAOSTAT package.

# NOTE: This package is currently under development at:
# https://gitlab.com/paulrougieux/faostatpackage/

Kindly ask questions and report issues on the gitlab issue page at:
https://gitlab.com/paulrougieux/faostatpackage/-/issues You are more likely to get a
meaningful answer to your question if you provide a [reproducible
example](https://stackoverflow.com/questions/5963269/how-to-make-a-great-r-reproducible-example),
including sample data, R code and output.


# Installation

Prefer installation method 1 most of the time, unless you want to develop and change the
code of the package.

1. The package can be installed from CRAN:

```r
install.packages("FAOSTAT")
```

2. To get the latest changes, install the development version via the following code.

```r
remotes::install_gitlab(repo = "paulrougieux/faostatpackage", subdir="FAOSTAT")
```


3. Install a local version in this git repository

```r
remotes::install_local("FAOSTAT", force=TRUE)
```

or in bash

    R CMD INSTALL FAOSTAT


# Documentation

A vignette and function documentation are available and please use them:

```r
library(FAOSTAT)
vignette(topic = "FAOSTAT")
help(get_faostat_bulk)
help(read_fao)
```

The vignette is also visible on CRAN at
https://cran.r-project.org/web/packages/FAOSTAT/vignettes/FAOSTAT.pdf


# Usage example

There are 2 ways to access FAOSTAT data:

1. Download bulk downloads files with get_faostat_bulk_url no login required.

2. Get fine grained API data with read_fao or load data for all countries and all years
   with get_faostat_bulk_api.


## 1. Bulk files (no API key required)

Find out the URL of the bulk data normalized on the FAOSTAT page. This example is for
the land use page https://www.fao.org/faostat/en/#data/RL in the right column "Bulk
Download", right click on the link "All Data Normalized" and copy the link to the zip
file, then paste it as the url_bulk function argument:

```r
library(FAOSTAT)
df <- get_faostat_bulk_url("https://bulks-faostat.fao.org/production/Inputs_LandUse_E_All_Data_(Normalized).zip", data_folder="data_raw")
```


## 2. API data (API key required)

First register to the developer portal https://www.fao.org/faostat/en/#developer-portal

Example using the `read_fao()` function to download data for a specific product in a
specific country from the API, will prompt for login and password on first use, this
will trigger the storage of a temporary FAOSTAT token (valid 60 minutes):

```r
# Get data for Cropland (6620) Area (5110) in Antigua and Barbuda (8) in 2017
df = read_fao(area_codes = "8", element_codes = "5110", item_codes = "6620", year_codes = "2017")
# Load cropland area for a range of year
df = read_fao(area_codes = "106", element_codes = "5110", item_codes = "6620", year_codes = 2010:2020)
```

Example downloading bulk data from the API with get_faostat_bulk

- create a folder to store the data
- login to the API, will create an access token
- load land use data using the `get_faostat_bulk()` with the code "RL" to load land use
  data for all countries.
- Cache the file i.e. save the data frame in the serialized RDS format for faster load
  time later.
- Now you can load your local version of the data from the RDS file

```r
library(FAOSTAT)
data_folder <- "data_raw"
dir.create(data_folder)
faostat_login()

land_use <- get_faostat_bulk(code = "RL", data_folder = data_folder)

saveRDS(land_use, "data_raw/land_use_e_all_data.rds")
land_use <- readRDS("data_raw/land_use_e_all_data.rds")
```



# WARNING

The FAOSTAT API on which this package was based has changed in 2017. As of 2020, The
main interest of this package lies in the updated functions to search and download data
from the FAOSTAT bulk download facility:

    FAOsearch
    get_faostat_bulk
    read_fao

Look at the help of those functions and data sets for more information.
Some functions might not work or give a depreciation warning.

# Alternative

There is also @muuankarski 's take on the FAOSTAT bulk download here:
https://github.com/muuankarski/faobulk
He also created functions to parse the FAOSTAT xml files and download data.

# Disclaimer

This package is not officially endorsed by FAO. Any data contained within it does not represent an official statement regarding sovereignty or any other properties of the countries included therein.



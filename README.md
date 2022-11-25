# Download satellite data on the state of the atmosphere

This repository provides code and alternatives to achieve specific variables that indicate the state of the atmosphere at a given time and meteorological variables.

The products that are detailed are the following:
1. Meterological variables from MERRA-2 via web page.
2. AOD MAIAC
3. PBLH MERRA-2
4. Satelite Variables using AppEEARS via web page
5. AOD MERRA-2
6. Meteorological ERA5Land

## Meterological variables from MERRA-2 via web page

1. Go to the web page:

https://www.soda-pro.com/

2. Create an account and sing in.

3. Go to the web page:

https://www.soda-pro.com/web-services/meteo-data/merra

4. Interactively download the desired data on the points. 

## AOD MAIAC

Product information: https://modis-land.gsfc.nasa.gov/MAIAC.html

1. Go to:

https://search.earthdata.nasa.gov/search

2. Create an account and sing in.

3. Download images using the script DownloadFilesEarthDataSearch.R

4. Extract values using ExtractAOD.R

## PBLH MERRA-2

Product information: https://disc.gsfc.nasa.gov/datasets/M2T1NXFLX_5.12.4/summary

1. Go to:

https://search.earthdata.nasa.gov/search

2. Create an account and sing in.

3. Download images using the script DownloadFilesEarthDataSearch.R

4. Extract values using ExtractPBLH.R

## Satelite Variables using AppEEARS via web page

1. Go to the web page:

https://appeears.earthdatacloud.nasa.gov/

2. Create an account and sing in.

3. Enter:

* Extract 

* Point

* Start a new request

* Upload coordinates

* Download satelite variables of interest


4. Interactively download the desired data on the points. 

## AOD MERRA-2

Product information: https://disc.gsfc.nasa.gov/datasets/M2I3NXGAS_5.12.4/summary

1. Go to:

https://search.earthdata.nasa.gov/search

2. Create an account and sing in.

3. Download images using the script DownloadFilesEarthDataSearch.R

4. Extract values using ExtractAOD.R

## Meteorological ERA5

Product information: https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-land

1. Go to:

https://cds.climate.copernicus.eu/user/login

2. Create an account and sing in.

3. Download and extract values using ERA5Land.R





















































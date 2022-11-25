# Install needed packages
# Load packages
library(KrigR)
library(tidyverse)
library(raster)

# Extrct hourly data from ERA5.

# Define user and api key
API_User <- "Complete API_USER"

API_Key <- "Complete API_KEY"

# Define extention area
Extent_ext <- extent(-64.34,-63.99,-31.52,-31.14)

# Define working directory
Dir.Data<-"C:/Users/marti/Desktop/SateliteFunctions/ERA5"

setwd(Dir.Data)

# Define variables you want to download
variable_era_land <- c("2m_temperature","2m_dewpoint_temperature")

variable_era_land <- tolower(variable_era_land)

# Define points spatial dataframe
puntos <- list.files(getwd(), pattern = ".csv")

df_puntos<-bind_rows(lapply(puntos, function(punto) {
  pointCoordinates=read.csv2(punto, header=T)
}))

## Make locations of mountains into SpatialPoints
df_puntos$lat<-as.numeric(df_puntos$lat)
df_puntos$lon<-as.numeric(df_puntos$lon)
coordinates(df_puntos) <- ~ lon + lat

# Define start and end date
start_date = "2021-03-30"
end_date = "2021-04-03"

# Define sequence with dates
a<-seq(
  from=as.POSIXct(paste(start_date,"00:00:00"), format = "%Y-%m-%d %H:%M:%S", tz = "UTC"),
  to=as.POSIXct(paste(end_date,"00:00:00"), format = "%Y-%m-%d %H:%M:%S", tz = "UTC"),
  by="hour"
  )

lapply(variable_era_land, function(variable) {
  tryCatch({
    FirstDL <- download_ERA(
      Variable = variable, # the variable we want to obtain data for
      DataSet = "era5-land", # the data set we want to obtain data from
      DateStart = start_date, # the starting date of our time-window
      DateStop = end_date, # the final date of our time-window
      Extent = Extent_ext, # the spatial preference we are after
      TResolution = 'hour', 
      Dir = Dir.Data, # where to store the downloaded data
      FileName = variable, # a name for our downloaded file
      API_User = API_User, # your API User Number
      API_Key = API_Key # your API User Key
    )
    }, error=function(e){}
    )
  
  extraction <- lapply(a, function(date) {
    i = match(date,a)
    tryCatch({
      toolik_silt <- raster::extract(FirstDL@layers[[i]], df_puntos, method='bilinear')
      results <- tibble(sitio = df_puntos$punto,
                        variable = toolik_silt,
                        date = rep(date,10)
      )
    }, error=function(e){}
    )
  })
  
  complete<-bind_rows(extraction)
  
  # Save results
  write.table(complete, file = paste0(variable,".txt")) # guarda un archivo excel
  
})

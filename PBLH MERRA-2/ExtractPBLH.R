# Install needed packages
# Load packages
library(ncdf4)
library(raster)
library(tidyverse)

# Define the working directory where you have the files and points csv
setwd("C:/Users/marti/Desktop/SateliteFunctions/PBLH MERRA-2")
lof = list.files(path=getwd(), pattern="*.nc4")
puntos <- list.files(getwd(), pattern = ".csv")
horas<-seq(1,24)

# Create a spatial data frame with the points
df_puntos<-bind_rows(lapply(puntos, function(punto) {
  pointCoordinates=read.csv2(punto, header=T)
  }))

df_puntos$lat<-as.numeric(df_puntos$lat)
df_puntos$lon<-as.numeric(df_puntos$lon)
coordinates(df_puntos) <- ~ lon + lat

# Extract PBL data  
extpbl <- lapply(lof, function(name) {
  # name=lof[2]
  nc_data <- nc_open(name)
  lon <- ncvar_get(nc_data, "lon")
  lat <- ncvar_get(nc_data, "lat", verbose = F)
  pbl.array <- ncvar_get(nc_data, "PBLH") # store the data in a 2-dimensional array
  
  fillvalue <- ncatt_get(nc_data, "PBLH", "_FillValue")
  pbl.array[pbl.array == fillvalue$value] <- NA
    
    lapply(horas, function(hora) {
      # hora=horas[1]
      tryCatch({
        r <- raster(t(pbl.array[1:nrow(pbl.array),1:ncol(pbl.array),hora]), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs=CRS("+proj=longlat +datum=WGS84"))
        r <- flip(r, direction='y')
        # plot(r)
        toolik_silt <- raster::extract(r, df_puntos, method='bilinear')
        results <- tibble(sitio = df_puntos$punto,
                          pbl = toolik_silt,
                          año = rep(substr(name,28,31),3), # The last number depends on the quanity of point that you have. If you have 10 points put 10. 
                          mes= rep(substr(name,32,33),3),
                          dia=rep(substr(name,34,35),3),
                          hora=rep(hora,3))
      }, error=function(e){}
      )
      
      
    })
})


complete<-bind_rows(extpbl)

# Save the data
write.table(complete, file = "pbl_horario.txt") 
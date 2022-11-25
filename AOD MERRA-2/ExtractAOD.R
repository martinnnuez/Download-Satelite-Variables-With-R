# Install needed packages
# Load packages
library(ncdf4)
library(raster)
library(tidyverse)


# Define the working directory where you have the files and points csv
setwd("C:/Users/marti/Desktop/SateliteFunctions/AOD MERRA-2")
lof = list.files(path=getwd(), pattern="*.nc4")
puntos <- list.files(getwd(), pattern = ".csv")
horas<-seq(1,8,1)

# Create a spatial data frame with the points
# Create a spatial data frame with the points
df_puntos<-bind_rows(lapply(puntos, function(punto) {
  pointCoordinates=read.csv2(punto, header=T)
}))

df_puntos$lat<-as.numeric(df_puntos$lat)
df_puntos$lon<-as.numeric(df_puntos$lon)
coordinates(df_puntos) <- ~ lon + lat

# Extract AOD data  
extaod <- lapply(lof, function(name) {
  # name=lof[2]
  nc_data <- nc_open(name)
  lon <- ncvar_get(nc_data, "lon")
  lat <- ncvar_get(nc_data, "lat", verbose = F)
  aod.array <- ncvar_get(nc_data, "AODANA")# store the data in a 2-dimensional array
  aod.inc.array<- ncvar_get(nc_data, "AODINC")
  
  fillvalue <- ncatt_get(nc_data, "AODANA", "_FillValue")
  aod.array[aod.array == fillvalue$value] <- NA
  
  fillvalue <- ncatt_get(nc_data, "AODINC", "_FillValue")
  aod.inc.array[aod.inc.array == fillvalue$value] <- NA
  
    lapply(horas, function(hora) {
      # hora=horas[1]
      tryCatch({
        r <- raster(t(aod.array[1:nrow(aod.array),1:ncol(aod.array),hora]), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs=CRS("+proj=longlat +datum=WGS84"))
        r <- flip(r, direction='y')
        
        s <- raster(t(aod.inc.array[1:nrow(aod.inc.array),1:ncol(aod.inc.array),hora]), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs=CRS("+proj=longlat +datum=WGS84"))
        s <- flip(s, direction='y')
        # plot(r)
        toolik_silt <- raster::extract(r, df_puntos, method='bilinear')
        toolik_silt2 <- raster::extract(s, df_puntos, method='bilinear')
        
        results <- tibble(sitio = df_puntos$punto,
                          AODmerra = toolik_silt,
                          AODINCmerra = toolik_silt2,
                          año = rep(substr(name,28,31),3),# The last number depends on the quanity of point that you have. If you have 10 points put 10. 
                          mes= rep(substr(name,32,33),3),
                          dia=rep(substr(name,34,35),3),
                          hora=rep(hora,3))
      }, error=function(e){}
      )
      
      
    })
})

complete<-bind_rows(extaod)
complete$hora <- ((complete$hora)-1)*3

# Save results
write.table(complete, file = "aod_merra_horario.txt") # guarda un archivo excel

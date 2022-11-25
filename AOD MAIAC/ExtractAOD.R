# Install needed packages
# Load packages
library(rgdal)
library(gdalUtils)
library(raster)
library(rasterVis)
library(viridisLite)
library(dplyr)

# Define the working directory where you have the files and points csv
setwd("C:/Users/marti/Desktop/SateliteFunctions/AOD MAIAC")

#### EXTRACT DATA AT SPECIFIC POINTS ####
# Definition of a regular long-lat grid onto which remap the data
# You may see coordinates on Worldview passing the mouse over the image
xmn_l = -68   # West border (degrees) #son coordenadas x y 
xmx_l = -60   # East border (degrees)
ymn_l = -36   # South border (degrees)
ymx_l = -28 # North border (degrees)
res_l = 0.1   # Resolution (degrees)

# Create a dummy raster on longlat projection.
# For example, it may be the grid of a model
rl <- raster( xmn = xmn_l, xmx = xmx_l, ymn = ymn_l, ymx = ymx_l,
              resolution = res_l,
              crs = "+proj=longlat +datum=WGS84")#Google maps coordinate system

# Creates a list of the file names in the directory
lof = list.files(path=getwd(), pattern="*.hdf")
#do.call("rbind", lapply(lof, as.data.frame))

# Cloud mask = cloudy or possibly cloudy.
# Ground Mask = Any value.
valid_qa = c(1,2,9,10,17,18,25,26)

# LOOP THAT READS THE IMAGES AND MAKES THEM GTIFF AND SAVES THEM IN A FOLDER.

for (i in 1:length(lof)){
  tryCatch({
    file <-lof[i]
    meta <- gdalinfo(file)
    sds <- get_subdatasets(file)
    #meta[63] Orbit_time_stamp
    horas<-substr(meta[63],20,73)
    horas = strsplit(horas, "\\s+")[[1]]
    #nombre <- substr(file, 10, 16)
    index_aod047 <- grep("Optical_Depth_047", sds)
    tipoaod <- c('47-')
    # Read AOD quality
    index_aodqa = grep("AOD_QA", sds)
    aodqa.1 <- readGDAL( sds[index_aodqa] )
    aodqa.1 <- brick( aodqa.1 )
    # Unselect not valid QA data
    ind = which( ! values(aodqa.1) %in% valid_qa )   # Not in valid_qa
    #
    aod047 <- readGDAL( sds[index_aod047] )   # class SpatialGridDataFrame
    aod047 <- brick( aod047 )                # convert to Raster Brick
    values(aod047)[ind] <- NA
    aod047_l <- projectRaster(aod047, rl)
    
    # Incrementar la resoluci?n.
    aod047_HD <- disaggregate(aod047_l, fact = 5, method = "bilinear")
    for (i in 1:length(horas)){
      hora  <- horas[i]
      # Guardar r?ster.
      #nombrearchivo <- paste(nombre, tipoaod)
      writeRaster(aod047_HD, filename=paste(file,hora), format="GTiff", bylayer=TRUE, suffix = names(aod047_HD), overwrite=TRUE)
    }
  }, error=function(e){})
}

# EXTRACT AOD FROM IMAGES AND PUT IT IN A TABLE

Arch <- list.files(getwd(), pattern = ".tif")
points <- list.files(getwd(), pattern = ".csv")

extaod <- bind_rows(lapply(points, function(points) {
  pointCoordinates=read.csv2(points, header=T)
  pointCoordinates$lat<-as.numeric(pointCoordinates$lat)
  pointCoordinates$lon<-as.numeric(pointCoordinates$lon)
  coordinates(pointCoordinates) <- ~ lon + lat
  # Extract AOD
    lapply(Arch, function(Arch){
      tryCatch({
        file <- raster(Arch) 
        file_name<- Arch[1]
        date<-as.Date(as.numeric(substr(file_name,14,16)), origin=as.Date("2021-01-01")) # Introduce the date of the first day of the same year of the files you want to extract
        banda<-substr(file_name,60,64)
        hora<-substr(file_name,54,57)
        rasValue=extract(file, pointCoordinates, buffer = 50,fun=mean) # 50 m buffer
        results <- tibble(sitio = pointCoordinates$punto,
                          aod = rasValue,
                          fecha = as.character(date),
                          banda = as.character(banda),
                          hora = paste0(substr(hora,1,2),":",substr(hora,3,4))
                        )
      }, error=function(e){}
      )
  }  
  )
}))

# Save table
# write.table(extaod, file = "aodtodos_4.txt") # guarda un archivo excel
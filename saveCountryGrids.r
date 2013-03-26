#saveCountryGrids.r
#andy south 23/3/2013

#to save a half degree country grid & maybe other common resolutions

library(rworldmap)


#sPDF <- getMap()
#sPDF <- getMap(resolution="low")
#str(sPDF@data)

#creating a 1 degree grid
#need to be careful about exactly where it starts


#function to create a grid from world polygons
#returns sGDF plus optionally saves rda file
#default uses country map from rworldmap : use low res rather than coarse 
polys2gridWorld <- function( sPDF=getMap(resolution="low"), gridRes=0.5 ){  #, file = "" ){

  gridResHalf <- gridRes/2
  #adding 0.5 times grid res to start coords to make central
  gridTopology <- GridTopology(c(-180+gridResHalf,-90+gridResHalf), c(gridRes,gridRes), c(360/gridRes,180/gridRes))
  #put dummy var in to start, name it ISO_N3 to be replaced later
  gridVals <- data.frame(ISO_N3=c(1:(gridTopology@cells.dim[1] * gridTopology@cells.dim[2])))
  #create sGDF
  sGDF <- SpatialGridDataFrame(gridTopology,data=gridVals)
  
  #set CRS for sGDF to same as sPDF (needed for over)
  proj4string(sGDF) <- proj4string(sPDF)
  
  #test plotting the grid
  #mapDevice("windows")
  #mapGriddedData(sGDF)
  
  #overlay the country map on the grid
  #gives all the attribute values at each grid cell
  attributesPerCell <- over(sGDF,sPDF)
  
  #getting points gives identical result
  #sPoints <- SpatialPoints(coordinates(sGDF))
  #proj4string(sPoints) <- proj4string(sPDF)
  #attributesPerCell <- over(sPoints,sPDF)
  
  #adding an attribute column to the sGDF containing numeric country code 
  sGDF$ISO_N3 <- attributesPerCell$ISO_N3
  tst <- sGDF@data  
  
  #mapDevice("windows")
  #mapGriddedData( sGDF, nameColumnToPlot="ISO_N3" )
  
  #sGDFcountries <- sGDF
  
  
  #if ( length(file) > 0 ) save(sGDFcountries, file=file, compress=TRUE)
  #objectName <- "gridCountriesDegreesHalf"
  #objectName <- "gridCountriesDegreesTwo"

  #gridCountriesDegreesTwo <- sGDF
  #eval( parse(text=objectName)) <- sGDF
  
  #assign(objectName, sGDF)
  
  #if ( length(file) > 0 ) save( eval( parse(text=objectName)), file=file, compress=TRUE)
  #if ( length(file) > 0 ) save( eval( parse(text=objectName),envir=parent.frame()), file=file, compress=TRUE)
  
  return(sGDF)

} #end of polys2gridWorld()


gridCountriesDegreesTwo <- polys2gridWorld( gridRes=2 ) #, file="C:\\rworldmapRForgeWC\\pkg\\rworldmap\\data\\gridCountriesDegreesTwo.rda" )
save( gridCountriesDegreesTwo, file="C:\\rworldmapRForgeWC\\pkg\\rworldmap\\data\\gridCountriesDegreesTwo.rda" )
#sgdf1 <- polys2gridWorld( gridRes=1, file="C:\\rworldmapRForgeWC\\pkg\\rworldmap\\data\\gridCountriesDegreesOne.rda" )
#polys2gridWorld( gridRes=0.5, file="C:\\rworldmapRForgeWC\\pkg\\rworldmap\\data\\gridCountriesDegreesHalf.rda" )
#sgdfQuarter <- polys2gridWorld( gridRes=0.25, file="C:\\rworldmapRForgeWC\\pkg\\rworldmap\\data\\gridCountriesDegreesQuarter.rda" )
gridCountriesDegreesHalf <- polys2gridWorld( gridRes=0.5 ) #, file="C:\\rworldmapRForgeWC\\pkg\\rworldmap\\data\\gridCountriesDegreesTwo.rda" )
save( gridCountriesDegreesHalf, file="C:\\rworldmapRForgeWC\\pkg\\rworldmap\\data\\gridCountriesDegreesHalf.rda" )




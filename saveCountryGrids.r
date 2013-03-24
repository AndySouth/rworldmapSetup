#saveCountryGrids.r
#andy south 23/3/2013

#to save a half degree country grid & maybe other common resolutions

library(rworldmap)

#get the country map from rworldmap : use low res rather than coarse 
#sPDF <- getMap()
sPDF <- getMap(resolution="low")
#str(sPDF@data)

#creating a 1 degree grid
#need to be careful about exactly where it starts
#try adding 0.5 times grid res to make central

#gridRes <- 1
gridRes <- 0.5

#!!!could put the below into a function
#& then pass it a gridRes & outFileName


gridResHalf <- gridRes/2
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
mapDevice("windows")
mapGriddedData( sGDF, nameColumnToPlot="ISO_N3" )

#I could maybe set the 


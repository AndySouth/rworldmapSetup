#saveMapPolygons.r
#developed from naturalEarthDataCompare.r

#andy south 23/5/12

#enables updating of rworldmap polygon mapfiles

#to load & compare 3 resolutions data
#from http://www.naturalearthdata.com/downloads/

library(rworldmap)


setwd("c:\\rworldmapdata\\naturalEarthData\\")

inLow <- "ne_110m_admin_0_countries.shp"
inMed <- "ne_50m_admin_0_countries.shp"
inHigh <- "ne_10m_admin_0_countries.shp"


countriesCoarse <- readShapePoly(inLow) 
#countriesCoarseLessIslands <- readShapePoly(inLow) 
countriesLow <- readShapePoly(inMed)
countriesHigh <- readShapePoly(inHigh)


#setting any POP_EST of -99 to NA
#countriesCoarseLessIslands$POP_EST[ which(countriesCoarseLessIslands$POP_EST < 0)] <- NA
countriesCoarse$POP_EST[ which(countriesCoarse$POP_EST < 0)] <- NA
countriesLow$POP_EST[ which(countriesLow$POP_EST < 0)] <- NA
countriesHigh$POP_EST[ which(countriesHigh$POP_EST < 0)] <- NA

#converting curacao that can be a pain later otherwise due to non-ascii
tmp <- countriesLow@data
for(i in seq(tmp))
   {
    levels(tmp[,i])[levels(tmp[,i])=="Curaçao"] <- "Curacao"
   }
countriesLow@data <- tmp

tmp <- countriesHigh@data
for(i in seq(tmp))
{
  levels(tmp[,i])[levels(tmp[,i])=="Curaçao"] <- "Curacao"
}
countriesHigh@data <- tmp

##**** 30/9/12
##**** still a problem for the 6 countries that don't have an ISO3 code
missingISO3nums <- which(countriesCoarse$ISO_A3 == '-99')
#[1] 1 2 3 4 5 6
countriesCoarse$ADMIN[missingISO3nums]
#[1] Indian Ocean Territories Kosovo                   Western Sahara          
#[4] Siachen Glacier          Somaliland               Northern Cyprus
#I could set them to ADMO_A3
countriesCoarse$ADM0_A3[missingISO3nums]
#[1] IOA KOS SAH KAS SOL CYN
countriesCoarse$ISO_A3 <- as.character(countriesCoarse$ISO_A3)
countriesCoarse$ISO_A3[missingISO3nums] <- as.character(countriesCoarse$ADM0_A3[missingISO3nums])

missingISO3nums <- which(countriesLow$ISO_A3 == '-99')
#[1] 1 2 3 4 5 6
countriesLow$ADMIN[missingISO3nums]
#[1] Indian Ocean Territories Kosovo                   Western Sahara          
#[4] Siachen Glacier          Somaliland               Northern Cyprus
#I could set them to ADMO_A3
countriesLow$ADM0_A3[missingISO3nums]
#[1] IOA KOS SAH KAS SOL CYN
countriesLow$ISO_A3 <- as.character(countriesLow$ISO_A3)
countriesLow$ISO_A3[missingISO3nums] <- as.character(countriesLow$ADM0_A3[missingISO3nums])

missingISO3nums <- which(countriesHigh$ISO_A3 == '-99')
countriesHigh$ADMIN[missingISO3nums]
countriesHigh$ADM0_A3[missingISO3nums]
countriesHigh$ISO_A3 <- as.character(countriesHigh$ISO_A3)
countriesHigh$ISO_A3[missingISO3nums] <- as.character(countriesHigh$ADM0_A3[missingISO3nums])

#checking for any repeated ISO3s which may have been created
countriesCoarse$ADMIN[which(duplicated(countriesCoarse$ISO_A3))]
#183 Ashmore and Cartier Islands AUS
#197 Gaza PSE
#I'm going to set them to close to the names so that user can see they aren't ISO3
countriesCoarse$ISO_A3[which(countriesCoarse$ADMIN=='Ashmore and Cartier Islands')] <- 'Ashm'
countriesCoarse$ISO_A3[which(countriesCoarse$ADMIN=='Gaza')] <- 'Gaza'

countriesLow@data[which(duplicated(countriesLow$ISO_A3)),]
countriesLow$ISO_A3[which(countriesLow$ADMIN=='Ashmore and Cartier Islands')] <- 'Ashm'
countriesLow$ISO_A3[which(countriesLow$ADMIN=='Gaza')] <- 'Gaza'

countriesHigh@data[which(duplicated(countriesHigh$ISO_A3)),]
countriesHigh$ISO_A3[which(countriesHigh$ADMIN=='Ashmore and Cartier Islands')] <- 'Ashm'
countriesHigh$ISO_A3[which(countriesHigh$ADMIN=='Gaza')] <- 'Gaza'

if ( length(which(duplicated(countriesCoarse$ISO_A3))) > 0 |
     length(which(duplicated(countriesLow$ISO_A3))) > 0 |
     length(which(duplicated(countriesHigh$ISO_A3))) > 0 )  warning("Duplicated ISO3 codes")        

#adding ISO3 columns as a copy of ISO_A3
countriesCoarse$ISO3 <- countriesCoarse$ISO_A3      
countriesLow$ISO3 <- countriesLow$ISO_A3
countriesHigh$ISO3 <- countriesHigh$ISO_A3

#creating a copy that won't have higher res bits added
countriesCoarseLessIslands <- countriesCoarse

#Bouvet seems not to be in data
#grep("Bouvet", sPDFhigh@data$ADMIN, ignore.case="TRUE")

# tcoarse <- countriesCoarse@data
# tlow <- countriesLow@data
# thigh <- countriesHigh@data
# nrow(tcoarse) #177
# nrow(tlow) #242
# nrow(thigh)#253

#testing which countries are in low but not in coarse
#some don't have an ISO_A3 so get lost
matchPosns <- match(countriesLow@data$ISO_A3, countriesCoarse@data$ISO_A3)
countriesLow@data$ADMIN[which(is.na(matchPosns))]

#mostly islands
#I wonder if I could add these on to the coarse map
#or even add the high ones
#matchPosns2 <- match(countriesHigh@data$ISO_A3, countriesLow@data$ISO_A3)
#matchPosns2 <- match(countriesHigh@data$ADMIN, countriesLow@data$ADMIN)
#countriesHigh@data$ADMIN[which(is.na(matchPosns2))]
#

#to add the extra low countries into the coarse map
matchPosns <- match(countriesLow@data$ADMIN, countriesCoarse@data$ADMIN)
extraPosns <- which(is.na(matchPosns))
countriesLow[extraPosns,]@data$ADMIN #shows the extra countries
#tst <- rbind(countriesCoarse,countriesLow[extraPosns,])
#gives invalid class "SpatialPolygons" object: non-unique Polygons ID slot values
#I could set Polygon IDs to ADMIN or ADMIN_A3
countriesLow <- spChFIDs(countriesLow, as.character(countriesLow$ADMIN))
countriesCoarse <- spChFIDs(countriesCoarse, as.character(countriesCoarse$ADMIN))
countriesCoarse <- rbind(countriesCoarse,countriesLow[extraPosns,])
countriesHigh <- spChFIDs(countriesHigh, as.character(countriesHigh$ADMIN))
#30/10/12 also needed to do this for li
countriesCoarseLessIslands <- spChFIDs(countriesCoarseLessIslands, as.character(countriesCoarseLessIslands$ADMIN))

#to add Tuvalu from the high map
#but problem that high map has 2 extra columns ne_10m_adm & OID_
countriesHigh <- spChFIDs(countriesHigh, as.character(countriesHigh$ADMIN))
#countriesCoarse <- rbind(countriesCoarse,countriesHigh[which(countriesHigh$ADMIN=="Tuvalu"),])
#how can I select out those extra columns
#this selects the columns I don't want !
#countriesHigh[which(countriesHigh$ADMIN=="Tuvalu"),][c("ne_10m_adm","OID_")]@data
badRows <- which(names(countriesHigh)=="ne_10m_adm" | names(countriesHigh)=="OID_")
tuvalu <- countriesHigh[which(countriesHigh$ADMIN=="Tuvalu"),][-badRows]
countriesCoarse <- rbind(countriesCoarse,tuvalu)
countriesLow <- rbind(countriesLow,tuvalu)


#now both low & course should have 243 countries (those in low + Tuvalu)
#testing that num polygons and num rows of data are the same
if ( length(countriesLow@polygons) != nrow(countriesLow@data) 
  |  length(countriesCoarse@polygons) != nrow(countriesCoarse@data) )
   warning("seems that number of polygons different from num data rows")

#testing some joining
#sPDF <- joinCountryData2Map(tlow,joinCode='NAME',nameJoinColumn='NAME')


#adding the polygon centroids on, as columns LON and LAT (does work)
countriesCoarseLessIslands$LON <- coordinates(countriesCoarseLessIslands)[,1]
countriesCoarseLessIslands$LAT <- coordinates(countriesCoarseLessIslands)[,2]
countriesCoarse$LON <- coordinates(countriesCoarse)[,1]
countriesCoarse$LAT <- coordinates(countriesCoarse)[,2]
countriesLow$LON <- coordinates(countriesLow)[,1]
countriesLow$LAT <- coordinates(countriesLow)[,2]
countriesHigh$LON <- coordinates(countriesHigh)[,1]
countriesHigh$LAT <- coordinates(countriesHigh)[,2]

#30/10/12 adding French Guiana (need to do before the countryRegions file is joined)
#the coordinates for French Guiana are the 2nd polygon of 3 in France
#need to create a new row for French Guiana
#and remove the 2nd polygon from France
addGUF <- function( sPDF, polyNumToMove=1 ){
  
  numFrance <- which( sPDF$ADMIN == 'France' ) #56
  franceCoarse <- sPDF[ 'France', ] #note this doesn't take any of the @data with it
  #the coordinates are the 2nd polygon in France
  guf<- Polygon(slot(slot(slot(franceCoarse,'polygons')[[1]],'Polygons')[[polyNumToMove]],'coords'))
  guf2 <- Polygons(list(guf),ID='French Guiana')
  gufData <- sPDF@data[numFrance,] #first copy data for France
  gufData$ADMIN <- gufData$NAME <- gufData$GEOUNIT <- gufData$SUBUNIT <- gufData$NAME_FORMA <- gufData$NAME_SORT <- 'French Guiana'
  gufData$ISO3 <- gufData$ISO_A3 <- gufData$ADM0_A3 <- gufData$GU_A3 <- gufData$SU_A3 <- 'GUF'
  #**I'll need to change other attributes for FG
  gufData$POP_EST <- 236250 #source wikipedia for Jan 2011
  gufData$TYPE <- 'Dependency'
  gufData$ABBREV <- 'Fr. Gui.'
  gufData$TERR_ <- 'Fr.'
  gufData$GDP_MD_EST <- NA #3.2 billion Euros wikipedia(2008)
  gufData$FIPS_10_ <- 'FG'
  gufData$ISO_A2 <- 'GF'
  gufData$LON <- -53.17471
  gufData$LAT <- 3.833223
  #other changes set in countryRegions
  
  row.names(gufData) <- 'French Guiana'
  guf3 <- SpatialPolygons(list(guf2))
  guf4 <- SpatialPolygonsDataFrame(guf3,data=gufData)
  guf4 <- spChFIDs(guf4, row.names(guf3))
  #strangely this was needed too
  sPDF <- spChFIDs(sPDF, row.names(sPDF))
  #the space at the start of the CRS is important
  proj4string(guf4) <- CRS(" +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")
  proj4string(sPDF) <- CRS(" +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")
  
  # joining French Guiana back on to countries map
  sPDF2 <- rbind(sPDF,guf4)
  
  #remove the GUF polygon from France - see the -polyNumToMove
  slot(slot(sPDF2,'polygons')[[numFrance]],'Polygons') <- slot(slot(sPDF2,'polygons')[[numFrance]],'Polygons')[-polyNumToMove]
  #also need to modify num polygons in plotOrder #***BEWARE this is tricky***#
  pO <- slot(slot(sPDF2,'polygons')[[numFrance]],'plotOrder') 
  pO <- pO[ -length(pO) ] #remove last element from plotOrder
  slot(slot(sPDF2,'polygons')[[numFrance]],'plotOrder') <- pO
  
  #returning the modified sPDF
  invisible(sPDF2)
} # end of addGUF function

#using addGUF() to modify package maps
countriesCoarse <- addGUF(countriesCoarse, polyNumToMove=1)
countriesCoarseLessIslands <- addGUF(countriesCoarseLessIslands, polyNumToMove=1)
countriesLow <- addGUF(countriesLow, polyNumToMove=3)
countriesHigh <- addGUF(countriesHigh, polyNumToMove=4)

#testing
plot(countriesCoarse[ 'France', ]) 
plot(countriesCoarseLessIslands[ 'France', ]) 
plot(countriesLow[ 'France', ]) 
plot(countriesHigh[ 'France', ]) 
#end of adding French Guiana


#join each map to the regions file #can't use joinCOuntryData2Map because the map data isn't in there yet !
data(countryRegions)

matchPosns <- match(countriesCoarse@data$ISO3, countryRegions$ISO3)
countriesCoarse@data <- cbind(countriesCoarse@data, countryRegions[matchPosns,])

matchPosns <- match(countriesCoarseLessIslands@data$ISO3, countryRegions$ISO3)
countriesCoarseLessIslands@data <- cbind(countriesCoarseLessIslands@data, countryRegions[matchPosns,])

matchPosns <- match(countriesLow@data$ISO3, countryRegions$ISO3)
countriesLow@data <- cbind(countriesLow@data, countryRegions[matchPosns,])

matchPosns <- match(countriesHigh@data$ISO3, countryRegions$ISO3)
countriesHigh@data <- cbind(countriesHigh@data, countryRegions[matchPosns,])

#BAD lines below screw up ordering
#countriesCoarse@data <- merge(countriesCoarse@data, countryRegions, by='ISO3', all.x=TRUE )
#countriesCoarseLessIslands@data <- merge(countriesCoarseLessIslands@data, countryRegions, by='ISO3', all.x=TRUE )
#countriesLow@data <- merge(countriesLow@data, countryRegions, by='ISO3', all.x=TRUE )


#how do I deal with non-ascii strings ? they cause warnings in check
#package(tools) showNonASCII() iconv()
#iconv(as.character(countriesCoarse@data),"ASCII","UTF-8")
#but problem that this converts all numeric data to characters
# * checking data for non-ASCII characters ... WARNING
# Warning: found non-ASCII string(s)
# 'Curagao' in object 'countriesCoarse'
# 'Eland Islands' in object 'countriesCoarse'
# 'Fxoroyar (Faroe Is.)' in object 'countriesCoarse'
# 'Ivory Coast (Ctte d'Ivoire)' in object 'countriesCoarse'
#   'Ivory Coast (Ctte d'Ivoire)' in object 'countriesCoarseLessIslands'
#   'Curagao' in object 'countriesLow'
#   'Eland Islands' in object 'countriesLow'
#   'Fxoroyar (Faroe Is.)' in object 'countriesLow'
#   'Ivory Coast (Ctte d'Ivoire)' in object 'countriesLow'
#i had to add an if not numeric bit in
countriesCoarseLessIslands@data <- data.frame(lapply(countriesCoarseLessIslands@data, function(x)  if(!is.numeric(x)) iconv(x,"ASCII","UTF-8") else x))
countriesCoarse@data <- data.frame(lapply(countriesCoarse@data, function(x)  if(!is.numeric(x)) iconv(x,"ASCII","UTF-8") else x))
countriesLow@data <- data.frame(lapply(countriesLow@data, function(x)  if(!is.numeric(x)) iconv(x,"ASCII","UTF-8") else x))
countriesHigh@data <- data.frame(lapply(countriesHigh@data, function(x)  if(!is.numeric(x)) iconv(x,"ASCII","UTF-8") else x))

# countriesCoarseLessIslands@data <- data.frame(lapply(countriesCoarseLessIslands@data, function(x)  if(!is.numeric(x)) iconv(x,"ASCII","ASCII") else x))
# countriesCoarse@data <- data.frame(lapply(countriesCoarse@data, function(x)  if(!is.numeric(x)) iconv(x,"ASCII","ASCII") else x))
# countriesLow@data <- data.frame(lapply(countriesLow@data, function(x)  if(!is.numeric(x)) iconv(x,"ASCII","ASCII") else x))
#Curaçao remains a problem it gets converted to Curagao but still causes problem at check

#checking fixing problems in polygon geometry
countriesCoarseLessIslands@polygons=lapply(countriesCoarseLessIslands@polygons, checkPolygonsHoles)
countriesCoarse@polygons=lapply(countriesCoarse@polygons, checkPolygonsHoles)
countriesLow@polygons=lapply(countriesLow@polygons, checkPolygonsHoles)
countriesHigh@polygons=lapply(countriesHigh@polygons, checkPolygonsHoles)

###TESTING
#tst <- countriesCoarse
#tst$tst2 <- ifelse(tst$GEO3major=='Africa',2,1)
#mapPolys(tst,nameColumnToPlot="tst2",catMethod='categorical',colourPalette='rainbow')
#tst$tst <- ifelse(tst$ADMIN=='India',2,1)
#mapPolys(tst,nameColumnToPlot="tst",catMethod='categorical',colourPalette='rainbow')

## setting the projection 
proj4string(countriesCoarse) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
proj4string(countriesCoarseLessIslands) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
proj4string(countriesLow) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
proj4string(countriesHigh) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

#transforming to mercator - have to miss out antarctica polygon 7
#cCmerc <- spTransform(countriesCoarse[-7,], CRS=CRS("+proj=merc +ellps=WGS84"))
#cCmerc <- spTransform(countriesCoarse[-7,], CRS=CRS("+proj=robin +ellps=WGS84"))

#26/10/12 changing ISO3 for South Sudan from SDS to SSD
levels(countriesCoarseLessIslands$ISO_A3)[which(levels(countriesCoarseLessIslands$ISO_A3)=='SDS')] <- 'SSD'
levels(countriesCoarse$ISO_A3)[which(levels(countriesCoarse$ISO_A3)=='SDS')] <- 'SSD'
levels(countriesLow$ISO_A3)[which(levels(countriesLow$ISO_A3)=='SDS')] <- 'SSD'
levels(countriesHigh$ISO_A3)[which(levels(countriesHigh$ISO_A3)=='SDS')] <- 'SSD'
countriesCoarseLessIslands$ISO3 <- countriesCoarseLessIslands$ISO_A3
countriesCoarse$ISO3 <- countriesCoarse$ISO_A3      
countriesLow$ISO3 <- countriesLow$ISO_A3
countriesHigh$ISO3 <- countriesHigh$ISO_A3

#10/12/12 changing ISO3 for Western Sahara from SAH to ESH
levels(countriesCoarseLessIslands$ISO_A3)[which(levels(countriesCoarseLessIslands$ISO_A3)=='SAH')] <- 'ESH'
levels(countriesCoarse$ISO_A3)[which(levels(countriesCoarse$ISO_A3)=='SAH')] <- 'ESH'
levels(countriesLow$ISO_A3)[which(levels(countriesLow$ISO_A3)=='SAH')] <- 'ESH'
levels(countriesHigh$ISO_A3)[which(levels(countriesHigh$ISO_A3)=='SAH')] <- 'ESH'
countriesCoarseLessIslands$ISO3 <- countriesCoarseLessIslands$ISO_A3
countriesCoarse$ISO3 <- countriesCoarse$ISO_A3      
countriesLow$ISO3 <- countriesLow$ISO_A3
countriesHigh$ISO3 <- countriesHigh$ISO_A3


save(countriesCoarseLessIslands, file="C://rworldmapRForgeWC//pkg//rworldmap//data//countriesCoarseLessIslands.rda")
save(countriesCoarse, file="C://rworldmapRForgeWC//pkg//rworldmap//data//countriesCoarse.rda")
save(countriesLow, file="C://rworldmapRForgeWC//pkg//rworldmap//data//countriesLow.rda")
#rworldxtra
save(countriesHigh, file="C://rworldmapRForgeWC//pkg//rworldxtra//data//countriesHigh.rda")

#create the documentation files - may need editing
#DONT run these after having edited the files
#prompt(countriesCoarseLessIslands, file="c://rworldmapRForgeWC//pkg//rworldmap//man//countriesCoarseLessIslands.Rd")
#prompt(countriesCoarse, file="c://rworldmapRForgeWC//pkg//rworldmap//man//countriesCoarse.Rd")
#prompt(countriesLow, file="c://rworldmapRForgeWC//pkg//rworldmap//man//countriesLow.Rd")
#prompt(countriesHigh, file="c://rworldmapRForgeWC//pkg//rworldmap//man//countriesHigh.Rd")

#30/9/2012
#sorting coastline to remove reliance on maps package
inCoast <- "c:\\rworldmapdata\\naturalEarthData\\110m_coastline.shp"

coastsCoarse <- readShapeLines(inCoast)
proj4string(coastsCoarse) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
save(coastsCoarse, file="C://rworldmapRForgeWC//pkg//rworldmap//data//coastsCoarse.rda")
#prompt(coastsCoarse, file="c://rworldmapRForgeWC//pkg//rworldmap//man//coastsCoarse.Rd")

#plot(coast)





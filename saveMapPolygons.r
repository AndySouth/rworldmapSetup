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





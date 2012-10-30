#saveCountryRegions.r

#andy south 31/5/2012
#to allow editing and saving of the countryRegions file

library(rworldmap)

data(countryRegions)
setwd('C:\\rworldmapRForgeWC\\rworldmapSetup\\')


#31/5/12
#checking for repeats in IS03
#countryRegions[which(duplicated(countryRegions$ISO3)),]
#this previously gave 2 repeats Congo and Svalbard
#countryRegions[which(duplicated(countryRegions$Name)),]
#countryRegions <- countryRegions[-which(duplicated(countryRegions$Name)),]

#countryRegions$GEO3major[which(countryRegions$GEO3major==7)] <- "Europe"

#outputting as a csv file to allow editing
write.csv(countryRegions,file="countryRegions.csv",row.names=FALSE)
#reading in from the csv

#1/10/12
#countryRegions contained 233 countries
#countriesHigh contains 253
#countriesLow contains 243
write.csv(countriesHigh@data,file="countriesHigh.csv",row.names=FALSE)

#which countries are in countriesHigh but not in countryRegions
matchPosns <- match(countriesHigh@data$ISO3, countryRegions$ISO3)
countriesHigh@data$ADMIN[which(is.na(matchPosns))]
#[1] Aland                                    Antarctica                              
#[3] French Southern and Antarctic Lands      Saint Barthelemy                        
#[5] Clipperton Island                        Cyprus No Mans Area                     
#[7] Coral Sea Islands                        Curacao                                 
#[9] Northern Cyprus                          Dhekelia Sovereign Base Area            
#[11] Gaza                                     Guernsey                                
#[13] Gibraltar                                Hong Kong S.A.R.                        
#[15] Heard Island and McDonald Islands        Isle of Man                             
#[17] Indian Ocean Territories                 British Indian Ocean Territory          
#[19] Jersey                                   Baykonur Cosmodrome                     
#[21] Siachen Glacier                          Korea No Mans Area                      
#[23] Kosovo                                   Macau S.A.R                             
#[25] Saint Martin                             Montenegro                              
#[27] Western Sahara                           South Sudan                             
#[29] South Georgia and South Sandwich Islands San Marino                              
#[31] Somaliland                               Republic of Serbia                      
#[33] Sint Maarten                             East Timor                              
#[35] United States Minor Outlying Islands     US Naval Base Guantanamo Bay            
#[37] Vatican                                  West Bank                               
#[39] Akrotiri Sovereign Base Area
#there are 39 countries extra iso3 codes in countriesHigh

#20 extra countries
#plus 10 countries that have NA for ISO3 in countryRegions
countryRegions$Name[which(is.na(countryRegions$ISO3))]

#lots of these are squitty small areas few will use !!
#also there are probably some in regions that are not in high

#1/10/12 Whats best thing to do ?
#1 start with countriesHigh ISO3 codes and ADMIN names (because I will join to countries files later, don't need more)
#2 cbind on the countryRegions that match with the ISO3 codes
#3 delete unwanted columns
#4 fill in missing row entries (either in csv or in R)

#1 start with countriesHigh ISO3 codes and ADMIN names 
cR2 <- data.frame(ISO3=countriesHigh@data$ISO3,ADMIN=countriesHigh@data$ADMIN)
#2 cbind on the countryRegions that match with the ISO3 codes
#matchPosns <- match(countryRegions$ISO3,countriesHigh@data$ISO3)
#cR2 <- cbind(cR2,countryRegions[matchPosns])
cR2 <- merge(cR2, countryRegions, by='ISO3', all.x=TRUE )
#3 delete unwanted columns
names2remove <- c('ISO2','Name','FIPS','Numeric','Vulnerability.Name','GIS.Country','CNTRY_NAME','GMI_CNTRY')
nums2remove <- match(names2remove,names(cR2))
cR2 <- cR2[-nums2remove]
#4 fill in missing row entries (either in csv or in R)

#outputting as a csv file to allow editing
write.csv(cR2,file="countryRegions.csv",row.names=FALSE)

#countryRegions <- read.csv("countryRegions.csv",as.is=TRUE)

#30/10/12 adding French Guiana
data(countryRegions)
#first copy from Guyana
newRow <- 1+nrow(countryRegions)
countryRegions[ newRow,] <- countryRegions[ which(countryRegions$ADMIN=='Guyana'),]
#then change fields that need changing
countryRegions$ADMIN[ newRow ] <- 'French Guiana'
countryRegions$ISO3[ newRow ] <- 'GUF'
#its not a SID
countryRegions$SID[ newRow ] <- 'other'

##TESTING
#testing num LDCs : least developed countries, should be 48 this is 49 due to South Sudan
length( which(countryRegions$LDC=='LDC'))
countryRegions$ADMIN[which(countryRegions$LDC=='LDC')]
#testing num LDCs : least developed countries, should be 31 yes is
length( which(countryRegions$LLDC=='LLDC'))
countryRegions$ADMIN[which(countryRegions$LLDC=='LLDC')]
#testing num SIDs : , should be 38 + 14 = 52, is 50 2 missing
length( which(countryRegions$SID=='SID'))
countryRegions$ADMIN[which(countryRegions$SID=='SID')]



save(countryRegions, file="C://rworldmapRForgeWC//pkg//rworldmap//data//countryRegions.rda")

#testingRefactoringOct2013.r

#andy south 11/10/2013

#testing refactoring of map* functions using rwmCheckAndLoadInput.r

#and fixing xlim,ylim in mapPies(), mapBars()


#check rworldmap version : CRAN 1.3-1 Dev 1.3-2
#use make install from DOS, & restart R to install dev version
packageDescription('rworldmap')$Version


mapPies()
#Error in class(dF) : 'dF' is missing

library(rworldmap)
#getting example data
dF <- getMap()@data 
sPDF <- getMap()

x11()

mapPies( dF,nameX="LON", nameY="LAT"
         , nameZs=c('POP_EST','POP_EST','POP_EST','POP_EST'),mapRegion='africa' )

#trying xlim,ylim does seem to work for mapPies()
#Africa : we=-20;   ea=80;    so=-30;   no=30
mapPies( dF, nameX="LON", nameY="LAT"
       , nameZs=c('POP_EST','POP_EST','POP_EST','POP_EST')
       , xlim=c(-20,80), ylim=c(-30,30) )

mapBars( dF, nameX="LON", nameY="LAT"
         , nameZs=c('POP_EST','POP_EST','POP_EST','POP_EST')
         , xlim=c(-20,80), ylim=c(-30,30) )
#Error in `[<-.data.frame`(`*tmp*`, nameZs, value = list(POP_EST = c(0.0212159904908377,  : 
#duplicate subscripts for columns



#TO DO
#put rwmCheckAndLoadInput() into mapBars() & see if it fixes xlim,ylim
#then can do same for mapPies()


## WORKING ON NOW 19/3/2014 ----

#works
mapBars()

#works
mapBars( sPDF 
         , nameZs=c('POP_EST','GDP_MD_EST')
         , mapRegion='africa'
         , symbolSize=4 )

#now works sPDF xlim, ylim used
mapBars( sPDF 
         , nameZs=c('POP_EST','GDP_MD_EST')
         , xlim=c(-20,80), ylim=c(-30,30)
         , symbolSize=4 )

#now works dF xlim, ylim used
mapBars( dF, nameX="LON", nameY="LAT" 
         , nameZs=c('POP_EST','GDP_MD_EST')
         , xlim=c(-20,80), ylim=c(-30,30)
         , symbolSize=4 )

#fails : Error in class(dF) : 'dF' is missing
mapPies()

# works (NA problem fixed)
mapPies( sPDF 
         , nameZs=c('POP_EST','GDP_MD_EST')
         , mapRegion='africa'
         , symbolSize=4 )

# works
mapPies( sPDF 
         , nameZs=c('POP_EST','POP_EST')
         , xlim=c(-20,80), ylim=c(-30,30)
         , symbolSize=4 )

#
mapPies( dF, nameX="LON", nameY="LAT" 
         , nameZs=c('POP_EST','GDP_MD_EST')
         , xlim=c(-20,80), ylim=c(-30,30)
         , symbolSize=4 )


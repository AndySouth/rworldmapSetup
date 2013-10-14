#testingRefactoringOct2013.r

#andy south 11/10/2013

#testing refactoring of map* functions using rwmCheckAndLoadInput.r

#and fixing xlim,ylim in mapPies(), mapBars()

mapPies()
#Error in class(dF) : 'dF' is missing

#getting example data
dF <- getMap()@data 
sPDF <- getMap()

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

#works
mapBars( sPDF, 
         , nameZs=c('POP_EST','GDP_MD_EST')
         , mapRegion='africa'
         , symbolSize=4 )

#trying xlim, ylim, they are discarded!
mapBars( sPDF, 
         , nameZs=c('POP_EST','GDP_MD_EST')
         , xlim=c(-20,80), ylim=c(-30,30)
         , symbolSize=4 )

#TO DO
#put rwmCheckAndLoadInput() into mapBars() & see if it fixes xlim,ylim
#then can do same for mapPies()


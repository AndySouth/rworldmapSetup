#testing.r

#andy south 2/10/2012

#assorted testing bits partic about polygon maps

###TESTING
tst <- getMap(resolution='coarse')
#tst <- centered.map
tst$tst2 <- ifelse(tst$GEO3major=='Africa',2,1)
mapPolys(tst,nameColumnToPlot="tst2",catMethod='categorical',colourPalette='rainbow')

#tst$tst <- ifelse(tst$ADMIN=='India',2,1)
#mapPolys(tst,nameColumnToPlot="tst",catMethod='categorical',colourPalette='rainbow')


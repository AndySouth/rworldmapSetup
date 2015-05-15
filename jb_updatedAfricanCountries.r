#jb_updatedAfricanCountries.r

#andy south 24/7/14

#borders Western Sahara comply with the UN standard
#updated Somalia and remove Somaliland, which lacks international recognition.

#the southwesternmost point of Morocco/northwesternmost point of Western Sahara,
#is very slightly into the ocean, should be move more towards inland. 
#So if you want to fix this as well, please do.

data("C:\\rWorldMapNotes\\rworldmapUsers\\JeanBaka\\modifiedCountriesCoarse2.rda")
#this loads it as countriesCoarse

plot(countriesCoarse)

#this is the old map
ccold <- getMap()
plot(ccold,add=TRUE,border='red')


#zooming in using jb's new recomended extents for Africa
#if ( mapRegion == 'africa' | mapRegion == 'Africa' )#2
#{we=-20;   ea=55;    so=-40;   no=42}

#new map first in black
#this shows that the new map has a horizontal line across that the old map doesn't
plot(countriesCoarse,xlim=c(-20,55),ylim=c(-40,42))
plot(ccold,add=TRUE,border='red')
#new map after in black- this shows the somaliland border removed in new map
x11()
plot(ccold,border='red',xlim=c(-20,55),ylim=c(-40,42))
plot(countriesCoarse,add=TRUE)

#new map looks good


wsold <- ccold[ ccold$ADMIN=="Western Sahara", ]
wsnew <- countriesCoarse[ countriesCoarse$ADMIN=="Western Sahara", ]
plot(wsnew,lwd=2)
plot(wsold,border='red',add=TRUE)

#my slight concern is that ideally I don't want to break
#the automated conversion from Natural Earth data
#check whether anything's happening at NatEarth data, seems not.
#I think I'm happy to just start using JBs map
#I can easily change it and later regress the change on SVN if I find problems
#I could also potentially copy the WS & Somalia polygons to a future map if I needed



#rworldmap_tmap_together.r
#andy south 14/5/15

#looking at using rworldmap and tmap together

library(rworldmap)
library(tmap)
sPDF <- getMap()
qtm(sPDF)
qtm(sPDF, fill="POP_EST")
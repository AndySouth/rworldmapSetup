`mapBars2` <- function( dF = ""
                       , nameX="longitude", nameY="latitude" 
                       , nameZs=c(names(dF)[3],names(dF)[4])
                       , zColours=c(1:length(nameZs))
                       , barWidth = 1
                       , barOrient = 'vert' ## orientation of bars 'vert' as default or 'horiz'
                       , barRelative = FALSE
                       
                       , ratio = 1
                       #,we=0, ea=0, so=0, no=0
                       , addCatLegend = TRUE
                       , addSizeLegend = TRUE
                       , legendVals = c(1,10)
                       , displayedLegends = nameZs
                       
                       , symbolSize = 1 #multiplier relative to the default
                       , maxZVal=NA
                       
                       , xlim=NA
                       , ylim=NA   
                       
                       , mapRegion = "world"   #sets map extents, overrides we,ea etc.                                                    
                       , borderCol = "grey"
                       , oceanCol=NA
                       , landCol=NA
                       , add=FALSE                        
                       
                       , main=''
                       , lwd=0.5
                       , lwdSymbols=1
                       , ... )
{ 
  
  functionName <- as.character(sys.call()[[1]])
  
  #for example data need to put in here before example dF loaded
  if (length(dF)==1 && dF == "")
  {
    nameZs <- c('POP_EST','GDP_MD_EST')
  }
  
  
  #2013 refactoring
  #this returns either a dF or sPDF
  dF <- rwmCheckAndLoadInput( dF, inputNeeded = "sPDF or dF", callingFunction=functionName ) 
  
  #if sPDF
  #  sPDF <- dF
  #  dF[nameX & nameY] <- coordinates(SPDF)
  #  dF <- dF@data
  
  #else if dF
  #  xlimylim <- max dF[nameX & nameY]
  #  sPDF <- getMap()
  
  # *shared*
  # plot map using sPDF
  # do bars using dF
  
  
  #if rwmCheckAndLoadInput returns a sPDF get the dF bit add columns for centroid coords & set nameX & nameY
  if ( class(dF)=="SpatialPolygonsDataFrame" ) #################################
{
  #copying map to sPDF to use later
  sPDF <- dF
  
  nameX <- "rwmX"
  nameY <- "rwmY"
  coords <- coordinates(dF)
  #fill columns in dF with centroid coords
  dF[[nameX]] <- coords[,1]
  dF[[nameY]] <- coords[,2]
  #dF bit to be used for bars
  dF <- dF@data
  
} else if( class(dF)=="data.frame"  ) #######################################
{   
  #to be used for background map if !add
  sPDF <- getMap()
  
} else
{
  stop(functionName," requires a dataFrame or spatialPolygonsDataFrame for the first argument or dF=\n")
  return(FALSE)       
}
  
  
  #debugging
  #browser()
  
  
  #background map
  #if user wants finer control they can call rwmNewMapPlot, and then this with add=TRUE 
  if (!add) 
  {      
    lims <- rwmNewMapPlot(sPDF, oceanCol=oceanCol, mapRegion=mapRegion, xlim=xlim, ylim=ylim)
    
    xlim <- lims$xlim #!!! these lims are used later to set symbol sizes
    ylim <- lims$ylim
    plot( sPDF, add=TRUE, border=borderCol, col=landCol, lwd=lwd )
  } #end of if (!add)    
  
  
  #**BEWARE what happens with symbolMaxSize if add=TRUE ???
  
  #Warning message:
  #  In max(xlim[2] - xlim[1], (ylim[2] - ylim[1]) * ratio) :
  #  no non-missing arguments to max; returning -Inf
  
  #browser()
  
  #1/7/13 adding a relative option so that all bars can be scaled 0-1
  #partly to make it easier to produce an example plot
  if (barRelative)
  {
    if (addSizeLegend)
      warning("The addSizeLegend option is incompatible with barRelative. No size legend will be produced.")
    
    for( numZ in 1:length(nameZs))
    {
      #TEMPORARY FIX TO REPLACE -99 with NA for pop & gdp
      #if ( length(which(dF[nameZs][numZ]=="-99") ))
      #  dF[nameZs][numZ][ which(dF[nameZs][numZ]=="-99"),1 ] <- NA  
      
      if ((m = max(dF[nameZs][numZ],na.rm=TRUE)) != 0)
        dF[nameZs][numZ] <- dF[nameZs][numZ] / m
      
    }
  }
  
  #browser()
  
  maxSumValues <- 0
  #go through each circle to plot to find maximum value for scaling
  for (locationNum in 1:length(dF[,nameZs[1]]))
  {  
    sumValues <- sum( dF[ locationNum, nameZs ], na.rm=TRUE )
    if ( sumValues > maxSumValues ) maxSumValues <- sumValues
  }
  
  
  #browser()    
  
  #set symbolMaxSize to 2% of max extent 
  symbolMaxSize <- 0.02*max( xlim[2]-xlim[1], (ylim[2]-ylim[1])*ratio, na.rm=TRUE )    
  
  #symbol size
  #maxZVal & symbolSize can be set by user
  #if ( is.na(maxZVal) ) maxZVal <- max( dF[,nameZSize], na.rm=TRUE )
  #4 in here is just a good sizing default found by trial & error
  #fMult = symbolSize * 4 / sqrt(maxZVal)
  #cex= fMult*sqrt(dF[,nameZSize])
  
  #so want maxSumValues to equate to maxSize
  symbolScale <- symbolMaxSize / maxSumValues 
  
  cat("symbolMaxSize=",symbolMaxSize," maxSumValues=",maxSumValues," symbolScale=",symbolScale,"\n")
  
  #for each location (row, got from num rows for first z value)
  for (locationNum in 1:length(dF[,nameZs[1]]))
  {    
    #to get an array of the values for each slice
    sliceValues <- as.numeric( dF[ locationNum, nameZs ] )
    
    #if the total of all values is 0 then skip this circle
    if (sum(sliceValues, na.rm=TRUE)==0) next
    
    #x is a cumulative list of proportions starting at 0 (i.e. 1 greater than num slices)
    cumulatVals <- c(0,cumsum(sliceValues))
    #cat("cumulative proportions", cumulatProps,"\n")
    # useless to compute cumulatProps (dividing by the sum) and then to include the multiplication by that same sum in the radius
    
    #radius <- sqrt(sum(sliceValues, na.rm=TRUE))*symbolScale
    #1/7/2013 removing sqrt
    radius <- symbolScale  * symbolSize      
    
    #for each slice
    for ( sliceNum in 1:length(sliceValues) ) {
      
      #rect(xleft, ybottom, xright, ytop, density = NULL, angle = 45,col = NA, border = NULL, lty = par("lty"), lwd = par("lwd")
      
      if ( barOrient == 'horiz' )
      {
        #cat('horiz')
        xleft <- dF[ locationNum, nameX ] + ( radius * cumulatVals[sliceNum] )
        ybottom <- dF[ locationNum, nameY ]  
        xright <- dF[ locationNum, nameX ] + ( radius * cumulatVals[sliceNum+1] ) 
        ytop <- dF[ locationNum, nameY ] + barWidth  
      } else
      {
        #cat('vert')
        xleft <- dF[ locationNum, nameX ] 
        ybottom <- dF[ locationNum, nameY ] + ( radius * cumulatVals[sliceNum] ) 
        xright <- dF[ locationNum, nameX ] + barWidth 
        ytop <- dF[ locationNum, nameY ] + ( radius * cumulatVals[sliceNum+1] )  
      }                         
      
      rect( xleft, ybottom, xright, ytop, col=zColours[sliceNum],lwd=lwdSymbols )
      #number of points on the circumference, minimum of 2
      #difference between next cumulative prop & this
      
      #cat("slice coords", P,"\n")
      
      #plot each slice
      #polygon(c(P$x,dF[ locationNum, nameX ]),c(P$y,dF[ locationNum, nameY ]),col=zColours[sliceNum]) #,col=colours()[tc[i]])
    } #end of each slice in a circle
  } #end of each circle
  
  #legend("bottomleft", select, fill=colours()[tc], cex=0.7, bg="white")
  if (addCatLegend)
    legendOutput <- legend("bottomleft", legend=displayedLegends, fill=zColours, cex=0.7, bg="white")#fill=c(1:length(nameZs))
  
  #do I also want to add option for a legend showing the scaling of the symbols
  if (addSizeLegend & !barRelative) { # makes no sense to draw that legend if all bars are scaled to show only proportions
    # we are putting this SizeLegend in the lower right corner, not further out than these original values of (lowerRight_x, lowerRight_y)
    plotting_area = par("usr")
    #areaWidth = plotting_area[2L] - plotting_area[1L]
    #areaHeight = plotting_area[4L] - plotting_area[3L]
    #lowerRight_x = plotting_area[2L] - symbolMaxSize # convenient to reuse this calculated value
    #lowerRight_y = plotting_area[3L] - symbolMaxSize # convenient to reuse this calculated value
    lowerRight_x = xlim[2] # - symbolMaxSize # convenient to reuse this calculated value
    lowerRight_y = ylim[1] # + symbolMaxSize # convenient to reuse this calculated value
    
    
    #if (is.null(legendVals))
    legendVals = signif( c(0.1,0.5,1)*maxSumValues, digits=1)
    
    
    for (legendVal in sort(legendVals, decreasing=T)) {
      
      if ( barOrient == 'horiz' )
      {
        #cat('horiz')
        xleft <- lowerRight_x - ( radius * legendVal )
        ybottom <- lowerRight_y  
        xright <- lowerRight_x 
        ytop <- lowerRight_y + barWidth  
        # then changing the value of lowerRight_y for the next legend bar...
        lowerRight_y <- lowerRight_y + 2* barWidth
        text(x=xleft, y=ybottom + 0.5 * barWidth, labels=as.character(legendVal), pos=2) # to the left of
      } else
      {
        #cat('vert')
        xleft <- lowerRight_x - barWidth
        ybottom <- lowerRight_y
        xright <- lowerRight_x 
        ytop <- lowerRight_y + ( radius * legendVal )  
        lowerRight_x <- lowerRight_x - 2* barWidth
        text(x=xleft + 0.5*barWidth, y=ytop, labels=as.character(legendVal), pos=3) # above
      }                         
      
      rect( xleft, ybottom, xright, ytop, col='gray82',lwd=lwdSymbols )
      
    } # for legendVal 
  } # end if (addSizeLegend) 
} # end of mapBars



#######################
#testing the function

#dF <- getMap()@data    
#dF <- getMap()@data    
#mapBars( dF,nameX="LON", nameY="LAT",nameZs=c('POP_EST','GDP_MD_EST') )
#mapBars( dF,nameX="LON", nameY="LAT",nameZs=c('POP_EST','GDP_MD_EST'), mapRegion='africa' )
#mapBars( dF,nameX="LON", nameY="LAT",nameZs=c('POP_EST','GDP_MD_EST'), mapRegion='africa', symbolSize=20 )
#mapBars( dF,nameX="LON", nameY="LAT",nameZs=c('POP_EST','GDP_MD_EST'), mapRegion='africa', symbolSize=20, barOrient = 'horiz' )



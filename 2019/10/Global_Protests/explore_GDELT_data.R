#Based on the work of Tidewater Big Data Enthusiasts' Chuck Cartledge's report on 25 October 2016 at 9:49am

rm(list=ls())

## wget -i urls -nc -U Mozilla/5.0

library(sp)
library(rworldmap)
library(urltools)
library(scales)
library(geosphere)

printStuff <- function(a)
{
    located <- 0
    missing <- 0
    for (i in head(a, n = 140))
    {
        temp <- strsplit(i, ".", fixed=TRUE)[[1]]
        command <- sprintf("grep ^%s.%s.%s /tmp/Also/GeoLite2-City-CSV_20161004/*.*",
                           temp[1], temp[2], temp[3])
        ## print(command)
        results <- system(command, intern=TRUE, ignore.stderr=TRUE)
        if(length(results) > 0)
        {
            located <- located + 1
            print(results)
        }
        else
        {
            missing <- missing + 1
        }
    }
    print(sprintf("located %.0f, missing %.0f", located, missing))
}

getUniqueIPs <- function(d)
{
    ips <- c()
    for (n in names(summarizeSourceDomains(d)))
    {
        ips <- c(ips, nsl(n))
    }

    ips <- unique(ips)

    ips
}

getCameoCodes <- function()
    {
        returnValue <- list(
        "2-01" = c(010, 011, 012, 013, 014, 015, 016, 017, 018, 019),
        "2-02" = c(020, 021, 0211, 0212, 0213, 0214, 022, 023, 0231, 0232, 0233, 0234, 024, 0241, 0242, 0243, 0244, 025, 0251, 0252, 0253, 0254, 0255, 0256, 026, 027, 028),
        "2-03" = c(030, 031, 0311, 0312, 0313, 0314, 032, 033, 0331, 0332, 0333, 0334, 034, 0341, 0342, 0343, 0344, 035, 0351, 0352, 0353, 0354, 0355, 0356, 036, 037, 038, 039),
        "2-04" = c(040, 041, 042, 043, 044, 045, 046),
        "2-05" = c(050, 051, 052, 053, 054, 055, 056, 057),
        "2-06" = c(060, 061, 062, 063, 064),
        "2-07" = c(070, 071, 072, 073, 074, 075),
        "2-08" = c(080, 081, 0811, 0812, 0813, 0814, 082, 083, 0831, 0832, 0833, 0834, 084, 0841, 0842, 085, 086, 0861, 0862, 0863, 087, 0871, 0872, 0873, 0874),
        "2-09" = c(090, 091, 092, 093, 094),
        "2-10" = c(100, 101, 1011, 1012, 1013, 1014, 102, 103, 1031, 1032, 1033, 1034, 104, 1041, 1042, 1043, 1044, 105, 1051, 1052, 1053, 1054, 1055, 1056, 106, 107, 108),
        "2-11" = c(110, 111, 112, 1121, 1122, 1123, 1124, 1125, 113, 114, 115, 116),
        "2-12" = c(120, 121, 1211, 1212, 1213, 1214, 122, 1221, 1222, 1223, 1224, 123, 1231, 1232, 1233, 1234, 124, 1241, 1242, 1243, 1244, 1245, 1246, 125, 126, 127, 128, 129),
        "2-13" = c(130, 131, 1311, 1312, 1313, 132, 1321, 1322, 1323, 1324, 133, 134, 135, 136, 137, 138, 1381, 1382, 1383, 1384, 1385, 139),
        "2-14" = c(140, 141, 1411, 1412, 1413, 1414, 142, 1421, 1422, 1423, 1424, 143, 1431, 1432, 1433, 1434, 144, 1441, 1442, 1443, 1444, 145, 1451, 1452, 1453, 1454),
        "2-15" = c(150, 151, 152, 153, 154, 155),
        "2-16" = c(160, 161, 162, 1621, 1622, 1623, 163, 164, 165, 166, 1661, 1662, 1663),
        "2-17" = c(170, 171, 1711, 1712, 172, 1721, 1722, 1723, 1724, 173, 174, 175, 176),
        "2-18" = c(180, 181, 182, 1821, 1822, 1823, 183, 1831, 1832, 1833, 1834, 184, 185, 186),
        "2-19" = c(190, 191, 192, 193, 194, 195, 1951, 1952, 196),
        "2-20" = c(200, 201, 202, 203, 204, 2041, 2042)
        )

        returnValue
}

plotCAMEOVerbCodebook <- function(d, imageDir=NULL, plotArcs=FALSE, area="world", positSummary=FALSE)
{
    cameoCodes <- getCameoCodes()
    
    for (i in 1:length(cameoCodes))
    {
        if (is.null(imageDir) == FALSE)
        {
            fileName <- sprintf("%s/%s.png", imageDir, names(cameoCodes)[i])
            png(filename=fileName, width=960, height=480, type="cairo-png")
            print(sprintf("Image being created in: %s", fileName))
        }
        else
        {
            oldPar=par()
            par(ask=TRUE)
        }

        plotData(selectData(d, cameoCodes[[i]]), area=area, plotArcs=plotArcs, positSummary=positSummary)

        if (is.null(imageDir) == FALSE)
        {
            dev.off()
        }
    }

    if (is.null(imageDir) == TRUE)
    {
        oldPar=par()
        par(ask=TRUE)
    }
}


summarizeActorPosits <- function(d)
{
    returnValue <- list("1g2g" = nrow(selectGoodActorPosits(d)),
                        "1g2b" = nrow(subset(d,
                          !is.na(Actor1Geo_Long) &
                          !is.na(Actor1Geo_Lat) &
                          (is.na(Actor2Geo_Long) |
                          is.na(Actor2Geo_Lat))
                          )),
                        "1b2g" = nrow(subset(d,
                          (is.na(Actor1Geo_Long) |
                          is.na(Actor1Geo_Lat)) &
                          !is.na(Actor2Geo_Long) &
                          !is.na(Actor2Geo_Lat)
                          )),
                        "1b2b" = nrow(subset(d,
                          (is.na(Actor1Geo_Long) |
                          is.na(Actor1Geo_Lat)) &
                          (is.na(Actor2Geo_Long) |
                          is.na(Actor2Geo_Lat))
                          ))
                        )

    returnValue
}

summarizeActorCodes <- function(d)
{
    returnValue <- list("1g2g" = nrow(subset(d,
                                             (nchar(Actor1Code) > 0) &
                                             (nchar(Actor2Code) > 0)) ),
                        "1g2b" = nrow(subset(d,
                                             (nchar(Actor1Code) > 0) &
                                             (nchar(Actor2Code) == 0)) ),
                        "1b2g" = nrow(subset(d,
                                             (nchar(Actor1Code) == 0) &
                                             (nchar(Actor2Code) > 0)) ),
                        "1b2b" = nrow(subset(d,
                                             (nchar(Actor1Code) == 0) &
                                             (nchar(Actor2Code) == 0)) )
                        )

    returnValue
}

selectGoodActorPosits <- function(d)
{
    returnValue <- subset(d,
                          !is.na(Actor1Geo_Long) &
                          !is.na(Actor1Geo_Lat) &
                          !is.na(Actor2Geo_Long) &
                          !is.na(Actor2Geo_Lat)
                          )

    returnValue
}

summarizeSourceDomains <- function(d)
{
    returnValue <- table(domain(subset(d, d$IsRootEvent == 1)$SOURCEURL))
    returnValue
}

summarizeDomains <- function(d)
{
    returnValue <- table(domain(subset(d, IsRootEvent == 1)$SOURCEURL))
    returnValue
}

summarizeSOURCEURLs <- function(d)
{
    returnValue <- table(subset(d, IsRootEvent == 1)$SOURCEURL)
    returnValue
}

summarizeEventCodes <- function(d)
{
    ## temp <- subset(d, d$IsRootEvent == 1)
    ## temp <- table(temp$Actor1Code)
    returnValue <- table(d$EventCode)

    returnValue
}

selectData <- function(d, eventCode)
{
    returnValue <- subset(d, EventCode %in% eventCode)
    returnValue <- subset(returnValue, IsRootEvent %in% 1)

    returnValue
}

plotData <- function(d, area="world", plotArcs=FALSE, positSummary=FALSE)
{
    oldPar <- par()
    newmap <- getMap(resolution = "low")
    xLimits <- NULL
    yLimits <- NULL
    switch(area,
           "world" = {
               xLimits <- c(-180, 180)
               yLimits <- c(-90, 90)
           },
           "nw" = {
               xLimits <- c(-180, 0)
               yLimits <- c(   0, 90)               
           },
           "ne" = {
               xLimits <- c(   0, 180)
               yLimits <- c(   0, 90)               
           },
           "sw" = {
               xLimits <- c(-180, 0)
               yLimits <- c( -90, 0)               
           },
           "se" = {
               xLimits <- c(   0, 180)
               yLimits <- c( -90, 0)               
           },
           )
    ## plot(newmap, xlim = c(-20, 59), ylim = c(35, 71), asp = 1)
    ## plot(newmap, xlim = c(-180, 180), ylim = c(-90, 90), asp = 1)
    rcols <- terrain.colors(length(unique(newmap$REGION)))
    newmap$col <- as.numeric(factor(newmap$REGION))
    par(bg = 'lightblue')

    plot(newmap,
         xlim = xLimits,
         ylim = yLimits,
         asp = 1,
         col = rcols[newmap$col]
         )

    temp <- ""

    counter <- 0
    for (i in names(summarizeEventCodes(d)))
    {
        temp <- sprintf("%s %s", temp, i)
        counter <- counter + 1

        if ((counter %% 40) == 0)
        {
            temp <- sprintf("%s \n", temp)
        }
    }

    numReports <- length(d$Actor1Geo_Long)
    if (counter > 2)
    {
        suffix <- "s"
    }
    else
    {
        suffix <- ""        
    }

    title(sprintf("%s reports worldwide for %.0f event code%s: %s",
                  prettyNum(numReports, big.mark=","),
                  counter,
                  suffix,
                  temp))

    actor1Color <- "blue"
    actor2Color <- "red"

    legend("bottomright",
           legend=c("Actor 1 does", "Actor 2 receives"),
           title="Meaning of color:",
           text.col=c(actor1Color, actor2Color),
           )
    ## points(d$Actor1Geo_Long, d$Actor1Geo_Lat,  col = alpha("red", 0.5), cex = .6)
    ## points(d$Actor2Geo_Long, d$Actor2Geo_Lat,  col = alpha("green", 0.5), cex = .6)

    dLocal <- selectGoodActorPosits(d)
    
    radius <- log(dLocal$NumMentions)
    ## print(radius)
    symbols(dLocal$Actor1Geo_Long, dLocal$Actor1Geo_Lat, circles=radius, bg=alpha(actor1Color, 0.5), add=TRUE, inches=FALSE)
    symbols(dLocal$Actor2Geo_Long, dLocal$Actor2Geo_Lat, circles=radius, bg=alpha(actor2Color, 0.5), add=TRUE, inches=FALSE)

    if (plotArcs == TRUE)
    {
        xs <- c()
        ys <- c()

        for (i in 1:numReports)
        {
            xs <- c(xs, dLocal$Actor1Geo_Long[i])
            ys <- c(ys, dLocal$Actor1Geo_Lat[i])
            xs <- c(xs, dLocal$Actor2Geo_Long[i])
            ys <- c(ys, dLocal$Actor2Geo_Lat[i])
        }

        ## print(length(xs))
        p <- SpatialPoints(matrix(cbind(xs,ys), ncol=2),
                           proj4string=CRS("+proj=longlat +datum=WGS84"))

        ## print(length(p))
        ## print(head(p))
        for (i in seq(1, length(p), by=2))
        {
            lines(gcIntermediate(p[i,], p[i+1,]), col = "black")
        }
    }

    if (positSummary == TRUE)
    {
        data <- summarizeActorPosits(d)
        temp <- c(sprintf("Actor 1 good, actor 2 good %s", format(prettyNum(data$'1g2g', big.mark=","), width=9, justify="right")),
                  sprintf("Actor 1 good, actor 2  bad %s", format(prettyNum(data$'1g2b', big.mark=","), width=9, justify="right")),
                  sprintf("Actor 1  bad, actor 2 good %s", format(prettyNum(data$'1b2g', big.mark=","), width=9, justify="right")),
                  sprintf("Actor 1  bad, actor 2  bad %s", format(prettyNum(data$'1b2b', big.mark=","), width=9, justify="right"))
                  )
        
        legend("bottomleft",
           legend=temp,
           title="Posit quality:"
           )
    }
    par(oldPar)
}

gdeltNames <- function()
{
    ## http://gdeltproject.org/data/lookups/CSV.header.dailyupdates.txt
    returnValue <- c(
        "GLOBALEVENTID",
        "SQLDATE",
        "MonthYear",
        "Year",
        "FractionDate",
        "Actor1Code",
        "Actor1Name",
        "Actor1CountryCode",
        "Actor1KnownGroupCode",
        "Actor1EthnicCode",
        "Actor1Religion1Code",
        "Actor1Religion2Code",
        "Actor1Type1Code",
        "Actor1Type2Code",
        "Actor1Type3Code",
        "Actor2Code",
        "Actor2Name",
        "Actor2CountryCode",
        "Actor2KnownGroupCode",
        "Actor2EthnicCode",
        "Actor2Religion1Code",
        "Actor2Religion2Code",
        "Actor2Type1Code",
        "Actor2Type2Code",
        "Actor2Type3Code",
        "IsRootEvent",
        "EventCode",
        "EventBaseCode",
        "EventRootCode",
        "QuadClass",
        "GoldsteinScale",
        "NumMentions",
        "NumSources",
        "NumArticles",
        "AvgTone",
        "Actor1Geo_Type",
        "Actor1Geo_FullName",
        "Actor1Geo_CountryCode",
        "Actor1Geo_ADM1Code",
        "Actor1Geo_Lat",
        "Actor1Geo_Long",
        "Actor1Geo_FeatureID",
        "Actor2Geo_Type",
        "Actor2Geo_FullName",
        "Actor2Geo_CountryCode",
        "Actor2Geo_ADM1Code",
        "Actor2Geo_Lat",
        "Actor2Geo_Long",
        "Actor2Geo_FeatureID",
        "ActionGeo_Type",
        "ActionGeo_FullName",
        "ActionGeo_CountryCode",
        "ActionGeo_ADM1Code",
        "ActionGeo_Lat",
        "ActionGeo_Long",
        "ActionGeo_FeatureID",
        "DATEADDED",
        "SOURCEURL"
    )

    returnValue
}


loadData <- function(saveFile, date="20161017")
{
    getData <- FALSE

    gdeltURL <- "http://data.gdeltproject.org/events/%s.export.CSV.zip"
    
    if (file.exists(saveFile) == FALSE)
    {
        getData <- TRUE
    }
    else
    {
        load(saveFile)

        temp <- sprintf(gdeltURL, date)
        
        if (temp != url)
        {
            getData <- TRUE
        }
    }

    if (getData == TRUE)
    {
        url <- sprintf(gdeltURL, date)

        fileName <- tempfile("GDELT")

        dir <- dirname(fileName)

        download.file(url, fileName, mode="wb")

        unzip(fileName, exdir=dir)
        
        temp <- unzip(fileName, exdir=dir, list=TRUE)$Name

        csvFile <- sprintf("%s/%s", dir, temp)

        print(sprintf("Processing: %s", csvFile))

        d <- read.csv(file=csvFile, header = FALSE, sep="\t", stringsAsFactors = FALSE)

        names(d) <- gdeltNames()

        save(d, url, file=saveFile)

        unlink(fileName)
        unlink(csvFile)
    }

    load(saveFile)

    d
}

presentData <- function(d, areaOfInterest, addPositSummary)
{
    print(head(d[,c("Actor1Geo_Lat","Actor1Geo_Long", "Actor2Geo_Lat","Actor2Geo_Long")]))

    plotData(d, area = areaOfInterest, positSummary=addPositSummary)

    print("Summarize event codes:")
    print(head(sort(summarizeEventCodes(d), decreasing=TRUE)))

    print("Summarize actor codes:")
    print(head(summarizeActorCodes(d)))

    print("Summarize actor posits:")
    print(head(summarizeActorPosits(d)))

    print("Summarize source URLs:")
    print(head(sort(summarizeSOURCEURLs(d), decreasing=TRUE)))

    print("Summarize source domains:")
    print(head(sort(summarizeDomains(d), decreasing=TRUE)))
    
    print("Plot CAMEO codes: ")
    plotCAMEOVerbCodebook(d, area = areaOfInterest, positSummary=addPositSummary)
}

main <- function()
{
    saveFile <- "savedData"
    dateOfInterest="20161017"

    plotAreas <- c("world", "nw", "ne", "sw", "se")

    areaOfInterest <- plotAreas[1]

    addPositSummary <- TRUE

    d <- loadData(saveFile, dateOfInterest)

    presentData(d, areaOfInterest, addPositSummary)
    
    b <- subset(d, EventCode %in% c(54, 55, 56))

    presentData(b, area = "nw", addPositSummary)

    d
}

main()

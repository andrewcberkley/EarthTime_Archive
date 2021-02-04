library(dplyr)
library(tidyverse)
library(data.table)

UK <- read.csv("C:/Users/ABERK/Desktop/Innovate UK/innovate_UK_clean_14-01-2019.csv", stringsAsFactors=FALSE)
UK <- UK[, -c(1:2, 6)]

df <- UK %>%
    group_by(Competition_Year) %>%
    mutate(idx = row_number()) %>%
    spread(Competition_Year, Grant_Offered_.GBP.) %>%
    select(-idx)

#How to sum columns by two groups, then collapse the rows in R data frame
#https://stackoverflow.com/questions/35636403/how-to-sum-columns-by-two-groups-then-collapse-the-rows-in-r-data-frame

setDT(df)

collapseddf <- df[ , .("2003" = sum(`2003`, na.rm = TRUE), "2004" = sum(`2004`, na.rm = TRUE), "2006" = sum(`2006`, na.rm = TRUE), "2007" = sum(`2007`, na.rm = TRUE), "2008" = sum(`2008`, na.rm = TRUE), "2009" = sum(`2009`, na.rm = TRUE), "2010" = sum(`2010`, na.rm = TRUE), "2011" = sum(`2011`, na.rm = TRUE), "2012" = sum(`2012`, na.rm = TRUE), "2013" = sum(`2013`, na.rm = TRUE), "2014" = sum(`2014`, na.rm = TRUE), "2015" = sum(`2015`, na.rm = TRUE), "2016" = sum(`2016`, na.rm = TRUE), "2017" = sum(`2017`, na.rm = TRUE), "2018" = sum(`2018`, na.rm = TRUE), "SumYear2003" = sum(`2003`, na.rm = TRUE), "SumYear2004" = sum(`2003`, `2004`, na.rm = TRUE), "SumYear2005" = sum(`2003`, `2004`, na.rm = TRUE), "SumYear2006" = sum(`2003`, `2004`, `2006`,na.rm = TRUE), "SumYear2007" = sum(`2003`, `2004`, `2006`, `2007`,na.rm = TRUE), "SumYear2008" = sum(`2003`, `2004`, `2006`,`2007`,`2008`,na.rm = TRUE), "SumYear2009" = sum(`2003`, `2004`, `2006`,`2007`,`2008`,`2009`,na.rm = TRUE), "SumYear2010" = sum(`2003`, `2004`, `2006`,`2007`,`2008`,`2009`,`2010`,na.rm = TRUE), "SumYear2011" = sum(`2003`, `2004`, `2006`,`2007`,`2008`,`2009`,`2010`,`2011`,na.rm = TRUE), "SumYear2012" = sum(`2003`, `2004`, `2006`,`2007`,`2008`,`2009`,`2010`,`2011`,`2012`,na.rm = TRUE), "SumYear2013" = sum(`2003`, `2004`, `2006`,`2007`,`2008`,`2009`,`2010`,`2011`,`2012`,`2013`,na.rm = TRUE), "SumYear2014" = sum(`2003`, `2004`, `2006`,`2007`,`2008`,`2009`,`2010`,`2011`,`2012`,`2013`,`2014`,na.rm = TRUE), "SumYear2015" = sum(`2003`, `2004`, `2006`,`2007`,`2008`,`2009`,`2010`,`2011`,`2012`,`2013`,`2014`,`2015`,na.rm = TRUE), "SumYear2016" = sum(`2003`, `2004`, `2006`,`2007`,`2008`,`2009`,`2010`,`2011`,`2012`,`2013`,`2014`,`2015`,`2016`,na.rm = TRUE), "SumYear2017" = sum(`2003`, `2004`, `2006`,`2007`,`2008`,`2009`,`2010`,`2011`,`2012`,`2013`,`2014`,`2015`,`2016`,`2017`,na.rm = TRUE), "SumYear2018" = sum(`2003`, `2004`, `2006`,`2007`,`2008`,`2009`,`2010`,`2011`,`2012`,`2013`,`2014`,`2015`,`2016`,`2017`,`2018`,na.rm = TRUE)),
   by = .(Theme_Name, Post_Area, Address_Region)]

themeList <- split(collapseddf, collapseddf$Theme_Name)

#List elements to dataframes in R
#https://stackoverflow.com/questions/26414836/list-elements-to-dataframes-in-r
#list2env(lapply(themeList, as.data.frame.list), .GlobalEnv)

#coalesce_by_column <- function(df) {
#    return(dplyr::coalesce(!!! as.list(df)))
#}
#
#aTest <- Sustainability %>%
#    group_by(Theme_Name, Post_Area, Address_Region) %>%
#    summarise_all(coalesce_by_column)
#
#View(aTest)

for (i in seq_along(themeList)) {
    try({
        filename = paste(names(themeList)[i], ".csv")
        write.csv(themeList[[i]], filename, na = "", row.names = FALSE)
    })
}


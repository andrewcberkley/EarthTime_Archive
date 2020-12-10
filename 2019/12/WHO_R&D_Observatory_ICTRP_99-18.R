setwd(file.path(Sys.getenv('my_dir'),'2019/12/'))

df <- read.csv("WHO R&D Observatory_ICTRP data_99-18.csv", stringsAsFactors=FALSE)

library(dplyr)
library(tidyverse)
library(data.table)

df$dummy_column <- 1

df2 <- df %>%
	group_by(Year) %>%
	mutate(idx = row_number()) %>%
	spread(Year, dummy_column) %>%
	select(-idx)


df3 <- df2[,-c(2:6, 11:14, 16:24, 45)]

df4 <- df3[!(df3$Country.Code=="" | df3$Health.category.Level.1==""),]

df5 <- df4[,-c(1,4:6)]

#For specific health categories
setDT(df5)
summed_health_data_by_category <- df5[ , .(`1999`=sum(`1999`, na.rm = TRUE), `2000`=sum(`2000`, na.rm = TRUE), `2001`=sum(`2001`, na.rm = TRUE), `2002`=sum(`2002`, na.rm = TRUE), `2003`=sum(`2003`, na.rm = TRUE), `2004`=sum(`2004`, na.rm = TRUE), `2005`=sum(`2005`, na.rm = TRUE), `2006`=sum(`2006`, na.rm = TRUE), `2007`=sum(`2007`, na.rm = TRUE), `2008`=sum(`2008`, na.rm = TRUE), `2009`=sum(`2009`, na.rm = TRUE), `2010`=sum(`2010`, na.rm = TRUE), `2011`=sum(`2011`, na.rm = TRUE), `2012`=sum(`2012`, na.rm = TRUE), `2013`=sum(`2013`, na.rm = TRUE), `2014`=sum(`2014`, na.rm = TRUE), `2015`=sum(`2015`, na.rm = TRUE), `2016`=sum(`2016`, na.rm = TRUE), `2017`=sum(`2017`, na.rm = TRUE), `2018`=sum(`2018`, na.rm = TRUE)), by = .(Country.Code, Health.category.Level.1)]

health_category_list <- split(summed_health_data, summed_health_data$Health.category.Level.1)

for (i in seq_along(health_category_list)) {
    try({
        filename = paste(names(health_category_list)[i], ".csv")
        write.csv(health_category_list[[i]], filename, na = "", row.names = FALSE)
    })
}

#Combining all health categories
df6 <- df4[,-c(1,3:6)]
setDT(df6)
summed_health_data_all <- df6[ , .(`1999`=sum(`1999`, na.rm = TRUE), `2000`=sum(`2000`, na.rm = TRUE), `2001`=sum(`2001`, na.rm = TRUE), `2002`=sum(`2002`, na.rm = TRUE), `2003`=sum(`2003`, na.rm = TRUE), `2004`=sum(`2004`, na.rm = TRUE), `2005`=sum(`2005`, na.rm = TRUE), `2006`=sum(`2006`, na.rm = TRUE), `2007`=sum(`2007`, na.rm = TRUE), `2008`=sum(`2008`, na.rm = TRUE), `2009`=sum(`2009`, na.rm = TRUE), `2010`=sum(`2010`, na.rm = TRUE), `2011`=sum(`2011`, na.rm = TRUE), `2012`=sum(`2012`, na.rm = TRUE), `2013`=sum(`2013`, na.rm = TRUE), `2014`=sum(`2014`, na.rm = TRUE), `2015`=sum(`2015`, na.rm = TRUE), `2016`=sum(`2016`, na.rm = TRUE), `2017`=sum(`2017`, na.rm = TRUE), `2018`=sum(`2018`, na.rm = TRUE)), by = .(Country.Code)]

write.csv(summed_health_data_all, "all_clincial_trials.csv", na = "", row.names = FALSE)
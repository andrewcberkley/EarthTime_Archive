setwd(file.path(Sys.getenv('my_dir'),'2021/06/global_views_on_homosexuality'))

options(java.parameters = "-Xmx12000m")
library(beepr) #for fun sounds when task is completed :)
library(tabulizer)
#Error: package or namespace load failed for 'tabulizer':
#  .onLoad failed in loadNamespace() for 'tabulizerjars', details:
#  call: NULL
#error: .onLoad failed in loadNamespace() for 'rJava', details:
#  call: fun(libname, pkgname)
#error: JAVA_HOME cannot be determined from the Registry

#rJava install error "JAVA_HOME cannot be determined from the Registry"
#https://stackoverflow.com/questions/29522088/rjava-install-error-java-home-cannot-be-determined-from-the-registry
library(tabulizer)
library(shiny)
library(tidyverse)
library(zoo)
#https://www.gzeromedia.com/the-graphic-truth-global-attitudes-towards-lgbt-people
#https://www.pewresearch.org/global/2020/06/25/global-divide-on-homosexuality-persists/
#https://www.pewresearch.org/global/wp-content/uploads/sites/2/2020/06/PG_2020.06.25_Global-Views-Homosexuality_TOPLINE.pdf
#https://www.pewresearch.org/methodology/international-survey-research/international-methodology/all-survey/all-country/all-year

#In Japan, where conservative ideas about gender identity and sexual orientation have long dominated, 68% of Japanese now think gay people should be fully accepted by society.That's an increase of 14 percentage points from 2013.

pewTables <- extract_tables("PG_2020.06.25_Global-Views-Homosexuality_TOPLINE.pdf", pages = c(3:5))
df <- as.data.frame(do.call(rbind, pewTables))

rm(pewTables)
rm(df)

#Q31. And which one of these comes closer to your opinion?
#Homosexuality should be accepted by society OR Homosexuality should not be accepted by society
Q31 <- read.csv("Q31.csv")

should_be_accepted_df <- Q31[,c(1:3)]

wide_df <- should_be_accepted_df %>%
  group_by(Country, Year) %>%
  mutate(idx = row_number()) %>%
  spread(Year, Homosexuality.should.be.accepted.by.society) %>%
  select(-idx)

pew_response_linear_interpolate0 <- function(y1, y2, side) {
  if (side==0) {return(y1)}
  else {return(y2)}
}

pew_response_linear_interpolate1 <- function(x1, x2, y1, y2, val) {
  slope <- (y2-y1)/(x2-x1)
  return(y1+(val-x1)*slope)
}

c_names <- c("Country", 2002:2019)

list_edges <- rbind(
  cbind(2002, 2007),
  cbind(2007, 2011),
  cbind(2011, 2013),
  cbind(2013, 2019))

get_interpolated_pew_responses <- function(my.df, type) {
  
  k <- 2
  
  for (i in 1:nrow(list_edges)) {
    
    x1 <- list_edges[i,1]
    x2 <- list_edges[i,2]
    
    for (j in 1:(x2-x1-1)) {
      
      my.df <- cbind(my.df, apply(
        my.df, 1, 
        function(x) {
          y1 <- as.numeric(x[k])
          y2 <- as.numeric(x[k+1])
          if (type==0) {
            if (is.na(y1) | is.na(y2)) {return(NA)}
            else {return(pew_response_linear_interpolate0(y1, y2, 0))}
          } else if (type==1) {
            if (is.na(y1) | is.na(y2)) {return(NA)}
            else {return(pew_response_linear_interpolate1(x1, x2, y1, y2, x1+j))}
          }
        }))
      colnames(my.df)[ncol(my.df)] <- as.character(x1+j)
    }
    
    k <- k+1
  }
  
  return(my.df)
}

wide_df_interpolated <- get_interpolated_pew_responses(wide_df, 1)

wide_df_interpolated <- wide_df_interpolated[,c_names]

long_df <- gather(wide_df_interpolated, Year, Responses, "2002":"2019", factor_key = TRUE)

long_df_alpha <- long_df[order(long_df$Country),]

long_df_interploated <- long_df_alpha %>%
  group_by(Country) %>%
  mutate(ValueInterp = na.approx(Responses, na.rm=FALSE))

long_df_interploated_v2 <- long_df_interploated[,-3]

final_df <- long_df_interploated_v2 %>%
  group_by(Country, Year) %>%
  mutate(idx = row_number()) %>%
  spread(Year, ValueInterp) %>%
  select(-idx)

options(digits=2)

write.csv(final_df, "homosexuality_should_be_accepted_by_society.csv", row.names = FALSE, na = "")
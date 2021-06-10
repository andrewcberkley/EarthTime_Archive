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

################################
###Agenda Blog Scrapping in R###
################################

library(magrittr) 
library(dplyr) 
library(rvest) 
library(xml2) 
library(selectr)
library(tibble)
library(purrr)
library(datapasta)
library(tryCatchLog)
library(qdapRegex)
library(textclean)

text_remove_html <- function(mytext){
  return(bracketX(mytext,"angle"))
}
# Loading the links

list_articles <- read.csv("5000_articles.csv",header=TRUE,stringsAsFactors=FALSE)
colnames(list_articles) <- c("Tag","Title","Link","Text")

###Function for Scraping the Text (via the "rvest" package)
get_agenda_blog_text <- function(x){
     tryCatch(
           read_html(x) %>%
                html_nodes(xpath = '/html/body/div[4]/section/div[2]/div[2]/div[1]') %>%
                html_text(),
           		error = function(x){NA} #This is a function that will return "NA" regardless of it's passes
       )    
 }

#Iterate over the list of articles (via the "purrr" package)
system.time(Agenda_Blogs_with_Text <- list_of_agenda_articles %>%
  mutate(., Article_Text = map_chr(.x = Link, .f = get_agenda_blog_text)))

Agenda_Blogs_with_Text$columnnametest <- rm_white(Agenda_Blogs_with_Text$columnnametest)
Agenda_Blogs_with_Text$columnnametest <- gsub("\\n","",Agenda_Blogs_with_Text$columnnametest)



get_text <- function(dt) {

	

}



list_articles$Text <- apply(list_articles, 1, function(x) get_text(x))
################################
###Agenda Blog Scrapping in R###
################################

###Load Librarys
library(magrittr) #for pipes
library(dplyr) #for pull function
library(rvest) #get html nodes
library(xml2) #pull html data
library(selectr) #for xpath element
library(tibble)
library(purrr) #for map functions
library(datapasta) #for recreating tibble's with ease
library(tryCatchLog) #for error handling
library(qdapRegex)

###Agenda Blog List Formatting (via the "tibble" package)

list_of_agenda_articles <- tibble::tibble(
  Article_Name = c(
    "Why today's leaders need to know about the power of narratives",
    "Following the World Cup? Then you're watching high-performing migrants at work",
    "This 'smart' prosthetic ankle could change the lives of amputees",
    "The British government has pledged to end gay conversion therapy"
    ),
  Article_Link = c(
    "https://www.weforum.org/agenda/2018/07/market-for-narratives-battleground-leader-strategy-why",
    "https://www.weforum.org/agenda/2018/07/following-the-world-cup-then-youre-watching-high-performing-migrants-at-work",
    "https://www.weforum.org/agenda/2018/07/smart-prosthetic-ankle-takes-the-pain-out-of-stairs",
    "https://www.weforum.org/agenda/2018/07/britain-vows-to-end-gay-conversion-therapy-as-survey-reveals-burning-injustices"
  )
)

###Function for Scraping the Text (via the "rvest" package)
get_agenda_blog_text <- function(x){
     tryCatch(
           read_html(x) %>%
                 html_node(xpath = '/html/body/div[4]/section/div[2]/div[2]/div[1]') %>%
                 html_text(),
           error = function(x){NA} #This is a function that will return "NA" regardless of it's passes
       )    
 }

#Iterate over the list of articles (via the "purrr" package)
system.time(Agenda_Blogs_with_Text <- list_of_agenda_articles %>%
  mutate(., Article_Text = map_chr(.x = Article_Link, .f = get_agenda_blog_text)))

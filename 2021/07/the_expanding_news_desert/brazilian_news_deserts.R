setwd(file.path(Sys.getenv('my_dir'),'2021/07/the_expanding_news_desert'))

#if (!require("devtools")) install.packages("devtools")
#devtools::install_github("voltdatalab/newsatlasbr")

library(newsatlasbr)

#https://latamjournalismreview.org/news/digital-journalism-reduces-incidence-of-news-deserts-in-brazil/
#https://www.atlas.jor.br/plataforma/api/pacote/
atlas_signin(email = Sys.getenv('atlas_da_noticia_user'), password = Sys.getenv('atlas_da_noticia_password'))

brazil <- get_municipalities()
almost_deserts_dataset <- almost_deserts()
municipalities_with_media <- n_orgs_100k()
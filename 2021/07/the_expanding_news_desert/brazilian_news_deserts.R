setwd(file.path(Sys.getenv('my_dir'),'2021/07/the_expanding_news_desert'))

##if (!require("devtools")) install.packages("devtools")
##devtools::install_github("voltdatalab/newsatlasbr")

#library(newsatlasbr)

##https://latamjournalismreview.org/news/digital-journalism-reduces-incidence-of-news-deserts-in-brazil/
##https://www.atlas.jor.br/plataforma/api/pacote/

#atlas_signin(email = Sys.getenv('atlas_da_noticia_user'), password = Sys.getenv('atlas_da_noticia_password'))

#brazil <- get_municipalities()
#almost_deserts_dataset <- almost_deserts()
#municipalities_with_media <- n_orgs_100k()

#save(brazil, almost_deserts_dataset, municipalities_with_media, file = "brazil_news_deserts.RData")
load("brazil_news_deserts.RData")

##Details
##municipio: municipality name.
##uf: abbreviation of the state's name.
##regiao: name of the country's region where the municipality is located at.
##qtd_veiculos: number of news organizations in the municipality.
##codmun: IBGE's (Brazilian Institute of Geography and Statistics) code for the municipality (7-digit).
##populacao: municipality's population.
##ano: year from IBGE's population records (note that data on news organizations collected by Atlas' team were last updated on Nov. 30th, 2019.)
##veiculos_por_100k_hab: number of news organizations per 100,000 inhabitants.
##IDHM: Human Development Index for the municipality (Census 2010).
##IDHM_R: Human Development Index - per capita income for the municipality (Census 2010).
##IDHM_E: Human Development Index - education for the municipality (Census 2010).
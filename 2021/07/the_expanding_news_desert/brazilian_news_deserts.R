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

library(geobr)
mun <- read_municipality(code_muni="all", year=2020)

#Pereira, R.H.M.; Gonçalves, C.N.; et. all (2019) geobr: Loads Shapefiles of Official Spatial Data Sets of Brazil. GitHub repository - https://github.com/ipeaGIT/geobr.

download.file(mun, "brazil_municipalities.gpkg", mode = "wb")

brazil_json <- geojsonio::geojson_list(mun)
print(paste0("The file was originally ", object.size(brazil_json), units = "Mb"))

brazil_small <- rmapshaper::ms_simplify(brazil_json, keep = 0.05)
print(paste0("The file is now ", object.size(country_small), units = "Mb"))


rgdal::writeOGR(mun, "brazil_municipalities.gpkg", layer=municipalities, driver="GPKG")
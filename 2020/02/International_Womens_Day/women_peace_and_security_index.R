setwd(file.path(Sys.getenv('my_dir'),'2020/02/International_Womens_Day/'))

library(sp)
library(raster)
library(geojsonio)
library(rmapshaper)
library(rmapshaper)
library(rgdal)
library(glue)
#library(echarts4r)

#Admin Level 0 ≈ National Level
#Admin Level 1 ≈ State/Provence Level
#Admin Level 2 ≈ County Level

aberk_geojson <- function (country_name, admin_level) {

	name_of_country <- country_name

	country_sp <- raster::getData("GADM", country = country_name, level = admin_level)

	country_sp %>%
    	head() %>%
    	knitr::kable()

    country_json <- geojsonio::geojson_list(country_sp)
    country_json <- geojsonio::geojson_list(country_sp)

    print(paste0("The file for ", country_name, " was originally ", object.size(country_json), units = "Mb"))

    country_small <- rmapshaper::ms_simplify(country_sp, keep = 0.05)
    print(paste0("The file for ", country_name, " is now ", object.size(country_small), units = "Mb"))
 #    country_json_small <- geojsonio::geojson_list(country_small)

 #    print(paste0("The file for ", country_name, " is now ", object.size(country_json_small), units = "Mb"))

 #    country_json_small$features <- country_json_small$features %>%
	# 	purrr::map(function(x){
	#     	x$properties$name <- x$properties$NAME_2
	#     return(x)
	#   })

	# e_chart() %>%
	# 	e_map_register(country_small, country_json_small) %>%
	# 	e_map(map = country_small)

	writeOGR(country_small, glue("{name_of_country}.geojson"), layer=country_name, driver="GeoJSON")

}

country_list <- c("china", "nigeria", "india")

for (i in country_list) {
    aberk_geojson(i, 1)
}
library(echarts4r)
library(sp)
library(raster)
library(geojsonio)
library(rmapshaper)
library(rmapshaper)

indonesia_sp <- raster::getData("GADM", country = "indonesia", level = 2)
indonesia_sp %>%
head() %>%
knitr::kable()
indonesia_json <- geojsonio::geojson_list(indonesia_sp)
indonesia_json <- geojsonio::geojson_list(indonesia_sp)
print(object.size(indonesia_json), units = "Mb")
#indonesia_amLL <- rmapshaper::ms_simplify(indonesia_sp, keep = 0.05)
indonesia_small <- rmapshaper::ms_simplify(indonesia_sp, keep = 0.05)
indonesia_json_small <- geojsonio::geojson_list(indonesia_small)
print(object.size(indonesia_json_small), units = "Mb")
indonesia_json_small$features <- indonesia_json_small$features %>%
purrr::map(function(x){
	x$properties$name <- x$properties$NAME_2
	return(x)
	})
e_chart() %>%
e_map_register("indonesia_small", indonesia_json_small) %>%
e_map(map = "indonesia_small")


library("rgdal")
writeOGR(indonesia_small, "indonesia.geojson", layer="indonesia", driver="GeoJSON")
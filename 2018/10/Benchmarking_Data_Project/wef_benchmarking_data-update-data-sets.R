setwd(file.path(Sys.getenv('my_dir'),'2018/10/benchmarking_data_project//WEF_IndexData/'))

source("functions.R")

update <- FALSE
dirpath <- getwd()

dt_all <- XLConnect::loadWorkbook("WEF_Dictionaries_20180314.xlsx")
XLConnect::setMissingValue(dt_all, value = NA)
lst_series <- XLConnect::readWorksheet(dt_all, sheet = "Series")
lst_queries <- XLConnect::readWorksheet(dt_all, sheet = "ListQueries")

# ===============================================
# retrieve list of available indexId and editions
# ===============================================

if (update) {

	update_mapping_table(lst_series)

	lst_series$Available <- apply(
		lst_series, 
		1, 
		function(x) {
			if (nrow(lst_map[lst_map$seriesId==x[1],])>0) { return(TRUE) }
			else {return(FALSE)}
		}
		)

	lst_mappings <- read.csv("Mapping_Index_Edition_Series.csv", header = TRUE, stringsAsFactors=FALSE)

	XLConnect::createSheet(dt_all, name = "ListQueries")
  	XLConnect::writeWorksheet(dt_all,lst_mappings, sheet="ListQueries", startRow=1, startCol=1)
  	XLConnect::saveWorkbook(dt_all)

	XLConnect::createSheet(dt_all, name = "Availability")
	XLConnect::writeWorksheet(dt_all, lst_series[,c(1,2,8,10,16)], sheet="Availability", startRow=1, startCol=1)
	XLConnect::saveWorkbook(dt_all)

}

lst_map <- read.csv("Mapping_Index_Edition_Series.csv", header = TRUE, stringsAsFactors=FALSE)
lst_tms <- do.call(rbind, apply(lst_map, 1, function(x) data.frame(strsplit(x[4], "; ")[[1]])))
lst_tms <- dplyr::arrange(data.frame(table(lst_tms[,1])), desc(Freq))
colnames(lst_tms) <- c("Map", "Freq")

cat("\n====================\n")
cat("Number of unique data series: ", nrow(lst_map),"\n")
cat("Number of unique maps tagged: ", length(unique(lst_tms$Var1)),"\n")
cat("\n")
cat("Twenty most popular maps:\n")
cat("-------------------------\n")
print(head(lst_tms,20))
cat("\n")







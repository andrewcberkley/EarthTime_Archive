library(httr)

url_base_edi <- "http://data-visualization-app-qa.herokuapp.com/api/v1/editions"
url_mapping <- "http://data-visualization-app.herokuapp.com/api/v1/index_edition_series_tree?"
url_base <- "http://data-visualization-app-qa.herokuapp.com/api/v1/index_edition_data?"

get_full_list <- function(vec) {

  lst_dates <- strsplit(as.character(vec[2]), "; ")[[1]]
  df <- data.frame(vec)
  df <- df[rep(seq_len(nrow(df)), each=length(lst_dates)),]
  df$edition <- lst_dates
  return(df)

}


call_index_mapping <- function(id, edt) {

  cat("Calling :", paste(url_mapping,"indexId=",id,"&edition=",edt,sep=""),"\n")
  req <- GET(paste(url_mapping,"indexId=",id,"&edition=",edt,sep=""))
  Sys.sleep(1)
  return(req)

}

get_index_mapping <- function() {

  cat("Retrieving edition listing...\n")
  lst_ed <- get_editions()

  cat("Retrieving mapping listing...\n")
  df <- do.call(rbind, apply(
    lst_ed, 
    1, 
    function(x) {
      cnt <- content(call_index_mapping(gsub(" ","%20",x[2]), x[3]))
      if(length(cnt[[1]]$value)>=1) {
        dtt <- data.frame(unlist(cnt[[1]]$value))
        dtt$indexId <- x[2]
        dtt$edition <- x[3]
        dtt <- dtt[,c(2,3,1)]
        colnames(dtt) <- c("indexId", "edition", "seriesId")
        return(dtt)
      }
    }
    )
  )

  return(df)

}


update_mapping_table <- function(dt_ser) {

  date <- format(Sys.Date(),"%Y%m%d")

  cat("\n")
  cat("Updating mapping table...\n")
  cat("-------------------------\n")
  lst_map <- get_index_mapping()
  lst_map$TMs <- dt_ser[match(lst_map$seriesId, dt_ser$Global.ID),"TMs"]

  write.csv(lst_map,paste(getwd(),"/Archive/Mapping_Index_Edition_Series_",date,".csv",sep=""), row.names=FALSE)
  write.csv(lst_map,paste(getwd(),"/Mapping_Index_Edition_Series.csv",sep=""), row.names=FALSE)
  return(cat("Mapping returned ", nrow(lst_map), " series available in DB\n\n"))

}

call_editions <- function() {

	req <- GET(paste(url_base_edi,sep=""))
  Sys.sleep(1)
  return(req)

}

get_editions <- function() {

	req <- call_editions()
	cnt <- content(req)
	df <- do.call(rbind, lapply(cnt, function(x) data.frame(t(unlist(x)))))
	return(df)

}

get_available_datasets <- function() {

  lst_ed <- get_editions()
  lst_ed_unique <- data.frame(unique(lst_ed$key))
  lst_ed_unique <- data.frame(lst_ed_unique[lst_ed_unique[,1]!="Country Readiness for the Future of Production Assessment",])
  colnames(lst_ed_unique) <- ("indexId")

  lst_series <- read.csv("../WEF_Dictionaries_20180314_Series.csv", header=TRUE, stringsAsFactors=FALSE)

  lst_series$indexId <- NA

  #apply(lst_ed_unique, 1, function(x) lst_series[grep(as.character(x[1]), lst_series$Global.ID),]$indexId <- as.character(x[1]))

  lst_series[grep(as.character(lst_ed_unique$indexId[1]), lst_series$Global.ID),]$indexId <- as.character(lst_ed_unique$indexId[1])
  lst_series[grep(as.character(lst_ed_unique$indexId[2]), lst_series$Global.ID),]$indexId <- as.character(lst_ed_unique$indexId[2])
  lst_series[grep(as.character(lst_ed_unique$indexId[3]), lst_series$Global.ID),]$indexId <- as.character(lst_ed_unique$indexId[3])
  lst_series[grep(as.character(lst_ed_unique$indexId[4]), lst_series$Global.ID),]$indexId <- as.character(lst_ed_unique$indexId[4])
  lst_series[grep(as.character(lst_ed_unique$indexId[5]), lst_series$Global.ID),]$indexId <- as.character(lst_ed_unique$indexId[5])
  lst_series[grep(as.character(lst_ed_unique$indexId[6]), lst_series$Global.ID),]$indexId <- as.character(lst_ed_unique$indexId[6])
  lst_series[grep(as.character(lst_ed_unique$indexId[7]), lst_series$Global.ID),]$indexId <- as.character(lst_ed_unique$indexId[7])
  lst_series[grep(as.character(lst_ed_unique$indexId[8]), lst_series$Global.ID),]$indexId <- as.character(lst_ed_unique$indexId[8])
  lst_series[grep(as.character(lst_ed_unique$indexId[9]), lst_series$Global.ID),]$indexId <- as.character(lst_ed_unique$indexId[9])

  lst_series <- lst_series[!is.na(lst_series$indexId),]
  lst_series$edition <- apply(lst_series, 1, function(x) paste(lst_ed[lst_ed$key==x[15],]$value1, collapse="; "))

}


call_eco_data <- function(url) {

  cat("Sending link ", url, "\n")
  req <- GET(url)
  Sys.sleep(1)
  return(req)
  
}

save_eco_data <- function(idx, edt, ser, updt) {

  if (file.exists(paste("Files/",gsub(" ","",idx),"_", edt,"_", ser ,".RData",sep="")) & !updt) {

    cat("File already exists in local drive\n")
    return(TRUE)

  } else {

    url <- paste(url_base, "indexId=", gsub(" ","%20",idx), "&edition=", edt, "&seriesId=", ser ,sep="")
    req <- call_eco_data(url)
    cnt <- content(req)

    if (length(cnt)>0) {
      save(cnt, file=paste("Files/",gsub(" ","",idx),"_", edt,"_", ser ,".RData",sep=""))
      return(TRUE)
    } else {
      return(FALSE)
    }

  }

}

get_eco_data <- function(idx, edt, ser, cntr, updt) {

  if (save_eco_data(idx, edt, ser, updt)) {

    load(paste("Files/", gsub(" ", "", idx), "_", edt, "_", ser, ".RData", sep = ""))

    if (length(cnt[[1]]) > 0 & length(cnt[[1]]$value$entries) > 0) {

      df1 <- do.call(rbind, lapply(cnt[[1]]$value$entries, function(x) {
        if (length(x) > 0)
          data.frame(t(unlist(x)))
      }))

      df <- data.frame(df1$date_description)

      df$note <- NA
      df$rank <- NA
      df$source <- NA
      df$source_date <- NA
      df$value <- NA
      df$Eco <- NA
      df$id <- NA
      df$key1 <- NA
      df$key2 <- NA
      df$freeze_date <- NA
      df$base_period <- NA
      df$sources_description <- NA
      df$code <- NA
      df$parent <- NA
      df$rank_direction <- NA
      df$additional_series <- NA
      df$is_pillar <- NA
      df$ranges_map <- NA
      df$max_rank <- NA
      df$max_value <- NA
      df$min_value <- NA
      df$avg_value <- NA
      df$median_value <- NA

      if (!is.null(df1$note))
        df$note <- df1$note
      if (!is.null(df1$rank))
        df$rank <- df1$rank
      if (!is.null(df1$source))
        df$source <- df1$source
      if (!is.null(df1$source_date))
        df$source_date <- df1$source_date
      if (!is.null(df1$value))
        df$value <- df1$value

      df$Eco <- row.names(df1)
      if (!is.null(cnt[[1]]$id))
        df$id <- cnt[[1]]$id
      if (!is.null(cnt[[1]]$key[[1]]))
        df$key1 <- cnt[[1]]$key[[1]]
      if (!is.null(cnt[[1]]$key[[2]]))
        df$key2 <- cnt[[1]]$key[[2]]
      if (!is.null(cnt[[1]]$value$freeze_date))
        df$freeze_date <- cnt[[1]]$value$freeze_date
      if (!is.null(cnt[[1]]$value$base_period))
        df$base_period <- cnt[[1]]$value$base_period
      if (!is.null(cnt[[1]]$value$sources_description))
        df$sources_description <- cnt[[1]]$value$sources_description
      if (!is.null(cnt[[1]]$value$code))
        df$code <- cnt[[1]]$value$code
      if (!is.null(cnt[[1]]$value$parent))
        df$parent <- cnt[[1]]$value$parent
      if (!is.null(cnt[[1]]$value$rank_direction))
        df$rank_direction <- cnt[[1]]$value$rank_direction
      if (!is.null(cnt[[1]]$value$additional_series))
        df$additional_series <- cnt[[1]]$value$additional_series
      if (!is.null(cnt[[1]]$value$is_pillar))
        df$is_pillar <- cnt[[1]]$value$is_pillar
      if (!is.null(cnt[[1]]$value$ranges_map))
        df$ranges_map <- cnt[[1]]$value$ranges_map
      if (!is.null(cnt[[1]]$value$max_rank))
        df$max_rank <- cnt[[1]]$value$max_rank
      if (!is.null(cnt[[1]]$value$max_value))
        df$max_value <- cnt[[1]]$value$max_value
      if (!is.null(cnt[[1]]$value$min_value))
        df$min_value <- cnt[[1]]$value$min_value
      if (!is.null(cnt[[1]]$value$avg_value))
        df$avg_value <- cnt[[1]]$value$avg_value
      if (!is.null(cnt[[1]]$value$median_value))
        df$median_value <- cnt[[1]]$value$median_value

      df <- df[, c(9, 10, 7, 5, 3, 6, 20:24, 13:18)]

      if (cntr != "All")
        df <- df[df$Eco == cntr, ]

      cat(paste("Loading Files/", gsub(" ", "", idx), "_", edt, "_", ser, ".RData",
        sep = ""), "\n")

      return(df)

    }
  } else {
    cat("Problem retrieving data on server...\n")
    return(NULL)
  }

}
create_all_df <- function(my.dt) {

  dt <- do.call(
    rbind, 
    apply(my.dt, 1, function(x) {
      get_eco_data(x[1], x[2], x[3], "All", update)
    }
    )
    )

  save(dt, file="all-combined-data.RData")
  return(dt)

}

get_series_by_map <- function(lst.queries, map.name) {

  lst <- lst.queries[lst.queries$TMs!="" & !is.na(lst.queries$TMs),]

  lst.quer.all <- do.call(
    rbind,
    apply(
      lst, 
      1,
      function(x){
        my.df <- data.frame(strsplit(x[4],";"))
        colnames(my.df) <- c("Map")
        my.df$indexId <- x[1]
        my.df$edition <- x[2]
        my.df$seriesId <- x[3]
        return(my.df)
      }
      )
    )

  return(lst.quer.all[lst.quer.all$Map==map.name,])

}














library(magrittr)

list_edges <- rbind(
    cbind(1982, 1990),
    cbind(1990, 2000),
    cbind(2000, 2010))

interpol_pol0 <- function(y1, y2, side) {
    if (side==0) {return(y1)}
    else {return(y2)}
}

interpol_pol1 <- function(x1, x2, y1, y2, val) {
    slope <- (y2-y1)/(x2-x1)
    return(y1+(val-x1)*slope)
}

get_interpolated_values <- function(my.df, type) {

    k <- 2
  
    for (i in 1:nrow(list_edges)) {

        x1 <- list_edges[i,1]
        x2 <- list_edges[i,2]

        for (j in 1:(x2-x1-1)) {

            my.df <- cbind(my.df, apply(
                my.df, 1, 
                function(x) {
                    y1 <- as.numeric(x[k])
                    y2 <- as.numeric(x[k+1])
                    if (type==0) {
                        if (is.na(y1) | is.na(y2)) {return(NA)}
                        else {return(interpol_pol0(y1, y2, 0))}
                    } else if (type==1) {
                        if (is.na(y1) | is.na(y2)) {return(NA)}
                        else {return(interpol_pol1(x1, x2, y1, y2, x1+j))}
                    }
                }))
                colnames(my.df)[ncol(my.df)] <- as.character(x1+j)
            }

        k <- k+1
    }

    return(my.df)
}

plot_curve <- function(my.df, lst_sel) {

    dt_gater <- my.df %>% tidyr::gather(YEAR,INDEX,2:29)
    dt_gater <- dt_gater[grep(lst_sel,dt_gater[,1]),]

    dt_gater %>%
        dplyr::group_by(ISO3) %>%
        echarts4r::e_charts(YEAR) %>%
        echarts4r::e_line(INDEX, smooth=TRUE) %>%
        echarts4r::e_tooltip(trigger = "axis") %>%
        echarts4r::e_datazoom(y_index = 0)

}
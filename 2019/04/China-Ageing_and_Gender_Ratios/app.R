
library(magrittr)
library(shiny)
library(shinythemes)
library(shinydashboard)
library(dashboardthemes)

source("setup.R")
source("plotting.R")

# Define UI
###########

ui <- fluidPage(
  
  theme = shinytheme("lumen"),
  br(),
    
  fluidRow(
    column(1),
    column(3,
           selectInput(
             inputId = "sel_ins", 
             label = strong("Insight Area"),
             choices = unique(df_net$name.ins),
             selected = "United States"
           )),
    column(2,
           selectInput(
             inputId = "sel_month", 
             label = strong("Month"),
             choices = unique(lst_months[-1,]$TIMETAG),
             selected = lst_months$TIMETAG[nrow(lst_months)]
           )),
    column(2,
           selectInput(
             inputId = "sel_mod", 
             label = strong("Moderation"),
             choices = c("Approved","Ignored"),
             selected = "Approved"
           )),
    column(2,
           selectInput(
             inputId = "sel_map", 
             label = strong("Map"),
             choices = c("Only map topics","All topics"),
             selected = "Only map topics"
           )),
    column(1)
  ),
  
  br(),
  
  fluidRow(
    column(1),
    column(5,echarts4r::echarts4rOutput("plt_1", height = 400)),
    column(5,echarts4r::echarts4rOutput("plt_2", height = 400)),
    column(1)
  ),
  
  br(),
  
  fluidRow(
    column(1),
    column(10,echarts4r::echarts4rOutput("plt_3", height = 450)),
    column(1)
  ),
  
  br(),
  
  fluidRow(
    column(1),
    column(10,DT::dataTableOutput("tbl")),
    column(1)
  )
    
)

# Define server function
########################

server <- function(input, output) {
  
  rec_val <- reactiveValues(
    id_sel = df_net[df_net$name.ins=="United States",]$sfid.ins[1],
    id_mth = lst_months$TIMETAG[ncol(lst_months)],
    id_mod = "Approved",
    id_map = 1,
    dt_sel1 = dt_topics,
    dt_sel2 = dt_topics,
    tbl_sel = dt_articles
    )
  
  observeEvent(c(input$sel_ins,input$sel_month,input$sel_mod,input$sel_map),{
    
    rec_val$id_sel <- as.character(dt_topics[dt_topics$INS.NAME==input$sel_ins,]$INS.ID[1])
    rec_val$tbl_sel <- dt_articles %>% dplyr::filter(grepl(as.character(rec_val$id_sel),TopicsID)) 

    if (input$sel_mod=="Approved") {
      rec_val$id_mth <- grep(input$sel_month, colnames(dt_topics))[1]
      rec_val$tbl_sel <- rec_val$tbl_sel %>% dplyr::filter(Approved==TRUE)
      } else {
      rec_val$id_mth <- grep(input$sel_month, colnames(dt_topics))[2]
      rec_val$tbl_sel <- rec_val$tbl_sel %>% dplyr::filter(Approved=="ignored")
      }
    
    if (input$sel_map=="Only map topics") {rec_val$id_map <- 1}
    else {rec_val$id_map <- 0}
    
    rec_val$dt_sel1 <- format_data_frame(dt_topics, rec_val$id_sel, (rec_val$id_mth), rec_val$id_map)
    rec_val$dt_sel2 <- format_data_frame(dt_topics, rec_val$id_sel, (rec_val$id_mth+10), rec_val$id_map)

    
  })
  
  output$plt_1 <- echarts4r::renderEcharts4r({
    plot_circ(rec_val$dt_sel1)
  })
  
  output$plt_2 <- echarts4r::renderEcharts4r({
    plot_polar(rec_val$dt_sel2)
  })
  
  output$plt_3 <- echarts4r::renderEcharts4r({
    plot_velocity_bar(dt_topics, rec_val$id_sel, rec_val$id_mth, rec_val$id_map)
  })
  
  output$tbl <- DT::renderDataTable({
    
    if (!is.null(input$plt_3_clicked_data[[1]][1])) {
      sel_ins <- as.character(input$plt_3_clicked_data[[1]][1])
      rec_val$tbl_sel <- rec_val$tbl_sel %>% dplyr::filter(grepl(sel_ins,Topics))
    }
      
    datatbl <- rec_val$tbl_sel[,c(2,5,6,7,9)]
    
    DT::datatable(
      datatbl,
      escape = FALSE,
      rownames = FALSE,
      options = list(
        dom = "ftip",
        pageLength = 5,
        initComplete = DT::JS(
          "function(settings, json) {","$(this.api().table().header()).css({'background-color': '#FBFCFC', 'color': '#000000'});",
        "}"))) %>%
      DT::formatStyle("Title", backgroundColor = "#FDFEFE", color = "#000000") %>%
      DT::formatStyle("Source", backgroundColor = "#FDFEFE", color = "#000000") %>%
      DT::formatStyle("NTopics", backgroundColor = "#FDFEFE" ,color = "#000000") %>%
      DT::formatStyle("Topics", backgroundColor = "#FDFEFE", color = "#000000") %>%
      DT::formatStyle("Date", backgroundColor = "#FDFEFE", color = "#000000")
    
  })
  
}

# Create Shiny object
shinyApp(ui = ui, server = server)
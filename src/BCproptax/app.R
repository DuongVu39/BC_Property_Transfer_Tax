#
# This is a Shiny web application
# An Exploration of British Columbia Property Tax Transfer
#

library(shiny)
library(tidyverse)
library(tibble)
library(glue)
city_tax <- read_csv("muni_tax.csv")


# Define UI for application that draws a map and two scatterplot
ui <- fluidPage(
  
  titlePanel("British Columbia Property Tax Transfer"),
  
  sidebarLayout(
    sidebarPanel(
      # Display 
      helpText(h3("Adjust the bar plot")),
      selectizeInput("city", label=h3("City Selection"), 
                     choices=c("Abbotsford", "Burnaby","Chilliwack", 
                               "Centrail Okanagan Rural", "Kelowna",
                               "Nanaimo", "Nanaimo Rural","Richmond",
                               "Rest of Metro Vancouver","Surrey",
                               "Vancouver", "Whistler"),
                     selected = c("Nanaimo", "Vancouver","Burnaby"), multiple = TRUE),
      
      selectInput("transType", h3("Transaction Type"),
                  choices = c(Transaction_Number = "Count",
                              Transaction_Value = "Dollar")),
      
      helpText(h5("Ctrl Click to select multiple features")),
      uiOutput("whatever"),
      

    
      # Display 1st scatterplot input method
      helpText(h3("Adjust the two trend plots")),
      
      
      selectInput("select", h3("City Selection"),
                  choices = c("Abbotsford", "Burnaby","Chilliwack", 
                              "Centrail Okanagan Rural", "Kelowna",
                              "Nanaimo", "Nanaimo Rural","Richmond",
                              "Rest of Metro Vancouver","Surrey",
                              "Vancouver", "Whistler"),
                  selected = "Nanaimo"),
      
     
      helpText(h3("Adjust the line plot")),
     
      selectInput("select2", h3("Feature Selection"),
                  choices = unique(city_tax$Statistics),
                  selected = "COMMERCIAL - COMMERCE (count)")

    ),
    
    # Show three plots
    mainPanel(
      h2("Overview"),
      plotOutput("barPlot"),
      
      h2("Line trend plot"),
        plotOutput("trendplot1"),
      
      # fluidRow(
      #   column(6,
      #   h2("First trend plot"),
      #   plotOutput("trendplot1")),
      #   column(6,
      #          h2("Transaction amount of"),
      #          textOutput("value"))),
        
      h2("Stacked area plot"),
      plotOutput("trendplot2")
    )
  ))


# Define server logic required 
server <- function(input, output) {
  
  output$whatever <- renderUI({
    count_dollar <- as.tibble(t(as.data.frame(list(
      c("Count","COMMERCIAL - COMMERCE (count)"),
      c("Count","COMMERCIAL - OTHER (count)"),
      c("Count","COMMERCIAL - STRATA NON-RESIDENTIAL (count)"),
      c("Count","COMMERCIAL TOTAL (count)"),
      c("Count","FARM TOTAL (count)"),
      c("Count","OTHER/UNKNOWN TOTAL (count)"),
      c("Count","RECREATIONAL TOTAL (count)"),
      c("Count","RESIDENTIAL - ACREAGE (count)"),
      c("Count","RESIDENTIAL - COMMERCE (count)"),
      c("Count","RESIDENTIAL - FARM (count)"),
      c("Count","RESIDENTIAL - MULTI-FAMILY (count)"),
      c("Count","RESIDENTIAL - OTHER (count)"),
      c("Count","RESIDENTIAL - SINGLE FAMILY RESIDENTIAL (count)"),
      c("Count","RESIDENTIAL - STRATA NON-RESIDENTIAL or RENTAL (count)"),
      c("Count","RESIDENTIAL - STRATA RESIDENTIAL (count)"),
      c("Count","RESIDENTIAL TOTAL (count)"),
      c("Count","Total Market Transactions (count)"),
      c("Count","Foreign Involvement Transactions (count)"),
      c("Dollar","FMV Median of Foreign Involvement Transactions ($ median)"),
      c("Dollar","FMV Sum of Foreign Involvement Transactions ($ sum)")))))

    names(count_dollar) <- c('type', 'nameft')

    selectInput("check", h3("Feature Type"),
                choices=filter(count_dollar,
                                 type==input$transType)$nameft,
                selected = c("COMMERCIAL TOTAL (count)",
                             "RESIDENTIAL TOTAL (count)",
                             "Foreign Involvement Transactions (count)"),
                multiple = TRUE, selectize = FALSE)
  })
  
  output$barPlot <- renderPlot({
    
    city_tax %>%  
      filter(Municipality %in% input$city, Statistics %in% input$check)  %>% 
      ggplot(aes(Municipality)) +
      geom_bar(aes(weight=values, fill=Statistics), position="dodge") +
      theme(legend.position="bottom")
    
  
  })
  

  # output$value <- renderText({ 
  #   h3(glue("Total transaction number of {input$select} city"))
  #   
  #   x <- sum((city_tax %>% filter(Municipality == input$select,
  #                                 !Statistics %in% 
  #                                   c("FMV Median of Foreign Involvement Transactions ($ median)",
  #                                     "FMV Sum of Foreign Involvement Transactions ($ sum)")))$values, na.rm = TRUE)
  #   
  #   h2(glue("{x} transactions"))
  #   
  # })
  
  
  output$trendplot1 <- renderPlot({
    city_tax %>% 
      filter(Municipality == input$select,
             Statistics == input$select2)  %>% 
      ggplot(aes(date, values, group = Municipality)) +
      geom_point(color = "red") +
      geom_line(color = "orange") +
      theme_bw() 
    
  })
  
  output$trendplot2 <- renderPlot({
  city_tax %>%
    filter(Municipality == input$select,
           Statistics %in% c("RESIDENTIAL - COMMERCE (count)",
                             "RESIDENTIAL - FARM (count)",
                             "RESIDENTIAL - MULTI-FAMILY (count)")) %>% 
    ggplot(aes(x=date,y=values,group=Statistics,fill=Statistics)) + 
    geom_area(position="fill")+
    scale_fill_manual(values=c("#7CB140", "#FF2A7F","#FFAA00")) +
    theme(legend.position="bottom")
  })
  

}

# Run the application 
options(shiny.sanitize.errors = TRUE)
shinyApp(ui = ui, server = server)


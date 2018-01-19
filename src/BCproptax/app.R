#
# This is a Shiny web application
# An Exploration of South American countries
#

library(shiny)
library(tidyverse)
city_tax <- read_csv("../muni_tax.csv")

tweaks <- 
  list(tags$head(tags$style(HTML("
                                 .multicol { 
                                 height: 150px;
                                 -webkit-column-count: 5; /* Chrome, Safari, Opera */ 
                                 -moz-column-count: 5;    /* Firefox */ 
                                 column-count: 5; 
                                 -moz-column-fill: auto;
                                 -column-fill: auto;
                                 } 
                                 "))
  ))

# Define UI for application that draws a map and two scatterplot
ui <- fluidPage(tweaks,
  
  titlePanel("British Columbia Property Tax Transfer"),
  
  sidebarLayout(
    sidebarPanel(
      # Display 
      helpText(h3("Adjust the bar plot")),    
      checkboxGroupInput("check", h3("City Selection"), 
                   choices = c("Abbotsford", "Burnaby","Chilliwack", 
                               "Centrail Okanagan Rural", "Kelowna",
                               "Nanaimo", "Nanaimo Rural","Richmond",
                               "Rest of Metro Vancouver","Surrey",
                               "Vancouver", "Whistler"), 
                   selected = c("Nanaimo", "Vancouver","Burnaby")),
      
      checkboxGroupInput("check2", h3("Feature Selection"),
                         choices = unique(city_tax$Statistics),
                         selected = c("COMMERCIAL TOTAL (count)",
                                         "RESIDENTIAL TOTAL (count)")),
      br(),
      br(),
      br(),
      # Display 1st scatterplot input method
      helpText(h3("Adjust the two trend plots")),
      
      
      selectInput("select", h3("City Selection"),
                  choices = c("Abbotsford", "Burnaby","Chilliwack", 
                              "Centrail Okanagan Rural", "Kelowna",
                              "Nanaimo", "Nanaimo Rural","Richmond",
                              "Rest of Metro Vancouver","Surrey",
                              "Vancouver", "Whistler"),
                  selected = "Nanaimo"),
      
      sliderInput("slider", h3("Time range"),
                  min = 1952, max = 2007, value = 1972, 
                  step = 5, sep = "", animate = TRUE),
      helpText("Adjust the trend line plot"),
     
      selectInput("select2", h3("Feature Selection"),
                  choices = c("COMMERCIAL - COMMERCE (count)",
                              "COMMERCIAL - OTHER (count)"),
                  selected = "COMMERCIAL - COMMERCE (count)")
      
    ),
    
    # Show three plots
    mainPanel(
      h2("First barplot"),
      plotOutput("barPlot"),
      
      fluidRow(
        column(6,
        h2("First trend plot"),
        plotOutput("trendplot1")),
        column(6,
               h2("Transaction amount of City A"),
               plotOutput("value"))),
        
      h2("Second trend plot"),
      plotOutput("trendplot2")
    )
  ))


# Define server logic required 
server <- function(input, output) {
  
  output$barPlot <- renderPlot({
    
    city_tax %>%  
      filter(Municipality %in% input$check, Statistics %in% input$check2)  %>% 
      ggplot(aes(Municipality)) +
      geom_bar(aes(weight=values, fill=Statistics), position="dodge") +
      theme(legend.position="bottom")
    
  
  })
  
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
    geom_area(position="fill", alpha = 0.8)+
    scale_fill_manual(values=c("#7CB140", "#FFC000", "#ED7D31")) +
    theme(legend.position="bottom")
  })
  
  output$value <- renderPrint({ 
    h3(input$select)
    x <- 100
    h1(x)
    h3("Average number of transaction")
     })
  
}

# Run the application 
options(shiny.sanitize.errors = TRUE)
shinyApp(ui = ui, server = server)


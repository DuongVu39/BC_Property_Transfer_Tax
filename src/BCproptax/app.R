#
# This is a Shiny web application
# An Exploration of South American countries
#

library(shiny)
library(tidyverse)


# Define UI for application that draws a map and two scatterplot
ui <- fluidPage(
  
  
  titlePanel("British Columbia Property Tax Transfer"),
  
  sidebarLayout(
    sidebarPanel(
      # Display map 
      helpText(h3("Adjust the bar plot")),    
      radioButtons("radio", h3("Choose the year to show life expectancy"),
                   choices = c("1952", "1997", "2007")),
      sliderInput("slider1", h3("Zoooooom"),
                  min = -200, max = 200, value = c(-180,180)),
      br(),
      br(),
      br(),
      # Display 1st scatterplot input method
      helpText(h3("Adjust the scatterplot of South Americas region")),
      
      
      sliderInput("slider2", h3("Year"),
                  min = 1952, max = 2007, value = 1972, 
                  step = 5, sep = "", animate = TRUE),
      helpText("You can click the play button for the map to change automatically"),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      # Display 2nd scatterplot input method
      helpText(h3("Adjust the scatterplot for South American countries")),
      
      checkboxGroupInput("checkGroup", label = h3("Choose country"),
                         #"You can choose one or more country", 
                         choices = c("Argentina","Bolivia","Brazil",
                                     "Chile","Colombia", "Ecuador","Paraguay",
                                     "Peru", "Uruguay","Venezuela"),
                         selected = "Colombia"),
      
      selectInput("select", h3("Select color palette"), 
                  choices = c("Spectral", "BuPu","Reds",
                              "PiYG"))
      
    ),
    
    # Show three plots
    mainPanel(
      h2("The location in the world map"),
      plotOutput("mapPlot"),
      h2("The change of South Americas through years"),
      plotOutput("distPlot2"),
      h2("The change of each South American countries through years"),
      plotOutput("distPlot")
    )
  ))


# Define server logic required 
server <- function(input, output) {
  
  output$mapPlot <- renderPlot({
    
    # draw the map of the world with Americas highlighted
    world <- read.csv("world.csv")
    
    gap_year <- gapminder %>% 
      filter(continent == "Americas") %>% 
      mutate(ISO = countrycode::countrycode(country, "country.name", "iso2c")
      ) %>% 
      filter(year == input$radio)
    
    new_americas <- left_join(world,gap_year, by = "ISO")
    
    ggplot(new_americas) +
      geom_polygon(aes(x = long, y = lat, group = group, fill = lifeExp)) +
      scale_x_continuous(limits = input$slider1) +
      scale_y_continuous(limits = (input$slider1)/2 ) +
      labs(title = "Americas continent colored by life expectancy of each country",
           x = "Latitude",
           y = "Longitude") +
      scale_fill_distiller(palette = "Reds", 
                           direction = 1, 
                           name = "Life Expectancy") +
      theme_bw() 
  })
  
  # draw the change of the whole South Americas region through years
  
  output$distPlot2 <- renderPlot({
    gapyear <- gapminder %>% 
      filter(year == input$slider2,
             country %in% c("Colombia", "Venezuela","Ecuador",
                            "Peru", "Brazil", "Bolivia",
                            "Chile", "Argentina", "Uruguay",
                            "Paraguay"))
    
    
    ggplot(gapyear, aes(gdpPercap, lifeExp, color = country, size = pop)) +
      geom_point(alpha = 0.7) +
      scale_y_continuous(limits = c(0,100))+
      scale_x_continuous(limits = c(1000,15000))+
      scale_size_continuous(range=c(3,18)) +
      labs(title = input$slider2,
           x = "GDP per cap",
           y = "Life Expectancy")+
      theme_light() 
    
  })
  
  
  # draw the change of each South American countries
  output$distPlot <- renderPlot({  
    
    ac <- gapminder %>% 
      filter(continent == "Americas",
             country %in% c(input$checkGroup)) %>%  
      arrange(country, year)
    
    titlegap <- paste(input$checkGroup, collapse = ", ")
    
    ggplot(ac, aes(gdpPercap, lifeExp)) +
      geom_point(aes(color = year), size = 6, alpha = 0.8) +
      scale_y_continuous(limits = c(0,100))+
      scale_x_continuous(limits = c(1000,15000))+
      scale_color_distiller(palette=input$select, direction = 1)+
      geom_path(aes(group = country), size=0.8, alpha = 0.8)+
      labs(title = titlegap,
           x = "GDP per cap",
           y = "Life Expectancy") +
      theme_light() 
  })
  
  
}

# Run the application 
options(shiny.sanitize.errors = TRUE)
shinyApp(ui = ui, server = server)


library(shiny)
library(tidyverse)
library(babynames)
library(rsconnect)

#c("Alabama", "Alaska", "Arizona", "Arkansas", "California")

ui <- fluidPage(selectInput("state", "State:", unique(as.character(covid_cum_2018_pop_est$state)), multiple = TRUE),
                sliderInput("years", "Years:", 2020, 2022, c(2020, 2022), sep = ""),
                submitButton(text = "Apply Changes", icon = NULL, width = NULL),
                plotOutput(outputId = "timeplot"))

server <- function(input, output) { output$timeplot <- renderPlot(covid19_census %>% 
                                                                    filter(state == input$state) %>%
                                                                    ggplot(aes(x = date, y = n)) +
                                                                    geom_line() +
                                                                    scale_x_continuous(limits = input$years) +
                                                                    theme_minimal()
)}
shinyApp(ui = ui, server = server)
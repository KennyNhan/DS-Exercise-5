library(shiny)
library(tidyverse)
library(ggplot2)

covid19 <- read_csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-states.csv")

census_pop_est_2018 <- read_csv("https://www.dropbox.com/s/6txwv3b4ng7pepe/us_census_2018_state_pop_est.csv?dl=1") %>% 
  separate(state, into = c("dot","state"), extra = "merge") %>% 
  select(-dot) %>% 
  mutate(state = str_to_lower(state))

daily_covid <- covid19 %>% 
  mutate(state = str_to_lower(state)) %>% 
  left_join(census_pop_est_2018,
            by = c("state" = "state")) %>% 
  group_by(state) %>% 
  mutate(lag_1 = lag(cases, 1, replace_na(0))) %>% 
  mutate(daily_case = cases-lag_1) %>% 
  mutate(daily_case_prop= (daily_case/est_pop_2018)*100000) %>% 
  ungroup()  %>% 
  arrange(state)

ui <- fluidPage(selectInput("state", "State:", unique(daily_covid$state), multiple = TRUE),
                sliderInput("date", "Dates:", 
                            min = as.Date("2020-01-21","%Y-%m-%d"),
                            max = as.Date("2022-03-29","%Y-%m-%d"),
                            value=c(as.Date("2020-01-21"), as.Date("2022-03-29")),
                            timeFormat="%Y-%m-%d"),
                submitButton(text = "Apply Changes", icon = NULL, width = NULL),
                plotOutput(outputId = "timeplot"))

server <- function(input, output) { output$timeplot <- renderPlot(daily_covid %>% 
                                                                    filter(state %in% input$state) %>% 
                                                                    ggplot(aes(x = date, y = daily_case_prop, color = state)) +
                                                                    labs(y="") +
                                                                    geom_line() +
                                                                    scale_x_date(limits = input$date) +
                                                                    theme_minimal()
)}
shinyApp(ui = ui, server = server)
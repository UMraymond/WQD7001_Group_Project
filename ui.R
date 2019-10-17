##ui.R


library(shiny)
library(tidyverse) ; library(httr) ; library(jsonlite); library(glue)
require("httr")
shinyUI(fluidPage(
  titlePanel("Hello Shiny BNM API!"),
  sidebarLayout(
    sidebarPanel(
      
      selectInput("chosen", label = "Currency Choice", choices = c("USD", "EUR", "RMB"), selected = "USD", multiple = FALSE),
      br(),
      p(strong("Data Set Info:"), "From", code("BNM API"), "online"),
      p("Past 30 days of selected currency with MYR currency.")
    ),
    mainPanel(
      plotOutput("currencyPlot")
    )
  )
  
))

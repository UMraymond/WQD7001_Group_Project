##ui.R

library(shiny); library(shinythemes)
library(tidyverse) ; library(httr) ; library(jsonlite); library(glue); library(ggplot2); library(plotly)
require("httr")
shinyUI(fluidPage(
  theme = shinytheme("darkly"),
  titlePanel(h1("Hello Shiny BNM API!")),
  sidebarLayout(
    sidebarPanel(
      
      selectInput("chosen", label = h3("Currency Choice"), choices = c("USD", "EUR", "SGD", "AUD", "GBP", "EUR", "JPY"), selected = "USD", multiple = FALSE),
      radioButtons("type", label = "Buying/Selling", choices = c("Buying", "Selling"), selected = "Buying"),
      p("Predict the next 10 days price"),
      actionButton("predict", label = "Predict"),
      br(),
      br(),
      p(strong("Data Set Info:"), "From", span("BNM API", style = "color:red"), "online"),
      p("Past 30 days of selected currency with MYR currency."),
      br(),
      h3("Check the gold price"),
      actionButton("check", label = "Check"),
      br(),
      br(),
      radioButtons("gold", label = "Buying/Selling", choices = c("Buying", "Selling"), selected = "Buying"),
      radioButtons("gram", label = "Choose units", choices = c("Ounce", "Gram"), selected = "Ounce"),
      br(),
      br()
    ),
    mainPanel(
      plotlyOutput("currencyPlot"),
      br(),
      plotlyOutput("goldplot")
    )
  )
  
))

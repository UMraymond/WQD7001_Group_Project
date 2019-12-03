##ui.R

library(shiny); library(shinythemes)
library(tidyverse) ; library(httr) ; library(jsonlite); library(glue); library(ggplot2); library(plotly)
require("httr")
shinyUI(fluidPage(
  theme = shinytheme("cerulean"),
  
  titlePanel(h1("Exchange Rates, Gold Prices, Blacklisted Company Checker")),
  sidebarLayout(
    
    sidebarPanel(width = 3,

                 
                 
                 
      selectInput("chosen", label = h3("Currency"), choices = c("USD", "EUR", "SGD", "AUD", "GBP", "EUR", "JPY"), selected = "USD", multiple = FALSE),
      radioButtons("type", label = "Buying/Selling", choices = c("Buying", "Selling"), selected = "Buying"),
      p("Predict the next 10 days price"),
      radioButtons("predict", label = "Prediction", choices = c("Yes", "No"), selected ="No"),

      
      #p("Past 30 days of selected currency with MYR currency."),
      #p("Created by"),
      #p("WQD190007, WQD190025, WQD190026, WQD190044"),

      h3("Gold Price"),
      actionButton("check", label = "Check"),
      radioButtons("gold", label = "Buying/Selling", choices = c("Buying", "Selling"), selected = "Buying"),
      radioButtons("gram", label = "Choose units", choices = c("Ounce", "Gram"), selected = "Ounce"),
      p(strong("User guide:")),
      p("If you want to buy foreign currencies, choose your FC and click 'Buy' to see 1 month historical exchange rates"),
      p("If you want to sell foreign currencies, choose your FC and click 'Sell' to see 1 month historical exchange rates"),
      p("To forecast future exchange rates, select 'Yes' under Predictions"),
      p("To check current gold prices, select 'Buy'/ 'Sell' and the unit desired (Ounce/ Gram) and click 'Check'"),
      p("To check current blacklisted companies, click 'Blacklisted Companies' tab, and type your company name in search bar"),
      br(),
      br(),
      p(strong("Data Set Info:"), "From", span("BNM API", style = "color:red"), "https://api.bnm.gov.my"),
    ),
    mainPanel(
      
      tabsetPanel(type = "tabs",
                  tabPanel("Currency and Gold Plot", plotlyOutput("currencyPlot"), plotlyOutput("goldplot")),
                  tabPanel("Blacklisted Companies", DT::dataTableOutput("mytable")) 
                  
      )
      

    )
  )
  
))

## server.R

library(shiny)
library(tidyverse) ; library(httr) ; library(jsonlite); library(glue); library(ggplot2); library(plotly)
require("httr")

shinyServer(function(input, output){
  output$currencyPlot <- renderPlotly({
    
    
    year = format(Sys.Date(), "%Y")
    currency_code = input$chosen
    month = format(Sys.Date(), "%m")
    session = "1700"
    
    
    path = paste0("https://api.bnm.gov.my/public/exchange-rate/", currency_code, "/", "year/",  year, "/", "month/", month)
    
    response = GET(path, session = session, 
                   accept("application/vnd.BNM.API.v1+json"),
                   user_agent("httr"))
    
    response <- content(response, as = "text", encoding = "UTF-8")
    #response
    
    df <- fromJSON(response, flatten = TRUE) %>% 
      data.frame()
    
    df <- select(df,
                 date = data.rate.date, 
                 currency = data.currency_code, 
                 buying = data.rate.buying_rate,
                 selling = data.rate.selling_rate)
    
    df <- df[order(df$date),]
    #head(df)
    
    p1 <- ggplot(df, aes(x=date, y=buying, group =1)) + geom_line() + geom_point() + geom_smooth(method='lm',formula=y~x) + theme(axis.text.x = element_text(angle = 90, hjust = 1)) + ggtitle(paste(as.character(df$currency[1]), "/MYR currency", sep = "")) +
      theme(plot.title = element_text(hjust = 0.5))
    ggplotly(p1) %>% layout(height = 500, width = 800)
  })
})

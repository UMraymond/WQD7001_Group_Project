## server.R

library(shiny)
library(tidyverse) ; library(httr) ; library(jsonlite); library(glue); library(ggplot2); library(plotly)
require("httr")

shinyServer(function(input, output){
  output$currencyPlot <- renderPlotly({
    
    x = as.numeric(format(Sys.Date(), "%m"))
    year = format(Sys.Date(), "%Y")
    currency_code = input$chosen
    month = list(x, x-1)
    session = "1700"
    
    df = data.frame()
    
    for (i in seq(1,2,1)){
    
    path = paste0("https://api.bnm.gov.my/public/exchange-rate/", currency_code, "/", "year/",  year, "/", "month/", month[i])
    
    response = GET(path, session = session, 
                   accept("application/vnd.BNM.API.v1+json"),
                   user_agent("httr"))
    
    response <- content(response, as = "text", encoding = "UTF-8")
    #response
    
    df1 <- fromJSON(response, flatten = TRUE) %>% 
      data.frame()
    df <- rbind(df,df1)
    }
    
    df <- select(df,
                 date = data.rate.date, 
                 currency = data.currency_code, 
                 Buying = data.rate.buying_rate,
                 Selling = data.rate.selling_rate)
    
    df <- df[order(df$date),]
    #head(df)
    
    p1 <- ggplot(df, aes_string(x="date", y=input$type, group =1)) + geom_line() + geom_point() + geom_smooth(method='lm',formula=y~x) + theme(axis.text.x = element_text(angle = 90, hjust = 1)) + ggtitle(paste(as.character(df$currency[1]), "/MYR currency", sep = "")) +
      theme(plot.title = element_text(hjust = 0.5))
    ggplotly(p1) %>% layout(height = 500, width = 800)
  })
})

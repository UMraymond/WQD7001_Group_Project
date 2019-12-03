#Server

library(shiny)
library(tidyverse) ; library(httr) ; library(jsonlite); library(glue); library(ggplot2); library(plotly)
require("httr")
library(lubridate)
library(DT)
# function t use below
bnm_api <- function(path, ...) {
  GET("https://api.bnm.gov.my",
      path = glue("public{path}"),
      ...,
      accept("application/vnd.BNM.API.v1+json"),
      user_agent("http://github.com/philip-khor/bnmr/")
  ) -> resp
  
  parsed <- fromJSON(content(resp, "text", encoding = "UTF-8"))
  
  if (http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }
  
  if (http_error(resp)) {
    stop(
      sprintf(
        "BNM API request failed [%s]\n%s\n<%s>",
        status_code(resp),
        parsed$message,
        parsed$documentation_url
      ),
      call. = TRUE
    )
  }
  
  structure(
    list(
      content = parsed,
      path = path,
      response = resp
    ),
    class = "bnm_api"
  )
}

get_bnm_data <- function(path, ...) {
  bnm_api(path, ...)[["content"]][["data"]]
}

consumer_alert <- function() get_bnm_data("/consumer-alert")


shinyServer(function(input, output){
  output$currencyPlot <- renderPlotly({
    #gold_plot()
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
    df$date <- as.Date(df$date)
    
    if (input$predict == "Yes"){
      p1 <- ggplot(df, aes_string(x="date", y=input$type, group =1)) + geom_line() + geom_point() + stat_smooth(method='lm',fullrange = TRUE) + theme(axis.text.x = element_text(angle = 90, hjust = 1)) + xlim(df$date[1],df$date[length(df$date)]+days(10)) + ggtitle(paste(as.character(df$currency[1]), "/MYR currency", sep = "")) + theme(plot.title = element_text(hjust = 0.5))
      ggplotly(p1, tooltip = c("date", input$type)) %>% layout(height = 350, width = 800)}
    else {
      p1 <- ggplot(df, aes_string(x="date", y=input$type, group =1)) + geom_line() + geom_point() + theme(axis.text.x = element_text(angle = 90, hjust = 1)) + ggtitle(paste(as.character(df$currency[1]), "/MYR currency", sep = "")) + theme(plot.title = element_text(hjust = 0.5))
      ggplotly(p1, tooltip = c("date", input$type)) %>% layout(height = 350, width = 800)}
  })
  
  
  gold_plot <- eventReactive(input$check, {
    runif(input$check)
  })
                             
                             
  output$goldplot <- renderPlotly({ 
    gold_plot()
    x = as.numeric(format(Sys.Date(), "%m"))
    year = format(Sys.Date(), "%Y")
    month = list(x, x-1)
    session = "1700"
    
    df_gold = data.frame()
    
    for (i in seq(1,2,1)){
      
      path_gold = paste0("https://api.bnm.gov.my/public/kijang-emas/year/", year, "/month/", month[i])
      
      response_gold = GET(path_gold, session = session, 
                     accept("application/vnd.BNM.API.v1+json"),
                     user_agent("httr"))
      
      response_gold <- content(response_gold, as = "text", encoding = "UTF-8")
      #response_gold
      
      df1_gold <- fromJSON(response_gold, flatten = TRUE) %>% 
        data.frame()
      df_gold <- rbind(df_gold,df1_gold)
    }
    
    df_gold <- select(df_gold,
                 date = data.effective_date, 
                 Buying_in_Ounce = data.one_oz.buying,
                 Selling_in_Ounce = data.one_oz.selling)
    df_gold <- mutate(df_gold,
                 Buying_in_Gram = Buying_in_Ounce/28.34952,
                 Selling_in_Gram = Selling_in_Ounce/28.34952)
  
    df_gold <- df_gold[order(df_gold$date),]
    #head(df)
    p2 <- ggplot(df_gold, aes_string(x="date", y=paste0(input$gold, "_in_", input$gram), group =1)) + geom_line() + geom_point() + theme(axis.text.x = element_text(angle = 90, hjust = 1)) + ggtitle("Gold Price (MYR)") +
      theme(plot.title = element_text(hjust = 0.5))
    ggplotly(p2) %>% layout(height = 350, width = 800)
   
  })
  data1 <- consumer_alert()
  
  output$mytable = DT::renderDataTable({
    DT::datatable(data1, rownames = FALSE, options = list(autoWidth = TRUE)) %>%
      formatStyle(columns = c("name", "regisration_number", 
                              "added_date", "websites"),
                  target = c("cell", "row"), backgroundColor = "#FFFFFF") 
    
  })
    
})

library(plotly)
library(wordcloud)
shinyServer(function(input, output){
  source("helpers.R")
  hansard_df = getWrittenQuestions(50)
  bag = makeBagOfWords(hansard_df, "question")

  people = hansard_df %>%
    group_by(member) %>%
    summarise(questions = n()) %>%
    as.data.frame() %>%
    arrange(desc(questions))
  
  dates = hansard_df %>%
    group_by(date) %>%
    summarise(questions = n())
  
  output$wordcloud <- renderPlot({
    wordcloud(bag$words, bag$freq, max.words = input$wordsToDisplay)
  })
  
  output$words_barchart <- renderPlotly({
    plot_ly(bag[1:input$wordsBarChart,], y = words, x = freq, type="bar", orientation = "h")
    
  })
  
  output$member_barchart <- renderPlotly({
    plot_ly(people[1:15,], y = member, x = questions, type="bar", orientation = "h")
  })
  
  output$date_linechart <- renderPlotly({
    all_dates = data.frame(date = seq(min(dates$date), max(dates$date), by = 'days')) %>%
      left_join(dates)
    all_dates[is.na(all_dates$questions), 'questions'] <- 0
    
    plot_ly(all_dates, x = date, y = questions)
  })
    
  
})
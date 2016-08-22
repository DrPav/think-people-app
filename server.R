library(plotly)
library(wordcloud)
shinyServer(function(input, output){
  source("helpers.R")
  
  hansardDF <- reactive({
    getWrittenQuestions(input$number_of_questions)
  })
  
  bag <- reactive({
    makeBagOfWords(hansardDF(), "question")
  })
  
  people <- reactive({
    hansardDF() %>%
      group_by(member) %>%
      summarise(questions = n()) %>%
      as.data.frame() %>%
      arrange(desc(questions))
  })

  
  dates <- reactive({
    hansardDF() %>%
      group_by(date) %>%
      summarise(questions = n())
  })
  
  
  output$wordcloud <- renderPlot({
    x = bag()
    wordcloud(x$words, x$freq, max.words = input$wordsToDisplay)
  })
  
  output$words_barchart <- renderPlotly({
    b = bag()
    plot_ly(b[1:input$wordsBarChart,], y = words, x = freq, type="bar", orientation = "h")
    
  })
  
  output$member_barchart <- renderPlotly({
    p = people()
    plot_ly(p[1:15,], y = member, x = questions, type="bar", orientation = "h")
  })
  
  output$date_linechart <- renderPlotly({
    d = dates()
    all_dates = data.frame(date = seq(min(d$date), max(d$date), by = 'days')) %>%
      left_join(d)
    all_dates[is.na(all_dates$questions), 'questions'] <- 0
    
    plot_ly(all_dates, x = date, y = questions)
  })
    
  output$dataTable <- renderDataTable(hansardDF(), escape = F, options = list(pageLength = 5))
  
})
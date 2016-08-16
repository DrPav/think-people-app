library(plotly)
shinyUI(navbarPage("Example dashboard",
                   tabPanel("Parlimentary questions",
                            fluidPage(
                              wellPanel(
                                fluidRow(
                                  column(4, offset = 1,
                                         selectInput("question_type",
                                                     label = "Type of parlimentary question",
                                                     choices = c("Commons written question",
                                                                 "Commons oral question",
                                                                 "Lords written question",
                                                                 "Lords oral question"))),
                                  column(7,
                                         numericInput("number_of_questions",
                                                      "How far back to go (Number of questions to analyse)",
                                                      value = 50,
                                                      max = 500,
                                                      min = 1))
                                )
                                
                              ),
                              fluidRow(
                                column(5, offset = 1,
                                       plotOutput("wordcloud")),
                                column(5,
                                       plotlyOutput("words_barchart"))
                              ),
                              wellPanel(
                                fluidRow(column(4, offset = 1,
                                               numericInput("wordsToDisplay",
                                                            "How many words to display in the wordcloud?",
                                                            value = 50)),
                                         column(4,
                                                numericInput("wordsBarChart",
                                                             "How many words to plot in the bar chart?",
                                                             value = 15))
                                         )
                              ),
                              fluidRow(
                                column(5, offset = 1,  plotlyOutput("member_barchart")),
                                column(5, plotlyOutput("date_linechart"))
                              )
                            
                            )),
                   tabPanel("Twitter")
))
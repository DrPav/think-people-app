library(plotly)
shinyUI(navbarPage("Example dashboard",
                   tabPanel("Parlimentary questions",
                            fluidPage(
                              wellPanel(
                                fluidRow(
                                  column(4, offset = 1,
                                         selectInput("question_type",
                                                     label = "Type of parlimentary questions",
                                                     choices = list("Commons written questions" = "commonswrittenquestions",
                                                                 "Commons oral questiosn" = "commonsoralquestions",
                                                                 "Lords written questions" = "lordswrittenquestions"))),
                                                                 #"Lords oral questions"))), #Doesn't exist yet
                                  column(7,
                                         numericInput("number_of_questions",
                                                      "How far back to go (Number of questions to analyse, max 500)",
                                                      value = 25,
                                                      max = 500,
                                                      min = 1, 
                                                      step = 25))
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
                                         ),
                                fluidRow(column(10, offset = 1,
                                                "The following words have been removed; ask, secretary, state, transport, department, majesty's, government, plus all common stopwords in English (the, at, too, me, I, he....)"))
                              ),
                              fluidRow(
                                column(5, offset = 1,  plotlyOutput("member_barchart")),
                                column(5, plotlyOutput("date_linechart"))
                              ),
                              br(),
                              hr(),
                              h3("Explore the data"),
                              br(),
                              fluidRow(
                                column(5, offset = 1,
                                       dataTableOutput("dataTable"))
                              ),
                              hr(),
                              fluidRow(column(10, offset = 1,
                                              p("Data taken from the ", 
                                                a("Hansard API", href = "http://explore.data.parliament.uk/")),
                                              p("Code and contact details are on ", 
                                                a("Github", href = "https://github.com/DrPav/think-people-app"))
                                              
                              ))
                              
                            
                            )),
                   tabPanel("Twitter", "Possible expansion analysing words from Twitter API")
))
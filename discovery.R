library(jsonlite)
library(dplyr)
library(tm)
library(wordcloud)
library(plotly)
library(lubridate)
#Getting the data
#http://explore.data.parliament.uk/
#There are Lords/commons written/oral questions
#Take commons written for now
#===================================================
#Downnoad written questions and loads as JSON using jsonlite package
#Set the page size up to 500. Longer is slower
#Filtered to the department for transport and sorted in reverse chronological (newest first)
url = "http://lda.data.parliament.uk/commonswrittenquestions.json?_pageSize=100&_page=0&AnsweringBody=Department%20for%20Transport&_sort=-dateTabled"
temp_file = "hansardData.json"
download.file(url, temp_file, method = "auto")
json = fromJSON(temp_file)

#Convert columns of interest into dataframe
data= json$result$items
questions = data$questionText
dates = data$dateTabled$`_value`
uins = data$uin #Unique identifier
members = data$tablingMember$label$`_value` #Remove the Biography... prefix
members = sub("Biography information for ", "", members)

commons_written_questions = data.frame(member = members,
                                       date = dates,
                                       question = questions,
                                       uin = uins)
#Clean up temporary data
rm(url, json, data, questions, dates, uins, members)

#==========================================================
#Create bag of words (identified on first pass)
common_words = c("ask",
                 "secretary",
                 "state",
                 "transport",
                 "department",
                 "(a)",
                 "(b)",
                 "(c)")
removeHtmlTags <- function(htmlString) {
  return(gsub("<.*?>", "", htmlString))
}

vc = VCorpus(VectorSource(commons_written_questions$question))
vc = tm_map(vc, stripWhitespace) %>%
  tm_map(content_transformer(tolower)) %>%
  tm_map(removeWords, stopwords("english")) %>%
  tm_map(removeWords, common_words) %>%
  tm_map(content_transformer(removeHtmlTags)) %>%
  tm_map(removePunctuation) 

#Count the words in each document. 
#Sparsity is set to 98%, so words can apppear in less than 98% of docs.
#With a 100 docs this means they appear in at least 2
bag = TermDocumentMatrix(vc) %>% 
  removeSparseTerms(0.98) %>% 
  as.matrix()
bag = data.frame( words = rownames(bag), freq = rowSums(bag)) %>%
  arrange(desc(freq))



#Make a word cloud
wordcloud(bag$words, bag$freq)

#Plot bar chart of who asked the questions
people = commons_written_questions %>%
  group_by(member) %>%
  summarise(questions = n()) %>%
  as.data.frame() %>%
  arrange(desc(questions))


#take top 15 people
plot_ly(people[1:15,], y = member, x = questions, type="bar", orientation = "h")


#Plot word counts
plot_ly(bag[1:15,], y = words, x = freq, type="bar", orientation = "h")

#Plot timeline somewhow
commons_written_questions$date = ymd(commons_written_questions$date)
dates = commons_written_questions %>%
  group_by(date) %>%
  summarise(questions = n()) %>%
  arrange(date) 
plot_ly(dates, x = date, y = questions)

#Show the data



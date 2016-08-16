#Functions
#Get written questions and return the dataframe
#NNumber of questions can be between 1 and 500
getWrittenQuestions <- function(number_of_questions){
  require(jsonlite)
  #Downnoad written questions and loads as JSON using jsonlite package
  #Set the page size up to 500. Longer is slower
  #Filtered to the department for transport and sorted in reverse chronological (newest first)
  
  temp_file = "hansardData.json" #Need to download somewhere
  
  prefix = "http://lda.data.parliament.uk/commonswrittenquestions.json?_pageSize="
  suffix = "&_page=0&AnsweringBody=Department%20for%20Transport&_sort=-dateTabled"
  url = paste0(prefix, number_of_questions, suffix)
  
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
  return(commons_written_questions)
}

makeBagOfWords <- function(hansard_df, text_col_name){
  #Create bag of words 
  require(tm)
  #Common words identified manually in discovery
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
  
  return(bag)
  
}
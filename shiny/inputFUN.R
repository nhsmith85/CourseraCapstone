

library(stringr)
library(tm)
library(googleVis)
library(wordcloud)

# load word rankings database
load("pred.RData")

# load gram frequency dataframes
load("freq.RData")

# Function for decomposing the input sentence
predict <- function(input) {
  
  phrase <- input
  # CLEANING THE INPUT PHRASE
  # remove numbers
  phrase <- removeNumbers(phrase)
  # remove punctuation
  phrase <- removePunctuation(phrase)
  # put in lower case
  phrase <- tolower(phrase)
  # remove white space
  phrase <- stripWhitespace(phrase)
  
  # splitting the cleaned phrase up into individual words
  w <- unlist(str_split(phrase, " "))
  len <- length(w)
  
  # remove space at end of sentence if typed
  if ( w[len] == "") {
      w <- w[-c(len)]
      len <- length(w) # reset the length after the change
  }
  
  # setting default selection
  match <- pred1
  
  # if 3 or more words are input
  if ( len >= 3 ){
    # Use the 4-gram to predict from the 3-gram input
    combine <- paste( w[len-2], w[len-1], w[len] )
    match <- pred4[pred4$match == combine,]
    
        # Use the 3-gram to predict from the 2-gram input remaining
        if( nrow(match) < 5 ) {   # if there are fewer than 5 matches
            combine <- paste( w[len-1], w[len] ) 
            match <- rbind( match, pred3[pred3$match == combine,] ) # stack first selection on top of second
        }
        # Use the 2-gram to predict from the 1-gram input remaining
        if( nrow(match) < 5 ){ 
            combine <- paste( w[len] )
            match <- rbind( match, pred2[pred2$match == combine,] ) # stack first selection on top of second
            match <- rbind( match, pred1)  # stack uni on bottom in case no matches
        }
  }
  # if 2 words are input
  if ( len == 2){
      # Use the 3-gram to predict from the the 2-gram input
      combine <- paste( w[len-1], w[len] )
      match <- pred3[pred3$match == combine,]
        # Use the 2-gram to predict from the 1-gram input remaining
        if( nrow(match) < 5 ){  # if there are fewer than 5 matches
          combine <- paste( w[len] )
          match <- rbind( match, pred2[pred2$match == combine,] )
          match <- rbind( match, pred1)
      }    
  }
  # if 1 word is input
  if ( len == 1){
      # Use the 2-gram to predict from the 1-gram input
      combine <- paste( w[len] )
      match <- pred2[pred2$match == combine,]
      match <- rbind( match, pred1 )
  }
    
  match <- unique(match$pred)
  match[1:5]
}









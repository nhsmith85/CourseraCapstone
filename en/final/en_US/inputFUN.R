

library(stringr)
library(tm)

# load word rankings (still need to make this)
load("wordRank.rdata")

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
  #wsRem <- function(x) return(gsub("^ *|(?<= ) | *$", "", x, perl=T))
  phrase <- stripWhitespace(phrase)
  
  # splitting the cleaned phrase up into individual words
  w <- unlist(str_split(phrase, " "))
  len <- length(w)
  
  # if 3 of more words are input
  if ( len >= 3 ){
    # Use the 4-gram to predict from the 3-gram input
    combine <- paste( w[len-2], w[len-1], w[len] )
    match <- pred4[pred4$match == combine,]
    
        # Use the 3-gram to predict from the 2-gram input remaining
        if( nrow(match) == 0 ) {
            combine <- paste( w[len-1], w[len] ) 
            match <- pred3[pred3$match == combine,]
        }
        # Use the 2-gram to predict from the 1-gram input remaining
        if( nrow(match) == 0){ 
            combine <- paste( w[len] )
            match <- pred2[pred2$match == combine,]
        }
  }
  # if 2 words are input
  if ( len == 2){
      # Use the 3-gram to predict from the the 2-gram input
      combine <- paste( w[len-1], w[len] )
      match <- pred3[pred3$match == combine,]
        # Use the 2-gram to predict from the 1-gram input remaining
        if( nrow(match) == 0){
          combine <- paste( w[len] )
          match <- pred2[pred2$match == combine,]
      }    
  }
  # if 1 word is input
  if ( len == 1){
      # Use the 2-gram to predict from the 1-gram input
      combine <- paste( w[len] )
      match <- pred2[pred2$match == combine,]
  }
  
  # if there is no match anywhere then recommend the top 5 unigrams
  if( is.null(nrow(match)) ){
      match <- pred1$pred[1:5]
  }

  match$pred

}

# need to delete the last white space if user ends with a space



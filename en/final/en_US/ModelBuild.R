
#############################
####### SAMPLING DATA #######
# see getting data file for first iteration and for download code

setwd("/Users/nathansmith/CourseraCapstone/en/final/en_US")
news <- readLines("en_US.news.txt", skipNul = T)
blogs <- readLines("en_US.blogs.txt", skipNul = T)
twit <- readLines("en_US.twitter.txt", skipNul = T)

# Sampling
set.seed(300)
Snews <- sample(news, size = 10000) # random sample of 10,000 lines
write(Snews,"ModelSample/en_US.news.sample.txt")
set.seed(322)
Sblogs <- sample(blogs, size=10000)
write(Sblogs,"ModelSample/en_US.blogs.sample.txt")
set.seed(323)
Stwit <- sample(twit, size=10000)
write(Stwit,"ModelSample/en_US.twitter.sample.txt")

rm(news);rm(blogs);rm(twit)

# if coming back to this script use readlines to get the sampled back into R
Sample <- c(Snews, Sblogs, Stwit)
str(Sample)

##############################
##### MAKING THE CORPUS ######
library(tm)
myCorpus <- Corpus(VectorSource(Sample))

# CUSTOM REMOVALS
toSpace <- content_transformer(function(x, pattern) gsub(pattern, "", x))
# remove URLs
myCorpus <- tm_map(myCorpus, toSpace, "(f|ht)tp(s?)://(.*)[.][a-z]+")
# removing / and @
myCorpus <- tm_map(myCorpus, toSpace,  "/|@|\\|")
# remove retweet and via labels
myCorpus <- tm_map(myCorpus, toSpace, "RT |via ")

# STANDARD REMOVALS  (leaving stopwords in)
myCorpus <- tm_map(myCorpus, content_transformer(tolower))
myCorpus <- tm_map(myCorpus, removePunctuation)
myCorpus <- tm_map(myCorpus, removeNumbers)

# PROFANITY FILTERING
url <- "http://www.frontgatemedia.com/new/wp-content/uploads/2014/03/Terms-to-Block.csv"
if (!file.exists("profanity.csv")) {
    download.file(url, destfile = "profanity.csv", method = "curl")
}
profanity <- read.csv("profanity.csv", stringsAsFactors=FALSE, skip = 3)
profanity <- profanity[,2]
profanity <- unlist(gsub(",", "", profanity))
profanity <- unique(profanity)
myCorpus <- tm_map(myCorpus, removeWords, profanity)

# WHITESPACE REMOVAL
myCorpus <- tm_map(myCorpus, stripWhitespace)


###############################
#### EXPLORATORY ANALYSIS #####
library(tm)
library(RWeka)

# tokenizers
options(mc.cores=1)
UniGramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 1, max = 1))
BiGramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 2, max = 2))
TriGramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 3, max = 3))
QuadGramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 4, max = 4))
    
# make DTMs
uni.DTM <- DocumentTermMatrix(myCorpus, control = list(tokenize = UniGramTokenizer))
bi.DTM <- DocumentTermMatrix(myCorpus, control = list(tokenize = BiGramTokenizer))
tri.DTM <- DocumentTermMatrix(myCorpus, control = list(tokenize = TriGramTokenizer))
quad.DTM <- DocumentTermMatrix(myCorpus, control = list(tokenize = QuadGramTokenizer))

# remove sparse terms
uni.sparse <- removeSparseTerms(uni.DTM, 0.999)
bi.sparse <- removeSparseTerms(bi.DTM, 0.999)
tri.sparse <- removeSparseTerms(tri.DTM, 0.999)
quad.sparse <- removeSparseTerms(quad.DTM, 0.999)
rm(uni.DTM,bi.DTM,tri.DTM, quad.DTM)

# find frequency rankings
uni.freq <- sort(colSums(as.matrix(uni.sparse)), decreasing=TRUE)
bi.freq <- sort(colSums(as.matrix(bi.sparse)), decreasing=TRUE)
tri.freq <- sort(colSums(as.matrix(tri.sparse)), decreasing=TRUE)
quad.freq <- sort(colSums(as.matrix(quad.sparse)), decreasing=TRUE)

head(uni.freq,25)
head(bi.freq,25)
head(tri.freq,25)
head(quad.freq,25)

str(uni.freq)







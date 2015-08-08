
#############################
####### SAMPLING DATA #######
# see getting data file for first iteration and for download code

setwd("/Users/nathansmith/CourseraCapstone/en/final/en_US")
news <- readLines("en_US.news.txt", skipNul = T)
blogs <- readLines("en_US.blogs.txt", skipNul = T)
twit <- readLines("en_US.twitter.txt", skipNul = T)

# Sampling
set.seed(300)
Snews <- sample(news, size = 50000) # random sample of 50,000 lines
write(Snews,"ModelSample/en_US.news.sample.txt")
set.seed(322)
Sblogs <- sample(blogs, size = 50000)
write(Sblogs,"ModelSample/en_US.blogs.sample.txt")
set.seed(323)
Stwit <- sample(twit, size = 50000)
write(Stwit,"ModelSample/en_US.twitter.sample.txt")

rm(news);rm(blogs);rm(twit)

# if coming back to this script use readlines to get the sampled back into R
setwd("./ModelSample")
Snews <- readLines("en_US.news.sample.txt", skipNul = T)
Sblogs <- readLines("en_US.blogs.sample.txt", skipNul = T)
Stwit <- readLines("en_US.twitter.sample.txt", skipNul = T)

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
bi.sparse <- removeSparseTerms(bi.DTM, 0.9999) # extending the possible list
tri.sparse <- removeSparseTerms(tri.DTM, 0.9999) # extending the possible list
quad.sparse <- removeSparseTerms(quad.DTM, 0.9999) # extending the possible list
rm(uni.DTM,bi.DTM,tri.DTM, quad.DTM)

# find frequency rankings
uni.freq <- sort(colSums(as.matrix(uni.sparse)), decreasing=TRUE)
bi.freq <- sort(colSums(as.matrix(bi.sparse)), decreasing=TRUE)
tri.freq <- sort(colSums(as.matrix(tri.sparse)), decreasing=TRUE)
quad.freq <- sort(colSums(as.matrix(quad.sparse)), decreasing=TRUE)

head(uni.freq,25)
head(bi.freq,25)
head(tri.freq,75)
head(quad.freq,50)

str(tri.freq)
bi.freq[2]
bi.freq.df <- as.data.frame(bi.freq)
head(bi.freq.df)
str(bi.freq.df)
names(bi.freq)

# split tokened n grams and unlist so you can search for a match on the first three letters and return the final one?

library(qdap)

# 4-gram data frame assembly
df4 <- colsplit2df(data.frame(names(quad.freq)), sep = " ")
df4$minus <- paste( df4[,1], df4[,2], df4[,3])
pred4 <- data.frame( match=df4$minus, pred=df4$X4, freq=unname(quad.freq), stringsAsFactors = FALSE)
str(pred4)
head(pred4)

# 3-gram data frame assembly
df3 <- colsplit2df(data.frame(names(tri.freq)), sep = " ")
df3$minus <- paste( df3[,1], df3[,2])
pred3 <- data.frame( match=df3$minus, pred=df3$X3, freq=unname(tri.freq), stringsAsFactors = FALSE)
str(pred3)
head(pred3)

# 2-gram data frame assembly
df2 <- colsplit2df(data.frame(names(bi.freq)), sep = " ")
df2$minus <- paste( df2[,1] )
pred2 <- data.frame( match=df2$minus, pred=df2$X2, freq=unname(bi.freq), stringsAsFactors = FALSE)
str(pred2)
head(pred2)

# 1-gram data frame assembly
pred1 <- data.frame(match=names(uni.freq), pred=names(uni.freq), freq=unname(uni.freq), stringsAsFactors = FALSE)
head(pred1)

save(pred4,pred3,pred2,pred1, file = "pred.RData")

predict("I have seen them in quite some")
predict("bacon and a case of")
predict("romantic date at the")
predict("library doesn't")
tail(tri.freq)
tail(quad.freq)
predict("what are your plans for the") 
# still only giving one option, need to move down an n-gram also to give more suggestions

getwd()
setwd("/Users/nathansmith/CourseraCapstone/en/final/en_US")
load("pred.RData")
str(pred.Rdata)
rm(pred1,pred2,pred3,pred4)


install.packages("shinythemes")


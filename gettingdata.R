
#########################################
#### GETTING and SAMPLING THE DATA ######

### Obtaining the data from the coursera site
url <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"
if (!file.exists("/Users/nathansmith/CourseraCapstone/Coursera-Swiftkey.zip")){
    download.file(url, destfile="/Users/nathansmith/CourseraCapstone/Coursera-Swiftkey.zip", method="curl")
}

# unzipping the files we want (english)
getwd()
(files <- unzip("Coursera-SwiftKey.zip", list=T)) # list the files in the zipped folder
enIndex <- grep("en", files$Name) # grabs the index of all the names that start with "en"
unzip("Coursera-SwiftKey.zip", files=files[enIndex,1], exdir = "/Users/nathansmith/CourseraCapstone/en")
list.files("/Users/nathansmith/CourseraCapstone/en/final/en_US")

# read raw datasets into R and get some simple stats on each file
setwd("/Users/nathansmith/CourseraCapstone/en/final/en_US")
news <- readLines("en_US.news.txt", skipNul = T)
size_of_news <- format(object.size(news), units = "Mb")
news_line_count <- length(news)
blogs <- readLines("en_US.blogs.txt", skipNul = T)
size_of_blogs <- format(object.size(blogs), units = "Mb")
(blog_line_count <- length(blogs))
twit <- readLines("en_US.twitter.txt", skipNul = T)
size_of_twit <- format(object.size(twit), units = "Mb")
(twit_line_count <- length(twit))

# number of characters per line
summary( nchar(news)    )
summary( nchar(blogs)   )
summary( nchar(twit)    )

# stats on line counts and total number of characters
library(stringi)
( news.stats  <- stri_stats_general(news) )
( blogs.stats <- stri_stats_general(blogs) )
( twit.stats <- stri_stats_general(twit) )

# number of words in a string
summary( news.W.count   <- stri_count_words(news) )
summary( blogs.W.count   <- stri_count_words(blogs) )
summary( twit.W.count <- stri_count_words(twit) )

par(mfrow=c(1,3))
hist(news.W.count, breaks=100, main="News word count",xlab="no. of words")
hist(blogs.W.count, breaks=100, main="Blogs word count", xlab="no. of words")
hist(twit.W.count, breaks=100, main="Twitter word count", xlab="no. of words")


# saving off random samples of each data set
# news
set.seed(300)
Snews <- sample(news, size = 50000) # random sample of 50,000 lines
if (!file.exists("sample/en_US.news.sample.txt")) {
    write(Snews,"sample/en_US.news.sample.txt")
}
rm(Snews);rm(news)
# blogs
set.seed(322)
Sblogs <- sample(blogs, size=50000)
if (!file.exists("sample/en_US.blogs.sample.txt")) {
    write(Sblogs,"sample/en_US.blogs.sample.txt")
}
rm(Sblogs);rm(blogs)
# twitter
set.seed(323)
Stwit <- sample(twit, size=50000)
if (!file.exists("sample/en_US.twitter.sample.txt")) {
    write(Stwit,"sample/en_US.twitter.sample.txt")
}
rm(Stwit);rm(twit)


#################################################
#### CREATING A CORPUS DATABASE FROM SAMPLES ####

library(filehash)
library(tm)
myCorpus <- PCorpus(DirSource("sample"), dbControl = list( dbName = "sampleCorpusDB1.db", dbType="DB1"))

# new database used for making transformations on
TransCorpus <- PCorpus(DirSource("sample"), dbControl = list( dbName = "TransCorpus.db", dbType = "DB1"))
file.remove("/Users/nathansmith/CourseraCapstone/en/final/en_US/TransCorpus.db")
# custom removals
toSpace <- content_transformer(function(x, pattern) gsub(pattern, "", x))
# remove URLs
TransCorpus <- tm_map(TransCorpus, toSpace, "(f|ht)tp(s?)://(.*)[.][a-z]+")
# removing / and @
TransCorpus <- tm_map(TransCorpus, toSpace,  "/|@|\\|")
# remove retweet and via labels
TransCorpus <- tm_map(TransCorpus, toSpace, "RT |via ")

# standard removals
TransCorpus <- tm_map(TransCorpus, content_transformer(tolower))
TransCorpus <- tm_map(TransCorpus, removeWords, stopwords("english"))
TransCorpus <- tm_map(TransCorpus, removePunctuation)
TransCorpus <- tm_map(TransCorpus, removeNumbers)

# profanity filtering 
# http://www.frontgatemedia.com/a-list-of-723-bad-words-to-blacklist-and-how-to-use-facebooks-moderation-tool/
url <- "http://www.frontgatemedia.com/new/wp-content/uploads/2014/03/Terms-to-Block.csv"
download.file(url, destfile = "profanity.csv", method = "curl")
profanity <- read.csv("profanity.csv", stringsAsFactors=FALSE, skip = 3)
head(profanity)
profanity <- profanity[,2]
profanity <- unlist(gsub(",", "", profanity))
profanity <- unique(profanity)
head(profanity)
TransCorpus <- tm_map(TransCorpus, removeWords, profanity)

# last step of removals is to remove extra whitespace
TransCorpus <- tm_map(TransCorpus, stripWhitespace)


####################################
#### Exploratory Data Analysis ####

# Tasks to accomplish
# Exploratory analysis - perform a thorough exploratory analysis of the data, understanding the distribution of words 
# and relationship between the words in the corpora. 
# Understand frequencies of words and word pairs - build figures and tables to understand variation in the 
# frequencies of words and word pairs in the data.

# Questions to consider
# Some words are more frequent than others - what are the distributions of word frequencies? 
# What are the frequencies of 2-grams and 3-grams in the dataset? 
# How many unique words do you need in a frequency sorted dictionary to cover 50% of all word instances in the language? 
# 90%? 
# How do you evaluate how many of the words come from foreign languages? 
# Can you think of a way to increase the coverage -- identifying words that may not be in the corpora or using 
# a smaller number of words in the dictionary to cover the same number of phrases?

library(tm)
library(RWeka)
library(wordcloud)
library(ggplot2)
library(RColorBrewer)
library(filehash)
install.packages("ProjectTemplate")
library("ProjectTemplate")
pal <- brewer.pal(8, "Dark2")
# if coming back to file, will need to initialize the database
dbInit("TransCorpus.db")
db.reader("TransCorpus.db", ".", TransCorpus)

# tokenizers
options(mc.cores=1)
BiGramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 2, max = 2))
TriGramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 3, max = 3))

## NEWS ###############
news.dtm <- DocumentTermMatrix(VCorpus(VectorSource(TransCorpus[[2]]$content)))
news.dtm.sparse <- removeSparseTerms(news.dtm, 0.999)
rm(news.dtm)
news.freq <- sort(colSums(as.matrix(news.dtm.sparse)), decreasing=TRUE)
head(news.freq,50)
hist(news.freq, breaks = 500)
setwd("./graphs")
dev.copy(png, "news-uni-cloud.png")
wordcloud(names(news.freq), news.freq, min.freq=100, max.words=100, colors=pal)
dev.off()
dev.copy(png, "news-uni-bar.png")
barplot(news.freq[1:25], las = 2, col ="lightblue", main ="Most frequent words", ylab = "Word frequencies")
dev.off()
findAssocs(news.dtm.sparse, "said", corlimit=0.2)
rm(news.dtm.sparse)

# news bi-gram
setwd("/Users/nathansmith/CourseraCapstone/en/final/en_US")
news.dtm.bi <- DocumentTermMatrix(VCorpus(VectorSource(TransCorpus[[2]]$content)), 
                                  control=list(tokenize = BiGramTokenizer))
news.dtm.bi.sparse <- removeSparseTerms(news.dtm.bi, 0.999)
rm(news.dtm.bi)
news.bi.freq <- sort(colSums(as.matrix(news.dtm.bi.sparse)), decreasing=TRUE)
head(news.bi.freq,20)
hist(news.bi.freq, breaks = 500)
dev.copy(png, "./graphs/news-bi-cloud.png")
wordcloud(names(news.bi.freq), news.bi.freq, min.freq=100, max.words=100)
dev.off()
dev.copy(png, "./graphs/news-bi-bar.png")
par(mar=c(5.1,4.1,4.1,2.1))
barplot(news.bi.freq[1:25], las = 2, col ="lightblue", 
        main ="News Bi-Gram Word Frequency", ylab = "Word frequencies", horiz=FALSE)
dev.off()
findAssocs(news.dtm.bi.sparse, "last year", corlimit=0.2)
# news tri-gram
news.dtm.tri <- DocumentTermMatrix(VCorpus(VectorSource(TransCorpus[[2]]$content)), 
                                   control=list(tokenize = TriGramTokenizer))
news.dtm.tri.sparse <- removeSparseTerms(news.dtm.tri, 0.999)
rm(news.dtm.tri)
news.tri.freq <- sort(colSums(as.matrix(news.dtm.tri.sparse)), decreasing=TRUE)
head(news.tri.freq,10)
hist(news.tri.freq, breaks = 500)
wordcloud(names(news.tri.freq), news.tri.freq, min.freq=100, max.words=100)
barplot(news.tri.freq[1:25], las = 2, col ="lightblue", main ="Most frequent words", ylab = "Word frequencies")

## BLOGS #################
# blogs uni-gram
blogs.dtm <- DocumentTermMatrix(VCorpus(VectorSource(TransCorpus[[1]]$content)))
blogs.dtm.sparse <- removeSparseTerms(blogs.dtm, 0.999)
blogs.freq <- sort(colSums(as.matrix(blogs.dtm.sparse)), decreasing=TRUE)
head(blogs.freq,50)
hist(blogs.freq, breaks = 500)
dev.copy(png, "./graphs/blogs-cloud.png")
wordcloud(names(blogs.freq), blogs.freq, min.freq=100, max.words=100)
dev.off()
dev.copy(png, "./graphs/blogs-bar.png")
barplot(blogs.freq[1:25], las = 2, col ="lightblue", main ="Most frequent words", ylab = "Word frequencies")
dev.off()
findAssocs(blogs.dtm, "one", corlimit=0.9)
rm(blogs.dtm)
rm(blogs.dtm.sparse)
# blogs bi-gram
blogs.dtm.bi <- DocumentTermMatrix(VCorpus(VectorSource(TransCorpus[[1]]$content)), 
                                   control=list(tokenize = BiGramTokenizer))
blogs.dtm.bi.sparse <- removeSparseTerms(blogs.dtm.bi, 0.999)
blogs.bi.freq <- sort(colSums(as.matrix(blogs.dtm.bi.sparse)), decreasing=TRUE)
head(blogs.bi.freq)
hist(blogs.bi.freq, breaks = 500)
dev.copy(png, "./graphs/blogs-bi-cloud.png")
wordcloud(names(blogs.bi.freq), blogs.bi.freq, min.freq=100, max.words=100)
dev.off()
dev.copy(png, "./graphs/blogs-bi-bar.png")
barplot(blogs.bi.freq[1:25], las = 2, col ="lightblue", main ="Most frequent words", ylab = "Word frequencies")
dev.off()
rm(blogs.dtm.bi)
rm(blogs.dtm.bi.sparse)
# blogs tri-gram
blogs.dtm.trii <- DocumentTermMatrix(VCorpus(VectorSource(TransCorpus[[1]]$content)), 
                                     control=list(tokenize = TriGramTokenizer))
blogs.dtm.tri.sparse <- removeSparseTerms(blogs.dtm.tri, 0.999)
rm(blogs.dtm.tri)
blogs.tri.freq <- sort(colSums(as.matrix(blogs.dtm.trii.sparse)), decreasing=TRUE)
head(blogs.tri.freq)
hist(blogs.tri.freq, breaks = 500)

## TWITTER ################
# twit uni-gram
twit.dtm <- DocumentTermMatrix(VCorpus(VectorSource(TransCorpus[[3]]$content)))
twit.dtm.sparse <- removeSparseTerms(twit.dtm, 0.999)
rm(twit.dtm)
twit.freq <- sort(colSums(as.matrix(twit.dtm.sparse)), decreasing=TRUE)
head(twit.freq,50)
hist(twit.freq, breaks = 500)
dev.copy(png, "./graphs/twit-cloud.png")
wordcloud(names(twit.freq), twit.freq, min.freq=100, max.words=100)
dev.off()
dev.copy(png, "./graphs/twit-bar.png")
barplot(twit.freq[1:25], las = 2, col ="lightblue", main ="Most frequent words", ylab = "Word frequencies")
dev.off()

# twit bi-gram
twit.dtm.bi <- DocumentTermMatrix(VCorpus(VectorSource(TransCorpus[[3]]$content)), 
                                  control=list(tokenize = BiGramTokenizer))
twit.dtm.bi.sparse <- removeSparseTerms(twit.dtm.bi, 0.999)
rm(twit.dtm.bi)
twit.bi.freq <- sort(colSums(as.matrix(twit.dtm.bi.sparse)), decreasing=TRUE)
head(twit.bi.freq)
hist(twit.bi.freq, breaks = 500)
dev.copy(png, "./graphs/twit-bi-bar.png")
barplot(twit.bi.freq[1:25], las = 2, col ="lightblue", main ="Most frequent words", ylab = "Word frequencies")
dev.off()
dev.copy(png, "./graphs/twit-bi-cloud.png")
wordcloud(names(twit.bi.freq), twit.freq, min.freq=100, max.words=100)
dev.off()
rm(twit.dtm.sparse)
# twit tri-gram
twit.dtm.tri <- DocumentTermMatrix(VCorpus(VectorSource(TransCorpus[[3]]$content)), 
                                    control=list(tokenize = TriGramTokenizer))
twit.dtm.tri.sparse <- removeSparseTerms(twit.dtm.tri, 0.999)
rm(twit.dtm.tri)
twit.tri.freq <- sort(colSums(as.matrix(twit.dtm.trii.sparse)), decreasing=TRUE)
head(twit.tri.freq)
hist(twit.tri.freq, breaks = 500)





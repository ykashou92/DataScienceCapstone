### Load necessary libraries
#library(openNLP)
#library(NLP)
library(tm)
library(quanteda)
library(SnowballC)
library(stringi)

##########################################################################################

### Set seed for reproducibility
set.seed(0)

### Set working directory (Raw Data - Windows OS)
setwd("C://Users//Yanal Kashou//Data Science//Projects//R//DataScienceCapstone//data//raw_data")

con1 <- file("en_US.blogs.txt", "r") 
con2 <- file("en_US.news.txt", "r")
con3 <- file("en_US.twitter.txt", "r")

RawBlogsText <- readLines(con1)
RawNewsText <- readLines(con2)
RawTwitterText <- readLines(con3)

blogs.info <- file.info("en_US.blogs.txt")
blogs.size <- blogs.info$size / 10^6
news.info <- file.info("en_US.news.txt")
news.size <- news.info$size / 10^6
twitter.info <- file.info("en_US.twitter.txt")
twitter.size <- twitter.info$size / 10^6

Blogs.Lines <- length(RawBlogsText)
News.Lines <- length(RawNewsText)
Twitter.Lines <- length(RawTwitterText)

CharLengthOfBlogsText <- sum(nchar(RawBlogsText))
CharLengthOfNewsText <- sum(nchar(RawNewsText))
CharLengthOfTwitterText <- sum(nchar(RawTwitterText))

Blogs.Words <- sum(stri_count(RawBlogsText, regex = "\\S+"))
News.Words <- sum(stri_count(RawNewsText, regex = "\\S+"))
Twitter.Words <- sum(stri_count(RawTwitterText, regex = "\\S+"))

r.df <- data.frame('Dataset' = c("Blogs", "News", "Twitter"),'Sample Size (MB)' = c(blogs.size, news.size, twitter.size), 'Lines' = c(Blogs.Lines, News.Lines, Twitter.Lines), 'Words' = c(Blogs.Words, News.Words, Twitter.Words), 'Characters' = c(CharLengthOfBlogsText, CharLengthOfNewsText,  CharLengthOfTwitterText))

colnames(r.df) <- c("Dataset", "Size (MB)", "Line Count", "Word Count", "Character Count")

# Close file connections
close(con1, con2, con3)

##########################################################################################

## Set working directory (processed_data)
setwd("C://Users//Yanal Kashou//Data Science//Projects//R//DataScienceCapstone//data//processed_data")

# 15% Sampling
SampledBlogsText <- RawBlogsText[rbinom(Blogs.Lines*.15, Blogs.Lines, .5)]
SampledNewsText <- RawNewsText[rbinom(News.Lines*.15, News.Lines, .5)]
SampledTwitterText <- RawTwitterText[rbinom(Twitter.Lines*.15, Twitter.Lines, .5)]

# Tokenize
TokenizedBlogs <- tokenize(SampledBlogsText)
TokenizedNews <- tokenize(SampledNewsText)
TokenizedTwitter <- tokenize(SampledTwitterText)

# Export sampled text to .txt files
con4 <- file("sampled.blogs.txt")
writeLines(SampledBlogsText, con4)
con5 <- file("sampled.news.txt")
writeLines(SampledNewsText, con5)
con6 <- file("sampled.twitter.txt")
writeLines(SampledTwitterText, con6)
close(con4, con5, con6)

# Table
s.blogs.info <- file.info("sampled.blogs.txt")
s.blogs.size <- s.blogs.info$size / 10^6
s.news.info <- file.info("sampled.news.txt")
s.news.size <- s.news.info$size / 10^6
s.twitter.info <- file.info("sampled.twitter.txt")
s.twitter.size <- s.twitter.info$size / 10^6
s.Blogs.Lines <- length(SampledBlogsText)
s.News.Lines <- length(SampledNewsText)
s.Twitter.Lines <- length(SampledTwitterText)
s.CharLengthOfBlogsText <- sum(nchar(SampledBlogsText))
s.CharLengthOfNewsText <- sum(nchar(SampledNewsText))
s.CharLengthOfTwitterText <- sum(nchar(SampledTwitterText))
s.Blogs.Words <- sum(stri_count(TokenizedBlogs, regex = "\\S+"))
s.News.Words <- sum(stri_count(TokenizedNews, regex = "\\S+"))
s.Twitter.Words <- sum(stri_count(TokenizedTwitter, regex = "\\S+"))

s.df <- data.frame('Dataset' = c("Blogs", "News", "Twitter"), 'Sample Size (MB)' = c(s.blogs.size, s.news.size, s.twitter.size), 'Lines' = c(s.Blogs.Lines, s.News.Lines, s.Twitter.Lines), 'Words' = c(s.Blogs.Words, s.News.Words, s.Twitter.Words), 'Characters' = c(s.CharLengthOfBlogsText, s.CharLengthOfNewsText,  s.CharLengthOfTwitterText))
colnames(s.df) <- c("Dataset", "Sample Size (MB)", "Line Count", "Word Count", "Character Count")

##########################################################################################

### Create Corpus 
TextCorpus <- Corpus(DirSource(directory = getwd(), pattern="sampled.*.txt|sampled.*.txt"))
inspect(TextCorpus)
str(TextCorpus)

### Set working directory (Banned Words - Windows OS)
setwd("C://Users//Yanal Kashou//Data Science//Projects//R//DataScienceCapstone//data//banned_words")

# Open file connection
con7 <- file("banned-words.txt", "r")
BannedWords <- readLines(con7)
BannedWords

# Close file connection
close(con7)

# Trim whitespace at the end of the word
trim.ending <- function (x)
        sub("\\s+$", "", x)
trim.ending(BannedWords)

### Set working directory (processed_data)
setwd("C://Users//Yanal Kashou//Data Science//Projects//R//DataScienceCapstone//data//processed_data")

# Remove punctuation, whitespace, numbers, stopwords from text and convert to lower case 
inspect(TextCorpus)
CleanCorpus <- tm_map(TextCorpus, removePunctuation)
CleanCorpus <- tm_map(CleanCorpus, stripWhitespace)
CleanCorpus <- tm_map(CleanCorpus, removeNumbers)
#CleanCorpus <- tm_map(CleanCorpus, removeWords, stopwords("english"))
CleanCorpus <- tm_map(CleanCorpus, content_transformer(tolower))
inspect(CleanCorpus)

writeLines(as.character(CleanCorpus[[1]]), con="cleaned.blogs.txt")
writeLines(as.character(CleanCorpus[[2]]), con="cleaned.news.txt")
writeLines(as.character(CleanCorpus[[3]]), con="cleaned.twitter.txt")

# Remove Profanity
PoliteCorpus <- tm_map(CleanCorpus, removeWords, BannedWords)
inspect(PoliteCorpus)

writeLines(as.character(PoliteCorpus[[1]]), con="polite.blogs.txt")
writeLines(as.character(PoliteCorpus[[2]]), con="polite.news.txt")
writeLines(as.character(PoliteCorpus[[3]]), con="polite.twitter.txt")

# Create char length dataframe
#"Post-Stemming" = c(21415989, 1564823, 17116878)

CharLengthDF <- data.frame("Original" = c(31521201, 2248401, 24324928), "Post-Cleaning" = c(23806006, 1750801, 18672851), "Post-Profanity-Removal" = c(21385469, 1563741, 17030475))

# Divide char length by 10^6 to appear in millions
CharLengthDF <- CharLengthDF[1:3, ]/10^6
CharLengthDF
# Final Corpus and export to txt
FinalCorpus <- tm_map(PoliteCorpus, PlainTextDocument)

writeLines(as.character(FinalCorpus[[1]]), con="final.blogs.txt")
writeLines(as.character(FinalCorpus[[2]]), con="final.news.txt")
writeLines(as.character(FinalCorpus[[3]]), con="final.twitter.txt")

FinalBlogsText <- readLines(con = "final.blogs.txt")
FinalNewsText <- readLines(con = "final.news.txt")
FinalTwitterText <- readLines(con = "final.twitter.txt")

f.Blogs.Words <- sum(stri_count(FinalBlogsText, regex = "\\S+"))
f.News.Words <- sum(stri_count(FinalNewsText, regex = "\\S+"))
f.Twitter.Words <- sum(stri_count(FinalTwitterText, regex = "\\S+"))
f.df <- data.frame('Dataset' = c("Blogs", "News", "Twitter"), 'Pre-cleaning' = c(s.Blogs.Words, s.News.Words, s.Twitter.Words), 'Post-cleaning' = c(f.Blogs.Words, f.News.Words, f.Twitter.Words), '% Difference' = c((s.Blogs.Words-f.Blogs.Words)/s.Blogs.Words*100, (s.News.Words-f.News.Words)/s.News.Words*100, (s.Twitter.Words-f.Twitter.Words)/s.Twitter.Words*100))
colnames(f.df) <- c("Dataset", "Post-Sampling Word Count", "Post-Cleaning Word Count", "% Decrease")
##########################################################################################

# [PENDING] Document Term Matrix
#dfm(con = "polite.twitter.txt", ignoredFeatures = stopwords("english"), stem = TRUE)
TwitterDFM <- dfm(FinalTwitterText, stem = TRUE)
BlogsDFM <- dfm(FinalBlogsText, stem = TRUE)
NewsDFM <- dfm(FinalTwitterText, stem = TRUE)

write.table(c(CharLengthDF), file = "CharLengthTable")

setwd("C://Users//Yanal Kashou//Data Science//Projects//R//DataScienceCapstone//cache")

save(r.df, file="r.df.RData")
save(s.df, file="s.df.RData")
save(f.df, file="f.df.RData")
save(FinalCorpus, file="FinalCorpus.RData")
save.image(file="OneScriptToRuleThemAll.RData")
# Set seed for reproducibility
set.seed(1)

# Set working directory (Raw Data - Windows OS)
setwd("C://Users//Yanal Kashou//Data Science//Projects//R//DataScienceCapstone//data//raw_data")

# Open individual file connections
con1 <- file("en_US.blogs.txt", "r") 
con2 <- file("en_US.news.txt", "r")
con3 <- file("en_US.twitter.txt", "r")

# Read text files
RawBlogsText <- readLines(con1)
RawNewsText <- readLines(con2)
RawTwitterText <- readLines(con3)

# Close file connections
close(con1, con2, con3)

TextCorpus <- Corpus(DirSource(directory = getwd(), pattern="en_US.*.txt|en_US.*.txt"))
inspect(TextCorpus)
str(TextCorpus)

# Set working directory (cache)
setwd("C://Users//Yanal Kashou//Data Science//Projects//R//DataScienceCapstone//cache")

# Save .RData file(s)
save(TextCorpus, file="TextCorpus.RData")
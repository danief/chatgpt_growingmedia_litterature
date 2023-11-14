
# set wd 
setwd("C:/Users/dafl/Desktop/SGM")

# Load reticulate into current R session
library(reticulate)
library(tidyverse)

# Retrieve/force initialization of Python
reticulate::py_config()
# Check if python is available
reticulate::py_available()
# Install Python package into virtual environment
reticulate::py_install("transformers", pip = TRUE)
# Also installing pytorch just as a contingency?
reticulate::py_install(c("torch", "sentencepiece"), pip = TRUE)

# -----------------------------------------------------------------------------------------------------------------------------------------------
# Importing  transformers into R session
transformers <- reticulate::import("transformers")
# Instantiate a pipeline
classifier <- transformers$pipeline(task = "text-classification")
# -----------------------------------------------------------------------------------------------------------------------------------------------

# input needs to be tab delim texts from endnote 
df<-read.table("C:/Users/dafl/Desktop/SGM/test_search_one_beatrix.txt", header = F, sep= "\t",  na.strings = "NA", fill = TRUE)

text <- df %>% select(V39) 
text <- as.data.frame(text$V39)
text <- as.data.frame(text[1:50,])

names(text) <- "input"
head(text)

text <- text %>% mutate_all(na_if,"")
text <- na.omit(text)
text <- tibble::rowid_to_column(text, "ID")

#rio::export(text, "text.txt")

text <- as.list(text$input)

# -----------------------------------------------------------------------------------------------------------------------------------------------

# Specify task
reader <- transformers$pipeline(task = "question-answering",
                                model = "deepset/roberta-base-squad2")

# Question i want answered
question <- "what types of soil or growing media is mentioned in the text?"

# Assuming `texts` is a vector containing your text data

outputs_list <- lapply(text, function(text) {
  reader(question = question, context = text)
})

# Optionally convert the list of outputs to a tibble/data frame for easier viewing/analysis
outputs_df <- do.call(rbind, lapply(outputs_list, as.data.frame))

as_tibble(outputs_df)

# summary not working? ----------------------------------------------------------------------------------------------------------------------------------------------

# Assuming `texts` is a vector containing  text data
short_texts <- substr(text, 1, 2000)

summarizer <- transformers$pipeline("summarization", model = "sambydlo/bart-large-scientific-lay-summarisation")

# Use lapply to apply the model to each text input
outputs_list <- lapply(short_texts, function(short_texts) {
  summarizer(short_texts, max_length = 20L, clean_up_tokenization_spaces = TRUE)
})

# Optionally convert the list of outputs to a vector or a data frame for easier viewing/analysis
outputs_vector <- unlist(outputs_list)
outputs_df <- data.frame(summary = outputs_vector)

# need to merge output with original data
# also test to identify species or merge with species identification taxize script

# END
#
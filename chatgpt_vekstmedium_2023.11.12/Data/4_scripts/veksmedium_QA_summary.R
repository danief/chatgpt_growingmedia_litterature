
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

text <- as.list(data$abstract)

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

outputs_df <- bind_cols(data, outputs_df)

rio::export(outputs_df, "./chatgpt_vekstmedium_2023.11.12/Data/2_processed_data/outputs_df.xlsx")

# End -------------------------------------------------------------------------------------------------------------------------------------------

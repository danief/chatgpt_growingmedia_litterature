

# -----------------------------------------------------------------------------------------------------------------------------------------------
# read data from bert model 
output.xlsx

bert <- rio::import("./chatgpt_vekstmedium_2023.11.12/Data/2_processed_data/bert_best_output.xlsx")

# -----------------------------------------------------------------------------------------------------------------------------------------------

as_tibble(data_frame)
df <- bind_cols(data_frame, bert)

as_tibble(df)

test <- df %>% select(Author, Title,  Year, Abstract, Topic, Top_n_words)
as_tibble(test)

rio::export(test, "./chatgpt_vekstmedium_2023.11.12/Data/2_processed_data/veksmedium_bert_class.csv")

# .ris  -----------------------------------------------------------------------------------------------------------------------------------------

rio::export(test, "veksmedium_bert_class.csv")

library(readr)
library(purrr)

# Read CSV file
bert_data <- read_csv("./veksmedium_bert_class.csv")
bert_data <- test

# Function to convert a row to RIS format
convert_to_ris <- function(Author, Title,  Year, Abstract, Topic, Top_n_words) {
  ris_format <- paste0("TY  - JOUR\n",  # Default type
                       "AU  - ", Author, "\n",
                       "TI  - ", Title, "\n",
                       "Y1  - ", Year, "\n",
                       "AB  - ", Abstract, "\n",
                       "C1  - ", Topic, "\n",
                       "C2  - ", Top_n_words, "\n",
                       "ER  - \n")
  return(ris_format)
}

# Apply the function to each row and combine into one string
ris_data <- pmap_chr(bert_data, convert_to_ris)
ris_text <- paste(ris_data, collapse = "\n")

as_tibble(ris_text)
# Write to RIS file
writeLines(ris_text, "./chatgpt_vekstmedium_2023.11.12/Data/2_processed_data/veksmedium_bert_class.ris")


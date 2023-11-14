# -----------------------------------------------------------------------------------------------------------------------------------------------

library(xml2)
library(dplyr)
dir("./chatgpt_vekstmedium_2023.11.12/Data/1_raw_data/")
# Read the XML file
xml_data <- read_xml("./chatgpt_vekstmedium_2023.11.12/Data/1_raw_data/vekstmedier_test2.xml")

# Extract the records
records <- xml_find_all(xml_data, "//record")

# Define a function to extract and fill missing values with NA
extract_and_fill <- function(records, path) {
  sapply(records, function(record) {
    node <- xml_find_first(record, path)
    if (!is.null(node)) xml_text(node) else NA
  })
}

# Use the function to extract information for each record
keywords <- extract_and_fill(records, ".//keyword/style")
title <- extract_and_fill(records, ".//title/style")
years <- extract_and_fill(records, ".//year/style")
isbns <- extract_and_fill(records, ".//isbn/style")
accession_nums <- extract_and_fill(records, ".//accession-num/style")
abstracts <- extract_and_fill(records, ".//abstract/style")
notes <- extract_and_fill(records, ".//notes/style")
work_types <- extract_and_fill(records, ".//work-type/style")
pages <- extract_and_fill(records, ".//pages/style")
volume <- extract_and_fill(records, ".//volume/style")
urls <- extract_and_fill(records, ".//url/style")
remote_database_names <- extract_and_fill(records, ".//remote-database-name/style")
remote_database_providers <- extract_and_fill(records, ".//remote-database-provider/style")
languages <- extract_and_fill(records, ".//language/style")

# Create a data frame
data_frame <- data.frame(
  Keyword = I(keywords),
  Title =  I(title),
  Year = I(years),
  ISBN = I(isbns),
  AccessionNum = I(accession_nums),
  Abstract = I(abstracts),
  Notes = I(notes),
  WorkType = I(work_types),
  Pages = I(pages),
  Volume = I(volume),
  URL = I(urls),
  RemoteDatabaseName = I(remote_database_names),
  RemoteDatabaseProvider = I(remote_database_providers),
  Language = I(languages),
  stringsAsFactors = FALSE
)

# View the data frame
as_tibble(data_frame)

# -----------------------------------------------------------------------------------------------------------------------------------------------

# write data for Bert model 
text <- data_frame %>% select(Title, Abstract) 
text <- tibble::rowid_to_column(text, "ID")
as_tibble(text)
rio::export(text, "./chatgpt_vekstmedium_2023.11.12/Data/1_raw_data/dataset.txt")

# -----------------------------------------------------------------------------------------------------------------------------------------------
# read data from bert model 
output.xlsx

bert <- rio::import("output.xlsx")

# -----------------------------------------------------------------------------------------------------------------------------------------------

df <- bind_cols(data_frame, bert)

names(df)

test <- df %>% select(Title, Year, Abstract, Topic, Top_n_words, Keyword, ISBN)

rio::export(test, "veksmedium_bert_class.xlsx")

names(test)


# .ris  -----------------------------------------------------------------------------------------------------------------------------------------


rio::export(test, "veksmedium_bert_class.csv")

library(readr)
library(purrr)

# Read CSV file
data <- read_csv("./veksmedium_bert_class.csv")

# Function to convert a row to RIS format
convert_to_ris <- function(Title, Abstract, Topic, Top_n_words) {
  ris_format <- paste0("TY  - JOUR\n",  # Default type, you can change this
                       "TI  - ", Title, "\n",
                       "AB  - ", Abstract, "\n",
                       "C1  - ", Topic, "\n",
                       "C2  - ", Top_n_words, "\n",
                       "ER  - \n")
  return(ris_format)
}

# Apply the function to each row and combine into one string
ris_data <- pmap_chr(data, convert_to_ris)
ris_text <- paste(ris_data, collapse = "\n")

# Write to RIS file
writeLines(ris_text, "output.ris")


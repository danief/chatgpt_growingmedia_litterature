# -----------------------------------------------------------------------------------------------------------------------------------------------

library(xml2)
library(dplyr)
library(rio)
library(tidyverse)

# -----------------------------------------------------------------------------------------------------------------------------------------------

dir("C:/Users/dafl/OneDrive - Folkehelseinstituttet/VKM Data/Vekstmedium_2023.08.09/Risk_Norway_plant_health_soil_growing_media/Literature_Data/search_1/2_study_selection")
dir("./chatgpt_vekstmedium_2023.11.12/Data/1_raw_data/")
# Read the XML file
xml_data <- read_xml("./chatgpt_vekstmedium_2023.11.12/Data/1_raw_data/veksmdeier_cab_wos.xml")

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
authors <- extract_and_fill(records, ".//author/style")
years <- extract_and_fill(records, ".//year/style")
title <- extract_and_fill(records, ".//title/style")
abstracts <- extract_and_fill(records, ".//abstract/style")
journal <- extract_and_fill(records, ".//journal/style")

#isbns <- extract_and_fill(records, ".//isbn/style")
#accession_nums <- extract_and_fill(records, ".//accession-num/style")
#keywords <- extract_and_fill(records, ".//keyword/style")
#notes <- extract_and_fill(records, ".//notes/style")
#work_types <- extract_and_fill(records, ".//work-type/style")
#pages <- extract_and_fill(records, ".//pages/style")
#volume <- extract_and_fill(records, ".//volume/style")
#urls <- extract_and_fill(records, ".//url/style")
#remote_database_names <- extract_and_fill(records, ".//remote-database-name/style")
#remote_database_providers <- extract_and_fill(records, ".//remote-database-provider/style")
#languages <- extract_and_fill(records, ".//language/style")

# Create a data frame
data_frame <- data.frame(
  Author = I(authors),
  Year = I(years),
  Title =  I(title),
  Abstract = I(abstracts),
  Journal = I(journal),
  stringsAsFactors = FALSE
)

# Create a data frame
#data_frame <- data.frame(
#  Keyword = I(keywords),
#  Title =  I(title),
#  Year = I(years),
#  ISBN = I(isbns),
#  AccessionNum = I(accession_nums),
#  Abstract = I(abstracts),
#  Notes = I(notes),
#  WorkType = I(work_types),
#  Pages = I(pages),
#  Volume = I(volume),
#  URL = I(urls),
#  RemoteDatabaseName = I(remote_database_names),
#  RemoteDatabaseProvider = I(remote_database_providers),
#  Language = I(languages),
#  stringsAsFactors = FALSE
#)


# -----------------------------------------------------------------------------------------------------------------------------------------------

# write data for Bert model 
text <- data_frame %>% select(Title, Abstract) 
text <- tibble::rowid_to_column(text, "ID")
as_tibble(text)
rio::export(text, "./chatgpt_vekstmedium_2023.11.12/Data/1_raw_data/dataset.txt")

# -----------------------------------------------------------------------------------------------------------------------------------------------




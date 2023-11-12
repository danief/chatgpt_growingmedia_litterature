# -----------------------------------------------------------------------------------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(purrr)
library(taxize)
library(tidytext)

# read ------------------------------------------------------------------------------------------------------------------------------------------
# Unnest the species list
unnested_data <- data %>%
  unnest(species_list, names_repair = "unique") %>%
  rename(species = species_list)

# Tokenize the species into bigrams
bigram <- unnested_data %>%
  unnest_tokens(bigram, species, token = "ngrams", n = 2) %>%
  separate(bigram, c("word1", "word2"), sep = " ") %>%
  filter(!word1 %in% stop_words$word,
         !word2 %in% stop_words$word,
         !str_detect(word1, "[0-9]"),
         !str_detect(word2, "[0-9]")) %>%
  unite("species", word1, word2, sep = " ")

# Function to get GBIF ID and retain original species name and ID
get_gbif_info <- function(species_name, id) {
  gbif_data <- taxize::get_gbifid_(species_name, method = "backbone")
  gbif_data <- purrr::map_df(gbif_data, ~ .x %>% mutate(original_sciname = species_name, ID = id))
  return(gbif_data)
}

# 
sp <- bigram %>%
  rowwise() %>%
  mutate(gbif_data = list(get_gbif_info(species, ID))) %>%
  unnest(gbif_data, names_sep = "_")

# Filter the data
sp <- sp %>%
  filter(!gbif_data_matchtype == "Fuzzy") %>%
  filter(gbif_data_status == "ACCEPTED") %>% 
  select(ID, gbif_data_scientificname)

sp <- sp %>% 
  group_by(ID) %>% 
  distinct(gbif_data_scientificname)
  
# Join with original data
# Reshape the data to have multiple species columns per ID
wide_data <- sp %>%
  group_by(ID) %>%
  mutate(species_col = paste0("species_", row_number())) %>%
  ungroup() %>%
  pivot_wider(names_from = species_col, values_from = gbif_data_scientificname)

# Join with original data
final_data <- data %>%
  left_join(wide_data, by = "ID")

# write -----------------------------------------------------------------------------------------------------------------------------------------

export(final_data, "./chatgpt_vekstmedium_2023.11.12/Data/2_processed_data/final_data.xlsx")

# END -------------------------------------------------------------------------------------------------------------------------------------------
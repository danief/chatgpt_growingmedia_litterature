# Load required libraries
library(httr)
library(jsonlite)
library(tidyverse)
library(rio)

# Read data set and prepare data frame
# this uses the data set from the chatgpt_vekstmedium.R script and only processes the ones referring to soil and growing media 
data

# Read API key from file
api_key_file_path <- file.path("C:/Users/dafl/Desktop/chatgpt_apikey.txt")
api_key <- readLines(api_key_file_path, warn = FALSE)

# Initialize a counter
counter <- 0
total <- nrow(data)

# Function to call the ChatGPT API
call_chat_gpt <- function(prompt) {
  response <- POST(
    "https://api.openai.com/v1/chat/completions",
    add_headers(`Authorization` = paste("Bearer", api_key), `Content-Type` = "application/json"),
    body = toJSON(list(model = "gpt-3.5-turbo", messages = list(list(role = "system", content = "Start Chat"), list(role = "user", content = prompt))), auto_unbox = TRUE),
    encode = "json"
  )
  Sys.sleep(sample(1:3, 1))
  
  
  if (response$status_code != 200) stop("API call failed: ", response$status_code)
  result <- fromJSON(rawToChar(response$content), simplifyVector = FALSE)
  if (is.null(result$choices[[1]]$message$content)) stop("Message content not found.")
  result$choices[[1]]$message$content
  
}


# Function to identify and list species
identify_species <- function(abstract) {
  species_prompt <- paste("Identify and list different species mentioned in the following text:\n\n", abstract, sep = "")
  species <- call_chat_gpt(species_prompt)
  return(species)
}

# Function to process each abstract
process_abstract <- function(abstract, topic) {
  counter <<- counter + 1
  cat(sprintf("[%d/%d] Processing abstract ID %d...\n", counter, total, abstract$ID))
  
  species_check_prompt <- paste("Does the following text talk about a specific species?\n\n", abstract$abstract, sep = "")
  species_check_response <- call_chat_gpt(species_check_prompt)
  
  # Determine if the text discusses the topic of species
  discussed <- ifelse(grepl("^Yes,", species_check_response), "Yes", "No")
  
  # Initialize species variable
  species_list <- NA
  
  # If the topic of species is discussed, identify and list species
  if (discussed == "Yes") {
    species_list <- identify_species(abstract$abstract)
  }
  
  return(list(discussed = discussed, species_list = species_list))
  
}


# Process each abstract and store results
results <- future_lapply(seq_len(nrow(data)), function(i) process_abstract(data[i, ], topic_to_check))

# Combine results with original data
data$discussed_species <- sapply(results, `[[`, "discussed")
data$species_list <- sapply(results, `[[`, "species_list")

# Export to Excel
export(data, "./chatgpt_vekstmedium_2023.11.12/Data/2_processed_data/chatgpt_species_identification.xlsx")

# Print final data frame
print(as_tibble(data))

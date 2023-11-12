# library ---------------------------------------------------------------------------------------------------------------------------------------
pckgs=c("httr","jsonlite","tidyverse","rio");for(i in 1:length(pckgs))if(!require(pckgs[i],character.only = TRUE)){install.packages(pckgs[i])}

library(httr)
library(jsonlite)
library(tidyverse)
# -----------------------------------------------------------------------------------------------------------------------------------------------

df<- rio::import("./chatgpt_vekstmedium_2023.11.12/Data/1_raw_data/dataset.txt") %>% as_tibble()

df <- df %>%
  group_by(ID) %>%
  mutate(title_abs=paste0(Title, Abstract)) 

# subset test data 
data <- df %>% select(ID, title_abs)
names(data) <-c("ID", "abstract")
data <- data[1:10,]

# setup -----------------------------------------------------------------------------------------------------------------------------------------
api_key_file_path <- file.path("C:/Users/dafl/Desktop/chatgpt_apikey.txt")

api_key <- readLines(api_key_file_path, warn = FALSE)

# Initialize a counter --------------------------------------------------------------------------------------------------------------------------

counter <- 0
total <- nrow(data)

# Function to call the ChatGPT API --------------------------------------------------------------------------------------------------------------

call_chat_gpt <- function(prompt) {
  response <- POST(
    url = "https://api.openai.com/v1/chat/completions",
    add_headers(`Authorization` = paste("Bearer", api_key), `Content-Type` = "application/json"),
    body = toJSON(list(model = "gpt-3.5-turbo", messages = list(list(role = "system", content = "Start Chat"), list(role = "user", content = prompt))), auto_unbox = TRUE),
    encode = "json"
  )
  
  # Check for a valid response
  if (response$status_code != 200) {
    stop("Error: ", response$status_code, " - ", rawToChar(response$content))
  }
  
  result <- fromJSON(rawToChar(response$content), simplifyVector = FALSE)
  # Use simplifyVector to ensure a consistent structure
  
  # Ensure that we have a non-empty choices list
  if (length(result$choices) == 0 || !is.list(result$choices)) {
    stop("Invalid response structure.")
  }
  
  # Extract the message content if it exists
  if (!is.null(result$choices[[1]]$message) && !is.null(result$choices[[1]]$message$content)) {
    return(result$choices[[1]]$message$content)
  } else {
    stop("Message content not found in response.")
  }
}

# Function to process a text abstract -----------------------------------------------------------------------------------------------------------

process_abstract <- function(abstract, topic) {
  # Step 1: Check if the abstract discusses the topic
  counter <<- counter + 1
  cat(sprintf("[%d/%d] Processing abstract...\n", counter, total))
  
  check_prompt <- paste("Does the following text discuss the topic of '", topic, "'?\n\n", abstract, sep = "")
  check_response <- call_chat_gpt(check_prompt)
  
  # Determine if the text discusses the topic
  discussed <- ifelse(grepl("^Yes,", check_response), "Yes", ifelse(grepl("^No,", check_response), "No", "Unclear"))
  
  # Initialize summary variable
  summary <- NA
  
  # If the topic is discussed, get a summary
  if (discussed == "Yes") {
    summary_prompt <- paste("Give a 25 words summary of the following text focusing on the topic '", topic, "':\n\n", abstract, sep = "")
    summary <- call_chat_gpt(summary_prompt)
  }
  
  # Return a list with the discussed response and summary
  return(list(discussed = discussed, summary = summary))
}

# Topic to check --------------------------------------------------------------------------------------------------------------------------------

topic_to_check <- "soil or other other growing media"

# process ---------------------------------------------------------------------------------------------------------------------------------------
# Process each abstract and store results
results <- lapply(data$abstract, process_abstract, topic = topic_to_check)

# finalize --------------------------------------------------------------------------------------------------------------------------------------

# Extract the results into separate columns
data$discussed <- sapply(results, `[[`, "discussed")
data$summary <- sapply(results, `[[`, "summary")

# data frame
as_tibble(data)

# write file ------------------------------------------------------------------------------------------------------------------------------------
rio::export(data, "./chatgpt_vekstmedium_2023.11.12/Data/2_processed_data/chatgpt_vksmedium_yes_no.xlsx")

# End -------------------------------------------------------------------------------------------------------------------------------------------
# 
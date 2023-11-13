

# counter --------------------------------------------------------------------------------------------------------------------------

counter <- 0
total <- nrow(data)

# -----------------------------------------------------------------------------------------------------------------------------------------------

# Function to call the ChatGPT API
# Define a function to answer a question based on the abstracts
answer_question <- function(abstract, question, model="gpt-3.5-turbo", max_tokens=150) {
  
  counter <<- counter + 1
  cat(sprintf("[%d/%d] Processing abstract...\n", counter, total))
  
  # Create the context from the abstract
  context <- paste("Context: ", abstract, "\n\n---\n\nQuestion: ", question, "\nAnswer:", sep="")
  
  # Create a chat completion using the question and context
  response <- POST(
    url = "https://api.openai.com/v1/chat/completions",
    add_headers(`Authorization` = paste("Bearer", api_key), `Content-Type` = "application/json"),
    body = toJSON(list(
      model = model,
      messages = list(
        list(role = "system", content = "Answer the question based on the context below, and if the question can't be answered based on the context, say \"I don't know\"."),
        list(role = "user", content = context)
      )
    ), auto_unbox = TRUE),
    encode = "json"
  )
  
  # Check for a valid response
  if (response$status_code != 200) {
    stop("Error: ", response$status_code, " - ", rawToChar(response$content))
  }
  
  result <- fromJSON(rawToChar(response$content), simplifyVector = FALSE)
  # Extract the answer from the response
  if (!is.null(result$choices[[1]]$message) && !is.null(result$choices[[1]]$message$content)) {
    answer <- result$choices[[1]]$message$content
    return(substring(answer, 10)) # Remove 'Answer: ' prefix
  } else {
    stop("Answer content not found in response.")
  }
}

# Example usage of the function
data$answer <- sapply(data$abstract, answer_question, question="What type of soil or other growing media are discussed?", max_tokens=150)

# -----------------------------------------------------------------------------------------------------------------------------------------------

rio::export(data, "./chatgpt_vekstmedium_2023.11.12/Data/2_processed_data/chatgpt_vksmedium_QA.xlsx")

# -----------------------------------------------------------------------------------------------------------------------------------------------



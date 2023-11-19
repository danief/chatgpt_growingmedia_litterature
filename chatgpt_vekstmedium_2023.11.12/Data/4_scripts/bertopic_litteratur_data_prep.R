
library(tidyverse)

df<- rio::import("dataset.txt") %>% as_tibble()

as_tibble(df)

text <- df %>% mutate_all(na_if,"")
text <- na.omit(df)

text <- text %>%   mutate(title_abs=paste0(Title, Abstract)) 
as_tibble(text)

filer <- text %>% unnest_tokens(word, title_abs)

##################################### rydd opp #####################################

# dydd opp og kast ut tall og symboler
filer <- filer %>%
  filter(
    !str_detect(word, "[0-9]"),
    !str_detect(word, "[\\s]+"),
    !str_detect(word, "[^a-zA-Z\\s]"),
    !str_detect(word, "[a-z]_"),
    !str_detect(word, ":"),
    !str_detect(word, "textless")
  )

# en stop words
filer <- filer %>% anti_join(stop_words, by = c("word" = "word"))

clean_text <- filer %>%
  group_by(ID) %>%
  summarize(clean_sentence = str_c(word, collapse = " ")) %>%
  ungroup()

rio::export(clean_text, "text.txt")

# -----------------------------------------------------------------------------------------------------------------------------------------------

# best practice 
text <- df %>% select(V4, V39) 

names(text) <- c("title", "abstract" )

rio::export(text, "dataset.txt")


# -----------------------------------------------------------------------------------------------------------------------------------------------

# se python script for å kjøre bertopic


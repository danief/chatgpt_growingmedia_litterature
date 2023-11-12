
# Only run once

# vkm_data <- function(input = "vkm_data", is.SLR = FALSE, search.num = 1) {
  newdir <- paste0(getwd(), "/", input, format(Sys.Date(), "_%Y.%m.%d"))
  
  # Check if directory already exists
  if (!file.exists(newdir)) {
    dir.create(newdir)
    
    # Create subdirectories
    dir.create(paste0(newdir, "/Data"), showWarnings = FALSE)
    dir.create(paste0(newdir, "/Literature_Data"), showWarnings = FALSE)
    
    for (s in 1:search.num) {
      dir.create(paste0(newdir, "/Literature_Data/search_", s), showWarnings = FALSE)
      dir.create(paste0(newdir, "/Literature_Data/search_", s, "/1_search_query"), showWarnings = FALSE)
      dir.create(paste0(newdir, "/Literature_Data/search_", s, "/2_study_selection"), showWarnings = FALSE)
      dir.create(paste0(newdir, "/Literature_Data/search_", s, "/3_full_text"), showWarnings = FALSE)
      dir.create(paste0(newdir, "/Literature_Data/search_", s, "/4_data_extraction"), showWarnings = FALSE)
      
      if (is.SLR) {
        dir.create(paste0(newdir, "/Literature_Data/search_", s, "/5_internal_validity"), showWarnings = FALSE)
        dir.create(paste0(newdir, "/Literature_Data/search_", s, "/6_confidence_in_evidence"), showWarnings = FALSE)
      }
    }
    
    dir.create(paste0(newdir, "/Data/1_raw_data"), showWarnings = FALSE)
    dir.create(paste0(newdir, "/Data/2_processed_data"), showWarnings = FALSE)
    dir.create(paste0(newdir, "/Data/3_metadata"), showWarnings = FALSE)
    dir.create(paste0(newdir, "/Data/4_scripts"), showWarnings = FALSE)
    dir.create(paste0(newdir, "/Data/5_outputs"), showWarnings = FALSE)
  } else {
    print("Folder already exists.")
  }
}

# kjør funksjon uten SLR 
vkm_data("chatgpt_vekstmedium")


Soil and Species Identification from Abstracts, using ChatGPT
================
Daniel Flø
2023-11-12

## Identification of Soil or Growing Media fraom Abstracts

The script is designed to recognize and flag abstracts that discuss
“soil or other growing media.” The identification is crucial for
filtering the dataset to those abstracts that are relevant to the topic
of interest. This filtered set of abstracts is then further analyzed for
species identification.

The function `process_abstract` is responsible for this identification.
It uses a regular expression search to determine whether the abstract
contains the phrases “soil” or “growing media.” If the abstract is
relevant, it proceeds to summarize the content and identify species.
This targeted approach ensures that the output is focused and relevant
to researchers or readers interested in the intersection of species and
their growing environments.

For abstracts that discuss soil or growing media, the script offers an
additional layer of analysis by identifying the specific species
mentioned. This dual focus on topic relevance and species identification
provides a comprehensive view of the abstract’s content, making the
script a valuable tool for sorting through large volumes of literature
to find studies.

## Requirements

To run this script, you will need R and the following R packages
installed:

- `httr` for making API calls.
- `jsonlite` for parsing JSON.
- `dplyr` for data manipulation (tidyverse).
- `rio` for importing and exporting data.

Additionally, you will need an API key from OpenAI for making calls to
the ChatGPT API.

## Usage

To run the script, follow these steps:

1.  Place the dataset file named `dataset.txt` in the directory
    `./chatgpt_vekstmedium_2023.11.12/Data/1_raw_data/`.
2.  Ensure that the dataset has columns named `Title` and `Abstract`.
3.  Save your OpenAI API key in a text file named `chatgpt_apikey.txt`
    on your desktop.
4.  Set the working directory to the location of the script.
5.  Run the script in R.

## Script Structure

The main components of the script are as follows:

- **Data Import:** The script starts by importing the data set and
  preparing a data frame.
- **API Key Reading:** The API key for ChatGPT is read from a file on
  the desktop.
- **API Call Function:** `call_chat_gpt` is a function that takes a
  prompt and makes an API call to ChatGPT.
- **Species Identification Function:** `identify_species` sends a prompt
  to ChatGPT to identify species in a text.
- **Abstract Processing Function:** `process_abstract` processes each
  abstract, checking for the topic and identifying species.
- **Execution and Results Export:** The script processes each abstract,
  compiles the results, and exports them to Excel.

## Contributing

Contributions to this project are welcome. You can contribute by:

- Improving the script.
- Extending the functionality.
- Reporting issues.
- Providing feedback.

##### Daniel Flø

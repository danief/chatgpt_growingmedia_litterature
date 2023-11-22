from bertopic import BERTopic
from sklearn.datasets import fetch_20newsgroups
import pandas as pd

# Replace the path with the appropriate one on your system
file_path = "C:/Users/dafl/Desktop/chatgpt_growingmedia_litterature/chatgpt_vekstmedium_2023.11.12/Data/1_raw_data/bert_text.txt"

# Open the text file and read it into a string
with open(file_path, 'r') as file: docs = file.read()
documents = docs.split('\n') 

# Create and initialize a BERTopic model
topic_model = BERTopic()

# Fit the model to the documents and generate topics and their probabilities
topics, probs = topic_model.fit_transform(documents)

# Get information about the topics generated by the model
topic_model.get_topic_info()

# Get information about the documents and their corresponding topics
test = topic_model.get_document_info(documents)

# Convert the document info into a DataFrame using pandas
df = pd.DataFrame(test)

# Write the DataFrame to an Excel file named 'output.xlsx'
df.to_excel('C:/Users/dafl/Desktop/chatgpt_growingmedia_litterature/chatgpt_vekstmedium_2023.11.12/Data/2_processed_data/bert_output.xlsx', index=False, engine='openpyxl')

# Visualization
fig = topic_model.visualize_topics()
fig.show()

#######################################################################################################
# With dimension reduction and tuning
# https://maartengr.github.io/BERTopic/algorithm/algorithm.html#code-overview

from umap import UMAP
from hdbscan import HDBSCAN
from sentence_transformers import SentenceTransformer
from sklearn.feature_extraction.text import CountVectorizer

from bertopic import BERTopic
from bertopic.representation import KeyBERTInspired
from bertopic.vectorizers import ClassTfidfTransformer


# Step 1 - Extract embeddings
embedding_model = SentenceTransformer("all-MiniLM-L6-v2")

# Step 2 - Reduce dimensionality
umap_model = UMAP(n_neighbors=15, n_components=5, min_dist=0.0, metric='cosine')

# Step 3 - Cluster reduced embeddings
hdbscan_model = HDBSCAN(min_cluster_size=15, metric='euclidean', cluster_selection_method='eom', prediction_data=True)

# Step 4 - Tokenize topics
vectorizer_model = CountVectorizer(stop_words="english")

# Step 5 - Create topic representation
ctfidf_model = ClassTfidfTransformer()

# Step 6 - (Optional) Fine-tune topic representations with 
# a `bertopic.representation` model
representation_model = KeyBERTInspired()

# All steps together
topic_model = BERTopic(
  embedding_model=embedding_model,          # Step 1 - Extract embeddings
  umap_model=umap_model,                    # Step 2 - Reduce dimensionality
  hdbscan_model=hdbscan_model,              # Step 3 - Cluster reduced embeddings
  vectorizer_model=vectorizer_model,        # Step 4 - Tokenize topics
  ctfidf_model=ctfidf_model,                # Step 5 - Extract topic words
  representation_model=representation_model # Step 6 - (Optional) Fine-tune topic represenations
)

topics, probs = topic_model.fit_transform(documents)

# Get information about the topics generated by the model
topic_model.get_topic_info()

# Get information about the documents and their corresponding topics
test = topic_model.get_document_info(documents)

# Convert the document info into a DataFrame using pandas
df = pd.DataFrame(test)

# Write the DataFrame to an Excel file named 'output.xlsx'
df.to_excel('output.xlsx', index=False, engine='openpyxl')

# Visualization
fig = topic_model.visualize_topics()
fig.show()


######################################################################################################
# Best Practices
# https://maartengr.github.io/BERTopic/getting_started/best_practices/best_practices.html


# data 
import pandas as pd
file_path = "C:/Users/dafl/Desktop/chatgpt_growingmedia_litterature/chatgpt_vekstmedium_2023.11.12/Data/1_raw_data/bert_dataset.csv"

dataset = pd.read_csv(file_path, sep=',')

abstracts = dataset["abstract"]
abstracts = abstracts.fillna('')  # Replace NaN values with empty strings
abstracts = abstracts.astype(str)  # Ensure all elements are of type str

titles = dataset["title"]

# Pre-calculate embeddings
from sentence_transformers import SentenceTransformer
embedding_model = SentenceTransformer("all-MiniLM-L6-v2")
embeddings = embedding_model.encode(abstracts, show_progress_bar=True)

# Preventing Stochastic Behavior
from umap import UMAP
umap_model = UMAP(n_neighbors=15, n_components=5, min_dist=0.0, metric='cosine', random_state=42)

# Controlling Number of Topics
from hdbscan import HDBSCAN
hdbscan_model = HDBSCAN(min_cluster_size=50, metric='euclidean', cluster_selection_method='eom', prediction_data=True)

# Improving Default Representation
from sklearn.feature_extraction.text import CountVectorizer
vectorizer_model = CountVectorizer(stop_words="english", min_df=2, ngram_range=(1, 2))


# Additional Representations
# using standard
from bertopic.representation import KeyBERTInspired
representation_model = KeyBERTInspired()

# Training
from bertopic import BERTopic

topic_model = BERTopic(

  # Pipeline models
  embedding_model=embedding_model,
  umap_model=umap_model,
  hdbscan_model=hdbscan_model,
  vectorizer_model=vectorizer_model,
  representation_model=representation_model,

  # Hyperparameters
  top_n_words=10,
  verbose=True
)

# Train model
topics, probs = topic_model.fit_transform(abstracts, embeddings)

# Show topics
topic_model.get_topic_info()

test = topic_model.get_document_info(abstracts)

# Convert the document info into a DataFrame using pandas
df = pd.DataFrame(test)

# Write the DataFrame to an Excel file named 'output.xlsx'
df.to_excel('C:/Users/dafl/Desktop/chatgpt_growingmedia_litterature/chatgpt_vekstmedium_2023.11.12/Data/2_processed_data/bert_best_output.xlsx', index=False, engine='openpyxl')

import os
os.getcwd()

fig = topic_model.visualize_topics()
fig.show()


# Visualize hierarchy with custom labels
t = topic_model.visualize_hierarchy(custom_labels=False)
t.show()


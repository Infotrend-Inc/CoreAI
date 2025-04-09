# In virtual env: pip3 install wordcloud matplotlib
from wordcloud import WordCloud
import matplotlib.pyplot as plt

# Define the main word and related terms with weights for prominence
words = {
    "CoreAI": 100,
    "TensorFlow": 60,
    "PyTorch": 60,
    "CUDA": 60,
    "OpenCV": 60,
    "Image Generation": 50,
    "Large Language Models": 50,
    "Natural Language Processing": 45,
    "Computer Vision": 45,
    "Reinforcement Learning": 40,
    "Neural Networks": 40,
    "Deep Learning": 45,
    "Machine Learning": 50,
    "Generative AI": 50,
    "Transfer Learning": 35,
    "Object Detection": 35,
    "Text-to-Image": 30,
    "Speech Recognition": 30,
    "Data Augmentation": 25,
    "Model Optimization": 25,
    "Semantic Segmentation": 25,
    "AI Ethics": 20,
    "Prompt Engineering": 30,
    "Self-Supervised Learning": 20,
    "Few-Shot Learning": 20,
    "Transformer Models": 35,
}

# Generate the word cloud
wordcloud = WordCloud(
    width=1200,
    height=600,
    background_color='white',
    colormap='viridis'
).generate_from_frequencies(words)

# Save the word cloud
#wordcloud.to_file("wordcloud.png")

# Display the word cloud
plt.figure(figsize=(14, 7))
plt.imshow(wordcloud, interpolation='bilinear')
plt.axis('off')
plt.tight_layout(pad=0)
#plt.show()
plt.savefig("wordcloud.png")
plt.close()

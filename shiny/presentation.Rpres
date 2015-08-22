Word Prediction App
========================================================
author: Nathan Smith
date: August 2015
css: custom.css 
transition: rotate

Capstone Project 
</br>[JHU Coursera Data Science Specialization](https://www.coursera.org/specialization/jhudatascience/1?utm_medium=listingPage) 


========================================================
<h2><font color="#E56717">App Description and Instructions</font></h2>

<div style = "font-size:80%")>
 The goal of the capstone project was to create a word prediction algorithm and deploy it in a [Shiny](http://shiny.rstudio.com/) application. We were instructed to use a [collection](http://www.corpora.heliohost.org/aboutcorpus.html) of newspaper articles, blog posts, and twitter feeds to train our model. An embedded live version of the app appears in the next slide.

**INSTRUCTIONS:**

1. Enter your sentence in the input field and hit "Submit".
2. A primary suggestion for the next word will show up in the table to the right. There will be another table with supplementary suggestions beneath it. 
3. Read the DETAIL tab in the embedded app to learn more about the process of text mining on the Data/Sampling tab. 
4. Check out the EXPLORE tab in the embedded app to see the most frequent n-grams in the sampled Corpus. 

========================================================
<h3><font color="#E56717">Try the app for yourself, this is an embedded live version.</font></h3>

<iframe src="https://nhsmith85.shinyapps.io/shiny" height=600 width=2000></iframe>
   
========================================================
<h1><font color="#E56717">Algorithm</font></h1>

The algorithm works as follows:

1. Clean the input sentence.
2. Determine the length (n) of the cleaned sentence.
3. If $n >=3$ then search for matches in the 4-gram matching on the $n-2$, $n-1$, and $n$ words.
4. If there are no matches, then [back-off](https://en.wikipedia.org/wiki/Katz%27s_back-off_model) to the 3-gram and so on. 
5. Return the top words in descending order of likelihood.  

========================================================
<h1><font color="#E56717">Future Work</font></h1>

The algorithm currently in use relies entirely on (at maximum) the last 3 words in the sentence. 
As we all know, a sentence has long-range context where the last 3 words may not really tell you much at all about the broader intent of the sentence. A method called [bag-of-words](https://en.wikipedia.org/wiki/Bag-of-words_model) should be explored to collect words used previously in the sentence to give more context around word prediction. 










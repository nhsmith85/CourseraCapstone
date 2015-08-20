# CourseraCapstone

This repo contains the code for an Shiny application that predicts the next word in a sentence. It was designed as the capstone project for the Data Science Specialization offered through Coursera and Johns Hopkins University.

The first step in the process of building a word prediction application is using a set of text data from the language you want to build your model in - this case is English. The good folks at Johns Hopkins Bloomberg School of Public Health provided us with a dataset of the following size:

***
Type | File Size | Line Count 
----|----|-----
**News** | 249.6 MB | 1,010,242
**Blog** | 248.5 MB | 899,288
**Twitter**| 301.4 MB | 2,360,148
***

I randomly selected 50,000 rows of text data from each of the blog, news, and twitter datasets and combined them into a single dataset of 150,000 rows and roughly 13 MB. I made heavy use of the great analysis tools in the `tm` package written by [Ingo Feinerer](https://cran.r-project.org/web/packages/tm/vignettes/tm.pdf) and in the `RWeka` package which is an R interface to a collection of machine learning algorithms for data mining tasks written in Java. The shiny application can be found [here]( https://nhsmith85.shinyapps.io/shiny) and a short slide deck on the model can be found at [Rpubs](http://rpubs.com/nhsmith/WebAppSlides).



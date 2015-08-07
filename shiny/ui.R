
library(shiny)
library(shinythemes)

shinyUI(
    navbarPage("Word Prediction Application",
               theme = shinytheme("journal"),   
               tabPanel("PREDICT",
                        fluidRow(
                            column(2, offset=2, 
                                   textInput(inputId='text', label=h3("Enter your phrase below")),
                                   helpText('Hint: Do not leave a space after your last word.'),
                                   submitButton('Submit')
                            ),
                            column(1),
                            column(4,
                                   h3('YOU ENTERED THIS PHRASE:'),
                                   tags$span(style="color:blue",tags$strong(tags$h3(textOutput("enter")))),
                                   hr(),
                                   h3('THE APPLICATION PREDICTS:'),
                                   helpText('Ranked by most likely at the top'),
                                   tags$span(style="color:blue", tags$strong(tags$h4(tableOutput("nextWord")))),
                                   hr(),
                                   tags$span(style="color:darked", tags$footer(("App Developer: Nathan Smith")))
                            )
                        )
               ),
               tabPanel("About",
                        fluidRow(
                            column(2),
                            column(8,includeMarkdown("/Users/nathansmith/CourseraCapstone/milestone.Rmd"))
                            #column(2)
                        )         
               )
    )
)  
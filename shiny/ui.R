
library(shiny)
library(shinythemes)

shinyUI(
    navbarPage("Natural Language Processing Application",
               theme = "bootstrap.css",  
               tabPanel("PREDICT",
                        sidebarLayout(
                            sidebarPanel(width = 4,
                                   textInput(inputId="text", label=h3("Enter your phrase below"), value="Type here" ),
                                   helpText('Suggestions ranked by most likely at the top')
                                   #  submitButton("Submit")
                            ),
                           mainPanel(
                                   h3("YOU ENTERED THIS PHRASE:"),
                                   tags$span(style="color:orange",tags$strong(tags$h3(textOutput("userInput")))),
                                   hr(),
                                   h3("THE APPLICATION SUGGESTS:"),
                                   tags$span(style="color:red",tags$strong(tags$h3(tableOutput("nextWord1")))),
                                   hr(),
                                   tags$span(style="color:darked", tags$footer(("App Developer: Nathan Smith")))
                            )
                        )
               ),
               tabPanel("DETAIL",
                        sidebarLayout(
                            sidebarPanel(width=2, 
                                         selectInput("gram", "Choose the N-Gram:", 
                                                     choices = c("uni","bi","tri","quad")
                                                     )
                                         #submitButton('Submit')
                                         ),
                            mainPanel(
                                tabsetPanel(type = "tabs",
                                            tabPanel("Data/Sampling",
                                                     fluidRow(
                                                         br(),
                                                         column(10,includeMarkdown("sampling.Rmd"))
                                                         )
                                                     ),
                                            tabPanel("Explore",
                                                     htmlOutput("bar")
                                                     )
                                            )
                                    )
                                )
                        ),
               tabPanel("ABOUT",
                        fluidRow(
                            column(2),
                            column(8,includeMarkdown("about.Rmd"))
                            #column(2)
                        )         
               )
    )
)
  

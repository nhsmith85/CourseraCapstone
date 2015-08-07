
library(shiny)

setwd("/Users/nathansmith/CourseraCapstone/en/final/en_US")
source("inputFUN.R")

shinyServer(
    function(input, output) {
        
        prediction <- reactive({
            predList <- predict(as.character(input$text))
            data.frame(PREDICTION = predList)
        })
        output$enter <- renderText({
            input$Submit
            input$text
        })
        output$nextWord <- renderTable({
            input$Submit
            prediction()
        },include.rownames = FALSE)
    }
)


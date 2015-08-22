
library(shiny)
library(googleVis)


source("inputFUN.R")

shinyServer(
    function(input, output) {
        x <- reactive({
            input$text
        })
        prediction1 <- reactive({
            predList1 <- predict1(as.character(input$text))
            data.frame(predList1)
        })
        prediction2 <- reactive({
            predList2 <- predict2(as.character(input$text))
            data.frame(predList2)
        })
        output$userInput <- renderText({
            # input$Submit
            x()
        })
        
        output$nextWord1 <- renderTable({
           #  input$Submit
             prediction1()
        }, include.rownames = FALSE, include.colnames=FALSE)
        
        output$nextWord2 <- renderTable({
            #  input$Submit
            t(prediction2())
        }, include.rownames = FALSE, include.colnames=FALSE)
        
        datasetInput <- reactive({
            switch(input$gram,
                   "uni" = df.uni,
                   "bi" = df.bi,
                   "tri" = df.tri,
                   "quad" = df.quad)
        })
            output$bar <- renderGvis({
                gvisBarChart(datasetInput()[1:25,], options=list(
                    width = 700,
                    height = 600,
                    chartArea="{left:175,top:50,width:\"50%\",height:\"70%\"}",
                    colors = "['#cbb69d']",
                    titleTextStyle="{color:'black',fontName:'Times New Roman',fontSize:20}",
                    title="Freq of Top 25 n-grams"))
         
        })
    
    }
    
)


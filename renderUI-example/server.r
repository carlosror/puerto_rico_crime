library(shiny)
biz = data.frame(
  Sector = c("a", "a", "a", "a", "b", "b", "b", "b", "b", "b", "b", "b"), 
  Stock = c("Infy","TCS","Wipro","TechM","SBIN","ICICI","HDFC", "Axis", "IDBI", "PSB","BOI","Bob"),
  stringsAsFactors = FALSE
)
shinyServer(function(input, output) {


  output$Box1 = renderUI(selectInput("sector","select a sector",c(unique(biz$Sector),"pick one"),"pick one"))


  output$Box2 = renderUI(
    if (is.null(input$sector) || input$sector == "pick one"){return()
    }else selectInput("stock", 
                      "Select a stock", 
                      c(unique(biz$Stock[which(biz$Sector == input$sector)]),"pick one"),
                      "pick one")
  )


  subdata1 = reactive(biz[which(biz$Sector == input$sector),])
  subdata2 = reactive(subdata1()[which(subdata1()$Stock == input$stock),])

  output$view = renderTable({
    if(is.null(input$sector) || is.null(input$stock)){return()
    } else if (input$sector == "pick one" || input$stock == "pick one"){return()

    } else return(subdata2())
  })

})
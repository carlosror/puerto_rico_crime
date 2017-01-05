library(shiny)
shinyUI(fluidPage(
  titlePanel("Forecasting of stock prices and their accuracies"),

  sidebarLayout(
    sidebarPanel(
      radioButtons("rd",
                   label="Select time range for training dataset",
                   choices=list("23 month","18 month","12 month","6 month"),
                   selected="23 months"),
      uiOutput("Box1"),
      uiOutput("Box2")
    ),
    mainPanel("Display results",
              tableOutput("view"))
  )
))  
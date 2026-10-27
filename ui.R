library(shiny)

shinyUI(fluidPage(
  tags$head(tags$style(HTML("
    body {background:#f6f8f7; color:#203b3a; font-size:16px;}
    h1,h3,h4 {color:#124e48;}
    .well {background:white;}
    .tab-content {background:white; padding:20px;}
    .selection-summary {
      background:#edf5f1;
      padding:15px;
      margin-bottom:20px;
      font-weight:bold;
    }
  "))),
  
  titlePanel("Growth Lab"),
  
  p("Explore vitamin C dose and supplement differences in",
    "R's ToothGrowth experiment."),
  
  sidebarLayout(
    sidebarPanel(
      h4("Choose observations"),
      
      selectInput(
        "dose",
        "Vitamin C dose (mg/day)",
        choices = c(
          "All doses" = "all",
          "0.5" = "0.5",
          "1" = "1",
          "2" = "2"
        ),
        selected = "all"
      ),
      
      checkboxGroupInput(
        "supp",
        "Supplement",
        choices = c(
          "Orange juice (OJ)" = "OJ",
          "Ascorbic acid (VC)" = "VC"
        ),
        selected = c("OJ", "VC")
      ),
      
      checkboxInput(
        "show_points",
        "Show individual observations",
        value = TRUE
      ),
      
      hr(),
      
      p("Change the filters to update the results automatically."),
      p("Open How to use for instructions and definitions."),
      
      downloadButton("download_data", "Download selected data")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel(
          "Explore",
          
          div(
            class = "selection-summary",
            textOutput("selection_summary")
          ),
          
          plotOutput("growth_plot", height = "370px"),
          
          h3("Group summaries"),
          p("Each row describes one supplement at one dose.",
            "SD measures variation among animals in that group."),
          tableOutput("group_summary"),
          
          h3("Mean difference at each dose"),
          p("The difference equals the OJ mean minus the VC mean.",
            "A positive value means the OJ mean is larger."),
          tableOutput("dose_comparison")
        ),
        
        tabPanel(
          "How to use",
          
          h3("Getting started"),
          
          tags$ol(
            tags$li("Start with All doses and both supplements selected."),
            tags$li("Choose 0.5, 1 or 2 mg/day to examine one dose."),
            tags$li("Select OJ, VC or both supplements."),
            tags$li("Toggle individual observations to show or hide dots."),
            tags$li("Read the chart and the calculated summary tables."),
            tags$li("Download selected data to save the filtered records as CSV.")
          ),
          
          h3("Try this example"),
          p("Choose dose 0.5 and keep both supplements selected.",
            "You should see 20 animals.",
            "The OJ mean is 13.23 and the VC mean is 7.98.",
            "Their difference is 5.25."),
          
          h3("About the data"),
          p("ToothGrowth is a built-in R dataset containing observations",
            "from 60 guinea pigs. Each animal received vitamin C at",
            "0.5, 1 or 2 mg/day through orange juice (OJ) or",
            "ascorbic acid (VC). Each supplement/dose group has 10 animals."),
          
          p("The response is odontoblast length, a measurement of cells",
            "responsible for tooth growth. R's documentation does not",
            "specify a physical unit, so this app uses the recorded scale."),
          
          h3("Definitions"),
          tags$ul(
            tags$li("N: number of animals in the selected group."),
            tags$li("Mean: sum of responses divided by the number of animals."),
            tags$li("Median: the middle response after sorting."),
            tags$li("SD: sample standard deviation, describing variation."),
            tags$li("OJ minus VC: difference between group means at the same dose.")
          ),
          
          h3("Reading the chart"),
          p("The line inside each box is the median.",
            "The box contains the middle 50% of responses.",
            "Whiskers extend to observations within 1.5 times",
            "the box height from its edges.",
            "With individual observations enabled, each dot is one animal.",
            "When disabled, observations beyond the whiskers still appear."),
          
          h3("How the app calculates results"),
          p("The server filters records using your dose and supplement",
            "selections. It then recalculates counts, means, medians,",
            "standard deviations and mean differences.",
            "Select both supplements to display the comparison table.",
            "Selecting neither supplement displays a helpful message."),
          
          h3("Limitations and source"),
          p("These are descriptive summaries of a historical animal",
            "experiment. The app does not perform significance tests",
            "or establish effects in humans."),
          
          p("Data source: datasets::ToothGrowth, distributed with R.",
            "R lists C. I. Bliss (1952), The Statistics of Bioassay,",
            "as the source.")
        )
      )
    )
  )
))

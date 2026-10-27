library(shiny)

# Calculate statistics for each supplement and dose.
summarise_groups <- function(dat) {
  keys <- unique(dat[c("dose", "supp")])
  keys <- keys[order(keys$dose, keys$supp), , drop = FALSE]
  
  result <- lapply(seq_len(nrow(keys)), function(i) {
    values <- dat$len[
      dat$dose == keys$dose[i] &
        dat$supp == keys$supp[i]
    ]
    
    data.frame(
      Dose = keys$dose[i],
      Supplement = as.character(keys$supp[i]),
      N = length(values),
      Mean = mean(values),
      Median = median(values),
      SD = sd(values)
    )
  })
  
  do.call(rbind, result)
}

shinyServer(function(input, output, session) {
  
  # Filter the data whenever the user changes a selection.
  selected_data <- reactive({
    validate(
      need(length(input$supp) > 0,
           "Select at least one supplement.")
    )
    
    req(input$dose)
    
    dat <- datasets::ToothGrowth
    dat <- dat[dat$supp %in% input$supp, , drop = FALSE]
    
    if (input$dose != "all") {
      dat <- dat[
        dat$dose == as.numeric(input$dose),
        , drop = FALSE
      ]
    }
    
    validate(
      need(nrow(dat) > 0,
           "No observations match these filters.")
    )
    
    dat
  })
  
  group_summary <- reactive({
    summarise_groups(selected_data())
  })
  
  # Compare OJ and VC separately at each selected dose.
  dose_comparison <- reactive({
    dat <- selected_data()
    
    validate(
      need(
        all(c("OJ", "VC") %in% as.character(unique(dat$supp))),
        "Select both OJ and VC to compare their means."
      )
    )
    
    doses <- sort(unique(dat$dose))
    
    result <- lapply(doses, function(d) {
      oj <- mean(dat$len[dat$dose == d & dat$supp == "OJ"])
      vc <- mean(dat$len[dat$dose == d & dat$supp == "VC"])
      
      data.frame(
        Dose = d,
        OJ_mean = oj,
        VC_mean = vc,
        OJ_minus_VC = oj - vc
      )
    })
    
    do.call(rbind, result)
  })
  
  output$selection_summary <- renderText({
    dat <- selected_data()
    
    sprintf(
      "%d animals in %d groups. Overall mean response: %.2f.",
      nrow(dat),
      nrow(group_summary()),
      mean(dat$len)
    )
  })
  
  output$group_summary <- renderTable({
    group_summary()
  }, digits = 2, striped = TRUE, spacing = "s")
  
  output$dose_comparison <- renderTable({
    dose_comparison()
  }, digits = 2, striped = TRUE, spacing = "s")
  
  output$growth_plot <- renderPlot({
    dat <- selected_data()
    
    grouping <- interaction(
      dat$supp,
      dat$dose,
      drop = TRUE,
      sep = " / "
    )
    
    values <- split(dat$len, grouping)
    
    colours <- ifelse(
      startsWith(names(values), "OJ"),
      "#147d70",
      "#e09b53"
    )
    
    par(mar = c(5, 5, 2, 1), las = 1)
    
    boxplot(
      values,
      col = adjustcolor(colours, alpha.f = 0.35),
      border = colours,
      outline = !isTRUE(input$show_points),
      ylim = c(0, max(datasets::ToothGrowth$len) + 3),
      ylab = "Tooth-growth response (recorded scale)",
      xlab = "Supplement / dose (mg/day)",
      main = "Responses within each selected group"
    )
    
    if (isTRUE(input$show_points)) {
      for (i in seq_along(values)) {
        offsets <- seq(
          -0.16, 0.16,
          length.out = length(values[[i]])
        )
        
        points(
          i + offsets,
          values[[i]],
          pch = 21,
          bg = colours[i],
          col = "white",
          cex = 1.15
        )
      }
    }
  }, res = 110)
  
  output$download_data <- downloadHandler(
    filename = function() {
      paste0("toothgrowth-dose-", input$dose, ".csv")
    },
    
    content = function(file) {
      write.csv(
        selected_data(),
        file,
        row.names = FALSE
      )
    }
  )
})

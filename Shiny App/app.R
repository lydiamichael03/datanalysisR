# ============================================================
# Gonorrhea Case Rates Explorer — Shiny App
# VTPEH 6270 | Checkpoint 07
# ============================================================

library(shiny)
library(ggplot2)
library(dplyr)

# ── Load data ──────────────────────────────────────────────
gonorrhea <- read.csv("gonorrhea_clean.csv", stringsAsFactors = FALSE)

age_order <- c("15-19","20-24","25-29","30-34","35-44","45-54","55-64","65+")
gonorrhea$age_group <- factor(gonorrhea$age_group, levels = age_order)
if (!"rate_log" %in% names(gonorrhea)) {
  gonorrhea$rate_log <- log10(gonorrhea$rate + 0.01)
}

# ── UI ─────────────────────────────────────────────────────
ui <- fluidPage(

  tags$head(tags$style(HTML("
    body { font-family: 'Georgia', serif; background-color: #f8f6f2; color: #2c2c2c; }
    h2   { color: #2c4a6e; border-bottom: 2px solid #2c4a6e; padding-bottom: 6px; }
    h4   { color: #5a5a5a; }
    .well { background-color: #eef2f7; border: 1px solid #c8d8ea; border-radius: 6px; }
    .btn-primary { background-color: #2c4a6e; border-color: #2c4a6e; }
    .btn-primary:hover { background-color: #1a3252; }
    .info-box { background:#eef2f7; border-left: 4px solid #2c4a6e;
                border-radius: 6px; padding: 16px 20px; margin-bottom: 16px; }
  "))),

  titlePanel(
    div(
      h2("Gonorrhea Case Rates in the United States"),
      h4("Interactive exploration of trends by sex, age group, and year (2000-2022)")
    )
  ),

  br(),

  fluidRow(
    column(
      width = 10, offset = 1,
      div(
        class = "info-box",
        h4("Background", style = "color:#2c4a6e; margin-top:0;"),
        p("Link to Relevant GitHub: https://github.com/lydiamichael03/datanalysisR.git"),
        p("Gonorrhea is a sexually transmitted infection (STI) caused by the bacterium ",
          em("Neisseria gonorrhoeae"), ". It is one of the most commonly reported
          infectious diseases in the United States, affecting the urogenital tract,
          rectum, and throat. If left untreated, gonorrhea can lead to serious health
          complications including pelvic inflammatory disease, infertility, and
          increased susceptibility to HIV."),
        p("After a period of decline in the early 2000s, gonorrhea rates in the U.S.
          have risen steadily since around 2009. Young adults aged 15-29 are
          disproportionately affected, and disparities by sex and age group remain
          pronounced. Growing antimicrobial resistance has further complicated
          treatment and surveillance efforts."),
        p("This app explores reported gonorrhea case rates per 100,000 population
          across sex and age groups from 2000 to 2022. Use the tabs below to examine
          trends over time, compare age groups within a given year, or browse the
          underlying data.")
      )
    )
  ),

  tabsetPanel(
    id = "tabs",

    tabPanel(
      "Trends Over Time",
      br(),
      sidebarLayout(
        sidebarPanel(
          width = 3,
          h4("Controls"),
          checkboxGroupInput("sel_sex_trend", "Sex:",
            choices = c("Male", "Female"), selected = c("Male", "Female")),
          checkboxGroupInput("sel_age_trend", "Age group(s):",
            choices = age_order, selected = c("20-24", "25-29")),
          radioButtons("y_scale", "Y-axis scale:",
            choices = c("Rate per 100,000" = "rate", "Log10(Rate)" = "rate_log"),
            selected = "rate"),
          br(),
          actionButton("update_trend", "Update Plot", class = "btn-primary btn-block")
        ),
        mainPanel(
          width = 9,
          plotOutput("trend_plot", height = "460px"),
          br(),
          div(class = "info-box",
            strong("How to read this chart: "),
            "Each line traces the reported case rate (cases per 100,000 population)
             over time for a selected sex x age-group combination.
             Use the log scale to compare groups with very different baseline rates.")
        )
      )
    ),

    tabPanel(
      "Age-Group Comparison",
      br(),
      sidebarLayout(
        sidebarPanel(
          width = 3,
          h4("Controls"),
          selectInput("sel_year_age", "Year:",
            choices = sort(unique(gonorrhea$year)), selected = 2022),
          radioButtons("sel_sex_age", "Sex:",
            choices = c("Male", "Female", "Both (side-by-side)" = "Both"),
            selected = "Both"),
          br(),
          actionButton("update_age", "Update Plot", class = "btn-primary btn-block")
        ),
        mainPanel(
          width = 9,
          plotOutput("age_plot", height = "460px"),
          br(),
          div(class = "info-box",
            strong("How to read this chart: "),
            "Bars show the case rate per 100,000 for each age group in the selected year.
             Choose 'Both' to compare male and female rates side-by-side.")
        )
      )
    ),

    tabPanel(
      "Summary Table",
      br(),
      sidebarLayout(
        sidebarPanel(
          width = 3,
          h4("Filters"),
          selectInput("tbl_sex", "Sex:",
            choices = c("All", "Male", "Female"), selected = "All"),
          selectInput("tbl_age", "Age group:",
            choices = c("All", age_order), selected = "All"),
          br(),
          actionButton("update_tbl", "Apply Filters", class = "btn-primary btn-block"),
          br(), br(),
          downloadButton("dl_tbl", "Download CSV")
        ),
        mainPanel(
          width = 9,
          tableOutput("summary_tbl")
        )
      )
    ),

    tabPanel(
      "About & References",
      br(),
      fluidRow(
        column(
          width = 8, offset = 1,

          div(
            class = "info-box",
            h4("Author", style = "color:#2c4a6e; margin-top:0;"),
            p("Lydia Michael"),
            p("VTPEH 6270 | Cornell University")
          ),

          br(),

          div(
            class = "info-box",
            h4("Research Question", style = "color:#2c4a6e; margin-top:0;"),
            p("How have gonorrhea case rates in the United States changed between
              2000 and 2022, and do trends differ by sex and age group?")
          ),

          br(),

          div(
            class = "info-box",
            h4("Data Source", style = "color:#2c4a6e; margin-top:0;"),
            p("Data were obtained from the ",
              strong("CDC Division of STD Prevention"),
              " — National Overview of STDs, 2022. Case counts and rates per 100,000
              population are stratified by sex and age group for the years 2000-2022."),
            p(a("CDC STD Surveillance Data",
                href = "https://www.cdc.gov/std/statistics/",
                target = "_blank"))
          ),

          br(),

          div(
            class = "info-box",
            h4("Methods", style = "color:#2c4a6e; margin-top:0;"),
            p("Reported gonorrhea case rates (cases per 100,000 population) were
              extracted and cleaned from CDC national surveillance tables. Data were
              stratified by biological sex (male/female) and age group (15-19, 20-24,
              25-29, 30-34, 35-44, 45-54, 55-64, 65+). A log10 transformation is
              available in the trend plot to aid visualization of groups with large
              differences in absolute rates. No statistical modeling was performed;
              this app is intended for descriptive data exploration.")
          ),

          br(),

          div(
            class = "info-box",
            h4("AI Disclosure", style = "color:#2c4a6e; margin-top:0;"),
            p("Claude (Anthropic) was used to assist in writing and debugging the
              R Shiny code for this application. All data, research question, and
              interpretation are the work of the author. AI-generated code was
              reviewed and edited by the author prior to submission.")
          )
        )
      )
    )
  )
)

# ── Server ─────────────────────────────────────────────────
server <- function(input, output, session) {

  trend_data <- eventReactive(input$update_trend, {
    req(input$sel_sex_trend, input$sel_age_trend)
    gonorrhea %>%
      filter(sex %in% input$sel_sex_trend,
             as.character(age_group) %in% input$sel_age_trend)
  }, ignoreNULL = FALSE)

  output$trend_plot <- renderPlot({
    df <- trend_data()
    req(nrow(df) > 0)
    y_var   <- isolate(input$y_scale)
    y_label <- if (y_var == "rate") "Rate per 100,000" else "Log10(Rate per 100,000)"
    df$group_label <- paste(df$sex, df$age_group, sep = " | ")
    ggplot(df, aes(x = year, y = .data[[y_var]],
                   color = group_label, group = group_label)) +
      geom_line(linewidth = 1.1) +
      geom_point(size = 2.5) +
      scale_x_continuous(breaks = sort(unique(gonorrhea$year))) +
      labs(title = "Gonorrhea Case Rates Over Time",
           x = "Year", y = y_label, color = "Sex | Age Group") +
      theme_minimal(base_size = 13) +
      theme(plot.title = element_text(face = "bold", color = "#2c4a6e"),
            axis.text.x = element_text(angle = 45, hjust = 1),
            legend.position = "right",
            panel.grid.minor = element_blank())
  })

  age_data <- eventReactive(input$update_age, {
    df <- gonorrhea %>% filter(year == as.integer(input$sel_year_age))
    if (input$sel_sex_age != "Both") df <- df %>% filter(sex == input$sel_sex_age)
    df
  }, ignoreNULL = FALSE)

  output$age_plot <- renderPlot({
    df <- age_data()
    req(nrow(df) > 0)
    yr <- isolate(input$sel_year_age)
    if (isolate(input$sel_sex_age) == "Both") {
      p <- ggplot(df, aes(x = age_group, y = rate, fill = sex)) +
        geom_col(position = "dodge", width = 0.7) +
        scale_fill_manual(values = c("Male" = "#2c4a6e", "Female" = "#b5473a"))
    } else {
      fill_col <- if (isolate(input$sel_sex_age) == "Male") "#2c4a6e" else "#b5473a"
      p <- ggplot(df, aes(x = age_group, y = rate)) +
        geom_col(fill = fill_col, width = 0.65)
    }
    p + labs(title = paste("Gonorrhea Case Rates by Age Group -", yr),
             x = "Age Group", y = "Rate per 100,000", fill = "Sex") +
      theme_minimal(base_size = 13) +
      theme(plot.title = element_text(face = "bold", color = "#2c4a6e"),
            panel.grid.minor = element_blank())
  })

  tbl_data <- eventReactive(input$update_tbl, {
    df <- gonorrhea
    if (input$tbl_sex != "All") df <- df %>% filter(sex == input$tbl_sex)
    if (input$tbl_age != "All") df <- df %>% filter(as.character(age_group) == input$tbl_age)
    df %>%
      select(Year = year, Sex = sex, `Age Group` = age_group,
             Cases = cases, `Rate per 100k` = rate, Population = population) %>%
      arrange(Year, Sex, `Age Group`)
  }, ignoreNULL = FALSE)

  output$summary_tbl <- renderTable({
    tbl_data()
  }, striped = TRUE, hover = TRUE, bordered = TRUE)

  output$dl_tbl <- downloadHandler(
    filename = function() {
      paste0("gonorrhea_filtered_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(tbl_data(), file, row.names = FALSE)
    }
  )

}

# ── Launch ──────────────────────────────────────────────────
shinyApp(ui = ui, server = server)

# ============================================================
# Gonorrhea Case Rates Explorer — Shiny App
# VTPEH 6270 | Checkpoint 07
# ============================================================

library(shiny)
library(ggplot2)
library(dplyr)

# ── Load data ──────────────────────────────────────────────
gonorrhea <- read.csv("gonorrhea_clean.csv", stringsAsFactors = FALSE)

# Ordered age-group factor for clean axes
age_order <- c("15-19","20-24","25-29","30-34","35-44","45-54","55-64","65+")
gonorrhea$age_group <- factor(gonorrhea$age_group, levels = age_order)

# ── UI ─────────────────────────────────────────────────────
ui <- fluidPage(

  # ---------- Styling ----------
  tags$head(tags$style(HTML("
    body { font-family: 'Georgia', serif; background-color: #f8f6f2; color: #2c2c2c; }
    h2   { color: #2c4a6e; border-bottom: 2px solid #2c4a6e; padding-bottom: 6px; }
    h4   { color: #5a5a5a; }
    .well { background-color: #eef2f7; border: 1px solid #c8d8ea; border-radius: 6px; }
    .btn-primary { background-color: #2c4a6e; border-color: #2c4a6e; }
    .btn-primary:hover { background-color: #1a3252; }
  "))),

  # ---------- Header ----------
  titlePanel(
    div(
      h2("Gonorrhea Case Rates in the United States"),
      h4("Interactive exploration of trends by sex, age group, and year (2000–2022)")
    )
  ),

  br(),

  # ---------- Tabbed layout ----------
  tabsetPanel(
    id = "tabs",

    # ══════════════════════════════════════════
    # TAB 1 — Trends Over Time
    # ══════════════════════════════════════════
    tabPanel(
      "Trends Over Time",
      br(),
      sidebarLayout(
        sidebarPanel(
          width = 3,

          h4("Controls"),

          checkboxGroupInput(
            "sel_sex_trend",
            "Sex:",
            choices  = c("Male", "Female"),
            selected = c("Male", "Female")
          ),

          checkboxGroupInput(
            "sel_age_trend",
            "Age group(s):",
            choices  = age_order,
            selected = c("20-24", "25-29")
          ),

          radioButtons(
            "y_scale",
            "Y-axis scale:",
            choices  = c("Rate per 100,000" = "rate",
                         "Log10(Rate)"       = "rate_log"),
            selected = "rate"
          ),

          br(),
          actionButton("update_trend", "Update Plot",
                       class = "btn-primary btn-block")
        ),

        mainPanel(
          width = 9,
          plotOutput("trend_plot", height = "460px"),
          br(),
          div(
            style = "background:#eef2f7; border-radius:6px; padding:12px;",
            strong("How to read this chart: "),
            "Each line traces the reported case rate (cases per 100,000 population)
             over time for a selected sex × age-group combination.
             Use the log scale to compare groups with very different baseline rates."
          )
        )
      )
    ),

    # ══════════════════════════════════════════
    # TAB 2 — Age-Group Comparison
    # ══════════════════════════════════════════
    tabPanel(
      "Age-Group Comparison",
      br(),
      sidebarLayout(
        sidebarPanel(
          width = 3,

          h4("Controls"),

          selectInput(
            "sel_year_age",
            "Year:",
            choices  = sort(unique(gonorrhea$year)),
            selected = 2022
          ),

          radioButtons(
            "sel_sex_age",
            "Sex:",
            choices  = c("Male", "Female", "Both (side-by-side)" = "Both"),
            selected = "Both"
          ),

          br(),
          actionButton("update_age", "Update Plot",
                       class = "btn-primary btn-block")
        ),

        mainPanel(
          width = 9,
          plotOutput("age_plot", height = "460px"),
          br(),
          div(
            style = "background:#eef2f7; border-radius:6px; padding:12px;",
            strong("How to read this chart: "),
            "Bars show the case rate per 100,000 for each age group in the
             selected year. Choose 'Both' to compare male and female rates
             side-by-side within each age group."
          )
        )
      )
    ),

    # ══════════════════════════════════════════
    # TAB 3 — Summary Statistics
    # ══════════════════════════════════════════
    tabPanel(
      "Summary Table",
      br(),
      sidebarLayout(
        sidebarPanel(
          width = 3,

          h4("Filters"),

          selectInput(
            "tbl_sex",
            "Sex:",
            choices  = c("All", "Male", "Female"),
            selected = "All"
          ),

          selectInput(
            "tbl_age",
            "Age group:",
            choices  = c("All", age_order),
            selected = "All"
          ),

          br(),
          actionButton("update_tbl", "Apply Filters",
                       class = "btn-primary btn-block"),
          br(), br(),
          downloadButton("dl_tbl", "Download CSV")
        ),

        mainPanel(
          width = 9,
          tableOutput("summary_tbl")
        )
      )
    )
  )
)

# ── Server ─────────────────────────────────────────────────
server <- function(input, output, session) {

  # ── Tab 1: Trend plot ────────────────────────────────────
  trend_data <- eventReactive(input$update_trend, {
    gonorrhea %>%
      filter(sex %in% input$sel_sex_trend,
             age_group %in% input$sel_age_trend)
  }, ignoreNULL = FALSE)

  output$trend_plot <- renderPlot({
    df <- trend_data()
    req(nrow(df) > 0)

    y_var   <- input$y_scale
    y_label <- if (y_var == "rate") "Rate per 100,000" else "Log10(Rate per 100,000)"

    df$group_label <- paste(df$sex, df$age_group, sep = " | ")

    ggplot(df, aes(x = year, y = .data[[y_var]],
                   color = group_label, group = group_label)) +
      geom_line(linewidth = 1.1) +
      geom_point(size = 2.5) +
      scale_x_continuous(breaks = sort(unique(gonorrhea$year))) +
      labs(title  = "Gonorrhea Case Rates Over Time",
           x      = "Year",
           y      = y_label,
           color  = "Sex | Age Group") +
      theme_minimal(base_size = 13) +
      theme(
        plot.title      = element_text(face = "bold", color = "#2c4a6e"),
        axis.text.x     = element_text(angle = 45, hjust = 1),
        legend.position = "right",
        panel.grid.minor = element_blank()
      )
  })

  # ── Tab 2: Age-group bar chart ───────────────────────────
  age_data <- eventReactive(input$update_age, {
    df <- gonorrhea %>% filter(year == as.integer(input$sel_year_age))
    if (input$sel_sex_age != "Both") {
      df <- df %>% filter(sex == input$sel_sex_age)
    }
    df
  }, ignoreNULL = FALSE)

  output$age_plot <- renderPlot({
    df <- age_data()
    req(nrow(df) > 0)

    yr <- input$sel_year_age

    if (input$sel_sex_age == "Both") {
      p <- ggplot(df, aes(x = age_group, y = rate, fill = sex)) +
        geom_col(position = "dodge", width = 0.7) +
        scale_fill_manual(values = c("Male" = "#2c4a6e", "Female" = "#b5473a"))
    } else {
      fill_col <- if (input$sel_sex_age == "Male") "#2c4a6e" else "#b5473a"
      p <- ggplot(df, aes(x = age_group, y = rate)) +
        geom_col(fill = fill_col, width = 0.65)
    }

    p +
      labs(title  = paste("Gonorrhea Case Rates by Age Group —", yr),
           x      = "Age Group",
           y      = "Rate per 100,000",
           fill   = "Sex") +
      theme_minimal(base_size = 13) +
      theme(
        plot.title       = element_text(face = "bold", color = "#2c4a6e"),
        panel.grid.minor = element_blank()
      )
  })

  # ── Tab 3: Summary table ─────────────────────────────────
  tbl_data <- eventReactive(input$update_tbl, {
    df <- gonorrhea
    if (input$tbl_sex != "All")
      df <- df %>% filter(sex == input$tbl_sex)
    if (input$tbl_age != "All")
      df <- df %>% filter(age_group == input$tbl_age)
    df %>%
      select(Year = year, Sex = sex, `Age Group` = age_group,
             Cases = cases, `Rate per 100k` = rate,
             Population = population) %>%
      arrange(Year, Sex, `Age Group`)
  }, ignoreNULL = FALSE)

  output$summary_tbl <- renderTable({
    tbl_data()
  }, striped = TRUE, hover = TRUE, bordered = TRUE)

  output$dl_tbl <- downloadHandler(
    filename = function() paste0("gonorrhea_filtered_", Sys.Date(), ".csv"),
    content  = function(file) write.csv(tbl_data(), file, row.names = FALSE)
  )
}

# ── Launch ──────────────────────────────────────────────────
shinyApp(ui = ui, server = server)
library(rsconnect)
rsconnect::deployApp('Users/Lydia/Dowloads/app.R')

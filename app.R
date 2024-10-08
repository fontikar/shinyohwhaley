# Install ohwhaley package from GitHub if not already installed:
# install.packages("remotes")
# remotes::install_github("fontikar/ohwhaley")

library(shiny)
library(bslib)
library(ohwhaley)
library(clipr)

# Custom underwater theme
underwater_theme <- bs_theme(
  bg = "#E6F3FF",  # Light blue background
  fg = "#05445E",  # Dark blue text
  primary = "#189AB4",  # Medium blue for primary elements
  secondary = "#75E6DA",  # Light teal for secondary elements
  success = "#2E8B57",  # Sea green for success messages
  base_font = "Arial",
  heading_font = "Verdana",
  font_scale = 0.9
)

# Add custom CSS for underwater effect and hex sticker
underwater_css <- "
body {
  background-image: linear-gradient(to bottom, #E6F3FF, #B5D8FF);
  background-attachment: fixed;
}
.card {
  background-color: rgba(255, 255, 255, 0.7);
  border: none;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}
#hex-sticker {
  width: 100px;
  height: 100px;
  margin-right: 15px;
}
#app-title {
  display: flex;
  align-items: center;
}
"

ui <- page_sidebar(
  theme = underwater_theme,
  title = div(id = "app-title",
              img(id = "hex-sticker", src = "https://raw.githubusercontent.com/fontikar/ohwhaley/master/inst/figures/imgfile.png", alt = "ohwhaley hex sticker"),
              "{ohwhaley} Messages with a whale-esque flair"),
  sidebar = sidebar(
    textInput("whale_text", "Enter your message (optional):"),
    actionButton("say_button", "Say it!", class = "btn-primary")
  ),
  mainPanel(
    card(
      card_header("Whale Output"),
      verbatimTextOutput("whale_output"),
      actionButton("copy_button", "Copy to Clipboard", class = "btn-secondary mt-3")
    )
  ),
  tags$head(tags$style(HTML(underwater_css)))
)

server <- function(input, output, session) {
  whale_message <- reactiveVal("")
  
  observeEvent(input$say_button, {
    # Capture the message output without printing
    whale_output <- capture.output({
      if (nchar(trimws(input$whale_text)) > 0) {
        temp <- say(input$whale_text)
      } else {
        temp <- say()  # Use default message
      }
    }, type = "message")
    
    whale_message(paste(whale_output, collapse = "\n"))
  })
  
  output$whale_output <- renderPrint({
    cat(whale_message())
  })
  
  observeEvent(input$copy_button, {
    if (whale_message() != "") {
      clipr::write_clip(whale_message())
      showNotification("Copied to clipboard!", type = "message")
    } else {
      showNotification("Nothing to copy. Generate a message first!", type = "warning")
    }
  })
}

shinyApp(ui, server)

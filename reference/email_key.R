library(dplyr)
library(glue)
library(rmarkdown)
library(sendmailR)
library(writexl)

# Get dataset
data <- readr::read_csv("dataset.csv")
providers <- sort(unique(data$provider))

email_provider <- function(provider) {
  # Render R Markdown
  rmarkdown::render("report.Rmd", params = list(provider = provider))
  
  # Write Excel file
  data_for_provider <- dplyr::filter(data, provider == !!provider)
  writexl::write_xlsx(data_for_provider, "data.xlsx")
  
  
  # Create HTML email body
  body <- sendmailR::mime_part('<p>Please see the attached report</p>')
  body[["headers"]][["Content-Type"]] <- "text/html"
  
  # Set attachments
  attachments <- list(
    sendmailR::mime_part("report.html"),
    sendmailR::mime_part("data.xlsx")
  )
  
  # Send email
  # NOTE: You will need a valid SMTP server to send an email
  #sendmailR::sendmail(
  #  from = "reporting@chop.edu",
  #  to = "mirizioj@chop.edu",
  #  subject = glue::glue("Physician Report - {provider}"),
  #  msg = c(body, attachments),
  #  control = list(smtpServer = "smtp.server.com")
  #)
}

lapply(providers, email_provider)

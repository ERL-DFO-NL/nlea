#' Download and Extract a FRDR Dataset via DOI
#'
#' This function downloads all files from a dataset hosted on the
#' Federated Research Data Repository (FRDR) using its DOI.
#' If the dataset contains multiple files, the function retrieves
#' the "Download as Zip" link, downloads the ZIP archive, extracts
#' its contents, and optionally reads all CSV files into R.
#'
#' @param doi Character string. The DOI of the FRDR dataset
#'   (e.g., `"10.20383/103.0969"`).
#' @param dest_dir Character string. The directory where the downloaded
#'   ZIP file and extracted contents will be stored. If it does not exist,
#'   it will be created.
#'
#' @return A named list of data frames containing the contents of all
#'   CSV files found in the extracted dataset. The list names correspond
#'   to the CSV file names. If no CSV files are found, returns an empty list.
#'   Returns `NULL` if an error occurs.
#'
#' @details
#' The function performs the following steps:
#' \enumerate{
#'   \item Resolves the DOI to the FRDR dataset landing page.
#'   \item Parses the HTML to locate the "Download as Zip" link.
#'   \item Downloads the ZIP archive containing all dataset files.
#'   \item Extracts the files into the specified destination directory.
#'   \item Reads all `.csv` files into R as data frames.
#' }
#'
#' This function assumes the dataset is publicly accessible. If the
#' "Download as Zip" link redirects to Globus for large datasets,
#' manual download or Globus CLI may be required.
#'
#' @examples
#' \dontrun{
#' # Download and extract dataset
#' doi <- "10.20383/103.0969"
#' output_dir <- "frdr_download"
#' data_list <- download_frdr_dataset(doi, output_dir)
#'
#' # Preview first dataset
#' if (!is.null(data_list) && length(data_list) > 0) {
#'   head(data_list[[1]])
#' }
#' }
#'
#' @import httr readr xml2
#' @export

# Required packages
# install.packages(c("httr", "readr", "xml2"))
library(httr)
library(readr)
library(xml2)

download_frdr_dataset <- function(doi, dest_dir) {
  tryCatch({
    # Step 1: Resolve DOI to FRDR landing page
    doi_url <- paste0("https://doi.org/", doi)
    landing_resp <- GET(doi_url)
    if (status_code(landing_resp) != 200) {
      stop("Failed to resolve DOI. HTTP status: ", status_code(landing_resp))
    }
    landing_page <- content(landing_resp, "text")

    # Step 2: Parse HTML to find "Download as Zip" link
    html <- read_html(landing_page)
    zip_link <- xml_find_first(html, "//a[contains(text(), 'Download as Zip')]")
    if (is.na(zip_link)) {
      stop("Could not find 'Download as Zip' link on FRDR page.")
    }
    zip_url <- xml_attr(zip_link, "href")

    # Step 3: Download ZIP file
    if (!dir.exists(dest_dir)) dir.create(dest_dir, recursive = TRUE)
    zip_path <- file.path(dest_dir, "frdr_dataset.zip")
    message("Downloading ZIP from: ", zip_url)
    zip_resp <- GET(zip_url)
    if (status_code(zip_resp) != 200) {
      stop("Failed to download ZIP. HTTP status: ", status_code(zip_resp))
    }
    writeBin(content(zip_resp, "raw"), zip_path)
    message("ZIP downloaded: ", zip_path)

    # Step 4: Unzip files
    unzip(zip_path, exdir = dest_dir)
    message("Files extracted to: ", dest_dir)

    # Step 5: Optionally read CSV files
    csv_files <- list.files(dest_dir, pattern = "\\.csv$", full.names = TRUE)
    datasets <- lapply(csv_files, function(f) {
      read_csv(f, show_col_types = FALSE)
    })
    names(datasets) <- basename(csv_files)

    return(datasets)
  }, error = function(e) {
    message("Error: ", e$message)
    return(NULL)
  })
}

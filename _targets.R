# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline # nolint

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes) # Load other packages as needed. # nolint

# Set target options:
tar_option_set(
  packages = c(
    "tibble",
    "dplyr",
    "rtweet",
    "stringr",
    "tidyr",
    "ggplot2",
    "here",
    "readr",
    "forcats",
    "lubridate",
    "glue"
  ),
  # packages that your targets need to run
  format = "rds" # default storage format
  # Set other options as needed.
)

# tar_make_clustermq() configuration (okay to leave alone):
options(clustermq.scheduler = "multicore")

# tar_make_future() configuration (okay to leave alone):
future::plan(future.callr::callr)

# Load the R scripts with your custom functions:
lapply(list.files("R", full.names = TRUE, recursive = TRUE), source)
# source("other_functions.R") # Source other scripts as needed. # nolint

# Replace the target list below with your own:
list(
  tar_target(
    name = data,
    command = get_tweets(
      limit = 5000,
      start_date = as.character(lubridate::today() - 7),
      end_date = as.character(today())
    )
  ),
  tar_target(isolated,
             isolate_tweets(data)),
  tar_target(pkg_mentions,
             wrangle_tweets(isolated)),
  tar_target(tweets_plot,
             plot_tweet_freq(pkg_mentions)),
  tar_target(pos_gran_links,
             gen_cran_links(pkg_mentions)),
  tar_render(readme, "README.Rmd")
)
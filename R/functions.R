get_tweets <- function(hashtags = c("#rstats"),
                       limit = 100,
                       start_date = as.character(lubridate::today()-7),
                       end_date = as.character(today()) ) {
  all_tweets <- search_tweets2(hashtags,
                               include_rts = FALSE,
                               type = "mixed",
                               n = limit,
                               since = start_date,
                               until = end_date)
  return(all_tweets)
}

isolate_tweets <- function(all_tweets) {
  tweets <- all_tweets %>%
    select(matches("text")) %>%
    select(1)
  return(tweets)
}

wrangle_tweets <- function(tweets, pat = "\\{[A-Za-z0-9\\.]*\\}") {
  packageMentions <- tweets %>%
    mutate(et = str_extract_all(text, pat)) %>%
    filter(str_detect(text, pat)) %>%
    select(et) %>%
    unnest(cols = c(et)) %>%
    mutate(et = str_remove_all(et, "\\{|\\}")) %>%
    count(et, sort = TRUE) %>%
    filter(!is.na(et)) %>%
    mutate(et = fct_reorder(et, n))
  return(packageMentions)
}

gen_cran_links <- function(packageMentions) {
  cranBaseURL <- "https://cran.r-project.org/web/packages/"
  cran_links <- packageMentions %>%
    mutate(cran_link = str_c(cranBaseURL, et, "/", sep = ""))
  return(cran_links)
}

save_all_tweets <- function(all_tweets) {
  data_path <- here("data", "all_tweets.RDS")
  write_rds(all_tweets, data_path)
  return(data_path)
}

save_wrangle_tweets <- function(packageMentions) {
  data_path <- here("data", "package_mentions.RDS")
  write_rds(packageMentions, data_path)
  return(data_path)
}

plot_tweet_freq <-
  function(packageMentions,
           limit = 10,
           hashtag = "#rstats") {
    df <- packageMentions
    df %>% slice_max(n, n = limit) %>%
      ggplot(., aes(n, et)) +
      geom_col(fill = "lightblue", color = "black") +
      labs(
        title = glue(
          "{limit} most mentioned packages on {hashtag} Twitter in last few days"
        ),
        y = "Package",
        x = "Count"
      )
  }

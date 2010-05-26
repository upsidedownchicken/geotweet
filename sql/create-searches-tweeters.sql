CREATE TABLE searches_tweeters (
  search_id int unsigned not null,
  tweeter_id int unsigned not null,
  created timestamp not null default CURRENT_TIMESTAMP,
  PRIMARY KEY (search_id, tweeter_id),
  KEY tweeter_index (tweeter_id)
);

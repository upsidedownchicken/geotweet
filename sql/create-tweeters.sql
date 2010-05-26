CREATE TABLE tweeters (
  id int unsigned not null auto_increment primary key,
  uri varchar(255) not null,
  name varchar(255),
  location varchar(255),
  UNIQUE unique_uri (uri)
);

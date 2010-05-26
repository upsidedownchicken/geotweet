CREATE TABLE searches (
  id int unsigned not null auto_increment primary key,
  name varchar(255) not null,
  url varchar(255) not null,
  last_id varchar(255) not null,
  UNIQUE unique_name (name)
);

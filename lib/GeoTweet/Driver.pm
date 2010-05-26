package GeoTweet::Driver;

use Data::ObjectDriver ();
use Data::ObjectDriver::Driver::DBI ();

sub driver {
  Data::ObjectDriver::Driver::DBI->new(
    dsn => 'dbi:mysql:geotweet',
    username => 'geotweet',
    password => 'n0 yer not 4free',
  );
}

1;

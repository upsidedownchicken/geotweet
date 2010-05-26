package GeoTweet::Search;

use base qw/Data::ObjectDriver::BaseObject/;

use GeoTweet::Driver;
use GeoTweet::SearchesTweeters;
use GeoTweet::Tweeter;
use GeoTweet::Twitter;
use Log::Log4perl;

__PACKAGE__->install_properties({
  columns => [ 'id', 'name', 'url', 'last_id' ],
  datasource => 'searches',
  primary_key => 'id',
  driver => GeoTweet::Driver->driver,
});

1;

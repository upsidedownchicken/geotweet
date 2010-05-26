package GeoTweet::Tweeter;

use base qw/Data::ObjectDriver::BaseObject/;

use GeoTweet::Driver;

__PACKAGE__->install_properties({
  columns => [ 'id', 'uri', 'name', 'location' ],
  datasource => 'tweeters',
  primary_key => 'id',
  driver => GeoTweet::Driver->driver,
});

1;

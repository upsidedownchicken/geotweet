package GeoTweet::ZipCode;

use base qw/Data::ObjectDriver::BaseObject/;

__PACKAGE__->install_properties({
  columns => [ 'id', 'zip', 'latitude', 'longitude', 'city', 'state', 'fullstate', 'county', 'zipclass' ],
  datasource => 'zipcodes',
  primary_key => 'id',
  driver => GeoTweet::Driver->driver,
});

1;

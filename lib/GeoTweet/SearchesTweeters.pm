package GeoTweet::SearchesTweeters;

use base qw/Data::ObjectDriver::BaseObject/;

use GeoTweet::Driver;

__PACKAGE__->install_properties({
  columns => [ 'search_id', 'tweeter_id', 'created' ],
  datasource => 'searches_tweeters',
  primary_key => [ 'search_id', 'tweeter_id' ],
  driver => GeoTweet::Driver->driver,
});

sub latest_by_search_id {
  my( $class, $id ) = @_;

  my @st = GeoTweet::SearchesTweeters->search( {search_id => $id}, {
    group => 'tweeter_id',
    'sort' => 'created',
    direction => 'descend',
    limit => 20,
  });

  return \@st;
}

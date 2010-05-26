package GeoTweet::FrontController;

use strict;
use warnings;

use Apache2::RequestRec ();
use Apache2::RequestIO ();
use Apache2::Const -compile => qw/OK NOT_FOUND/;

use GeoTweet::Driver;
use GeoTweet::Search;
use GeoTweet::SearchesTweeters;
use GeoTweet::Tweeter;
use GeoTweet::Twitter;

use Data::Dump qw/dump/;
use JSON ();
use Log::Log4perl;

my $DEFAULT_RANGE = 10;

sub handler {
  my $r = shift;
  my $log = Log::Log4perl->get_logger;

  (my $q = $r->path_info) =~ s/^\///mosx;

  unless( defined $q ){
    return Apache2::Const::NOT_FOUND;
  }

  my @searches = GeoTweet::Search->search({ name => $q });
  my $search = $searches[0] if @searches;

  unless( @searches ){
    my $feed_url = GeoTweet::Twitter->feed_url( $q );
    return Apache2::Const::NOT_FOUND unless $feed_url;

    $search = GeoTweet::Search->new;
    $search->name( $q );
    $search->url( $feed_url );
    $search->last_id( 0 );
    $search->save;

    GeoTweet::Twitter->incremental_check_for_new_users( $search );
  }

  my $search_tweeters = GeoTweet::SearchesTweeters->latest_by_search_id( $search->id );
  my @ids = map { $_->tweeter_id } @$search_tweeters;
  my $tweeters = GeoTweet::Tweeter->lookup_multi( \@ids );
  my @out = ();

  for my $i ( 0..$#{$tweeters} ){
    my $tweeter = $tweeters->[$i];
    push @out, {
      uri => $tweeter->uri,
      name => $tweeter->name,
      location => $tweeter->location,
    };
  }

  my $json = JSON->new;
  print $json->encode({ tweeters => \@out });

  return Apache2::Const::OK;
}

1;
__END__
sub _handler {
  my $r = shift;
  my %query = ();

  ## parse query string
  #my @pairs = split /&/, $r->args;
  #my %qs = map { split /=/, $_ } @pairs;

  ## parse path
  {
    if( $r->path_info =~ m/^\/(\d+)\/?(\d*)/mosx ){
      $query{zip} = $1;
      $query{range} = $2 || $DEFAULT_RANGE;
    }

    unless( defined $query{zip} ){
      return Apache2::Const::NOT_FOUND;
    }
  }

  my @zipcodes = GeoTweet::ZipCode->search({ zip => $query{zip} });

  unless( @zipcodes ){
    return Apache2::Const::NOT_FOUND;
  }

  ($query{latitude} = $zipcodes[0]->latitude) =~ s/^\+//mosx;
  $query{longitude} = $zipcodes[0]->longitude;
  $query{zip_id} = $zipcodes[0]->id;
  $query{page} = 1;

  my $tweeters = GeoTweet::Twitter->search( \%query );
  my @tweetzips = GeoTweet::TweetersZipCodes->search({ zip => $query{zip} });

  if( @tweetzips ){
    my @ids = map { $_->tweeter_id } @tweetzips;
    my @tweeters = GeoTweet::Tweeters->lookup_multi( \@ids );
    $tweeters = \@tweeters;
  }

  my $json = JSON->new->allow_blessed(1)->convert_blessed(1);

  print $json->encode({ tweeters => $tweeters });
  return Apache2::Const::OK;
}

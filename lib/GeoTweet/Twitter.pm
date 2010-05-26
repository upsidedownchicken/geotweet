package GeoTweet::Twitter;

use strict;
use warnings;

use GeoTweet::Search;
use GeoTweet::SearchesTweeters;
use GeoTweet::Tweeter;
use Log::Log4perl;
use XML::FeedPP ();
use WWW::Mechanize;

sub incremental_check_for_new_users {
  my( $class, $search ) = @_;
  my $log = Log::Log4perl->get_logger;
  my %uniques;

  for my $i ( 1..3 ){
    sleep( 1 ) unless $i == 1;
    $log->debug( qq/page $i/ );
    my $tweets = GeoTweet::Twitter->search_atom({ url => $search->url, page => $i });
    next unless @$tweets;
    $log->debug( 'Found '.@$tweets.' tweets' );
    for my $tweet ( @$tweets ){
      $uniques{ $tweet->{uri} } = $tweet unless exists $uniques{ $tweet->{uri} };
    }
    last if @$tweets < 100;
  }

  $log->debug( 'Found '. scalar (keys %uniques) . ' uniques' );

  for my $tweet ( values %uniques ){
    my $tweeter = GeoTweet::Twitter->save_user( $tweet );
    GeoTweet::Twitter->save_search_tweeter( $search, $tweeter );
  }

  return \%uniques;
}

sub feed_url {
  my( $class, $query ) = @_;
  my $log = Log::Log4perl->get_logger;

  my $url = qq{http://search.twitter.com/search?near="$query"};
  my $mech = WWW::Mechanize->new;
  my $response = $mech->get( $url );
  my $atom_link = $mech->find_link( text => 'Feed for this query' );

  return undef unless $atom_link;
  return $atom_link->url_abs;
}

sub save_search_tweeter {
  my( $class, $search, $tweeter ) = @_;
  my $log = Log::Log4perl->get_logger;
    my( $search_tweeter ) = GeoTweet::SearchesTweeters->search({
      search_id => $search->id,
      tweeter_id => $tweeter->id,
    });

    unless( $search_tweeter ){
      $search_tweeter = GeoTweet::SearchesTweeters->new;
      $search_tweeter->search_id( $search->id );
      $search_tweeter->tweeter_id( $tweeter->id );
      $search_tweeter->save;

      $log->debug( $search_tweeter->search_id . '-' . $search_tweeter->tweeter_id );
    }
}

sub save_user {
  my( $class, $tweet ) = @_;
  my( $tweeter ) = GeoTweet::Tweeter->search({ uri => $tweet->{uri} });
  my $log = Log::Log4perl->get_logger;

  unless( $tweeter ){
	  $tweeter = GeoTweet::Tweeter->new;
	  $tweeter->uri( $tweet->{uri} );
	  $tweeter->name( $tweet->{name} );
	  $tweeter->location( $tweet->{location} );
	  $tweeter->save;

    $log->debug( $tweeter->uri );
  }

  return $tweeter;
}

sub search_atom {
  my( $class, $args ) = @_;
  my $url = $args->{url};
  my $page = $args->{page} || 1;
  my $feed = XML::FeedPP->new( $url . '&rpp=100&page=' . $page );
  my @tweets = ();

  for my $item ( $feed->get_item ){
    my( $uri, $name ) = split /\s\(/mosx, $item->author;
    $name =~ s/\)$//mosx;
    push @tweets, {
      uri => $item->get('author/uri'),
      name => $name,
      location => $item->get('google:location'),
    };
  }

  return \@tweets;
}

1;

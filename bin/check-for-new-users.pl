#!/usr/bin/perl -w
use strict;
use lib qw(/home/john/projects/geotweet/lib);

use Data::Dump qw/dump/;
use GeoTweet::Search;
use GeoTweet::Twitter;
use Log::Log4perl;

Log::Log4perl->init_once( '/home/john/projects/geotweet/log.conf' );

my $log = Log::Log4perl->get_logger;
my $iter = GeoTweet::Search->search( {} );

while( my $search = $iter->next ){
  $log->debug( $search->name . ' ' . $search->url );
  GeoTweet::Twitter->incremental_check_for_new_users( $search );
}

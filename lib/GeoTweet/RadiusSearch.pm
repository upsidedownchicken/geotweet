package GeoTweet::RadiusSearch;

use strict;
use warnings;

## lifted from http://maps.huge.info/blog/2007/07/doing_a_radius_search_code.html

sub search {
  my( $class, $radius, $clat, $clng ) = @_;
	my $PI = 3.141593 ;
	my $d2r = $PI/180 ;
	my $r2d = 180/$PI ;
	my $lat = ($radius/3963) * $r2d ;
	my $lng = $lat/cos($clat * $d2r);
	my @points = ( ) ;
	my $i = 0 ;
	my $x = '' ;
	my $y = '' ;
	
	for ($i = 0 ; $i < 13 ; $i++)
	{
	  $y = sprintf("%0.6f",$clng + ($lng * cos($PI * ($i/6)))) ;
	  $x = sprintf("%0.6f",$clat + ($lat * sin($PI * ($i/6)))) ;
	  push( @points, [$x,$y] ) ;
	}

  return \@points;
}

1;

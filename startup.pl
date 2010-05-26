use lib qw( /home/john/projects/geotweet/lib );

use Apache2::RequestRec ();
use Apache2::RequestIO ();
use Apache2::Const ();
use JSON::PP ();
use Log::Log4perl;
use Template ();

Log::Log4perl->init_once( '/home/john/projects/geotweet/log.conf' );
1;

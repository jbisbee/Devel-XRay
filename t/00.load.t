use Test::More tests => 4;

BEGIN {
use_ok( 'trace' );
use_ok( 'trace','all');
use_ok( 'trace', 'ignore', 'test');
use_ok( 'trace', 'only',   'test');
}

diag( "Testing trace $trace::VERSION" );

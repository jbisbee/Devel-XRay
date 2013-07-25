#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'trace' );
}

diag( "Testing trace $trace::VERSION, Perl $], $^X" );

#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'trace' );
}

use trace 'ignore' => qw(test);


use strict;
use warnings;

use Test::More 0.88;

use File::LibMagic;

ok( File::LibMagic::MagicBuffer("Hello World\n") eq "ASCII text" );

done_testing();

use strict;
use warnings;

use Test::More 0.88;

use File::LibMagic;

my $v = File::LibMagic::magic_version() || 'no version';
diag("libmagic version $v");
unlike( $v, qr/^no version$/, 'got a version' );

done_testing();

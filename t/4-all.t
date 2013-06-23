use strict;
use warnings;
use Test::More tests => 6;

use File::LibMagic qw( :all );

# subs from :easy
is( MagicBuffer("Hello World\n"),   'ASCII text'           );

is( MagicFile('t/samples/foo.txt'), 'ASCII text'           );
is( MagicFile('t/samples/foo.c'  ), 'ASCII C program text' );

# subs from :complete
my $handle = magic_open(MAGIC_NONE);
magic_load( $handle, q{} );
is( magic_buffer( $handle, "Hello World\n" ), 'ASCII text' );

is( magic_file( $handle, 't/samples/foo.txt' ), 'ASCII text'           );
is( magic_file( $handle, 't/samples/foo.c'   ), 'ASCII C program text' );

magic_close($handle);


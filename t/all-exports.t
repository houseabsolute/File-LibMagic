use strict;
use warnings;

use lib 't/lib';

use Test::AnyOf;
use Test::More 0.88;

use File::LibMagic qw( :all );

# subs from :easy
is( MagicBuffer("Hello World\n"), 'ASCII text' );

is( MagicFile('t/samples/foo.txt'), 'ASCII text' );
is_any_of(
    MagicFile('t/samples/foo.c'),
    [ 'ASCII C program text', 'C source, ASCII text' ]
);

# subs from :complete
my $handle = magic_open(MAGIC_NONE);
magic_load( $handle, q{} );
is( magic_buffer( $handle, "Hello World\n" ), 'ASCII text' );

is( magic_file( $handle, 't/samples/foo.txt' ), 'ASCII text' );

is_any_of(
    magic_file( $handle, 't/samples/foo.c' ),
    [ 'ASCII C program text', 'C source, ASCII text' ]
);

magic_close($handle);

done_testing();

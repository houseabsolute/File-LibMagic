use strict;
use warnings;
use Test::More tests => 14;

use File::LibMagic qw( :complete );

# check for constants
my $fail = 0;
my @names = qw(
    MAGIC_CHECK MAGIC_COMPRESS MAGIC_CONTINUE MAGIC_DEBUG MAGIC_DEVICES
    MAGIC_ERROR MAGIC_MIME MAGIC_NONE MAGIC_PRESERVE_ATIME MAGIC_RAW
    MAGIC_SYMLINK
);
foreach my $constname (@names) {
    next if ( eval "my \$a = $constname; 1" );
    if ( $@ =~ /^Your vendor has not defined constants macro $constname/ ) {
        diag "pass: $@";
    }
    else {
        diag "fail: $@";
        $fail = 1;
    }

}
ok( $fail == 0 , 'Constants' );

# try loading a non-standard magic file
{
    my $handle = magic_open(MAGIC_NONE);
    magic_load( $handle, 't/samples/magic' );
    is( magic_buffer( $handle, "Hello World\n" ), 'ASCII text' );
    is( magic_buffer( $handle, "Footastic\n" ), 'A foo file' );

    is( magic_file( $handle, 't/samples/foo.txt' ), 'ASCII text'           );
    is( magic_file( $handle, 't/samples/foo.c'   ), 'ASCII C program text' );
    is( magic_file( $handle, 't/samples/foo.foo' ), 'A foo file' );

    magic_close($handle);
}

# test the traditional empty string for magic_load
{
    my $handle = magic_open(MAGIC_NONE);
    magic_load( $handle, q{} );
    is( magic_buffer( $handle, "Hello World\n" ), 'ASCII text' );

    is( magic_file( $handle, 't/samples/foo.txt' ), 'ASCII text'           );
    is( magic_file( $handle, 't/samples/foo.c'   ), 'ASCII C program text' );
    is( magic_file( $handle, 't/samples/foo.foo' ), 'ASCII text' );

    magic_close($handle);
}

# test undef as the filename for magic_load
{
    my $handle = magic_open(MAGIC_NONE);
    magic_load( $handle, undef );
    is( magic_buffer( $handle, "Hello World\n" ), 'ASCII text' );

    is( magic_file( $handle, 't/samples/foo.txt' ), 'ASCII text'           );
    is( magic_file( $handle, 't/samples/foo.c'   ), 'ASCII C program text' );
    is( magic_file( $handle, 't/samples/foo.foo' ), 'ASCII text' );

    magic_close($handle);
}

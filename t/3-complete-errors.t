use strict;
use warnings;

use Test::More tests => 7;

use File::LibMagic qw( :complete );

# TODO can we simulate an out-of-memory error?

# try to use a missing magic file
{
    my $h = magic_open(MAGIC_NONE);
    
    {
        no warnings 'uninitialized';
        eval { magic_load(undef, 't/samples/magic') };
        like( $@, qr{magic_load requires a defined handle}, 'magic_load(undef)' );
    }
    eval { magic_load($h, 't/samples/missing') };
#    like( $@, qr{libmagic could not find any magic files}, 'missing magic file' );
    magic_close($h);
}

{
    my $h = magic_open(MAGIC_NONE);
    magic_load($h, 't/samples/magic');

    # try to get information about an undef buffer
    {
        no warnings 'uninitialized';
        eval { magic_buffer(undef, "Foo") };
        like( $@, qr{magic_buffer requires a defined handle}, 'magic_buffer(undef)' );
    }

    eval { magic_buffer($h, undef) };
    like( $@, qr{magic_buffer requires defined content}, 'magic_buffer no content' );


    # try to get information about a missing file
    {
        no warnings 'uninitialized';
        eval { magic_file(undef, 't/samples/foo.foo') };
        like( $@, qr{magic_file requires a defined handle}, 'magic_file(undef)' );
    }

    eval { magic_file($h, undef) };
    like( $@, qr{magic_file requires a filename}, 'magic_file no file' );

    TODO: {
        local $TODO = 'check libmagic version';
        eval { magic_file($h, 't/samples/missing') };
        like( $@, qr{libmagic cannot open .+ at }, 'missing file' );
        magic_close($h)
    };
}

# try calling magic_close with undef handle
{
    no warnings 'uninitialized';
    my $h = magic_open(MAGIC_NONE);
    eval { magic_close(undef) };
    like($@, qr{magic_close requires a defined handle});
}

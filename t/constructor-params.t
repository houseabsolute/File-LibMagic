use strict;
use warnings;

use lib 't/lib';

use Cwd qw( abs_path );
use File::Temp qw( tempdir );
use Test::AnyOf;
use Test::More 0.96;

use File::LibMagic;

{
    ## no critic (InputOutput::RequireCheckedSyscalls)
    skip 'This platform does not support symlinks', 1
        unless eval { symlink( q{}, q{} ); 1 };
    ## use critic

    my $dir = tempdir( CLEANUP => 1 );
    my $link_file = "$dir/link-to-tiny.pdf";
    symlink abs_path() . '/t/samples/tiny.pdf' => $link_file
        or die "Cannot create symlink to t/samples/tiny.pdf: $!";

    my $info = File::LibMagic->new( follow_symlinks => 1 )
        ->info_from_filename($link_file);

    is_deeply(
        $info, {
            description        => 'PDF document, version 1.4',
            mime_type          => 'application/pdf',
            encoding           => 'binary',
            mime_with_encoding => 'application/pdf; charset=binary',
        },
        'got expected info for symlink to PDF'
    );
}

{
    my $info
        = File::LibMagic->new()->info_from_filename('t/samples/tiny.pdf.gz');

    is_any_of(
        $info->{mime_type},
        [ 'application/gzip', 'application/x-gzip' ],
        'gzip file is application/gzip or application/x-gzip by default'
    );

    $info
        = File::LibMagic->new( uncompress => 1 )
        ->info_from_filename('t/samples/tiny.pdf.gz');

    is(
        $info->{mime_type},
        'application/pdf',
        'gzip file is application/pdf when uncompressed'
    );
}


done_testing();

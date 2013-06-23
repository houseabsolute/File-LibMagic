use strict;
use warnings;

use Test::More;
use File::LibMagic;

my %standard = (
    'foo.foo' => [ 'ASCII text',           'text/plain; charset=us-ascii' ],
    'foo.c'   => [ 'ASCII C program text', 'text/x-c; charset=us-ascii'   ],
);

my %custom = (
    'foo.foo' => [ 'A foo file',           'text/plain; charset=us-ascii' ],
    'foo.c'   => [ 'ASCII C program text', 'text/x-c; charset=us-ascii'   ],
);

plan tests => 4 + 4*(keys %standard) + 4*(keys %custom);

# try using a the standard magic database
my $flm = File::LibMagic->new();
isa_ok($flm, 'File::LibMagic');

while ( my ($file, $expect) = each %standard ) {
    my ($descr, $mime) = @$expect;
    $file = "t/samples/$file";

    # the original file utility uses text/plain;...  so does gentoo, debian,
    # etc ..., but OpenSUSE returns text/plain... (no semicolon)
    $mime=~s/;/;?/g;
    like( $flm->checktype_filename($file), qr#$mime#,  "MIME $file" );
    is  ( $flm->describe_filename($file),  $descr, "Describe $file" );

    my $data = do {
        local $/;
        open my $fh, '<', $file or die $!;
        <$fh>;
    };

    like( $flm->checktype_contents($data), qr#$mime#,  "MIME data $file" );
    is  ( $flm->describe_contents($data),  $descr, "Describe data $file" );
}

# try using a custom magic database
$flm = File::LibMagic->new('t/samples/magic');
isa_ok($flm, 'File::LibMagic');

while ( my ($file, $expect) = each %custom ) {
    my ($descr, $mime) = @$expect;
    $file = "t/samples/$file";

    # OpenSUSE fix
    $mime=~s/;/;?/g;
    # text/x-foo to keep netbsd and older solaris installations happy
    like( $flm->checktype_filename($file), qr#(?:$mime|text/x-foo)#,  "MIME $file" );
    is(   $flm->describe_filename($file),  $descr, "Describe $file" );

    my $data = do {
        local $/;
        open my $fh, '<', $file or die $!;
        <$fh>;
    };

    # text/x-foo to keep netbsd and older solaris installations happy
    like( $flm->checktype_contents($data), qr#(?:$mime|text/x-foo)#,  "MIME data $file" );
    is(   $flm->describe_contents($data),  $descr, "Describe data $file" );
}

my $subclass = My::Magic::Subclass->new();
isa_ok( $subclass, 'My::Magic::Subclass', 'subclass' );
is( $subclass->checktype_filename('t/samples/missing'), 'text/x-test-passes' );

# define a subclass of File::LibMagic to test subclassing
package My::Magic::Subclass;
use base qw( File::LibMagic );
sub checktype_filename { 'text/x-test-passes' }


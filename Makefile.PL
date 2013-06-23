#! perl -w

use 5.008;

use ExtUtils::MakeMaker;

use lib qw( inc );
use Devel::CheckLib;

check_lib_or_exit( lib => 'magic', header => 'magic.h' );

WriteMakefile(
    'NAME'          => 'File::LibMagic',
    'VERSION_FROM'  => 'LibMagic.pm',
    'ABSTRACT_FROM' => 'LibMagic.pm',
    'AUTHOR'        => 'Andreas Fitzner <andreas.fitzner@fv-berlin.de>',
    'LIBS'          => ['-lmagic -lz'],
    'DEFINE'        => '',
    'INC'           => '-I.'
);

if ( eval { require ExtUtils::Constant; 1 } ) {

    # If you edit these definitions to change the constants used by this module,
    # you will need to use the generated const-c.inc and const-xs.inc
    # files to replace their "fallback" counterparts before distributing your
    # changes.

    my @names = (
        qw(MAGIC_CHECK MAGIC_COMPRESS MAGIC_CONTINUE MAGIC_DEBUG
            MAGIC_DEVICES MAGIC_ERROR MAGIC_MIME MAGIC_NONE
            MAGIC_PRESERVE_ATIME MAGIC_RAW MAGIC_SYMLINK)
    );

    ExtUtils::Constant::WriteConstants(
        NAME         => 'File::LibMagic',
        NAMES        => \@names,
        DEFAULT_TYPE => 'IV',
        C_FILE       => 'const-c.inc',
        XS_FILE      => 'const-xs.inc',
    );

}
else {
    use File::Copy;
    use File::Spec;
    foreach my $file ( 'const-c.inc', 'const-xs.inc' ) {
        my $fallback = File::Spec->catfile( 'fallback', $file );
        copy( $fallback, $file ) or die "Can't copy $fallback to $file: $!";
    }
}

exit 0;

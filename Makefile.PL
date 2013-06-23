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

exit 0;

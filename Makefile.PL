#! perl -w

use 5.008;

BEGIN {
    eval { require ExtUtils::MakeMaker::Dist::Zilla::Develop };
    if ($@) {
        warn
            "You need to install ExtUtils::MakeMaker::Dist::Zilla::Develop to run this Makefile.PL\n";
        exit 1;
    }

    ExtUtils::MakeMaker::Dist::Zilla::Develop->import();
}

use ExtUtils::MakeMaker;

use lib qw( inc );
use Devel::CheckLib;

check_lib_or_exit( lib => 'magic', header => 'magic.h' );

WriteMakefile(
    NAME    => 'File::LibMagic',
    VERSION => 42,
    LIBS    => ['-lmagic'],
    DEFINE  => '',
    INC     => '-I.'
);

exit 0;

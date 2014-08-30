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

use lib qw( inc );
use inc::MyMakeMaker;

inc::MyMakeMaker->run_autoconf_check();

WriteMakefile(
    NAME    => 'File::LibMagic',
    VERSION => 42,
    LIBS    => ['-lmagic'],
    DEFINE  => '',
    INC     => '-I.'
);

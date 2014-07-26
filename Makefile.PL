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
use Config::AutoConf;

unless ( Config::AutoConf->check_header('magic.h')
    && Config::AutoConf->check_lib( 'magic', 'magic_open' ) ) {
    warn <<'EOF';

  This module requires the libmagic.so library and magic.h header. See
  INSTALL.md for more details on installing these.

EOF
    exit 1;
}

WriteMakefile(
    NAME    => 'File::LibMagic',
    VERSION => 42,
    LIBS    => ['-lmagic'],
    DEFINE  => '',
    INC     => '-I.'
);

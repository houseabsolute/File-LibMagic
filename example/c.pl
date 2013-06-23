#! perl -w

use lib qw(../blib/lib ../blib/arch ../blib/lib/auto ../blib/arch/auto);

use File::LibMagic ':all';

MagicFile("");
MagicFile("/notexistent");


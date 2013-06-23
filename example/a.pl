#! perl

use lib qw(../blib/lib ../blib/arch ../blib/lib/auto ../blib/arch/auto);

use File::LibMagic ':easy';

print MagicBuffer("Hello World\n"),"\n";
print MagicFile("/bin/ls"),"\n";

print "1: ",MagicBuffer("Test1"),"\n";
print "2: ",MagicBuffer(""),"\n";


# test if LibMagic can handle undef vars
my $x;
print "3: |",MagicBuffer($x),"|\n";
if (! MagicBuffer($x)) { print "ok\n"; }


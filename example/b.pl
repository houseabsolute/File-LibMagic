#! perl -w

use lib qw(../blib/lib ../blib/arch ../blib/lib/auto ../blib/arch/auto);

use File::LibMagic ':all';
use Benchmark qw(timethese cmpthese);

my $handle=magic_open(0);
my $ret   =magic_load($handle,"");

my $r=timethese(5000, {
	a => sub { my $a=magic_buffer($handle,"Hi\n"); },
	b => sub { my $a=MagicBuffer("Hi\n"); },
      } );

cmpthese($r);

magic_close($handle);


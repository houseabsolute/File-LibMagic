package inc::MyMakeMaker;

# ABSTRACT: build a Makefile.PL that uses ExtUtils::MakeMaker
use Moose;
use Moose::Autobox;

use namespace::autoclean;

extends 'Dist::Zilla::Plugin::MakeMaker';

around write_makefile_args => sub {
    my $orig = shift;
    my $self = shift;

    my $args = $self->$orig(@_);

    $args->{LIBS} = ['-lmagic'];
    $args->{INC}  = '-I.';

    return $args;
};

my $check = <<'EOC';
use lib qw( inc );
use Config::AutoConf;
use Getopt::Long;

my %ac_args;
my @libs;
my @includes;
GetOptions(
    'lib:s@'     => \@libs,
    'include:s@' => \@includes,
);

@libs = map { '-L' . $_ } @libs;
$ac_args{extra_link_flags} = \@libs
    if @libs;

@includes = map { '-I' . $_ } @includes;
$ac_args{extra_include_flags} = \@includes
    if @includes;

my $ac = Config::AutoConf->new(%ac_args);

unless ( $ac->check_header('magic.h')
    && $ac->check_lib( 'magic', 'magic_open' ) ) {
    warn <<'EOF';

  This module requires the libmagic.so library and magic.h header. See
  INSTALL.md for more details on installing these.

EOF
    exit 0;
}
EOC

around fill_in_string => sub {
    my $orig     = shift;
    my $self     = shift;
    my $template = shift;
    my $args     = shift;

    $template =~ s/(use ExtUtils::MakeMaker.+;\n)/$1\n$check\n/;

    my $munge_args = <<'EOF';
unshift @{ $WriteMakefileArgs{LIBS} }, @libs;
$WriteMakefileArgs{INC} = join q{ }, @includes, $WriteMakefileArgs{INC};


EOF

    $template =~ s/(WriteMakefile\()/$munge_args$1/;

    return $self->$orig( $template, $args );
};

__PACKAGE__->meta->make_immutable;

1;

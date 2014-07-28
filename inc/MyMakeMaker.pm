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

unless ( Config::AutoConf->check_header('magic.h')
    && Config::AutoConf->check_lib( 'magic', 'magic_open' ) ) {
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

    return $self->$orig( $template, $args );
};

__PACKAGE__->meta->make_immutable;

1;

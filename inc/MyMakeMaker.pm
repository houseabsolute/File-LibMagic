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

my $CheckLib = <<'EOF';
use lib qw( inc );
use Devel::CheckLib;

check_lib_or_exit( lib => 'magic', header => 'magic.h' );
EOF

around fill_in_string => sub {
    my $orig     = shift;
    my $self     = shift;
    my $template = shift;
    my $args     = shift;

    $template =~ s/(use ExtUtils::MakeMaker.+;\n)/$1\n$CheckLib\n/;

    return $self->$orig( $template, $args );
};

__PACKAGE__->meta->make_immutable;

1;

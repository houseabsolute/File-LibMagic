package inc::MyInstallGuide;

use Dist::Zilla::File::FromCode;
use Moose;

use namespace::autoclean;

extends 'Dist::Zilla::Plugin::InstallGuide';

my $requires_libmagic = <<'EOF';
Installing File-LibMagic requires that you have the *libmagic.so* library and
the *magic.h* header file installed. Once those are installed, this module is
installed like any other Perl distribution.

## Installing libmagic

On Debian/Ubuntu run:

    sudo apt-get install libmagic-dev

On Mac you can use homebrew (https://brew.sh/):

    brew install libmagic
EOF

my $specifying = <<'EOF';
## Specifying additional lib and include directories

On some systems, you may need to pass additional lib and include directories
to the Makefile.PL. You can do this with the `--lib` and `--include`
parameters:

    perl Makefile.PL --lib /usr/local/lib --include /usr/local/include

You can pass these parameters multiple times to specify more than one
location.
EOF

sub template {
    my $self = shift;

    my $template = $self->SUPER::template;
    $template
        =~ s{Installing \{\{ .+ \}\} is straightforward\.\n}{$requires_libmagic}
        or die
        q{Could not add the "requires libmagic" text to the install guide};
    $template =~ s{(## Manual installation)}{$specifying\n$1}
        or die
        q{Could not add the "specifying libmagic location" text to the install guide};

    return $template;
}

__PACKAGE__->meta()->make_immutable();

1;

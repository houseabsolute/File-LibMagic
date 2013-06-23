package File::LibMagic;

use 5.008;

use strict;
use warnings;

use Carp;
use Exporter;

BEGIN {
    use XSLoader;
    XSLoader::load(
        __PACKAGE__,
        exists $File::LibMagic::{VERSION} && ${ $File::LibMagic::{VERSION} }
        ? ${ $File::LibMagic::{VERSION} }
        : 0
    );
}

our @ISA = qw(Exporter);

my @Constants;

BEGIN {
    @Constants = qw(
        MAGIC_CHECK
        MAGIC_COMPRESS
        MAGIC_CONTINUE
        MAGIC_DEBUG
        MAGIC_DEVICES
        MAGIC_ERROR
        MAGIC_MIME
        MAGIC_NONE
        MAGIC_PRESERVE_ATIME
        MAGIC_RAW
        MAGIC_SYMLINK
    );

    for my $name (@Constants) {
        my ( $error, $value ) = constant($name);

        croak "WTF defining $name - $error"
            if defined $error;

        my $sub = sub { $value };

        no strict 'refs';
        *{$name} = $sub;
    }
}
our %EXPORT_TAGS = (
    'easy'     => [qw( MagicBuffer MagicFile )],
    'complete' => [
        @Constants,
        qw(
            magic_buffer
            magic_buffer_offset
            magic_close
            magic_file
            magic_load
            magic_open
            )
    ]
);

$EXPORT_TAGS{"all"}
    = [ @{ $EXPORT_TAGS{"easy"} }, @{ $EXPORT_TAGS{"complete"} } ];

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

use constant _MAGIC_FILE      => 0;
use constant _MIME_HANDLE     => 1;
use constant _DESCRIBE_HANDLE => 2;

sub new {
    my ( $class, $magic_file ) = @_;

    return bless [ $magic_file || q{} ], $class;
}

sub _mime_handle {
    my ($self) = @_;

    my $m = magic_open( MAGIC_MIME() );
    magic_load( $m, $self->[_MAGIC_FILE] );

    return $m;
}

sub _descr_handle {
    my ($self) = @_;

    my $m = magic_open( MAGIC_NONE() );
    magic_load( $m, $self->[_MAGIC_FILE] );

    return $m;
}

sub checktype_contents {
    my ( $self, $data ) = @_;

    my $m = $self->[_MIME_HANDLE] ||= $self->_mime_handle();
    return magic_buffer( $m, $data );
}

sub checktype_filename {
    my ( $self, $filename ) = @_;

    my $m = $self->[_MIME_HANDLE] ||= $self->_mime_handle();

    return magic_file( $m, $filename );
}

sub describe_contents {
    my ( $self, $data ) = @_;

    my $m = $self->[_DESCRIBE_HANDLE] ||= $self->_descr_handle();

    return magic_buffer( $m, $data );
}

sub describe_filename {
    my ( $self, $filename ) = @_;

    my $m = $self->[_DESCRIBE_HANDLE] ||= $self->_descr_handle();

    return magic_file( $m, $filename );
}

sub DESTROY {
    my ($self) = @_;

    for ( _MIME_HANDLE, _DESCRIBE_HANDLE ) {
        magic_close( $self->[$_] ) if $self->[$_];
    }
}

1;

# ABSTRACT: Determine MIME types of data or files using libmagic

__END__

=pod

=head1 SYNOPSIS

  use File::LibMagic;

  my $magic = File::LibMagic->new();

  # prints a description like "ASCII text"
  print $magic->describe_filename('path/to/file');
  print $magic->describe_contents('this is some data');

  # Prints a MIME type like "text/plain; charset=us-ascii"
  print $magic->checktype_filename('path/to/file');
  print $magic->checktype_contents('this is some data');

=head1 DESCRIPTION

The C<File::LibMagic> is a simple perl interface to libmagic from
the file package (version 4.x or 5.x).

=head1 API

This module provides an object-oriented API with the following methods:

=head2 File::LibMagic->new()

Creates a new File::LibMagic object.

Using the object oriented interface provides an efficient way to repeatedly
determine the magic of a file.

Each File::LibMagic object loads the magic database independently of other
File::LibMagic objects, so you may want to share a single object across many
modules as a singleton.

This method takes an optional argument containing a path to the magic file. If
the file doesn't exist this will throw an exception (but only with libmagic
4.17+).

If you don't pass an argument, it will throw an exception if it can't find any
magic files at all.

=head2 $magic->checktype_contents($data)

Returns the MIME type of the data given as the first argument.

This is the same value as would be returned by the C<file> command with the
C<-i> switch.

=head2 $magic->checktype_filename($filename)

Returns the MIME type of the given file.

This is the same value as would be returned by the C<file> command with the
C<-i> switch.

=head2 $magic->describe_contents($data)

Returns a description (as a string) of the data given as the first argument.

This is the same value as would be returned by the C<file> command with no
switches.

=head2 $magic->describe_filename($filename)

Returns a description (as a string) of the given file.

This is the same value as would be returned by the C<file> command with no
switches.

=head1 DEPRECATED APIS

This module offers two different procedural APIS based on optional exports,
the "easy" and "complete" interfaces. These APIS are now deprecated. I
strongly recommend you use the OO interface. It's simpler than the complete
interface and more efficient than the easy interface.

=head2 The "easy" interface

This interface is exported by:

  use File::LibMagic ':easy';

This interface exports two subroutines:

=over 4

=item * MagicBuffer($data)

Returns the description of a chunk of data, just like the C<describe_contents>
method.

=item * MagicFile($filename)

Returns the description of a file, just like the C<describe_filename> method.

=back

=head2 The "complete" interface

This interface is exported by:

  use File::LibMagic ':easy';

This interface exports several subroutines:

=over 4

=item * magic_open($flags)

This subroutine opens creates a magic handle. See the libmagic man page for a
description of all the flags. These are exported by the C<:complete> import.

  my $handle = magic_open(MAGIC_MIME);

=item * magic_load($handle, $filename)

This subroutine actually loads the magic file. The C<$filename> argument is
optional. There should be a sane default compiled into your C<libmagic>
library.

=item * magic_buffer($handle, $data)

This returns information about a chunk of data as a string. What it returns
depends on the flags you passed to C<magic_open>, a description, a MIME type,
etc.

=item * magic_file($handle, $filename)

This returns information about a file as a string. What it returns depends on
the flags you passed to C<magic_open>, a description, a MIME type, etc.

=item * magic_close($handle)

Closes the magic handle.

=back

=head1 EXCEPTIONS

This module can throw an exception if you system runs out of memory when
trying to call C<magic_open> internally.

=head1 SUPPORT

Please submit bugs to the CPAN RT system at
http://rt.cpan.org/NoAuth/Bugs.html?Dist=File-LibMagic or via email at
bug-file-libmagic@rt.cpan.org.

=head1 BUGS

This module is totally dependent on the version of file on your system. It's
possible that the tests will fail because of this. Please report these
failures so I can make the tests smarter. Please make sure to report the
version of file on your system as well!

=head1 DEPENDENCIES/PREREQUISITES

This module requires file 4.x or file 5x and the associated libmagic library
and headers (http://darwinsys.com/file/).

=head1 RELATED MODULES

Andreas created File::LibMagic because he wanted to use libmagic (from
file 4.x) L<File::MMagic> only worked with file 3.x.

L<File::MimeInfo::Magic> uses the magic file from freedesktop.org which is
encoded in XML, and is thus not the fastest approach
(http://mail.gnome.org/archives/nautilus-list/2003-December/msg00260.html).

File::Type uses a relatively small magic file, which is directly hacked into
the module code. It is quite fast but the database is quite small relative to
the file package.

=cut

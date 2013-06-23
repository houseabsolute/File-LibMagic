package File::LibMagic;

use 5.008;
use strict;
use warnings;
use Carp;

require Exporter;
use AutoLoader;

our @ISA = qw(Exporter);

# This allows declaration
#              use File::LibMagic ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'easy'     => [ qw( MagicBuffer MagicFile ) ],
		     'complete' => [ qw(magic_buffer magic_file magic_open magic_load
		     			magic_close magic_buffer_offset
		     			MAGIC_CHECK MAGIC_COMPRESS MAGIC_CONTINUE
					MAGIC_DEBUG MAGIC_DEVICES MAGIC_ERROR MAGIC_MIME
					MAGIC_NONE MAGIC_PRESERVE_ATIME MAGIC_RAW MAGIC_SYMLINK
		                       ) ]
);
# Attention @{$EXPORT_TAGS{"easy"}} != @$EXPORT_TAGS{"easy"}   
# hm.
$EXPORT_TAGS{"all"}=[ @{$EXPORT_TAGS{"easy"}}, @{$EXPORT_TAGS{"complete"}} ];

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw( );

our $VERSION = '0.96';

sub AUTOLOAD {
    # This AUTOLOAD is used to 'autoload' constants from the constant()
    # XS function.

    my $constname;
    our $AUTOLOAD;
    ($constname = $AUTOLOAD) =~ s/.*:://;
    croak "&File::LibMagic::constant not defined" if $constname eq 'constant';
    my ($error, $val) = constant($constname);
    if ($error) { croak $error; }
    {
	no strict 'refs';
        *$AUTOLOAD = sub { $val };
    }
    goto &$AUTOLOAD;
}

require XSLoader;
XSLoader::load('File::LibMagic', $VERSION);

# Preloaded methods go here.

sub new {
    my ($self, $magic_file) = @_;
    my $pkg = ref $self || $self;
    return bless [ $magic_file || q{} ], $pkg;
}

sub _mime_handle {
    my ($self) = @_;
    my $m = magic_open( MAGIC_MIME() );
    magic_load( $m, $self->[0] );
    return $m;
}

sub _descr_handle {
    my ($self) = @_;
    my $m = magic_open( MAGIC_NONE() );
    magic_load( $m, $self->[0] );
    return $m;
}

sub checktype_contents {
    my ($self, $data) = @_;

    my $m = $self->[1] ||= $self->_mime_handle();
    return magic_buffer($m, $data);
}

sub checktype_filename {
    my ($self, $filename) = @_;

    my $m = $self->[1] ||= $self->_mime_handle();
    return magic_file($m, $filename);
}

sub describe_contents {
    my ($self, $data) = @_;

    my $m = $self->[2] ||= $self->_descr_handle();
    return magic_buffer($m, $data);
}

sub describe_filename {
    my ($self, $filename) = @_;

    my $m = $self->[2] ||= $self->_descr_handle();
    return magic_file($m, $filename);
}

sub DESTROY {
    my ($self) = @_;
    for ( 1, 2 ) {
        magic_close( $self->[$_] ) if $self->[$_];
    }
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 NAME

File::LibMagic - Perlwrapper for libmagic (file-4.x or file-5.x)

=head1 SYNOPSIS

The easy way:

	  use File::LibMagic ':easy';

	  print MagicBuffer("Hello World\n"),"\n";
	  # returns "ASCII text"

	  print MagicFile("/bin/ls"),"\n";
	  # returns "ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV)"
	  # on my system

To use all capabilities of libmagic use
 
	  use File::LibMagic ':complete';

	  my $handle=magic_open(0);
	  my $ret   =magic_load($handle,"");  # use default magic file
	  # OR $ret =magic_load($handle, '/home/someone/.magic');

	  print magic_buffer($handle,"Hello World\n"),"\n";
	  print magic_file($handle,"/bin/ls"),"\n";

	  magic_close($handle);

Using the object-oriented interface:

    use File::LibMagic;
    
    my $flm = File::LibMagic->new();
    
    # determine a content description
    print $flm->describe_filename('path/to/file');
    print $flm->describe_contents('this is some data');
    
    # determine the MIME type
    print $flm->checktype_filename('path/to/file');
    print $flm->checktype_contents('this is some data');

Please have a look at the files in the example-directory.

=head1 ABSTRACT

The C<File::LibMagic> is a simple perl interface to libmagic from
the file-4.x or file-5.x package from Christos Zoulas (ftp://ftp.astron.com/pub/file/).

=head1 DESCRIPTION

The C<File::LibMagic> is a simple perlinterface to libmagic from
the file-4.x or file-5.x package from Christos Zoulas (ftp://ftp.astron.com/pub/file/).

You can use the simple Interface like MagicBuffer() or MagicFile(), use the
functions of libmagic(3) or use the OO-Interface.

=head2 Simple Interface

=head3 MagicBuffer() 

fixme

=head3 MagicFile()

fixme

=head2 libmagic(3)

magic_open, magic_close, magic_error, magic_file, magic_buffer, magic_setflags, magic_check, magic_compile,
magic_load -- Magic number recognition library

=head2 OO-Interface

=head3 new

Create a new File::LibMagic object to use for determining the type or MIME
type of content.

Using the object oriented interface provides an efficient way to repeatedly
determine the magic of a file.  Using the object oriented interface provides
significant performance improvements over using the C<:easy> interface when
testing many files.  This performance improvement is because the loading of
the magic database happens only once, during object creation.

Each File::LibMagic object loads the magic database independently of other
File::LibMagic objects.

=head3 checktype_contents

Returns the MIME type of the data given as the first argument.

=head3 checktype_filename

Returns the MIME type of the given file.  This will be the same as returned by
the C<file -i> command.

=head3 describe_contents

Returns a description of the data given as the first argument.

=head3 describe_filename

Returns the MIME type of the given file.  This will be the same as returned by
the C<file> command.

=head2 EXPORT

None by default.

=head1 DIAGNOSTICS

=head2 MagicBuffer requires defined content

This exception is thrown if C<MagicBuffer> is called with an undefined argument.

=head2 libmagic cannot open %s

If libmagic is unable to open the file for which you want to determine the
type, this exception is thrown.  The exception can be thrown by C<MagicFile>
or C<magic_file>.  '%s' contains details about why libmagic was unable to open
the file.

This exception is only thrown when using libmagic version 4.17 or later.

=head2 libmagic could not find any magic files

If libmagic is unable to find a suitable database of magic definitions, this
exception is thrown.  The exception can be thrown by C<MagicBuffer>,
C<MagicFile> or C<magic_load>.

With C<magic_load>, you can specify the location of the magic database with
the second argument.  Depending on your libmagic implementation, you can often
set the MAGIC environment variable to tell libmagic where to find the correct
magic database.

=head2 libmagic out of memory

If libmagic is unable to allocate enough memory for its internal data
structures, this exception is thrown.  The exception can be thrown by
C<MagicBuffer>, C<MagicFile> or C<magic_open>.

=head2 magic_file requires a filename

If C<magic_file> is called with an undefined second argument, this exception
is thrown.

=head1 BUGS

=over 1

=item "normalisation"-problem:

The results from libmagic are dependend on the (linux) distribution being used.
A Gentoo-Linux might return "text/plain; charset=us-asci", an OpenSUSE 
"text/plain charset=us-asci" (no semicolon!). Please check this if you run 
your project on a different platform (and send me an mail if you see different 
outputs/return-values).

=item I'm still learning perlxs ...

=item still no real error handling (printf is not enough)

=back

=head1 DEPENDENCIES/PREREQUISITES

This module requires these other modules and libraries:

  o) file-4.x or file-5x and the associated libmagic 
        (ftp://ftp.astron.com/pub/file/)
  o) on some systems zlib is required.

=head1 RELATED MODULES

I created File::LibMagic because I wanted to use libmagic (from file-4.x) and 
the otherwise great Module File::MMagic only works with file-3.x. In file-3.x 
exists no libmagic but an ascii file (/etc/magic) in which all data (magic
numbers, etc.) is included. File::MMagic parsed this ascii file at each request
and is thus releativly slow. Also it can not use the new data from file-4.x
or file-5.x.

File::MimeInfo::Magic uses the magic file from freedesktop which is encoded 
completely in XML, and thus not the fastest approach (
  http://mail.gnome.org/archives/nautilus-list/2003-December/msg00260.html
).

File::Type uses a relativly small magic file, which is directly hacked into
the module code. Thus it is quite fast. It is also mod_perl save.
It may be the right choice for you, but the databasis is quite small relative
to the file-package.

=head1 HISTORY

April 2004 initial Release

April 2005 version 0.81

Thanks to James Olin Oden (joden@lee.k12.nc.us) for his help.
Thanks to Nathan Hawkins <utsl@quic.net> for his port to 64-bit
systems.

June 2006 version 0.8x (x>1)
Michael Hendricks started to put a lot of work into File::LibMagic.

May 2009 latest relase.

=head1 AUTHOR

Andreas Fitzner E<lt>fitzner@informatik.hu-berlin.deE<gt>,
Michael Hendricks E<lt>michael@ndrix.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 200[5-9] by Andreas Fitzner, Michael Hendricks

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut


# NAME

File::LibMagic - Determine MIME types of data or files using libmagic

# VERSION

version 1.04

# SYNOPSIS

    use File::LibMagic;

    my $magic = File::LibMagic->new();

    # prints a description like "ASCII text"
    print $magic->describe_filename('path/to/file');
    print $magic->describe_contents('this is some data');

    # Prints a MIME type like "text/plain; charset=us-ascii"
    print $magic->checktype_filename('path/to/file');
    print $magic->checktype_contents('this is some data');

# DESCRIPTION

The `File::LibMagic` is a simple perl interface to libmagic from the file
package (version 4.x or 5.x). You will need both the library (`libmagic.so`)
and the header file (`magic.h`) to build this Perl module.

## Installing libmagic

On Debian/Ubuntu run:

    sudo apt-get install libmagic-dev

On Mac you can use homebrew (http://brew.sh/):

    brew install libmagic

## Specifying lib and/or include directories

On some systems, you may need to pass additional lib and include directories
to the Makefile.PL. You can do this with the \`--lib\` and \`--include\`
parameters:

    perl Makefile.PL --lib /usr/local/include --include /usr/local/include

You can pass these parameters multiple times to specify more than one
location.

# API

This module provides an object-oriented API with the following methods:

## File::LibMagic->new()

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

## $magic->checktype\_contents($data)

Returns the MIME type of the data given as the first argument. The data can be
passed as a plain scalar or as a reference to a scalar.

This is the same value as would be returned by the `file` command with the
`-i` switch.

## $magic->checktype\_filename($filename)

Returns the MIME type of the given file.

This is the same value as would be returned by the `file` command with the
`-i` switch.

## $magic->describe\_contents($data)

Returns a description (as a string) of the data given as the first argument.
The data can be passed as a plain scalar or as a reference to a scalar.

This is the same value as would be returned by the `file` command with no
switches.

## $magic->describe\_filename($filename)

Returns a description (as a string) of the given file.

This is the same value as would be returned by the `file` command with no
switches.

# DEPRECATED APIS

This module offers two different procedural APIS based on optional exports,
the "easy" and "complete" interfaces. These APIS are now deprecated. I
strongly recommend you use the OO interface. It's simpler than the complete
interface and more efficient than the easy interface.

## The "easy" interface

This interface is exported by:

    use File::LibMagic ':easy';

This interface exports two subroutines:

- MagicBuffer($data)

    Returns the description of a chunk of data, just like the `describe_contents`
    method.

- MagicFile($filename)

    Returns the description of a file, just like the `describe_filename` method.

## The "complete" interface

This interface is exported by:

    use File::LibMagic ':complete';

This interface exports several subroutines:

- magic\_open($flags)

    This subroutine opens creates a magic handle. See the libmagic man page for a
    description of all the flags. These are exported by the `:complete` import.

        my $handle = magic_open(MAGIC_MIME);

- magic\_load($handle, $filename)

    This subroutine actually loads the magic file. The `$filename` argument is
    optional. There should be a sane default compiled into your `libmagic`
    library.

- magic\_buffer($handle, $data)

    This returns information about a chunk of data as a string. What it returns
    depends on the flags you passed to `magic_open`, a description, a MIME type,
    etc.

- magic\_file($handle, $filename)

    This returns information about a file as a string. What it returns depends on
    the flags you passed to `magic_open`, a description, a MIME type, etc.

- magic\_close($handle)

    Closes the magic handle.

# EXCEPTIONS

This module can throw an exception if your system runs out of memory when
trying to call `magic_open` internally.

# SUPPORT

Please submit bugs to the CPAN RT system at
http://rt.cpan.org/NoAuth/Bugs.html?Dist=File-LibMagic or via email at
bug-file-libmagic@rt.cpan.org.

# BUGS

This module is totally dependent on the version of file on your system. It's
possible that the tests will fail because of this. Please report these
failures so I can make the tests smarter. Please make sure to report the
version of file on your system as well!

# DEPENDENCIES/PREREQUISITES

This module requires file 4.x or file 5x and the associated libmagic library
and headers (http://darwinsys.com/file/).

# RELATED MODULES

Andreas created File::LibMagic because he wanted to use libmagic (from
file 4.x) [File::MMagic](https://metacpan.org/pod/File::MMagic) only worked with file 3.x.

[File::MimeInfo::Magic](https://metacpan.org/pod/File::MimeInfo::Magic) uses the magic file from freedesktop.org which is
encoded in XML, and is thus not the fastest approach. See
[http://mail.gnome.org/archives/nautilus-list/2003-December/msg00260.html](http://mail.gnome.org/archives/nautilus-list/2003-December/msg00260.html)
for a discussion of this issue.

File::Type uses a relatively small magic file, which is directly hacked into
the module code. It is quite fast but the database is quite small relative to
the file package.

# AUTHORS

- Andreas Fitzner
- Michael Hendricks <michael@ndrix.org>
- Dave Rolsky <autarch@urth.org>

# CONTRIBUTOR

Olaf Alders <olaf@wundersolutions.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Andreas Fitzner, Michael Hendricks, and Dave Rolsky.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

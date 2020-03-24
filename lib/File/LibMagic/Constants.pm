package File::LibMagic::Constants;

use 5.008;

use strict;
use warnings;

use Exporter qw( import );

our $VERSION = '1.17';

sub constants {
    return qw(
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
}

our @EXPORT_OK = ('constants');

1;

# ABSTRACT: Contains a list of libmagic constant names that we use in many places

__END__

=for Pod::Coverage .+

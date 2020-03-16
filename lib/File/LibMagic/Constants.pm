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
        MAGIC_PARAM_INDIR_MAX
        MAGIC_PARAM_NAME_MAX
        MAGIC_PARAM_ELF_PHNUM_MAX
        MAGIC_PARAM_ELF_SHNUM_MAX
        MAGIC_PARAM_ELF_NOTES_MAX
        MAGIC_PARAM_REGEX_MAX
        MAGIC_PARAM_BYTES_MAX
    );
}

our @EXPORT_OK = ('constants');

1;

# ABSTRACT: Contains a list of libmagic constant names that we use in many places

__END__

=for Pod::Coverage .+

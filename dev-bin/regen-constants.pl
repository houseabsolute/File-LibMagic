#!/usr/bin/env perl

use strict;
use warnings;

use ExtUtils::Constant;

use FindBin qw( $Bin );
use lib "$Bin/../lib";
use File::LibMagic::Constants qw ( Constants );

ExtUtils::Constant::WriteConstants(
    NAME         => 'File::LibMagic',
    NAMES        => Constants(),
    DEFAULT_TYPE => 'IV',
    C_FILE       => 'const/inc.c',
    XS_FILE      => 'const/inc.xs',
);

exit 0;

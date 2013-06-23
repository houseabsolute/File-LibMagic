#! perl -w

use 5.008;
use ExtUtils::MakeMaker;
use Config qw/%Config/;

use lib qw(inc);
use Devel::CheckLib;

check_lib_or_exit( lib => 'magic', header => 'magic.h' );

WriteMakefile(
    'NAME'		=> 'File::LibMagic',
    'VERSION_FROM'	=> 'LibMagic.pm', # finds $VERSION
    'PREREQ_PM'		=> { },
    'ABSTRACT_FROM'     => 'LibMagic.pm', # retrieve abstract from module
    'AUTHOR'            => 'Andreas Fitzner <andreas.fitzner@fv-berlin.de>',
    'LIBS'		=> ['-lmagic -lz'], # e.g., '-lm'
    'DEFINE'		=> '', # e.g., '-DHAVE_SOMETHING'
    'INC'		=> '-I.', # e.g., '-I. -I/usr/include/other'
	# Un-comment this if you add C files to link with later:
    # 'OBJECT'		=> '$(O_FILES)', # link all the C files too
);
if  (eval {require ExtUtils::Constant; 1}) {
  # If you edit these definitions to change the constants used by this module,
  # you will need to use the generated const-c.inc and const-xs.inc
  # files to replace their "fallback" counterparts before distributing your
  # changes.

  my @names = (qw(MAGIC_CHECK MAGIC_COMPRESS MAGIC_CONTINUE MAGIC_DEBUG
               MAGIC_DEVICES MAGIC_ERROR MAGIC_MIME MAGIC_NONE
               MAGIC_PRESERVE_ATIME MAGIC_RAW MAGIC_SYMLINK));

  ExtUtils::Constant::WriteConstants(
                                     NAME         => 'File::LibMagic',
                                     NAMES        => \@names,
                                     DEFAULT_TYPE => 'IV',
                                     C_FILE       => 'const-c.inc',
                                     XS_FILE      => 'const-xs.inc',
                                  );

}
else {
  use File::Copy;
  use File::Spec;
  foreach my $file ('const-c.inc', 'const-xs.inc') {
    my $fallback = File::Spec->catfile('fallback', $file);
    copy ($fallback, $file) or die "Can't copy $fallback to $file: $!";
  }
}

# Michael does not like this test.

#open(TestFile,">test-if-libmagic-exists.c") || die "$|";
#print TestFile <<EOT;
##include <magic.h>
#
#int main(void) {
#	magic_t m;
#
#	m=magic_open(MAGIC_NONE);
#
#	return 0;
#}
#EOT
#
# my $exe = "test-if-libmagic-exists$Config{exe_ext}";
# $cc_cmd .= "$Config{cc} $Config{ccflags} -I$Config{archlibexp}/CORE -o $exe";
# my $rc = system("$cc_cmd $Config{ldflags} test-if-libmagic-exists.c -lmagic $Config{libs}");
#
# unlink("test-if-libmagic-exists.c", $exe, "test-if-libmagic-exists$Config{obj_ext}");
#
# if ($rc) {
#        warn "Can't compile test program. Make sure you have the file-4.x package installed\n",
#              "and libmagic is accessable (use ldconfig).\n";
#        exit 1; # exit with error to the shell
#  }

exit 0;

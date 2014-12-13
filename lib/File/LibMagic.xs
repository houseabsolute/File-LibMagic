#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
#define NEED_sv_2pv_flags_GLOBAL
#include <magic.h>
#include <string.h>

#include "const/inc.c"

magic_t magic_handle(SV *self)
{
    return (magic_t)SvIV(*( hv_fetchs((HV *)SvRV(self), "magic", 0)));
}

MODULE = File::LibMagic     PACKAGE = File::LibMagic

INCLUDE: ../../const/inc.xs

PROTOTYPES: ENABLE

# First the two :easy functions
SV *MagicBuffer(buffer)
   SV *buffer
   PREINIT:
       char *ret;
       STRLEN len;
       int ret_i;
       char *buffer_value;
       magic_t m;
   CODE:
       /* First make sure they actually gave us a defined scalar */
       if ( !SvOK(buffer) ) {
          Perl_croak(aTHX_ "MagicBuffer requires defined content");
       }

       m = magic_open(MAGIC_NONE);
       if ( m == NULL ) {
           Perl_croak(aTHX_ "libmagic out of memory");
       }
       ret_i = magic_load(m, NULL);
       if ( ret_i < 0 ) {
           Perl_croak(aTHX_ "libmagic %s", magic_error(m));
       }
       buffer_value = SvPV(buffer, len);
       ret = (char*) magic_buffer(m, buffer_value, len);
       if ( ret == NULL ) {
           Perl_croak(aTHX_ "libmagic %s", magic_error(m));
       }
       RETVAL = newSVpvn(ret, strlen(ret));
       magic_close(m);
   OUTPUT:
       RETVAL

SV *MagicFile(file)
   SV *file
   PREINIT:
       char *ret;
       int ret_i;
       magic_t m;
       char *file_value;
   CODE:
       /* First make sure they actually gave us a defined scalar */
       if ( !SvOK(file) ) {
          Perl_croak(aTHX_ "MagicFile requires a filename");
       }

       m = magic_open(MAGIC_NONE);
       if ( m == NULL ) {
           Perl_croak(aTHX_ "libmagic out of memory");
       }
       ret_i = magic_load(m, NULL);
       if ( ret_i < 0 ) {
           Perl_croak(aTHX_ "libmagic %s", magic_error(m));
       }
       file_value = SvPV_nolen(file);
       ret = (char*) magic_file(m, file_value);
       if ( ret == NULL ) {
           Perl_croak(aTHX_ "libmagic %s", magic_error(m));
       }
       RETVAL = newSVpvn(ret, strlen(ret));
       magic_close(m);
   OUTPUT:
       RETVAL

magic_t magic_open(flags)
   int flags
   PREINIT:
        magic_t m;
   CODE:
        m = magic_open(flags);
        if ( m == NULL ) {
            Perl_croak( aTHX_ "libmagic out of memory" );
        }
        RETVAL = m;
   OUTPUT:
        RETVAL

void magic_close(m)
    magic_t m
    CODE:
        if ( !m ) {
            Perl_croak( aTHX_ "magic_close requires a defined handle" );
        }
        magic_close(m);

IV magic_load(m, dbnames)
    magic_t m
    SV *dbnames
    PREINIT:
        STRLEN len = 0;
        char *dbnames_value;
        int ret;
    CODE:
        if ( !m ) {
            Perl_croak( aTHX_ "magic_load requires a defined handle" );
        }
        if ( SvOK(dbnames) ) {  /* is dbnames defined? */
            dbnames_value = SvPV(dbnames, len);
        }
        /* FIXME
         *manpage says 0 = success, any other failure
         *thus does the following line correctly reflect this? */
        ret = magic_load(m, len > 0 ? dbnames_value : NULL);
        /*
         *printf("Ret %d, \"%s\"\n", ret, dbnames_value);
         */
        RETVAL = ! ret;
        if ( RETVAL < 0 ) {
            Perl_croak( aTHX_ "libmagic %s", magic_error(m) );
        }
    OUTPUT:
        RETVAL

SV *magic_buffer(m, buffer)
    magic_t m
    SV *buffer
    PREINIT:
        char *ret;
        STRLEN len;
        char *buffer_value;
    CODE:
        if ( !m ) {
            Perl_croak( aTHX_ "magic_buffer requires a defined handle" );
        }
        /* First make sure they actually gave us a defined scalar */
        if ( !SvOK(buffer) ) {
            Perl_croak(aTHX_ "magic_buffer requires defined content");
        }

        buffer_value = SvROK(buffer) ? SvPV(SvRV(buffer), len) : SvPV(buffer, len);
        ret = (char*) magic_buffer(m, buffer_value, len);
        if ( ret == NULL ) {
            Perl_croak(aTHX_ "libmagic %s", magic_error(m));
        }
        RETVAL = newSVpvn(ret, strlen(ret));
    OUTPUT:
        RETVAL

SV *magic_file(m, file)
    magic_t m
    SV *file
    PREINIT:
        char *ret;
        char *file_value;
    CODE:
        if ( !m ) {
            Perl_croak( aTHX_ "magic_file requires a defined handle" );
        }
        /* First make sure they actually gave us a defined scalar */
        if ( !SvOK(file) ) {
            Perl_croak(aTHX_ "magic_file requires a filename");
        }

        file_value = SvPV_nolen(file);
        ret = (char*) magic_file(m, file_value);
        if ( ret == NULL ) {
            Perl_croak(aTHX_ "libmagic %s", magic_error(m));
        }
        RETVAL = newSVpvn(ret, strlen(ret));
    OUTPUT:
        RETVAL

void magic_setflags(m, flags)
    magic_t m
    int flags
    CODE:
        magic_setflags(m, flags);

SV *magic_buffer_offset(m, buffer, offset, BuffLen)
    magic_t m
    char *buffer
    long offset
    long BuffLen
    PREINIT:
        char *ret;
        STRLEN len;
        long MyLen;
    CODE:
        if ( !m ) {
            Perl_croak( aTHX_ "magic_buffer requires a defined handle" );
        }
        /* FIXME check length for out of bound errors */
        MyLen = (long) BuffLen;
        ret = (char*) magic_buffer(m, (char *) &buffer[ (long) offset], MyLen);
        if ( ret == NULL ) {
            Perl_croak(aTHX_ "libmagic %s", magic_error(m));
        }
        RETVAL = newSVpvn(ret, strlen(ret));
    OUTPUT:
        RETVAL

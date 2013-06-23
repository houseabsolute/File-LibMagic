#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <magic.h>
#include <string.h>

#include "const-c.inc"

/* I don't know anything about perlxs, just trying my best. ;)
*/

MODULE = File::LibMagic		PACKAGE = File::LibMagic		

INCLUDE: const-xs.inc

PROTOTYPES: ENABLE

# First the two :easy functions
SV * MagicBuffer(buffer)
       SV * buffer
       PREINIT:
         char * ret;
         STRLEN len;
         int ret_i;
         char * buffer_value;
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
         ret_i = magic_load(m,NULL);
         if ( ret_i < 0 ) {
             Perl_croak(aTHX_ "libmagic %s", magic_error(m));
         }
         buffer_value = SvPV(buffer, len);
         ret = (char*) magic_buffer(m,buffer_value,len);
         if ( ret == NULL ) {
             Perl_croak(aTHX_ "libmagic %s", magic_error(m));
         }
         RETVAL = newSVpvn(ret, strlen(ret));
         magic_close(m);
       OUTPUT:
           RETVAL

SV * MagicFile(buffer)
       SV * buffer
       PREINIT:
         char * ret;
         int ret_i;
         magic_t m;
         char * buffer_value;
       CODE:
	     /* First make sure they actually gave us a defined scalar */
         if ( !SvOK(buffer) ) {
            Perl_croak(aTHX_ "MagicFile requires a filename");
         }

         m = magic_open(MAGIC_NONE);
         if ( m == NULL ) {
             Perl_croak(aTHX_ "libmagic out of memory");
         }
         ret_i = magic_load(m,NULL);
         if ( ret_i < 0 ) {
             Perl_croak(aTHX_ "libmagic %s", magic_error(m));
         }
	 buffer_value = SvPV_nolen(buffer);
	 ret=(char*) magic_file(m,buffer_value);
         if ( ret == NULL ) {
             Perl_croak(aTHX_ "libmagic %s", magic_error(m));
         }
         RETVAL = newSVpvn(ret, strlen(ret));
         magic_close(m);
       OUTPUT:
           RETVAL

# now all :complete functions
IV   magic_open(flags)
       int flags
       PREINIT:
       	    magic_t m;
       CODE:
             m=magic_open(flags);
             if ( m == NULL ) {
                 Perl_croak( aTHX_ "libmagic out of memory" );
             }
	         RETVAL=(long) m;
       OUTPUT:
       	     RETVAL

void magic_close(handle) 
	long handle
	PREINIT:
		magic_t m;
	CODE:
        if ( !handle ) {
            Perl_croak( aTHX_ "magic_close requires a defined handle" );
        }
		m=(magic_t) handle;
		magic_close(m);

IV   magic_load(handle,dbnames)
	long handle
	SV * dbnames
	PREINIT:
		magic_t m;
		STRLEN len = 0;
		char * dbnames_value;
		int ret;
	CODE:
        if ( !handle ) {
            Perl_croak( aTHX_ "magic_load requires a defined handle" );
        }
		m=(magic_t) handle;
		if ( SvOK(dbnames) ) {  // is dbnames defined?
		    dbnames_value = SvPV(dbnames, len);
		}
		/* FIXME 
		 * manpage says 0 = success, any other failure 
		 * thus does the following line correctly reflect this? */
		ret=magic_load(m, len > 0 ? dbnames_value : NULL);
		/*
		 * printf("Ret %d, \"%s\"\n",ret,dbnames_value);
		 */
		RETVAL = ! ret;
        if ( RETVAL < 0 ) {
            Perl_croak( aTHX_ "libmagic %s", magic_error(m) );
        }
	OUTPUT:
		RETVAL

SV * magic_buffer(handle,buffer)
	long handle
	SV * buffer
	PREINIT:
		magic_t m;
		char * ret;
		STRLEN len;
		char * buffer_value;
	CODE:
        if ( !handle ) {
            Perl_croak( aTHX_ "magic_buffer requires a defined handle" );
        }
        /* First make sure they actually gave us a defined scalar */
        if ( !SvOK(buffer) ) {
            Perl_croak(aTHX_ "magic_buffer requires defined content");
        }

		m = (magic_t) handle;
        buffer_value = SvPV(buffer, len);
        ret = (char*) magic_buffer(m,buffer_value,len);
        if ( ret == NULL ) {
            Perl_croak(aTHX_ "libmagic %s", magic_error(m));
        }
        RETVAL = newSVpvn(ret, strlen(ret));
	OUTPUT:
		RETVAL

SV * magic_buffer_offset(handle,buffer,offset,BuffLen)
	long handle
	char * buffer
	long offset
	long BuffLen
	PREINIT:
		magic_t m;
		char * ret;
		STRLEN len;
		long MyLen;
	CODE:
        if ( !handle ) {
            Perl_croak( aTHX_ "magic_buffer requires a defined handle" );
        }
	m = (magic_t) handle;
	/* FIXME check length for out of bound errors */
	MyLen= (long) BuffLen;
        ret = (char*) magic_buffer(m, (char *) &buffer[ (long) offset], MyLen);
        if ( ret == NULL ) {
            Perl_croak(aTHX_ "libmagic %s", magic_error(m));
        }
        RETVAL = newSVpvn(ret, strlen(ret));
	OUTPUT:
		RETVAL

SV * magic_file(handle,buffer)
       long handle
       SV * buffer
       PREINIT:
         char * ret;
         char * buffer_value;
         magic_t m;
       CODE:
         if ( !handle ) {
             Perl_croak( aTHX_ "magic_file requires a defined handle" );
         }
         /* First make sure they actually gave us a defined scalar */
         if ( !SvOK(buffer) ) {
             Perl_croak(aTHX_ "magic_file requires a filename");
         }

         m = (magic_t) handle;
         buffer_value = SvPV_nolen(buffer);
         ret = (char*) magic_file(m,buffer_value);
         if ( ret == NULL ) {
             Perl_croak(aTHX_ "libmagic %s", magic_error(m));
         }
         RETVAL = newSVpvn(ret, strlen(ret));
       OUTPUT:
          RETVAL


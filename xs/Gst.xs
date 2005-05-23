/*
 * Copyright (C) 2005 by the gtk2-perl team
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * $Id$
 */

#include "gst2perl.h"

MODULE = GStreamer	PACKAGE = GStreamer	PREFIX = gst_

BOOT:
	/* This stupid hack is required because some of GStreamer's type macros
	 * directly use a static variable, instead of the usual reference to
	 * the _get_type function.  Thus, the macros we rely on are NULL until
	 * the corresponding _get_type() function has been called. */
	gst_object_get_type ();
	gst_pad_get_type ();
	gst_real_pad_get_type ();
	gst_ghost_pad_get_type ();
	gst_element_factory_get_type ();
	gst_element_get_type ();
	gst_bin_get_type ();
	gst_event_get_type ();
	gst_buffer_get_type ();
#include "register.xsh"
#include "boot.xsh"
	gperl_handle_logs_for ("GStreamer");

# --------------------------------------------------------------------------- #

=for apidoc __hide__
=cut
void
GET_VERSION_INFO (class)
    PPCODE:
	EXTEND (SP, 3);
	PUSHs (sv_2mortal (newSViv (GST_MAJOR_VERSION)));
	PUSHs (sv_2mortal (newSViv (GST_MINOR_VERSION)));
	PUSHs (sv_2mortal (newSViv (GST_MICRO_VERSION)));
	PERL_UNUSED_VAR (ax);

=for apidoc __hide__
=cut
bool
CHECK_VERSION (class, major, minor, micro)
	int major
	int minor
	int micro
    CODE:
	RETVAL = GST_CHECK_VERSION (major, minor, micro);
    OUTPUT:
	RETVAL

=for apidoc __hide__
=cut
# void gst_version (guint *major, guint *minor, guint *micro);
void
gst_version (class)
    PREINIT:
	guint major, minor, micro;
    PPCODE:
	PERL_UNUSED_VAR (ax);
	gst_version (&major, &minor, &micro);
	EXTEND (sp, 3);
	PUSHs (sv_2mortal (newSVuv (major)));
	PUSHs (sv_2mortal (newSVuv (minor)));
	PUSHs (sv_2mortal (newSVuv (micro)));

# --------------------------------------------------------------------------- #

=for apidoc __hide__
=cut
# void gst_init (int *argc, char **argv[]);
void
gst_init (class)
    PREINIT:
	GPerlArgv *pargv;
    CODE:
	pargv = gperl_argv_new ();

	gst_init (&pargv->argc, &pargv->argv);

	gperl_argv_update (pargv);
	gperl_argv_free (pargv);
    CLEANUP:
#if !GST_CHECK_VERSION (0, 8, 10)
	gst2perl_event_initialize ();
#endif
	gst2perl_value_initialize ();

=for apidoc __hide__
=cut
# gboolean gst_init_check (int *argc, char **argv[]);
gboolean
gst_init_check (class)
    PREINIT:
	GPerlArgv *pargv;
    CODE:
	pargv = gperl_argv_new ();

	RETVAL = gst_init_check (&pargv->argc, &pargv->argv);

	gperl_argv_update (pargv);
	gperl_argv_free (pargv);
    OUTPUT:
	RETVAL

# void gst_init_with_popt_table (int *argc, char **argv[], const GstPoptOption *popt_options);

# gboolean gst_init_check_with_popt_table (int *argc, char **argv[], const GstPoptOption *popt_options);

# const GstPoptOption * gst_init_get_popt_table (void);

=for apidoc __hide__
=cut
# void gst_main (void);
void
gst_main (class)
    C_ARGS:
	/* void */

=for apidoc __hide__
=cut
# void gst_main_quit (void);
void
gst_main_quit (class)
    C_ARGS:
	/* void */

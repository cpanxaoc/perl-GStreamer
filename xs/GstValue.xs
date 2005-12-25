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

/* ------------------------------------------------------------------------- */

static GPerlValueWrapperClass gst2perl_int_range_wrapper_class;

static SV *
gst2perl_int_range_wrap (const GValue *value)
{
	AV *av = newAV ();

	av_push (av, newSViv (gst_value_get_int_range_min (value)));
	av_push (av, newSViv (gst_value_get_int_range_max (value)));

	return newRV_noinc ((SV *) av);
}

static void
gst2perl_int_range_unwrap (GValue *value, SV *sv)
{
	AV *av;
	SV **start, **end;

	if (!SvOK (sv) || !SvRV (sv) || SvTYPE (SvRV (sv)) != SVt_PVAV)
		croak ("GstIntRange must be an array reference");

	av = (AV *) SvRV (sv);

	if (av_len (av) != 1)
		croak ("GstIntRange must contain two values: start and end");

	start = av_fetch (av, 0, 0);
	end = av_fetch (av, 1, 0);

	if (start && SvOK (*start) && end && SvOK (*end))
		gst_value_set_int_range (value, SvIV (*start), SvIV (*end));
}

static void
gst2perl_int_range_initialize (void)
{
	gst2perl_int_range_wrapper_class.wrap = gst2perl_int_range_wrap;
	gst2perl_int_range_wrapper_class.unwrap = gst2perl_int_range_unwrap;

	gperl_register_fundamental_full (GST_TYPE_INT_RANGE,
	                                 "GStreamer::IntRange",
	                                 &gst2perl_int_range_wrapper_class);
}

/* ------------------------------------------------------------------------- */

static GPerlValueWrapperClass gst2perl_value_list_wrapper_class;

static SV *
gst2perl_value_list_wrap (const GValue *value)
{
	AV *av = newAV ();
	guint size, i;

	size = gst_value_list_get_size (value);
	for (i = 0; i < size; i++) {
		const GValue *list_value = gst_value_list_get_value (value, i);
		AV *list_av = newAV ();

		/* FIXME: Can this cause deadlocks? */
		av_push (list_av, gperl_sv_from_value (list_value));
		av_push (list_av, newSVpv (gperl_package_from_type (G_VALUE_TYPE (list_value)), PL_na));

		av_push (av, newRV_noinc ((SV *) list_av));
	}

	return newRV_noinc ((SV *) av);
}

static void
gst2perl_value_list_unwrap (GValue *value, SV *sv)
{
	AV *av;
	int i;

	if (!SvOK (sv) || !SvRV (sv) || SvTYPE (SvRV (sv)) != SVt_PVAV)
		croak ("GstValueList must be an array reference");

	av = (AV *) SvRV (sv);
	for (i = 0; i <= av_len (av); i++) {
		SV **list_value, **element, **type;
		AV *list_av;

		list_value = av_fetch (av, i, 0);

		if (!list_value || !SvOK (*list_value) || !SvRV (*list_value) || SvTYPE (SvRV (*list_value)) != SVt_PVAV)
			croak ("GstValueList must contain array references");

		list_av = (AV *) SvRV (*list_value);

		if (av_len (list_av) != 1)
			croak ("GstValueList must contain array references with two elements: value and type");

		element = av_fetch (list_av, 0, 0);
		type = av_fetch (list_av, 1, 0);

		if (element && SvOK (*element) && type && SvOK (*type)) {
			GValue new_value = { 0, };

			g_value_init (&new_value, gperl_type_from_package (SvPV_nolen (*type)));
			/* FIXME: Can this cause deadlocks? */
			gperl_value_from_sv (&new_value, *element);
			gst_value_list_append_value (value, &new_value);

			g_value_unset (&new_value);
		}
	}

}

static void
gst2perl_value_list_initialize (void)
{
	gst2perl_value_list_wrapper_class.wrap = gst2perl_value_list_wrap;
	gst2perl_value_list_wrapper_class.unwrap = gst2perl_value_list_unwrap;

	gperl_register_fundamental_full (GST_TYPE_LIST,
	                                 "GStreamer::ValueList",
	                                 &gst2perl_value_list_wrapper_class);
}

/* ------------------------------------------------------------------------- */

static GPerlBoxedWrapperClass gst2perl_date_wrapper_class;

static SV *
gst2perl_date_wrap (GType gtype,
		    const char *package,
                    GDate *date,
		    gboolean own)
{
	struct tm tm;
	time_t seconds;

	g_date_to_struct_tm (date, &tm);

	if (own)
		g_date_free (date);

	seconds = mktime (&tm);
	return seconds == -1 ? &PL_sv_undef : newSViv (seconds);
}

static GDate *
gst2perl_date_unwrap (GType gtype,
		      const char *package,
		      SV *sv)
{
	GDate *date;
	time_t seconds;

	date = g_date_new ();
	seconds = SvIV (sv);

#if GLIB_CHECK_VERSION (2, 10, 0)
	g_date_set_time_t (date, seconds);
#else
	g_date_set_time (date, (GTime) seconds);
#endif

	return date;
}

static void
gst2perl_date_initialize (void)
{
	GPerlBoxedWrapperClass *default_wrapper_class;

	default_wrapper_class = gperl_default_boxed_wrapper_class ();

	gst2perl_date_wrapper_class = *default_wrapper_class;
	gst2perl_date_wrapper_class.wrap =
		(GPerlBoxedWrapFunc) gst2perl_date_wrap;
	gst2perl_date_wrapper_class.unwrap =
		(GPerlBoxedUnwrapFunc) gst2perl_date_unwrap;

	gperl_register_boxed (GST_TYPE_DATE, "GStreamer::Date",
	                      &gst2perl_date_wrapper_class);
}

/* ------------------------------------------------------------------------- */

/**
 * TODO: GST_TYPE_FOURCC
 * 	 GST_TYPE_DOUBLE_RANGE
 * 	 GST_TYPE_ARRAY
 * 	 GST_TYPE_FRACTION
 */

/* ------------------------------------------------------------------------- */

MODULE = GStreamer::Value	PACKAGE = GStreamer::Value	PREFIX = gst_value_

BOOT:
	gst2perl_int_range_initialize ();
	gst2perl_value_list_initialize ();
	gst2perl_date_initialize ();

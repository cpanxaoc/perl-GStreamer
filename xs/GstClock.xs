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

SV *
newSVGstClockID (GstClockID id)
{
        SV *sv;

	if (id == NULL)
		return &PL_sv_undef;

	sv = newSV (0);

        return sv_setref_pv (sv, "GStreamer::ClockID", id);
}

GstClockID
SvGstClockID (SV *sv)
{
        return INT2PTR (GstClockID, SvIV (SvRV (sv)));

}

/* ------------------------------------------------------------------------- */

#include <gperl_marshal.h>

static GPerlCallback *
gst2perl_clock_callback_create (SV *func, SV *data)
{
	return gperl_callback_new (func, data, 0, NULL, 0);
}

static gboolean
gst2perl_clock_callback (GstClock *clock,
                         GstClockTime time,
                         GstClockID id,
                         gpointer user_data)
{
	gboolean retval;
	dGPERL_CALLBACK_MARSHAL_SP;

	GPerlCallback *callback = user_data;
	GPERL_CALLBACK_MARSHAL_INIT (callback);

	ENTER;
	SAVETMPS;

	PUSHMARK (SP);

	EXTEND (SP, 3);
	PUSHs (sv_2mortal (newSVGstClock (clock)));
	PUSHs (sv_2mortal (newSVnv (time)));
	PUSHs (sv_2mortal (newSVGstClockID (id)));
	if (callback->data)
		XPUSHs (sv_2mortal (newSVsv (callback->data)));

	PUTBACK;

	call_sv (callback->func, G_SCALAR);

	SPAGAIN;

	retval = POPi;

	PUTBACK;
	FREETMPS;
	LEAVE;

	return retval;
}

/* ------------------------------------------------------------------------- */

MODULE = GStreamer::Clock	PACKAGE = GStreamer::Clock	PREFIX = gst_clock_

BOOT:
	gperl_object_set_no_warn_unreg_subclass (GST_TYPE_CLOCK, TRUE);

gdouble gst_clock_set_speed (GstClock *clock, gdouble speed);

gdouble gst_clock_get_speed (GstClock *clock);

guint64 gst_clock_set_resolution (GstClock *clock, guint64 resolution);

guint64 gst_clock_get_resolution (GstClock *clock);

void gst_clock_set_active (GstClock *clock, gboolean active);

gboolean gst_clock_is_active (GstClock *clock);

void gst_clock_reset (GstClock *clock);

gboolean gst_clock_handle_discont (GstClock *clock, guint64 time);

GstClockTime gst_clock_get_time (GstClock *clock);

GstClockTime gst_clock_get_event_time (GstClock *clock);

GstClockTime gst_clock_get_event_time_delay (GstClock *clock, GstClockTime delay);

GstClockID gst_clock_get_next_id (GstClock *clock);

GstClockID gst_clock_new_single_shot_id (GstClock *clock, GstClockTime time);

GstClockID gst_clock_new_periodic_id (GstClock *clock, GstClockTime start_time, GstClockTime interval);

# --------------------------------------------------------------------------- #

MODULE = GStreamer::Clock	PACKAGE = GStreamer::ClockID	PREFIX = gst_clock_id_

void
DESTROY (id)
	GstClockID id
    CODE:
	gst_clock_id_free (id);

GstClockTime gst_clock_id_get_time (GstClockID id);

# GstClockReturn gst_clock_id_wait (GstClockID id, GstClockTimeDiff *jitter);
void
gst_clock_id_wait (id)
	GstClockID id
    PREINIT:
	GstClockReturn retval = 0;
	GstClockTimeDiff jitter = 0;
    PPCODE:
	retval = gst_clock_id_wait (id, &jitter);
	EXTEND (sp, 2);
	PUSHs (sv_2mortal (newSVGstClockReturn (retval)));
	PUSHs (sv_2mortal (newSVnv (jitter)));

# GstClockReturn gst_clock_id_wait_async (GstClockID id, GstClockCallback func, gpointer user_data);
GstClockReturn
gst_clock_id_wait_async (id, func, data=NULL);
	GstClockID id
	SV *func
	SV *data
    PREINIT:
	GPerlCallback *callback;
    CODE:
	callback = gst2perl_clock_callback_create (func, data);
	RETVAL = gst_clock_id_wait_async (id,
	                                  gst2perl_clock_callback,
	                                  callback);
	/* FIXME: When to free the callback? */
    OUTPUT:
	RETVAL

void gst_clock_id_unschedule (GstClockID id);

void gst_clock_id_unlock (GstClockID id);

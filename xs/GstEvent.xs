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

const char *
gst_event_get_package (GstEvent *event)
{
	switch (event->type) {
	    case GST_EVENT_UNKNOWN:
	    case GST_EVENT_EOS:
		return "GStreamer::Event";

	    case GST_EVENT_FLUSH:
		return "GStreamer::Event::Flush";

	    case GST_EVENT_EMPTY:
		return "GStreamer::Event";

	    case GST_EVENT_DISCONTINUOUS:
		return "GStreamer::Event::Discontinuous";

	    case GST_EVENT_QOS:
		return "GStreamer::Event";

	    case GST_EVENT_SEEK:
		return "GStreamer::Event::Seek";

	    case GST_EVENT_SEEK_SEGMENT:
		return "GStreamer::Event::SeekSegment";

	    case GST_EVENT_SEGMENT_DONE:
		return "GStreamer::Event";

	    case GST_EVENT_SIZE:
		return "GStreamer::Event::Size";

	    case GST_EVENT_RATE:
		return "GStreamer::Event::Rate";

	    case GST_EVENT_FILLER:
		return "GStreamer::Event::Filler";

	    case GST_EVENT_TS_OFFSET:
	    case GST_EVENT_INTERRUPT:
	    case GST_EVENT_NAVIGATION:
		return "GStreamer::Event";

	    default:
		croak ("Unknown GstEvent type encountered: %i", event->type);
	}
}

/* ------------------------------------------------------------------------- */

static GPerlBoxedWrapperClass gst_event_wrapper_class;
static GPerlBoxedWrapperClass *default_wrapper_class;

static SV *
gst_event_wrap (GType gtype,
                const char *package,
                GstEvent *event,
		gboolean own)
{
	HV *stash;
	SV *sv;

	sv = default_wrapper_class->wrap (gtype, package, event, own);

	/* We don't really care about the registered package, override it. */
	package = gst_event_get_package (event);
	stash = gv_stashpv (package, TRUE);
	return sv_bless (sv, stash);
}

static GstEvent *
gst_event_unwrap (GType gtype,
                  const char *package,
                  SV *sv)
{
	GstEvent *event = default_wrapper_class->unwrap (gtype, package, sv);

	/* We don't really care about the registered package, override it. */
	package = gst_event_get_package (event);

	if (!sv_derived_from (sv, package))
		croak ("%s is not of type %s",
		       gperl_format_variable_for_output (sv),
		       package);

	return event;
}

/* ------------------------------------------------------------------------- */

void
gst2perl_event_initialize (void)
{
	default_wrapper_class = gperl_default_boxed_wrapper_class ();
	gst_event_wrapper_class = *default_wrapper_class;
	gst_event_wrapper_class.wrap = (GPerlBoxedWrapFunc) gst_event_wrap;
	gst_event_wrapper_class.unwrap = (GPerlBoxedUnwrapFunc) gst_event_unwrap;

	gperl_register_boxed (GST_TYPE_EVENT, "GStreamer::Event",
	                      &gst_event_wrapper_class);

	gperl_set_isa ("GStreamer::Event", "GStreamer::Data");
}

/* ------------------------------------------------------------------------- */

SV *
newSVGstEventMask (GstEventMask *mask)
{
	HV *hv = newHV ();

	hv_store (hv, "type", 4, newSVGstEventType (mask->type), 0);
	hv_store (hv, "flags", 5, newSVGstEventFlag (mask->flags), 0);

	return (SV *) newRV_noinc ((SV *) hv);
}

/* ------------------------------------------------------------------------- */

MODULE = GStreamer::Event	PACKAGE = GStreamer::Event	PREFIX = gst_event_

BOOT:
#if GST_CHECK_VERSION (0, 8, 10)
	gst2perl_event_initialize ();
#endif

# GstEvent* gst_event_new (GstEventType type);
GstEvent_own *
gst_event_new (class, type)
	GstEventType type
    C_ARGS:
	type

GstEventType
type (event)
	GstEvent *event
    CODE:
	RETVAL = GST_EVENT_TYPE (event);
    OUTPUT:
	RETVAL

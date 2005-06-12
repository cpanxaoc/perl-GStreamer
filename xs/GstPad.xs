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

MODULE = GStreamer::Pad	PACKAGE = GStreamer::Pad	PREFIX = gst_pad_

BOOT:
	gperl_object_set_no_warn_unreg_subclass (GST_TYPE_REAL_PAD, TRUE);

# GstPad * gst_pad_new (const gchar *name, GstPadDirection direction);
GstPad_noinc_ornull *
gst_pad_new (class, name, direction)
	const gchar *name
	GstPadDirection direction
    C_ARGS:
	name, direction

# GstPad * gst_pad_new_from_template (GstPadTemplate *templ, const gchar *name);
GstPad_noinc_ornull *
gst_pad_new_from_template (class, templ, name)
	GstPadTemplate *templ
	const gchar *name
    C_ARGS:
	/* We need to ref templ since gst_pad_new_from_template sinks it. */
	g_object_ref (G_OBJECT (templ)), name

# FIXME?
# GstPad * gst_pad_custom_new (GType type, const gchar *name, GstPadDirection direction);
# GstPad * gst_pad_custom_new_from_template (GType type, GstPadTemplate *templ, const gchar *name);

void gst_pad_set_name (GstPad *pad, const gchar *name);

const gchar* gst_pad_get_name (GstPad *pad);

GstPadDirection gst_pad_get_direction (GstPad *pad);

void gst_pad_set_active (GstPad *pad, gboolean active);

#if GST_CHECK_VERSION (0, 8, 9)

void gst_pad_set_active_recursive (GstPad *pad, gboolean active);

#endif

gboolean gst_pad_is_active (GstPad *pad);

# FIXME?
# void gst_pad_set_element_private (GstPad *pad, gpointer priv);
# gpointer gst_pad_get_element_private (GstPad *pad);

# Deprecated.
# void gst_pad_set_parent (GstPad *pad, GstElement *parent);
# GstElement* gst_pad_get_parent (GstPad *pad);

GstElement* gst_pad_get_real_parent (GstPad *pad);

GstScheduler* gst_pad_get_scheduler (GstPad *pad);

# Will be deprecated soon.
# void gst_pad_add_ghost_pad (GstPad *pad, GstPad *ghostpad);
# void gst_pad_remove_ghost_pad (GstPad *pad, GstPad *ghostpad);

# GList* gst_pad_get_ghost_pad_list (GstPad *pad);
void gst_pad_get_ghost_pad_list (pad)
	GstPad *pad
    PREINIT:
	GList *ghosts, *i;
    PPCODE:
	ghosts = gst_pad_get_ghost_pad_list (pad);
	for (i = ghosts; i != NULL; i = i->next)
		XPUSHs (sv_2mortal (newSVGstGhostPad (i->data)));

GstPadTemplate * gst_pad_get_pad_template (GstPad *pad);

# FIXME?
# GstBuffer* gst_pad_alloc_buffer (GstPad *pad, guint64 offset, gint size);

# const GstEventMask* gst_pad_get_event_masks (GstPad *pad);
# const GstEventMask* gst_pad_get_event_masks_default (GstPad *pad);
void
gst_pad_get_event_masks (pad)
	GstPad *pad
    ALIAS:
	GStreamer::Pad::get_event_masks_default = 1
    PREINIT:
	GstEventMask *list;
	int i;
    PPCODE:
	list = ix == 1 ? 
		(GstEventMask *) gst_pad_get_event_masks_default (pad) :
		(GstEventMask *) gst_pad_get_event_masks (pad);

	if (list != NULL) {
		for (i = 0; list[i].type != 0; i++)
			XPUSHs (sv_2mortal (newSVGstEventMask (&(list[i]))));
	}

gboolean gst_pad_can_link (GstPad *srcpad, GstPad *sinkpad);

gboolean gst_pad_can_link_filtered (GstPad *srcpad, GstPad *sinkpad, const GstCaps *filtercaps);

gboolean gst_pad_link (GstPad *srcpad, GstPad *sinkpad);

gboolean gst_pad_link_filtered (GstPad *srcpad, GstPad *sinkpad, const GstCaps *filtercaps);

void gst_pad_unlink (GstPad *srcpad, GstPad *sinkpad);

gboolean gst_pad_is_linked (GstPad *pad);

GstPad* gst_pad_get_peer (GstPad *pad);

const GstCaps* gst_pad_get_negotiated_caps (GstPad *pad);

gboolean gst_pad_is_negotiated (GstPad *pad);

GstCaps_own * gst_pad_get_caps (GstPad *pad);

const GstCaps* gst_pad_get_pad_template_caps (GstPad *pad);

GstPadLinkReturn gst_pad_try_set_caps (GstPad *pad, const GstCaps *caps);

GstPadLinkReturn gst_pad_try_set_caps_nonfixed (GstPad *pad, const GstCaps *caps);

gboolean gst_pad_check_compatibility (GstPad *srcpad, GstPad *sinkpad);

# FIXME?
# GstCaps * gst_pad_proxy_getcaps (GstPad *pad);
# GstPadLinkReturn gst_pad_proxy_pad_link (GstPad *pad, const GstCaps *caps);
# GstCaps * gst_pad_proxy_fixate (GstPad *pad, const GstCaps *caps);

gboolean gst_pad_set_explicit_caps (GstPad *pad, const GstCaps_ornull *caps);

void gst_pad_use_explicit_caps (GstPad *pad);

gboolean gst_pad_relink_filtered (GstPad *srcpad, GstPad *sinkpad, const GstCaps *filtercaps);

GstPadLinkReturn gst_pad_renegotiate (GstPad *pad);

void gst_pad_unnegotiate (GstPad *pad);

gboolean gst_pad_try_relink_filtered (GstPad *srcpad, GstPad *sinkpad, const GstCaps *filtercaps);

GstCaps_own * gst_pad_get_allowed_caps (GstPad *pad);

void gst_pad_caps_change_notify (GstPad *pad);

gboolean gst_pad_recover_caps_error (GstPad *pad, const GstCaps *allowed);

# void gst_pad_push (GstPad *pad, GstData *data);
void
gst_pad_push (pad, data)
	GstPad *pad
	GstData *data
    C_ARGS:
	pad, gst_data_copy (data)

# GstData* gst_pad_pull (GstPad *pad);
SV *
gst_pad_pull (pad)
	GstPad *pad
    PREINIT:
	GstData *data;
    CODE:
	data = gst_pad_pull (pad);

	if (GST_IS_BUFFER (data)) {
		RETVAL = newSVGstBuffer_own (GST_BUFFER (data));
	} else if (GST_IS_EVENT (data)) {
		RETVAL = newSVGstEvent_own (GST_EVENT (data));
	} else {
		RETVAL = newSVGstData_own (data);
	}
    OUTPUT:
	RETVAL

# gboolean gst_pad_send_event (GstPad *pad, GstEvent *event);
gboolean
gst_pad_send_event (pad, event)
	GstPad *pad
	GstEvent *event
    C_ARGS:
	/* event gets unref'ed, we need to keep it alive. */
	pad, gst_event_ref (event)

# gboolean gst_pad_event_default (GstPad *pad, GstEvent *event);
gboolean
gst_pad_event_default (pad, event)
	GstPad *pad
	GstEvent *event
    C_ARGS:
	/* event gets unref'ed, we need to keep it alive. */
	pad, gst_event_ref (event)

#if GST_CHECK_VERSION (0, 8, 1)

# GstData * gst_pad_collectv (GstPad **selected, const GList *padlist);
# GstData * gst_pad_collect (GstPad **selected, GstPad *pad, ...);
# GstData * gst_pad_collect_valist (GstPad **selected, GstPad *pad, va_list varargs);
void
gst_pad_collect (class, pad, ...)
	GstPad *pad
    PREINIT:
	GList *list = NULL;
	int i;
	GstPad *selected = NULL;
	GstData *result = NULL;
    PPCODE:
	PERL_UNUSED_VAR (pad);

	for (i = 1; i < items; i++)
		list = g_list_append (list, SvGstPad (ST (i)));

	result = gst_pad_collectv (&selected, list);

	g_list_free (list);

	PUSHs (sv_2mortal (newSVGstData_own (result)));
	if (selected)
		XPUSHs (sv_2mortal (newSVGstPad (selected)));

#endif

# const GstFormat* gst_pad_get_formats (GstPad *pad);
# const GstFormat* gst_pad_get_formats_default (GstPad *pad);
void
gst_pad_get_formats (pad)
	GstPad *pad
    ALIAS:
	GStreamer::Pad::get_formats_default = 1
    PREINIT:
	const GstFormat *formats = NULL;
    PPCODE:
	formats = ix == 1 ? gst_pad_get_formats_default (pad) :
	                    gst_pad_get_formats (pad);
	if (formats)
		while (*formats++)
			XPUSHs (sv_2mortal (newSVGstFormat (*formats)));

# gboolean gst_pad_convert (GstPad *pad, GstFormat src_format,  gint64  src_value, GstFormat *dest_format, gint64 *dest_value);
# gboolean gst_pad_convert_default (GstPad *pad, GstFormat src_format,  gint64  src_value, GstFormat *dest_format, gint64 *dest_value);
void
gst_pad_convert (pad, src_format, src_value, dest_format)
	GstPad *pad
	GstFormat src_format
	GstInt64 src_value
	GstFormat dest_format
    ALIAS:
	GStreamer::Pad::convert_default = 1
    PREINIT:
	gint64 dest_value = 0;
    PPCODE:
	if (ix == 1 ? gst_pad_convert_default (pad, src_format, src_value, &dest_format, &dest_value) :
	              gst_pad_convert (pad, src_format, src_value, &dest_format, &dest_value)) {
		EXTEND (sp, 2);
		PUSHs (sv_2mortal (newSVGstFormat (dest_format)));
		PUSHs (sv_2mortal (newSVGstInt64 (dest_value)));
	}

# const GstQueryType* gst_pad_get_query_types (GstPad *pad);
# const GstQueryType* gst_pad_get_query_types_default (GstPad *pad);
void
gst_pad_get_query_types (pad)
	GstPad *pad
    ALIAS:
	GStreamer::Pad::get_query_types_default = 1
    PREINIT:
	const GstQueryType *types = NULL;
    PPCODE:
	types = ix == 1 ? gst_pad_get_query_types_default (pad) :
	                  gst_pad_get_query_types (pad);
	if (types)
		while (*types++)
			XPUSHs (sv_2mortal (newSVGstQueryType (*types)));

# gboolean gst_pad_query (GstPad *pad, GstQueryType type, GstFormat *format, gint64 *value);
# gboolean gst_pad_query_default (GstPad *pad, GstQueryType type, GstFormat *format, gint64 *value);
void
gst_pad_query (pad, type, format)
	GstPad *pad
	GstQueryType type
	GstFormat format
    ALIAS:
	GStreamer::Pad::query_default = 1
    PREINIT:
	gint64 value = 0;
    PPCODE:
	if (ix == 1 ? gst_pad_query_default (pad, type, &format, &value) :
	              gst_pad_query (pad, type, &format, &value)) {
		EXTEND (sp, 2);
		PUSHs (sv_2mortal (newSVGstFormat (format)));
		PUSHs (sv_2mortal (newSVGstInt64 (value)));
	}

# GList* gst_pad_get_internal_links (GstPad *pad);
# GList* gst_pad_get_internal_links_default (GstPad *pad);
void
gst_pad_get_internal_links (pad)
	GstPad *pad
    ALIAS:
	GStreamer::Pad::get_internal_links_default = 1
    PREINIT:
	GList *list, *i;
    PPCODE:
	list = ix == 1 ? gst_pad_get_internal_links_default (pad) :
	                 gst_pad_get_internal_links (pad);
	for (i = list; i != NULL; i = i->next)
		XPUSHs (sv_2mortal (newSVGstPad (i->data)));

# FIXME
# #define gst_pad_add_probe(pad, probe) (gst_probe_dispatcher_add_probe (&(GST_PAD_REALIZE (pad)->probedisp), probe))
# #define gst_pad_remove_probe(pad, probe) (gst_probe_dispatcher_remove_probe (&(GST_PAD_REALIZE (pad)->probedisp), probe))

# FIXME?
# GstPad* gst_ghost_pad_new (const gchar *name, GstPad *pad);

# Marked as "for schedulers only".
# void gst_pad_call_chain_function (GstPad *pad, GstData *data);
# GstData * gst_pad_call_get_function (GstPad *pad);

###############################################################################

# FIXME
# void gst_pad_set_bufferalloc_function (GstPad *pad, GstPadBufferAllocFunction bufalloc);
# void gst_pad_set_chain_function (GstPad *pad, GstPadChainFunction chain);
# void gst_pad_set_get_function (GstPad *pad, GstPadGetFunction get);
# void gst_pad_set_event_function (GstPad *pad, GstPadEventFunction event);
# void gst_pad_set_event_mask_function (GstPad *pad, GstPadEventMaskFunction mask_func);
# void gst_pad_set_link_function (GstPad *pad, GstPadLinkFunction link);
# void gst_pad_set_unlink_function (GstPad *pad, GstPadUnlinkFunction unlink);
# void gst_pad_set_getcaps_function (GstPad *pad, GstPadGetCapsFunction getcaps);
# void gst_pad_set_fixate_function (GstPad *pad, GstPadFixateFunction fixate);
# void gst_pad_set_formats_function (GstPad *pad, GstPadFormatsFunction formats);
# void gst_pad_set_convert_function (GstPad *pad, GstPadConvertFunction convert);
# void gst_pad_set_query_function (GstPad *pad, GstPadQueryFunction query);
# void gst_pad_set_query_type_function (GstPad *pad, GstPadQueryTypeFunction type_func);
# void gst_pad_set_internal_link_function (GstPad *pad, GstPadIntLinkFunction intlink);

# gboolean gst_pad_dispatcher (GstPad *pad, GstPadDispatcherFunction dispatch, gpointer data);

###############################################################################

MODULE = GStreamer::Pad	PACKAGE = GStreamer::PadTemplate	PREFIX = gst_pad_template_

# GstPadTemplate* gst_pad_template_new (const gchar *name_template, GstPadDirection direction, GstPadPresence presence, GstCaps *caps);
GstPadTemplate_noinc *
gst_pad_template_new (class, name_template, direction, presence, caps)
	const gchar *name_template
	GstPadDirection direction
	GstPadPresence presence
	GstCaps *caps
    C_ARGS:
	/* The template takes over ownership of caps, so we have to hand it a
	   copy. */
	name_template, direction, presence, gst_caps_copy (caps)

const GstCaps * gst_pad_template_get_caps (GstPadTemplate *templ);

# FIXME: File bug reports about these missing accessors?

const gchar *
get_name_template (templ)
	GstPadTemplate *templ
    CODE:
	RETVAL = templ->name_template;
    OUTPUT:
	RETVAL

GstPadDirection
get_direction (templ)
	GstPadTemplate *templ
    CODE:
	RETVAL = templ->direction;
    OUTPUT:
	RETVAL

GstPadPresence
get_presence (templ)
	GstPadTemplate *templ
    CODE:
	RETVAL = templ->presence;
    OUTPUT:
	RETVAL

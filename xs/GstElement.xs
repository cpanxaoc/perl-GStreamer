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

/* Copied from GObject.xs. */
static void
init_property_value (GObject * object,
		     const char * name,
		     GValue * value)
{
	GParamSpec * pspec;
	pspec = g_object_class_find_property (G_OBJECT_GET_CLASS (object),
	                                      name);
	if (!pspec) {
		const char * classname =
			gperl_object_package_from_type (G_OBJECT_TYPE (object));
		if (!classname)
			classname = G_OBJECT_TYPE_NAME (object);
		croak ("type %s does not support property '%s'",
		       classname, name);
	}
	g_value_init (value, G_PARAM_SPEC_VALUE_TYPE (pspec));
}

/* ------------------------------------------------------------------------- */

static GQuark
gst2perl_element_loop_function_quark (void)
{
	static GQuark q = 0;
	if (q == 0)
		q = g_quark_from_static_string ("gst2perl_element_loop_function");
	return q;
}

static GPerlCallback *
gst2perl_element_loop_function_create (SV *func, SV *data)
{
	GType param_types [1];
	param_types[0] = GST_TYPE_ELEMENT;

	return gperl_callback_new (func, data, G_N_ELEMENTS (param_types),
	                           param_types, 0);
}

static void
gst2perl_element_loop_function (GstElement *element)
{
	GPerlCallback *callback = g_object_get_qdata (
	                            G_OBJECT (element),
	                            gst2perl_element_loop_function_quark ());

	gperl_callback_invoke (callback, NULL, element);
}

/* ------------------------------------------------------------------------- */

static GPerlBoxedWrapperClass gst_tag_list_wrapper_class;

static void
fill_hv (const GstTagList *list,
         const gchar *tag,
         gpointer user_data)
{
	HV *hv = (HV *) user_data;
	AV *av = newAV ();
	guint size, i;

	size = gst_tag_list_get_tag_size (list, tag);
	for (i = 0; i < size; i++) {
		const GValue *value;
		value = gst_tag_list_get_value_index (list, tag, i);
		av_store (av, i, gperl_sv_from_value (value));
	}

	hv_store (hv, tag, strlen (tag), newRV_noinc ((SV *) av), 0);
}

static SV *
gst_tag_list_wrap (GType gtype,
                   const char *package,
                   GstTagList *list,
		   gboolean own)
{
	HV *hv = newHV ();

	gst_tag_list_foreach (list, fill_hv, hv);
	if (own)
		gst_tag_list_free (list);

	return newRV_noinc ((SV *) hv);
}

static GstTagList *
gst_tag_list_unwrap (GType gtype,
                     const char *package,
                     SV *sv)
{
	/* FIXME: Do we leak the list? */
	GstTagList *list = gst_tag_list_new ();
	HV *hv = (HV *) SvRV (sv);
	HE *he;

	hv_iterinit (hv);
	while (NULL != (he = hv_iternext (hv))) {
		I32 length, i;
		char *tag;
		GType type;
		SV *ref;
		AV *av;

		tag = hv_iterkey (he, &length);
		if (!gst_tag_exists (tag))
			continue;

		ref = hv_iterval (hv, he);
		if (!(SvOK (ref) && SvROK (ref) && SvTYPE (SvRV (ref)) == SVt_PVAV))
			continue;

		type = gst_tag_get_type (tag);

		av = (AV *) SvRV (ref);
		for (i = 0; i <= av_len (av); i++) {
			GValue value = { 0 };
			SV **entry = av_fetch (av, i, 0);

			if (!(entry && SvOK (*entry)))
				continue;

			g_value_init (&value, type);
			gperl_value_from_sv (&value, *entry);

			gst_tag_list_add_values (list, GST_TAG_MERGE_APPEND, tag, &value, NULL);

			g_value_unset (&value);
		}
	}

	return list;
}

/* ------------------------------------------------------------------------- */

MODULE = GStreamer::Element	PACKAGE = GStreamer::Element	PREFIX = gst_element_

BOOT:
	gperl_object_set_no_warn_unreg_subclass (GST_TYPE_ELEMENT, TRUE);
	gst_tag_list_wrapper_class = *gperl_default_boxed_wrapper_class ();
	gst_tag_list_wrapper_class.wrap = (GPerlBoxedWrapFunc) gst_tag_list_wrap;
	gst_tag_list_wrapper_class.unwrap = (GPerlBoxedUnwrapFunc) gst_tag_list_unwrap;
	gperl_register_boxed (GST_TYPE_TAG_LIST, "GStreamer::TagList",
	                      &gst_tag_list_wrapper_class);
	gperl_set_isa ("GStreamer::TagList", "Glib::Boxed");

# FIXME?
# void gst_element_class_add_pad_template (GstElementClass *klass, GstPadTemplate *templ);
# void gst_element_class_install_std_props (GstElementClass *klass, const gchar *first_name, ...);
# void gst_element_class_set_details (GstElementClass *klass, const GstElementDetails *details);

# FIXME?
# void gst_element_default_error (GObject *object, GstObject *orig, GError *error, gchar *debug);

# void gst_element_set_loop_function (GstElement *element, GstElementLoopFunction loop);
void
gst_element_set_loop_function (element, func, data=NULL);
	GstElement *element
	SV *func
	SV *data
    PREINIT:
	GPerlCallback *callback;
    CODE:
	callback = gst2perl_element_loop_function_create (func, data);
	g_object_set_qdata_full (G_OBJECT (element),
	                         gst2perl_element_loop_function_quark (),
	                         callback,
	                         (GDestroyNotify) gperl_callback_destroy);
	gst_element_set_loop_function (element,
	                               gst2perl_element_loop_function);

# void gst_element_set (GstElement *element, const gchar *first_property_name, ...);
# void gst_element_set_valist (GstElement *element, const gchar *first_property_name, va_list var_args);
# void gst_element_set_property (GstElement *element, const gchar *property_name, const GValue *value);
void
gst_element_set (element, property, value, ...);
	GstElement *element
	const gchar *property
	SV *value
    ALIAS:
	GStreamer::Element::set_property = 1
    PREINIT:
	GValue real_value = { 0, };
	int i;
    CODE:
	PERL_UNUSED_VAR (ix);
	PERL_UNUSED_VAR (value);

	for (i = 1; i < items; i += 2) {
		char *name = SvGChar (ST (i));
		SV *value = ST (i + 1);

		init_property_value (G_OBJECT (element), name, &real_value);
		gperl_value_from_sv (&real_value, value);
		gst_element_set_property (element, name, &real_value);
		g_value_unset (&real_value);
	}

# void gst_element_get (GstElement *element, const gchar *first_property_name, ...);
# void gst_element_get_valist (GstElement *element, const gchar *first_property_name, va_list var_args);
# void gst_element_get_property (GstElement *element, const gchar *property_name, GValue *value);
void
gst_element_get (element, property, ...);
	GstElement *element
	const gchar *property
    ALIAS:
	GStreamer::Element::get_property = 1
    PREINIT:
	GValue value = { 0, };
	int i;
    PPCODE:
	PERL_UNUSED_VAR (ix);

	for (i = 1; i < items; i++) {
		char *name = SvGChar (ST (i));

		init_property_value (G_OBJECT (element), name, &value);
		gst_element_get_property (element, name, &value);
		XPUSHs (sv_2mortal (gperl_sv_from_value (&value)));
		g_value_unset (&value);
	}

void gst_element_enable_threadsafe_properties (GstElement *element);

void gst_element_disable_threadsafe_properties (GstElement *element);

void gst_element_set_pending_properties (GstElement *element);

gboolean gst_element_requires_clock (GstElement *element);

gboolean gst_element_provides_clock (GstElement *element);

GstClock_ornull * gst_element_get_clock (GstElement *element);

void gst_element_set_clock (GstElement *element, GstClock_ornull *clock);

# GstClockReturn gst_element_clock_wait (GstElement *element, GstClockID id, GstClockTimeDiff *jitter);
void
gst_element_clock_wait (element, id)
	GstElement *element
	GstClockID id
    PREINIT:
	GstClockReturn retval = 0;
	GstClockTimeDiff jitter = 0;
    PPCODE:
	retval = gst_element_clock_wait (element, id, &jitter);
	EXTEND (sp, 2);
	PUSHs (sv_2mortal (newSVGstClockReturn (retval)));
	PUSHs (sv_2mortal (newSVGstClockTimeDiff (jitter)));

GstClockTime gst_element_get_time (GstElement *element);

gboolean gst_element_wait (GstElement *element, GstClockTime timestamp);

void gst_element_set_time (GstElement *element, GstClockTime time);

#if GST_CHECK_VERSION (0, 8, 1)

void gst_element_set_time_delay (GstElement *element, GstClockTime time, GstClockTime delay);

#endif

#if GST_CHECK_VERSION (0, 8, 2)

void gst_element_no_more_pads (GstElement *element);

#endif

void gst_element_adjust_time (GstElement *element, GstClockTimeDiff diff);

gboolean gst_element_is_indexable (GstElement *element);

void gst_element_set_index (GstElement *element, GstIndex *index);

GstIndex* gst_element_get_index (GstElement *element);

gboolean gst_element_release_locks (GstElement *element);

void gst_element_yield (GstElement *element);

gboolean gst_element_interrupt (GstElement *element);

void gst_element_set_scheduler (GstElement *element, GstScheduler *sched);

GstScheduler* gst_element_get_scheduler (GstElement *element);

void gst_element_add_pad (GstElement *element, GstPad *pad);

void gst_element_remove_pad (GstElement *element, GstPad *pad);

GstPad_noinc_ornull * gst_element_add_ghost_pad (GstElement *element, GstPad *pad, const gchar *name);

GstPad* gst_element_get_pad (GstElement *element, const gchar *name);

GstPad* gst_element_get_static_pad (GstElement *element, const gchar *name);

GstPad* gst_element_get_request_pad (GstElement *element, const gchar *name);

# FIXME?
# void gst_element_release_request_pad (GstElement *element, GstPad *pad);

# G_CONST_RETURN GList* gst_element_get_pad_list (GstElement *element);
void
gst_element_get_pad_list (element)
	GstElement *element
    PREINIT:
	GList *list, *i;
    PPCODE:
	list = (GList *) gst_element_get_pad_list (element);
	for (i = list; i != NULL; i = i->next)
		XPUSHs (sv_2mortal (newSVGstPad (i->data)));

GstPad* gst_element_get_compatible_pad (GstElement *element, GstPad *pad);

GstPad* gst_element_get_compatible_pad_filtered (GstElement *element, GstPad *pad, const GstCaps *filtercaps);

# FIXME?
# GstPadTemplate* gst_element_class_get_pad_template (GstElementClass *element_class, const gchar *name);
# GList* gst_element_class_get_pad_template_list (GstElementClass *element_class);

GstPadTemplate_ornull* gst_element_get_pad_template (GstElement *element, const gchar *name);

# GList* gst_element_get_pad_template_list (GstElement *element);
void
gst_element_get_pad_template_list (element)
	GstElement *element
    PREINIT:
	GList *list, *i;
    PPCODE:
	list = gst_element_get_pad_template_list (element);
	for (i = list; i != NULL; i = i->next)
		XPUSHs (sv_2mortal (newSVGstPadTemplate (i->data)));

GstPadTemplate_ornull* gst_element_get_compatible_pad_template (GstElement *element, GstPadTemplate *compattempl);

# gboolean gst_element_link (GstElement *src, GstElement *dest);
# gboolean gst_element_link_many (GstElement *element_1, GstElement *element_2, ...);
gboolean
gst_element_link (src, dest, ...)
	GstElement *src
	GstElement *dest
    ALIAS:
	GStreamer::Element::link_many = 1
    PREINIT:
	int i;
    CODE:
	PERL_UNUSED_VAR (ix);
	RETVAL = TRUE;

	for (i = 1; i < items && RETVAL != FALSE; i++) {
		dest = SvGstElement (ST (i));
		if (!gst_element_link (src, dest))
			RETVAL = FALSE;
		src = dest;
	}
    OUTPUT:
	RETVAL

gboolean gst_element_link_filtered (GstElement *src, GstElement *dest, const GstCaps *filtercaps);

# void gst_element_unlink (GstElement *src, GstElement *dest);
# void gst_element_unlink_many (GstElement *element_1, GstElement *element_2, ...);
void
gst_element_unlink (src, dest, ...)
	GstElement *src
	GstElement *dest
    ALIAS:
	GStreamer::Element::unlink_many = 1
    PREINIT:
	int i;
    CODE:
	PERL_UNUSED_VAR (ix);

	for (i = 1; i < items; i++) {
		dest = SvGstElement (ST (i));
		gst_element_unlink (src, dest);
		src = dest;
	}

gboolean gst_element_link_pads (GstElement *src, const gchar *srcpadname, GstElement *dest, const gchar *destpadname);

gboolean gst_element_link_pads_filtered (GstElement *src, const gchar *srcpadname, GstElement *dest, const gchar *destpadname, const GstCaps *filtercaps);

void gst_element_unlink_pads (GstElement *src, const gchar *srcpadname, GstElement *dest, const gchar *destpadname);

# G_CONST_RETURN GstEventMask* gst_element_get_event_masks (GstElement *element);
void
gst_element_get_event_masks (element)
	GstElement *element
    PREINIT:
	GstEventMask *masks;
    PPCODE:
	masks = (GstEventMask *) gst_element_get_event_masks (element);
	while (masks++)
		XPUSHs (sv_2mortal (newSVGstEventMask (masks)));

# gboolean gst_element_send_event (GstElement *element, GstEvent *event);
gboolean
gst_element_send_event (element, event)
	GstElement *element
	GstEvent *event
    C_ARGS:
	/* event gets unref'ed, we need to keep it alive. */
	element, gst_event_ref (event)

gboolean gst_element_seek (GstElement *element, GstSeekType seek_type, guint64 offset);

# G_CONST_RETURN GstQueryType* gst_element_get_query_types (GstElement *element);
void
gst_element_get_query_types (element)
	GstElement *element
    PREINIT:
	GstQueryType *types;
    PPCODE:
	types = (GstQueryType *) gst_element_get_query_types (element);
	if (types)
		while (*types++)
			XPUSHs (sv_2mortal (newSVGstQueryType (*types)));

# gboolean gst_element_query (GstElement *element, GstQueryType type, GstFormat *format, gint64 *value);
void
gst_element_query (element, type, format)
	GstElement *element
	GstQueryType type
	GstFormat format
    PREINIT:
	gint64 value = 0;
    PPCODE:
	if (gst_element_query (element, type, &format, &value)) {
		EXTEND (sp, 2);
		PUSHs (sv_2mortal (newSVGstFormat (format)));
		PUSHs (sv_2mortal (newSVnv (value)));
	}

# G_CONST_RETURN GstFormat* gst_element_get_formats (GstElement *element);
void
gst_element_get_formats (element)
	GstElement *element
    PREINIT:
	GstFormat *formats;
    PPCODE:
	formats = (GstFormat *) gst_element_get_formats (element);
	if (formats)
		while (*formats++)
			XPUSHs (sv_2mortal (newSVGstFormat (*formats)));

# gboolean gst_element_convert (GstElement *element, GstFormat  src_format,  gint64  src_value, GstFormat *dest_format, gint64 *dest_value);
void
gst_element_convert (element, src_format, src_value, dest_format)
	GstElement *element
	GstFormat src_format
	gint64 src_value
	GstFormat dest_format
    PREINIT:
	gint64 dest_value = 0;
    PPCODE:
	if (gst_element_convert (element, src_format, src_value, &dest_format, &dest_value)) {
		EXTEND (sp, 2);
		PUSHs (sv_2mortal (newSVGstFormat (dest_format)));
		PUSHs (sv_2mortal (newSVnv (dest_value)));
	}

void gst_element_found_tags (GstElement *element, const GstTagList *tag_list);

# void gst_element_found_tags_for_pad (GstElement *element, GstPad *pad, GstClockTime timestamp, GstTagList *list);
void
gst_element_found_tags_for_pad (element, pad, timestamp, list)
	GstElement *element
	GstPad *pad
	GstClockTime timestamp
	GstTagList *list
    C_ARGS:
	/* gst_element_found_tags_for_pad takes ownership of list. */
	element, pad, timestamp, gst_tag_list_copy (list)

void gst_element_set_eos (GstElement *element);

# FIXME?
# gchar * _gst_element_error_printf (const gchar *format, ...);
# void gst_element_error_full (GstElement *element, GQuark domain, gint code, gchar *message, gchar *debug, const gchar *file, const gchar *function, gint line);

gboolean gst_element_is_locked_state (GstElement *element);

void gst_element_set_locked_state (GstElement *element, gboolean locked_state);

gboolean gst_element_sync_state_with_parent (GstElement *element);

GstElementState gst_element_get_state (GstElement *element);

GstElementStateReturn gst_element_set_state (GstElement *element, GstElementState state);

void gst_element_wait_state_change (GstElement *element);

# FIXME?
# G_CONST_RETURN gchar* gst_element_state_get_name (GstElementState state);

GstElementFactory* gst_element_get_factory (GstElement *element);

GstBin* gst_element_get_managing_bin (GstElement *element);

# --------------------------------------------------------------------------- #

MODULE = GStreamer::Element	PACKAGE = GStreamer::ElementFactory	PREFIX = gst_element_factory_

# FIXME
# gboolean gst_element_register (GstPlugin *plugin, const gchar *name, guint rank, GType type);

# GstElementFactory * gst_element_factory_find (const gchar *name);
GstElementFactory_ornull *
gst_element_factory_find (class, name)
	const gchar *name
    C_ARGS:
	name

const gchar * gst_element_factory_get_longname (GstElementFactory *factory);

const gchar * gst_element_factory_get_klass (GstElementFactory *factory);

const gchar * gst_element_factory_get_description (GstElementFactory *factory);

const gchar * gst_element_factory_get_author (GstElementFactory *factory);

guint gst_element_factory_get_num_pad_templates (GstElementFactory *factory);

# const GList * gst_element_factory_get_pad_templates (GstElementFactory *factory);
void
gst_element_factory_get_pad_templates (factory)
	GstElementFactory *factory
    PREINIT:
	GList *templates, *i;
    PPCODE:
	templates = (GList *) gst_element_factory_get_pad_templates (factory);
	for (i = templates; i != NULL; i = i->next)
		XPUSHs (sv_2mortal (newSVGstPadTemplate (i->data)));

GstURIType gst_element_factory_get_uri_type (GstElementFactory *factory);

# gchar ** gst_element_factory_get_uri_protocols (GstElementFactory *factory);
void
gst_element_factory_get_uri_protocols (factory)
	GstElementFactory *factory
    PREINIT:
	gchar **uris;
    PPCODE:
	uris = gst_element_factory_get_uri_protocols (factory);
	if (uris) {
		gchar *uri;
		while ((uri = *(uris++)) != NULL)
		XPUSHs (sv_2mortal (newSVGChar (uri)));
	}

# Ref and sink newly created objects to claim ownership.

GstElement_noinc_ornull * gst_element_factory_create (GstElementFactory *factory, const gchar_ornull *name);

# GstElement * gst_element_factory_make (const gchar *factoryname, const gchar *name);
void
gst_element_factory_make (class, factoryname, name, ...);
	const gchar *factoryname
	const gchar *name
    PREINIT:
	int i;
    PPCODE:
	for (i = 1; i < items; i += 2)
		XPUSHs (
		  sv_2mortal (
		    newSVGstElement_noinc_ornull (
		      gst_element_factory_make (SvGChar (ST (i)),
		                                SvGChar (ST (i + 1))))));

gboolean gst_element_factory_can_src_caps (GstElementFactory *factory, const GstCaps *caps);

gboolean gst_element_factory_can_sink_caps (GstElementFactory *factory, const GstCaps *caps);

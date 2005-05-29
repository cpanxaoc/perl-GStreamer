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

static GQuark
gst2perl_index_filter_quark (void)
{
	static GQuark q = 0;
	if (q == 0)
		q = g_quark_from_static_string ("gst2perl_index_filter");
	return q;
}

static GPerlCallback *
gst2perl_index_filter_create (SV *func, SV *data)
{
	GType param_types [2];
	param_types[0] = GST_TYPE_INDEX;
	param_types[1] = GST_TYPE_INDEX_ENTRY;
	return gperl_callback_new (func, data, G_N_ELEMENTS (param_types),
				   param_types, G_TYPE_BOOLEAN);
}

static gboolean
gst2perl_index_filter (GstIndex *index,
                       GstIndexEntry *entry)
{
	GPerlCallback *callback;
	GValue value = { 0, };
	gboolean retval;

	callback = g_object_get_qdata (G_OBJECT (index),
	                               gst2perl_index_filter_quark ());

	g_value_init (&value, callback->return_type);
	gperl_callback_invoke (callback, &value, entry);
	retval = g_value_get_boolean (&value);
	g_value_unset (&value);

	return retval;
}

/* ------------------------------------------------------------------------- */

#if !GST_CHECK_VERSION (0, 8, 10)

extern GstIndexEntry * gst_index_add_associationv (GstIndex *index, gint id, GstAssocFlags flags, int n, const GstIndexAssociation *list);

#endif

/* ------------------------------------------------------------------------- */

#include <gperl_marshal.h>

static GQuark
gst2perl_index_resolver_quark (void)
{
	static GQuark q = 0;
	if (q == 0)
		q = g_quark_from_static_string ("gst2perl_index_resolver");
	return q;
}

static GPerlCallback *
gst2perl_index_resolver_create (SV *func, SV *data)
{
	return gperl_callback_new (func, data, 0, NULL, 0);
}

static gboolean
gst2perl_index_resolver (GstIndex *index,
                         GstObject *writer,
                         gchar **writer_string,
                         gpointer user_data)
{
	int n;
	SV *string;
	gboolean retval;
	dGPERL_CALLBACK_MARSHAL_SP;

	GPerlCallback *callback = user_data;
	GPERL_CALLBACK_MARSHAL_INIT (callback);

	ENTER;
	SAVETMPS;

	PUSHMARK (SP);

	EXTEND (SP, 2);
	PUSHs (sv_2mortal (newSVGstIndex (index)));
	PUSHs (sv_2mortal (newSVGstObject (writer)));
	if (callback->data)
		XPUSHs (sv_2mortal (newSVsv (callback->data)));

	PUTBACK;

	n = call_sv (callback->func, G_SCALAR);

	SPAGAIN;

	if (n != 1)
		croak ("resolver callback must return one value: the writer string");

	string = POPs;
	if (SvOK (string)) {
		*writer_string = g_strdup (SvGChar (string));
		retval = TRUE;
	} else {
		*writer_string = NULL;
		retval = FALSE;
	}

	PUTBACK;
	FREETMPS;
	LEAVE;

	return retval;
}

/* ------------------------------------------------------------------------- */

MODULE = GStreamer::Index	PACKAGE = GStreamer::Index	PREFIX = gst_index_

# GstIndex * gst_index_new (void);
GstIndex_noinc *
gst_index_new (class)
    C_ARGS:
	/* void */

void gst_index_commit (GstIndex *index, gint id);

gint gst_index_get_group (GstIndex *index);

gint gst_index_new_group (GstIndex *index);

gboolean gst_index_set_group (GstIndex *index, gint groupnum);

void gst_index_set_certainty (GstIndex *index, GstIndexCertainty certainty);

GstIndexCertainty gst_index_get_certainty (GstIndex *index);

# void gst_index_set_filter (GstIndex *index, GstIndexFilter filter, gpointer user_data);
void
gst_index_set_filter (index, func, data=NULL)
	GstIndex *index
	SV *func
	SV *data
    PREINIT:
	GPerlCallback *callback;
    CODE:
	/* gst_index_set_filter() ignores the user_data parameter, so we need
	   to put our callback into the object. */
	callback = gst2perl_index_filter_create (func, data);
	g_object_set_qdata_full (G_OBJECT (index),
	                         gst2perl_index_filter_quark (),
	                         callback,
	                         (GDestroyNotify) gperl_callback_destroy);
	gst_index_set_filter (index, gst2perl_index_filter, NULL);

# void gst_index_set_resolver (GstIndex *index, GstIndexResolver resolver, gpointer user_data);
void
gst_index_set_resolver (index, func, data=NULL)
	GstIndex *index
	SV *func
	SV *data
    PREINIT:
	GPerlCallback *callback;
    CODE:
	callback = gst2perl_index_resolver_create (func, data);
	g_object_set_qdata_full (G_OBJECT (index),
	                         gst2perl_index_resolver_quark (),
	                         callback,
	                         (GDestroyNotify) gperl_callback_destroy);
	gst_index_set_resolver (index, gst2perl_index_resolver, callback);

# gboolean gst_index_get_writer_id (GstIndex *index, GstObject *writer, gint *id);
gint
gst_index_get_writer_id (index, writer)
	GstIndex *index
	GstObject *writer
    CODE:
	if (!gst_index_get_writer_id (index, writer, &RETVAL))
		XSRETURN_UNDEF;
    OUTPUT:
	RETVAL

# FIXME: Is it right to assume ownership for all those GstIndexEntry's?

GstIndexEntry_own * gst_index_add_format (GstIndex *index, gint id, GstFormat format);

# GstIndexEntry * gst_index_add_association (GstIndex *index, gint id, GstAssocFlags flags, GstFormat format, gint64 value, ...);
GstIndexEntry_own *
gst_index_add_association (index, id, flags, format, value, ...)
	GstIndex *index
	gint id
	GstAssocFlags flags
	GstFormat format
	GstInt64 value
    PREINIT:
	GArray *array;
	int i, n_assocs = 0;
	GstIndexAssociation *list;
    CODE:
	PERL_UNUSED_VAR (format);
	PERL_UNUSED_VAR (value);

	array = g_array_new (FALSE, FALSE, sizeof (GstIndexAssociation));

	for (i = 3; i < items; i += 2) {
		GstIndexAssociation a;

		a.format = SvGstFormat (ST (i));
		a.value = SvGstInt64 (ST (i + 1));

		g_array_append_val (array, a);
		n_assocs++;
	}

	list = (GstIndexAssociation *) g_array_free (array, FALSE);

	RETVAL = gst_index_add_associationv (index, id, flags, n_assocs, list);
	g_free (list);
    OUTPUT:
	RETVAL

# GstIndexEntry * gst_index_add_object (GstIndex *index, gint id, gchar *key, GType type, gpointer object);
GstIndexEntry_own *
gst_index_add_object (index, id, key, object)
	GstIndex *index
	gint id
	gchar *key
	SV *object
    PREINIT:
	GType type;
    CODE:
	type = gperl_object_type_from_package (sv_reftype (SvRV (object),
	                                                   TRUE));
	RETVAL = gst_index_add_object (index, id, key, type,
	                               gperl_get_object_check (object, type));
    OUTPUT:
	RETVAL

GstIndexEntry_own * gst_index_add_id (GstIndex *index, gint id, gchar *description);

GstIndexEntry_own * gst_index_get_assoc_entry (GstIndex *index, gint id, GstIndexLookupMethod method, GstAssocFlags flags, GstFormat format, GstInt64 value);

# FIXME
# GstIndexEntry * gst_index_get_assoc_entry_full (GstIndex *index, gint id, GstIndexLookupMethod method, GstAssocFlags flags, GstFormat format, gint64 value, GCompareDataFunc func, gpointer user_data);

# --------------------------------------------------------------------------- #

MODULE = GStreamer::Index	PACKAGE = GStreamer::IndexEntry	PREFIX = gst_index_entry_

# gboolean gst_index_entry_assoc_map (GstIndexEntry *entry, GstFormat format, gint64 *value);
GstInt64
gst_index_entry_assoc_map (entry, format)
	GstIndexEntry *entry
	GstFormat format
    CODE:
	if (!gst_index_entry_assoc_map (entry, format, &RETVAL))
		XSRETURN_UNDEF;
    OUTPUT:
	RETVAL

# --------------------------------------------------------------------------- #

MODULE = GStreamer::Index	PACKAGE = GStreamer::IndexFactory	PREFIX = gst_index_factory_

# GstIndexFactory * gst_index_factory_new (const gchar *name, const gchar *longdesc, GType type);
GstIndexFactory_noinc *
gst_index_factory_new (class, name, longdesc, type)
	const gchar *name
	const gchar *longdesc
	const char *type
    PREINIT:
	GType real_type;
    CODE:
	real_type = gperl_type_from_package (type);
	RETVAL = gst_index_factory_new (name, longdesc, real_type);
#if !GST_CHECK_VERSION (0, 8, 10)
	if (RETVAL)
		g_object_ref (G_OBJECT (RETVAL));
#endif
    OUTPUT:
	RETVAL

# FIXME?
# void gst_index_factory_destroy (GstIndexFactory *factory);

# GstIndexFactory * gst_index_factory_find (const gchar *name);
GstIndexFactory *
gst_index_factory_find (class, name)
	const gchar *name
    C_ARGS:
	name

GstIndex_noinc * gst_index_factory_create (GstIndexFactory *factory);

# GstIndex * gst_index_factory_make (const gchar *name);
GstIndex_noinc *
gst_index_factory_make (class, name)
	const gchar *name
    C_ARGS:
	name

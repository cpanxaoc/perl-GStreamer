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

/* Implemented in GstPluginFeature.xs. */

extern GPerlCallback * gst2perl_plugin_feature_filter_create (SV *func, SV *data);

extern gboolean gst2perl_plugin_feature_filter (GstPluginFeature *feature, gpointer user_data);

/* ------------------------------------------------------------------------- */

/* Used in GstRegistry.xs and GstRegistryPool.xs. */

GPerlCallback *
gst2perl_plugin_filter_create (SV *func, SV *data)
{
	GType param_types [1];
	param_types[0] = GST_TYPE_PLUGIN;
	return gperl_callback_new (func, data, G_N_ELEMENTS (param_types),
				   param_types, G_TYPE_BOOLEAN);
}

gboolean
gst2perl_plugin_filter (GstPlugin *plugin,
                        gpointer user_data)
{
	GPerlCallback *callback = user_data;
	GValue value = { 0, };
	gboolean retval;

	g_value_init (&value, callback->return_type);
	gperl_callback_invoke (callback, &value, plugin);
	retval = g_value_get_boolean (&value);
	g_value_unset (&value);

	return retval;
}

/* ------------------------------------------------------------------------- */

MODULE = GStreamer::Plugin	PACKAGE = GStreamer::Plugin	PREFIX = gst_plugin_

const gchar* gst_plugin_get_name (GstPlugin *plugin);

const gchar* gst_plugin_get_description (GstPlugin *plugin);

const gchar* gst_plugin_get_filename (GstPlugin *plugin);

#if GST_CHECK_VERSION (0, 8, 8)

const gchar* gst_plugin_get_version (GstPlugin *plugin);

#endif

const gchar* gst_plugin_get_license (GstPlugin *plugin);

const gchar* gst_plugin_get_package (GstPlugin *plugin);

const gchar* gst_plugin_get_origin (GstPlugin *plugin);

# FIXME?
# GModule * gst_plugin_get_module (GstPlugin *plugin);

gboolean gst_plugin_is_loaded (GstPlugin *plugin);

# GList* gst_plugin_feature_filter (GstPlugin *plugin, GstPluginFeatureFilter filter, gboolean first, gpointer user_data);
void
gst_plugin_feature_filter (plugin, filter, first, data=NULL)
	GstPlugin *plugin
	SV *filter
	gboolean first
	SV *data
    PREINIT:
	GPerlCallback *callback;
	GList *list, *i;
    PPCODE:
	callback = gst2perl_plugin_feature_filter_create (filter, data);
	list = gst_plugin_feature_filter (plugin,
	                                  gst2perl_plugin_feature_filter,
	                                  first,
	                                  callback);

	for (i = list; i != NULL; i = i->next)
		XPUSHs (sv_2mortal (newSVGstPluginFeature (i->data)));

	g_list_free (list);
	gperl_callback_destroy (callback);

# FIXME?
# GList* gst_plugin_list_feature_filter (GList *list, GstPluginFeatureFilter filter, gboolean first, gpointer user_data);

gboolean gst_plugin_name_filter (GstPlugin *plugin, const gchar *name);

# GList* gst_plugin_get_feature_list (GstPlugin *plugin);
void
gst_plugin_get_feature_list (plugin)
	GstPlugin *plugin
    PREINIT:
	GList *list, *i;
    PPCODE:
	list = gst_plugin_get_feature_list (plugin);
	for (i = list; i != NULL; i = i->next)
		XPUSHs (sv_2mortal (newSVGstPluginFeature (i->data)));
	g_list_free (list);

# GstPluginFeature* gst_plugin_find_feature (GstPlugin *plugin, const gchar *name, GType type);
GstPluginFeature *
gst_plugin_find_feature (plugin, name, type)
	GstPlugin *plugin
	const gchar *name
	const char *type
    C_ARGS:
	plugin, name, gperl_type_from_package (type)

=for apidoc __function__
=cut
# gboolean gst_plugin_check_file (const gchar *filename, GError** error);
gboolean
gst_plugin_check_file (filename)
	const gchar *filename
    PREINIT:
	GError *error = NULL;
    CODE:
	RETVAL = gst_plugin_check_file (filename, &error);
	if (!RETVAL)
		gperl_croak_gerror (NULL, error);
    OUTPUT:
	RETVAL

=for apidoc __function__
=cut
# GstPlugin * gst_plugin_load_file (const gchar *filename, GError** error);
GstPlugin *
gst_plugin_load_file (filename)
	const gchar *filename
    PREINIT:
	GError *error = NULL;
    CODE:
	RETVAL = gst_plugin_load_file (filename, &error);
	if (!RETVAL)
		gperl_croak_gerror (NULL, error);
    OUTPUT:
	RETVAL

gboolean gst_plugin_unload_plugin (GstPlugin *plugin);

void gst_plugin_add_feature (GstPlugin *plugin, GstPluginFeature *feature);

=for apidoc __function__
=cut
gboolean gst_plugin_load (const gchar *name);

MODULE = GStreamer::Plugin	PACKAGE = GStreamer::Library	PREFIX = gst_library_

=for apidoc __function__
=cut
gboolean gst_library_load (const gchar *name);

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

/* Implemented in GstPlugin.xs. */

extern GPerlCallback * gst2perl_plugin_filter_create (SV *func, SV *data);

extern gboolean gst2perl_plugin_filter (GstPlugin *plugin, gpointer user_data);

/* ------------------------------------------------------------------------- */

/* Implemented in GstPluginFeature.xs. */

extern GPerlCallback * gst2perl_plugin_feature_filter_create (SV *func, SV *data);

extern gboolean gst2perl_plugin_feature_filter (GstPluginFeature *feature, gpointer user_data);

/* ------------------------------------------------------------------------- */

MODULE = GStreamer::Registry	PACKAGE = GStreamer::Registry	PREFIX = gst_registry_

BOOT:
	gperl_object_set_no_warn_unreg_subclass (GST_TYPE_REGISTRY, TRUE);

gboolean gst_registry_load (GstRegistry *registry);

gboolean gst_registry_is_loaded (GstRegistry *registry);

gboolean gst_registry_save (GstRegistry *registry);

gboolean gst_registry_rebuild (GstRegistry *registry);

gboolean gst_registry_unload (GstRegistry *registry);

void gst_registry_add_path (GstRegistry *registry, const gchar *path);

# GList* gst_registry_get_path_list (GstRegistry *registry);
void
gst_registry_get_path_list (registry)
	GstRegistry *registry
    PREINIT:
	GList *paths, *i;
    PPCODE:
	paths = gst_registry_get_path_list (registry);
	for (i = paths; i != NULL; i = i->next)
		XPUSHs (sv_2mortal (newSVGChar (i->data)));
	g_list_free (paths);

void gst_registry_clear_paths (GstRegistry *registry);

gboolean gst_registry_add_plugin (GstRegistry *registry, GstPlugin *plugin);

void gst_registry_remove_plugin (GstRegistry *registry, GstPlugin *plugin);

# GList* gst_registry_plugin_filter (GstRegistry *registry, GstPluginFilter filter, gboolean first, gpointer user_data);
void
gst_registry_plugin_filter (registry, filter, first, data=NULL)
	GstRegistry *registry
	SV *filter
	gboolean first
	SV *data
    PREINIT:
	GPerlCallback *callback;
	GList *list, *i;
    PPCODE:
	callback = gst2perl_plugin_filter_create (filter, data);
	list = gst_registry_plugin_filter (registry,
	                                   gst2perl_plugin_filter,
	                                   first,
	                                   callback);

	for (i = list; i != NULL; i = i->next)
		XPUSHs (sv_2mortal (newSVGstPlugin (i->data)));

	g_list_free (list);
	gperl_callback_destroy (callback);

# GList* gst_registry_feature_filter (GstRegistry *registry, GstPluginFeatureFilter filter, gboolean first, gpointer user_data);
void
gst_registry_feature_filter (registry, filter, first, data=NULL)
	GstRegistry *registry
	SV *filter
	gboolean first
	SV *data
    PREINIT:
	GPerlCallback *callback;
	GList *list, *i;
    PPCODE:
	callback = gst2perl_plugin_feature_filter_create (filter, data);
	list = gst_registry_feature_filter (registry,
	                                    gst2perl_plugin_feature_filter,
	                                    first,
	                                    callback);

	for (i = list; i != NULL; i = i->next)
		XPUSHs (sv_2mortal (newSVGstPluginFeature (i->data)));

	g_list_free (list);
	gperl_callback_destroy (callback);

GstPlugin* gst_registry_find_plugin (GstRegistry *registry, const gchar *name);

# GstPluginFeature* gst_registry_find_feature (GstRegistry *registry, const gchar *name, GType type);
GstPluginFeature *
gst_registry_find_feature (registry, name, type)
	GstRegistry *registry
	const gchar *name
	const char *type
    C_ARGS:
	registry, name, gperl_type_from_package (type)

GstRegistryReturn gst_registry_load_plugin (GstRegistry *registry, GstPlugin *plugin);

GstRegistryReturn gst_registry_unload_plugin (GstRegistry *registry, GstPlugin *plugin);

GstRegistryReturn gst_registry_update_plugin (GstRegistry *registry, GstPlugin *plugin);

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

MODULE = GStreamer::RegistryPool	PACKAGE = GStreamer::RegistryPool	PREFIX = gst_registry_pool_

# GList* gst_registry_pool_list (void);
void
gst_registry_pool_list (class)
    PREINIT:
	GList *list, *i;
    PPCODE:
	list = gst_registry_pool_list ();
	for (i = list; i != NULL; i = i->next)
		XPUSHs (sv_2mortal (newSVGstRegistry (i->data)));
	g_list_free (list);

# void gst_registry_pool_add (GstRegistry *registry, guint priority);
void
gst_registry_pool_add (class, registry, priority)
	GstRegistry *registry
	guint priority
    C_ARGS:
	registry, priority

# void gst_registry_pool_remove (GstRegistry *registry);
void
gst_registry_pool_remove (class, registry)
	GstRegistry *registry
    C_ARGS:
	registry

# void gst_registry_pool_add_plugin (GstPlugin *plugin);
void
gst_registry_pool_add_plugin (class, plugin)
	GstPlugin *plugin
    C_ARGS:
	plugin

# void gst_registry_pool_load_all (void);
void
gst_registry_pool_load_all (class)
    C_ARGS:
	/* void */

# GList* gst_registry_pool_plugin_filter (GstPluginFilter filter, gboolean first, gpointer user_data);
void
gst_registry_pool_plugin_filter (class, filter, first, data=NULL)
	SV *filter
	gboolean first
	SV *data
    PREINIT:
	GPerlCallback *callback;
	GList *list, *i;
    PPCODE:
	callback = gst2perl_plugin_filter_create (filter, data);
	list = gst_registry_pool_plugin_filter (gst2perl_plugin_filter,
	                                        first,
	                                        callback);

	for (i = list; i != NULL; i = i->next)
		XPUSHs (sv_2mortal (newSVGstPlugin (i->data)));

	g_list_free (list);
	gperl_callback_destroy (callback);

# GList* gst_registry_pool_feature_filter (GstPluginFeatureFilter filter, gboolean first, gpointer user_data);
void
gst_registry_pool_feature_filter (class, filter, first, data=NULL)
	SV *filter
	gboolean first
	SV *data
    PREINIT:
	GPerlCallback *callback;
	GList *list, *i;
    PPCODE:
	callback = gst2perl_plugin_feature_filter_create (filter, data);
	list = gst_registry_pool_feature_filter (gst2perl_plugin_feature_filter,
	                                         first,
	                                         callback);

	for (i = list; i != NULL; i = i->next)
		XPUSHs (sv_2mortal (newSVGstPluginFeature (i->data)));

	g_list_free (list);
	gperl_callback_destroy (callback);

# GList* gst_registry_pool_plugin_list (void);
void
gst_registry_pool_plugin_list (class)
    PREINIT:
	GList *list, *i;
    PPCODE:
	list = gst_registry_pool_plugin_list ();
	for (i = list; i != NULL; i = i->next)
		XPUSHs (sv_2mortal (newSVGstPlugin (i->data)));
	g_list_free (list);

# GList* gst_registry_pool_feature_list (GType type);
void
gst_registry_pool_feature_list (class, type)
	const char *type
    PREINIT:
	GList *list, *i;
    PPCODE:
	list = gst_registry_pool_feature_list (gperl_type_from_package (type));
	for (i = list; i != NULL; i = i->next)
		XPUSHs (sv_2mortal (newSVGstPluginFeature (i->data)));
	g_list_free (list);

# GstPlugin* gst_registry_pool_find_plugin (const gchar *name);
GstPlugin *
gst_registry_pool_find_plugin (class, name)
	const gchar *name
    C_ARGS:
	name

# GstPluginFeature* gst_registry_pool_find_feature (const gchar *name, GType type);

# GstRegistry* gst_registry_pool_get_prefered (GstRegistryFlags flags);
GstRegistry *
gst_registry_pool_get_prefered (class, flags)
	GstRegistryFlags flags
    C_ARGS:
	flags

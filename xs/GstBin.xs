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

MODULE = GStreamer::Bin	PACKAGE = GStreamer::Bin	PREFIX = gst_bin_

BOOT:
	gperl_object_set_no_warn_unreg_subclass (GST_TYPE_BIN, TRUE);

# GstElement* gst_bin_new (const gchar *name);
GstElement_noinc *
gst_bin_new (class, name)
	const gchar *name
    C_ARGS:
	name

# void gst_bin_add (GstBin *bin, GstElement *element);
# void gst_bin_add_many (GstBin *bin, GstElement *element_1, ...);
void
gst_bin_add (bin, element, ...)
	GstBin *bin
	GstElement *element
    ALIAS:
	GStreamer::Bin::add_many = 1
    PREINIT:
	int i;
    CODE:
	PERL_UNUSED_VAR (ix);
	PERL_UNUSED_VAR (element);
	for (i = 1; i < items; i++)
		gst_bin_add (bin, SvGstElement (ST (i)));

# void gst_bin_remove (GstBin *bin, GstElement *element);
# void gst_bin_remove_many (GstBin *bin, GstElement *element_1, ...);
void
gst_bin_remove (bin, element, ...)
	GstBin *bin
	GstElement *element
    ALIAS:
	GStreamer::Bin::remove_many = 1
    PREINIT:
	int i;
    CODE:
	PERL_UNUSED_VAR (element);
	PERL_UNUSED_VAR (ix);
	for (i = 1; i < items; i++)
		gst_bin_remove (bin, SvGstElement (ST (i)));

GstElement* gst_bin_get_by_name (GstBin *bin, const gchar *name);

GstElement* gst_bin_get_by_name_recurse_up (GstBin *bin, const gchar *name);

# G_CONST_RETURN GList* gst_bin_get_list (GstBin *bin);
void
gst_bin_get_list (bin)
	GstBin *bin
    PREINIT:
	GList *list, *i;
    PPCODE:
	list = (GList *) gst_bin_get_list (bin);
	for (i = list; i != NULL; i = i->next)
		XPUSHs (sv_2mortal (newSVGstElement (i->data)));

# FIXME?
# GstElement* gst_bin_get_by_interface (GstBin *bin, GType interface);
# GList * gst_bin_get_all_by_interface (GstBin *bin, GType interface);

gboolean gst_bin_iterate (GstBin *bin);

void gst_bin_use_clock (GstBin *bin, GstClock *clock);

GstClock* gst_bin_get_clock (GstBin *bin);

void gst_bin_auto_clock (GstBin *bin);

GstElementStateReturn gst_bin_sync_children_state (GstBin *bin);

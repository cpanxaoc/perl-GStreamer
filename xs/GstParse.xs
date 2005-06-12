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

MODULE = GStreamer::Parse	PACKAGE = GStreamer::Parse	PREFIX = gst_parse_

=for apidoc __function__
=cut
# GstElement* gst_parse_launch (const gchar *pipeline_description, GError **error);
GstElement_noinc *
gst_parse_launch (pipeline_description)
	const gchar *pipeline_description
    PREINIT:
	GError *error = NULL;
    CODE:
	RETVAL = gst_parse_launch (pipeline_description, &error);
	if (!RETVAL)
		gperl_croak_gerror (NULL, error);
    OUTPUT:
	RETVAL

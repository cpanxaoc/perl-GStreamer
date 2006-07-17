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

MODULE = GStreamer::Buffer	PACKAGE = GStreamer::Buffer	PREFIX = gst_buffer_

# DESTROY inherited from GStreamer::MiniObject.

GstBufferFlag
flags (buffer)
	GstBuffer *buffer
    CODE:
	RETVAL = GST_BUFFER_FLAGS (buffer);
    OUTPUT:
	RETVAL

SV *
data (buffer)
	GstBuffer *buffer
    CODE:
	RETVAL = newSVpv ((gchar *) GST_BUFFER_DATA (buffer), GST_BUFFER_SIZE (buffer));
    OUTPUT:
	RETVAL

guint
size (buffer)
	GstBuffer *buffer
    CODE:
	RETVAL = GST_BUFFER_SIZE (buffer);
    OUTPUT:
	RETVAL

GstClockTime
timestamp (buffer)
	GstBuffer *buffer
    CODE:
	RETVAL = GST_BUFFER_TIMESTAMP (buffer);
    OUTPUT:
	RETVAL

GstClockTime
duration (buffer)
	GstBuffer *buffer
    CODE:
	RETVAL = GST_BUFFER_DURATION (buffer);
    OUTPUT:
	RETVAL

guint64
offset (buffer)
	GstBuffer *buffer
    CODE:
	RETVAL = GST_BUFFER_OFFSET (buffer);
    OUTPUT:
	RETVAL

guint64
offset_end (buffer)
	GstBuffer *buffer
    CODE:
	RETVAL = GST_BUFFER_OFFSET_END (buffer);
    OUTPUT:
	RETVAL

# --------------------------------------------------------------------------- #

# GstBuffer* gst_buffer_new (void);
# GstBuffer* gst_buffer_new_and_alloc (guint size);
GstBuffer_noinc *
gst_buffer_new (class)
    C_ARGS:
	/* void */

# #define gst_buffer_set_data(buf, data, size)
void
gst_buffer_set_data (buf, data)
	GstBuffer *buf
	SV *data
    PREINIT:
	int length = sv_len (data);
    CODE:
	/* FIXME: Hot to get rid of the leak? */
	gst_buffer_set_data (buf,
	                     (guchar *) g_strndup (SvPV_nolen (data), length),
	                     length);

GstCaps_own_ornull * gst_buffer_get_caps (GstBuffer *buffer);

void gst_buffer_set_caps (GstBuffer *buffer, GstCaps *caps);

GstBuffer_noinc * gst_buffer_create_sub (GstBuffer *parent, guint offset, guint size);

gboolean gst_buffer_is_span_fast (GstBuffer *buf1, GstBuffer *buf2);

GstBuffer_noinc * gst_buffer_span (GstBuffer *buf1, guint32 offset, GstBuffer *buf2, guint32 len);

void gst_buffer_stamp (GstBuffer *dest, const GstBuffer *src);

# GstBuffer* gst_buffer_join (GstBuffer *buf1, GstBuffer *buf2);
GstBuffer_noinc *
gst_buffer_join (buf1, buf2)
	GstBuffer *buf1
	GstBuffer *buf2
    C_ARGS:
	/* gst_buffer_join unrefs the old buffers, but our SVs still point to
	   them, so we need to keep them alive. */
	gst_buffer_ref (buf1), gst_buffer_ref (buf2)

GstBuffer_noinc * gst_buffer_merge (GstBuffer *buf1, GstBuffer *buf2);

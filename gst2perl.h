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

#ifndef _GST2PERL_H_
#define _GST2PERL_H_

#include <gperl.h>

#include <gst/gst.h>

#include "gst2perl-version.h"
#include "gst2perl-autogen.h"

/* Custom enum handling. */
#undef newSVGstFormat
#undef SvGstFormat
SV * newSVGstFormat (GstFormat format);
GstFormat SvGstFormat (SV *sv);

#undef newSVGstQueryType
#undef SvGstQueryType
SV * newSVGstQueryType (GstQueryType type);
GstQueryType SvGstQueryType (SV *sv);

/* Custom type conversion. */
SV * newSVGstEventMask (GstEventMask *mask);

SV * newSVGstStructure (GstStructure *structure);
GstStructure * SvGstStructure (SV *sv);

SV * newSVGstClockTime (GstClockTime time);
GstClockTime SvGstClockTime (SV *time);

SV * newSVGstClockTimeDiff (GstClockTimeDiff diff);
GstClockTimeDiff SvGstClockTimeDiff (SV *diff);

SV * newSVGstClockID (GstClockID id);
GstClockID SvGstClockID (SV *sv);

/* Stupid hacks. */
void gst2perl_event_initialize (void);
void gst2perl_value_initialize (void);

#endif /* _GST2PERL_H_ */

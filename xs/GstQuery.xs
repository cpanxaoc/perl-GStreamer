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

SV *
newSVGstQueryType (GstQueryType type)
{
	SV *sv = gperl_convert_back_enum_pass_unknown (GST_TYPE_QUERY_TYPE, type);

	if (looks_like_number (sv)) {
		const GstQueryTypeDefinition *details;
		details = gst_query_type_get_details (type);
		if (details)
			sv_setpv (sv, details->nick);
	}
	return sv;
}

GstQueryType
SvGstQueryType (SV *sv)
{
	GstQueryType format;

	if (gperl_try_convert_enum (GST_TYPE_QUERY_TYPE, sv, (gint *) &format))
		return format;

	return gst_query_type_get_by_nick (SvPV_nolen (sv));
}

/* ------------------------------------------------------------------------- */

MODULE = GStreamer::QueryType		PACKAGE = GStreamer::QueryType	PREFIX = gst_query_type_

=for apidoc __function__
=cut
# GstQueryType gst_query_type_register (const gchar *nick, const gchar *description);
GstQueryType
gst_query_type_register (nick, description)
	const gchar *nick
	const gchar *description

=for apidoc __function__
=cut
# GstQueryType gst_query_type_get_by_nick (const gchar *nick);
GstQueryType
gst_query_type_get_by_nick (nick)
	const gchar *nick

# FIXME?
# gboolean gst_query_types_contains (const GstQueryType *types, GstQueryType type);

=for apidoc __function__
=cut
# G_CONST_RETURN GstQueryTypeDefinition* gst_query_type_get_details (GstQueryType type);
void
gst_query_type_get_details (type)
	GstQueryType type
    PREINIT:
	const GstQueryTypeDefinition *details;
    PPCODE:
	details = gst_query_type_get_details (type);
	if (details) {
		EXTEND (sp, 3);
		PUSHs (sv_2mortal (newSVGstQueryType (details->value)));
		PUSHs (sv_2mortal (newSVGChar (details->nick)));
		PUSHs (sv_2mortal (newSVGChar (details->description)));
	}

=for apidoc __function__
=cut
# G_CONST_RETURN GList* gst_query_type_get_definitions (void);
void
gst_query_type_get_definitions ()
    PREINIT:
	GList *definitions, *i;
    PPCODE:
	definitions = (GList *) gst_query_type_get_definitions ();
	for (i = definitions; i != NULL; i = i->next) {
		GstQueryTypeDefinition *details = i->data;
		AV *av = newAV ();

		av_push (av, newSVGstQueryType (details->value));
		av_push (av, newSVGChar (details->nick));
		av_push (av, newSVGChar (details->description));

		XPUSHs (sv_2mortal (newRV_noinc ((SV *) av)));
	}

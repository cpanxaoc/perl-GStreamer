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
newSVGstIterator (const GstIterator *iter)
{
	AV *av, *dummy;
	SV *tie, *ref;
	HV *stash;

	av = newAV ();
	dummy = newAV ();

	ref = newRV_noinc ((SV *) av);
	stash = gv_stashpv ("GStreamer::Iterator", TRUE);
	sv_bless (ref, stash);

	tie = newRV_noinc ((SV *) dummy);
	stash = gv_stashpv ("GStreamer::Iterator::Tie", TRUE);
	sv_bless (tie, stash);

	/* Both the dummy and the real array need to have the path stored in
	 * the ext slot.  SvGstIterator looks for it in the real array.
	 * FETCHSIZE and FETCH look for it in the dummy. */
	sv_magic ((SV *) dummy, 0, PERL_MAGIC_ext, (const char *) iter, 0);
	sv_magic ((SV *) av, 0, PERL_MAGIC_ext, (const char *) iter, 0);
	sv_magic ((SV *) av, tie, PERL_MAGIC_tied, "", 0);

	return ref;
}

GstIterator *
SvGstIterator (SV *sv)
{
	MAGIC *mg;
	if (!sv || !SvROK (sv) || !(mg = mg_find (SvRV (sv), PERL_MAGIC_ext)))
		return NULL;
	return (GstIterator *) mg->mg_ptr;
}

/* ------------------------------------------------------------------------- */

SV * sv_from_pointer (gpointer pointer, GType gtype, gboolean own)
{
	GType fundamental = G_TYPE_FUNDAMENTAL (gtype);
	switch (fundamental) {
    		case G_TYPE_INTERFACE:
		case G_TYPE_OBJECT:
			return gperl_new_object (G_OBJECT (pointer), own);

		case G_TYPE_BOXED:
			/* special case for SVs, which are stored directly
			 * rather than inside blessed wrappers. */
			if (gtype == GPERL_TYPE_SV) {
				SV * sv = pointer;
				return sv ? g_boxed_copy (GPERL_TYPE_SV, pointer)
				          : &PL_sv_undef;
			}

			return gperl_new_boxed (pointer, gtype,	own);

		case G_TYPE_PARAM:
			return newSVGParamSpec (pointer);

		case G_TYPE_POINTER:
			return newSViv (PTR2IV (pointer));

		default:
			croak ("FIXME: unhandled type - %d (%s fundamental for %s)\n",
			       fundamental, g_type_name (fundamental), g_type_name (gtype));
	}
}

/* ------------------------------------------------------------------------- */

MODULE = GStreamer::Iterator	PACKAGE = GStreamer::Iterator	PREFIX = gst_iterator_

void
DESTROY (GstIterator *iter)
    CODE:
	gst_iterator_free (iter);

# GstIteratorResult gst_iterator_next (GstIterator *it, gpointer *elem);
SV *
gst_iterator_next (iter)
	GstIterator *iter
    PREINIT:
	gboolean done = FALSE;
	gpointer item;
    CODE:
	while (!done) {
		switch (gst_iterator_next (iter, &item)) {
		case GST_ITERATOR_OK:
			RETVAL = sv_from_pointer (item, iter->type, TRUE);
			done = TRUE;
			break;

		case GST_ITERATOR_RESYNC:
			gst_iterator_resync (iter);
			break;

		case GST_ITERATOR_DONE:
			RETVAL = &PL_sv_undef;
			done = TRUE;
			break;

		case GST_ITERATOR_ERROR:
			croak ("An error occured while iterating");
		}
	}
    OUTPUT:
	RETVAL

# FIXME: Needed?
# void gst_iterator_push (GstIterator *it, GstIterator *other);

# FIXME?
# GstIterator * gst_iterator_filter (GstIterator *it, GCompareFunc func, gpointer user_data);
# GstIteratorResult gst_iterator_fold (GstIterator *iter, GstIteratorFoldFunction func, GValue *ret, gpointer user_data);
# GstIteratorResult gst_iterator_foreach (GstIterator *iter, GFunc func, gpointer user_data);
# gpointer gst_iterator_find_custom (GstIterator *it, GCompareFunc func, gpointer user_data);

MODULE = GStreamer::Iterator	PACKAGE = GStreamer::Iterator::Tie

IV
FETCHSIZE (GstIterator *iter, i_do_not_care_what_this_undocumented_second_argument_is)
    PREINIT:
	gboolean done = FALSE;
	gpointer item;
    CODE:
	RETVAL = 0;
	gst_iterator_resync (iter);

	while (!done) {
		switch (gst_iterator_next (iter, &item)) {
		case GST_ITERATOR_OK:
			RETVAL++;
			break;

		case GST_ITERATOR_RESYNC:
			RETVAL = 0;
			gst_iterator_resync (iter);
			break;

		 /* FIXME: Is it ok to handle ERROR like this? */
		case GST_ITERATOR_ERROR:
		case GST_ITERATOR_DONE:
			done = TRUE;
			break;
		}
	}
    OUTPUT:
	RETVAL

SV *
FETCH (GstIterator *iter, IV index)
    PREINIT:
	gboolean done = FALSE;
	gpointer item;
	IV counter = -1;
    CODE:
	RETVAL = &PL_sv_undef;
	gst_iterator_resync (iter);

	while (!done) {
		switch (gst_iterator_next (iter, &item)) {
		case GST_ITERATOR_OK:
			counter++;
			break;

		case GST_ITERATOR_RESYNC:
			counter = -1;
			gst_iterator_resync (iter);
			break;

		 /* FIXME: Is it ok to handle ERROR like this? */
		case GST_ITERATOR_ERROR:
		case GST_ITERATOR_DONE:
			done = TRUE;
			break;
		}

		if (counter == index) {
			RETVAL = sv_from_pointer (item, iter->type, TRUE);
			done = TRUE;
		}
	}
    OUTPUT:
	RETVAL

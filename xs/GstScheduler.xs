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

MODULE = GStreamer::Scheduler		PACKAGE = GStreamer::Scheduler	PREFIX = gst_scheduler_

void gst_scheduler_setup (GstScheduler *sched);

void gst_scheduler_reset (GstScheduler *sched);

void gst_scheduler_add_element (GstScheduler *sched, GstElement *element);

void gst_scheduler_remove_element (GstScheduler *sched, GstElement *element);

void gst_scheduler_add_scheduler (GstScheduler *sched, GstScheduler *sched2);

void gst_scheduler_remove_scheduler (GstScheduler *sched, GstScheduler *sched2);

GstElementStateReturn gst_scheduler_state_transition (GstScheduler *sched, GstElement *element, GstElementState transition);

void gst_scheduler_scheduling_change (GstScheduler *sched, GstElement *element);

gboolean gst_scheduler_yield (GstScheduler *sched, GstElement *element);

gboolean gst_scheduler_interrupt (GstScheduler *sched, GstElement *element);

void gst_scheduler_error (GstScheduler *sched, GstElement *element);

void gst_scheduler_pad_link (GstScheduler *sched, GstPad *srcpad, GstPad *sinkpad);

void gst_scheduler_pad_unlink (GstScheduler *sched, GstPad *srcpad, GstPad *sinkpad);

# GstClockReturn gst_scheduler_clock_wait (GstScheduler *sched, GstElement *element, GstClockID id, GstClockTimeDiff *jitter);
void
gst_scheduler_clock_wait (sched, element, id)
	GstScheduler *sched
	GstElement *element
	GstClockID id
    PREINIT:
	GstClockReturn retval = 0;
	GstClockTimeDiff jitter = 0;
    PPCODE:
	retval = gst_scheduler_clock_wait (sched, element, id, &jitter);
	EXTEND (sp, 2);
	PUSHs (sv_2mortal (newSVGstClockReturn (retval)));
	PUSHs (sv_2mortal (newSVGstClockTimeDiff (jitter)));

gboolean gst_scheduler_iterate (GstScheduler *sched);

void gst_scheduler_use_clock (GstScheduler *sched, GstClock *clock);

void gst_scheduler_set_clock (GstScheduler *sched, GstClock *clock);

GstClock* gst_scheduler_get_clock (GstScheduler *sched);

void gst_scheduler_auto_clock (GstScheduler *sched);

void gst_scheduler_show (GstScheduler *sched);

# --------------------------------------------------------------------------- #

MODULE = GStreamer::Scheduler		PACKAGE = GStreamer::SchedulerFactory		PREFIX = gst_scheduler_factory_

# FIXME
# gboolean gst_scheduler_register (GstPlugin *plugin, const gchar *name, const gchar *longdesc, GType type);

# GstSchedulerFactory* gst_scheduler_factory_new (const gchar *name, const gchar *longdesc, GType type);
GstSchedulerFactory_noinc *
gst_scheduler_factory_new (class, name, longdesc, type)
	const gchar *name
	const gchar *longdesc
	const char *type
    PREINIT:
	GType real_type;
    CODE:
	real_type = gperl_type_from_package (type);
	RETVAL = gst_scheduler_factory_new (name, longdesc, real_type);
    OUTPUT:
	RETVAL

# FIXME?
# void gst_scheduler_factory_destroy (GstSchedulerFactory *factory);

# GstSchedulerFactory* gst_scheduler_factory_find (const gchar *name);
GstSchedulerFactory *
gst_scheduler_factory_find (class, name)
	const gchar *name
    C_ARGS:
	name

GstScheduler * gst_scheduler_factory_create (GstSchedulerFactory *factory, GstElement *parent);

# GstScheduler* gst_scheduler_factory_make (const gchar *name, GstElement *parent);
GstScheduler *
gst_scheduler_factory_make (class, name, parent)
	const gchar *name
	GstElement *parent
    C_ARGS:
	name, parent

# void gst_scheduler_factory_set_default_name (const gchar* name);
void
gst_scheduler_factory_set_default_name (class, name)
	const gchar *name
    C_ARGS:
	name

# G_CONST_RETURN gchar* gst_scheduler_factory_get_default_name (void);
const gchar *
gst_scheduler_factory_get_default_name (class)
    C_ARGS:
	/* void */

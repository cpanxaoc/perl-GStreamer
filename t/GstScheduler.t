#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 11;

# $Id$

use GStreamer -init;

###############################################################################

package MyScheduler;

use Glib::Object::Subclass
  "GStreamer::Scheduler";

###############################################################################

package main;

my $factory = GStreamer::SchedulerFactory -> new("urgs", "Urgs!", "MyScheduler");
isa_ok($factory, "GStreamer::SchedulerFactory");

is(GStreamer::SchedulerFactory -> find("urgs"), undef);

my $parent = GStreamer::ElementFactory -> make("fakesrc", "source");

my $scheduler = $factory -> create($parent);
isa_ok($scheduler, "MyScheduler");
isa_ok($scheduler, "GStreamer::Scheduler");

is(GStreamer::SchedulerFactory -> make("urgs", $parent), undef);

GStreamer::SchedulerFactory -> set_default_name("urgs");
is(GStreamer::SchedulerFactory -> get_default_name(), "urgs");

###############################################################################

$scheduler -> setup();
$scheduler -> reset();

my $element = GStreamer::ElementFactory -> make("fakesrc", "sink");

$scheduler -> add_element($element);

my $scheduler_two = $factory -> create($parent);

$scheduler -> add_scheduler($scheduler_two);
$scheduler -> remove_scheduler($scheduler_two);

is($scheduler -> state_transition($element, "ready"), "success");
$scheduler -> scheduling_change($element);

ok(!$scheduler -> interrupt($element));
ok($scheduler -> yield($element));

$scheduler -> error($element);

$scheduler -> remove_element($element);

my $source = GStreamer::ElementFactory -> make("fakesrc", "source");
my $sink = GStreamer::ElementFactory -> make("osssink", "sink");

my $source_pad = $source -> get_pad("src");
my $sink_pad = $sink -> get_pad("sink");

$scheduler -> pad_link($source_pad, $sink_pad);
$scheduler -> pad_unlink($source_pad, $sink_pad);

ok(!$scheduler -> iterate());

my $clock = $sink -> get_clock();

$scheduler -> use_clock($clock);
$scheduler -> set_clock($clock);
is($scheduler -> get_clock(), $clock);

$scheduler -> auto_clock();
$scheduler -> show();

#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 58;

# $Id$

use Glib qw(TRUE FALSE);
use GStreamer -init;

###############################################################################

package MyScheduler;

use Glib::Object::Subclass
  "GStreamer::Scheduler";

###############################################################################

package main;

my $factory = GStreamer::ElementFactory -> find("__nada__");
is($factory, undef);

$factory = GStreamer::ElementFactory -> find("queue");
isa_ok($factory, "GStreamer::ElementFactory");

ok(defined($factory -> get_longname()));
ok(defined($factory -> get_klass()));
ok(defined($factory -> get_description()));
ok(defined($factory -> get_author()));

like($factory -> get_num_pad_templates(), qr/^\d+$/);

my @templates = $factory -> get_pad_templates();
isa_ok($templates[0], "GStreamer::PadTemplate");

is($factory -> get_uri_type(), "unknown");
is($factory -> get_uri_protocols(), ());

my $caps = GStreamer::Caps -> new_any();
ok($factory -> can_src_caps($caps));
ok($factory -> can_sink_caps($caps));

###############################################################################

my $element = $factory -> create(undef);
isa_ok($element, "GStreamer::Element");

$element = $factory -> create("source");
isa_ok($element, "GStreamer::Element");

$element -> set_loop_function(sub { warn @_; }, "bla");

$element -> set(block_timeout => 23);
is($element -> get("block-timeout"), 23);

$element -> set_property(block_timeout => 23);
is($element -> get_property("block-timeout"), 23);

$element -> enable_threadsafe_properties();
$element -> disable_threadsafe_properties();
$element -> set_pending_properties();

my ($tmp_one, $tmp_two) = GStreamer::ElementFactory -> make("osssink", "tmp one",
                                                            "osssink", "tmp two");
isa_ok($tmp_one, "GStreamer::Element");
isa_ok($tmp_two, "GStreamer::Element");

$element = GStreamer::ElementFactory -> make("osssink", "sink");
isa_ok($element, "GStreamer::Element");

ok($element -> requires_clock());
ok($element -> provides_clock());

my $clock = $element -> get_clock();
isa_ok($clock, "GStreamer::Clock");

$element -> set_clock($clock);

my ($return, $jitter) = $element -> clock_wait($clock -> new_single_shot_id($clock -> get_time() + 100));
is($return, "timeout");
is($jitter, 0);

ok($element -> get_time() > 0);

$element -> set_state("playing");
ok(!$element -> wait(23));

$element -> set_time(23);
$element -> adjust_time(23);

SKIP: {
  skip "new stuff", 0
    unless GStreamer -> CHECK_VERSION(0, 8, 1);

  $element -> set_time_delay(42, 23);
}

SKIP: {
  skip "new stuff", 0
    unless GStreamer -> CHECK_VERSION(0, 8, 2);

  $element -> no_more_pads();
}

ok(!$element -> is_indexable());
$element -> set_index(GStreamer::Index -> new());
is($element -> get_index(), undef);

ok($element -> release_locks());

$element -> yield();
ok($element -> interrupt());

my $scheduler_factory = GStreamer::SchedulerFactory -> new("urgs", "Urgs!", "MyScheduler");
my $scheduler = $scheduler_factory -> create($element);

$element -> set_scheduler($scheduler);
is($element -> get_scheduler(), $scheduler);

my $pad = GStreamer::Pad -> new("urgs", "src");

$element -> add_pad($pad);
$element -> remove_pad($pad);

my $ghost = $element -> add_ghost_pad($pad, "urgs");
isa_ok($ghost, "GStreamer::GhostPad");

is($element -> get_pad("urgs"), $ghost);
is($element -> get_static_pad("urgs"), $ghost);
is($element -> get_request_pad("urgs"), undef);

isa_ok(($element -> get_pad_list())[0], "GStreamer::Pad");
isa_ok($element -> get_compatible_pad($ghost), "GStreamer::Pad");
isa_ok($element -> get_compatible_pad_filtered($ghost, $caps), "GStreamer::Pad");

is($element -> get_pad_template("urgs"), undef);

my $template = ($element -> get_pad_template_list())[0];
isa_ok($template, "GStreamer::PadTemplate");
is($element -> get_compatible_pad_template($template), undef);

my $element_one = $factory -> create("source");
my $element_two = $factory -> create("source");
my $element_three = $factory -> create("source");
my $element_four = $factory -> create("source");
my $element_five = $factory -> create("source");

is($element_one -> link($element_two), TRUE);
is($element_two -> link_many($element_three, $element_four), TRUE);
is($element_four -> link_filtered($element_five, $caps), TRUE);

$element_one -> unlink($element_two);
$element_two -> unlink_many($element_three, $element_four, $element_five);

my $pad_one = GStreamer::Pad -> new("urgs", "src");
my $pad_two = GStreamer::Pad -> new("urgs", "sink");
my $pad_three = GStreamer::Pad -> new("urgs", "src");
my $pad_four = GStreamer::Pad -> new("urgs", "sink");

$element_one -> add_pad($pad_one);
$element_two -> add_pad($pad_two);
$element_three -> add_pad($pad_three);
$element_four -> add_pad($pad_four);

is($element_one -> link_pads("urgs", $element_two, "urgs"), TRUE);
is($element_three -> link_pads_filtered("urgs", $element_four, "urgs", $caps), TRUE);
$element_three -> unlink_pads("urgs", $element_four, "urgs");

is($element -> get_event_masks(), undef);

ok(!$element -> send_event(GStreamer::Event -> new("interrupt")));
ok(!$element -> seek(qw(method-end), 0));

is($element -> get_query_types(), undef);
is($element -> query("position", "default"), undef);
is($element -> get_formats(), undef);
is_deeply([$element -> convert("time", 23, "time")], ["time", 23]);

$element -> set_eos();

$element -> set_locked_state(TRUE);
ok($element -> is_locked_state());
# FIXME: ok($element -> sync_state_with_parent());
isa_ok($element -> get_state(), "GStreamer::ElementState");
is($element -> set_state([qw/null/]), "success");

# $element -> wait_state_change();

isa_ok($element -> get_factory(), "GStreamer::ElementFactory");
is($element -> get_managing_bin(), undef);

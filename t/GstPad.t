#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 52;

# $Id$

use Glib qw(TRUE FALSE);
use GStreamer -init;

###############################################################################

package MyScheduler;

use Glib::Object::Subclass
  "GStreamer::Scheduler";

###############################################################################

package main;

my $caps = GStreamer::Caps -> new_empty();

my $template = GStreamer::PadTemplate -> new("urgs", "src", "always", $caps);
isa_ok($template, "GStreamer::PadTemplate");
is($template -> get_name_template(), "urgs");
is($template -> get_direction(), "src");
is($template -> get_presence(), "always");
isa_ok($template -> get_caps(), "GStreamer::Caps");

my $pad = GStreamer::Pad -> new("urgs", "src");
isa_ok($pad, "GStreamer::Pad");

$pad = GStreamer::Pad -> new_from_template($template, "urgs");
isa_ok($pad, "GStreamer::Pad");

$pad -> set_name("sgru");
is($pad -> get_name(), "sgru");

is($pad -> get_direction(), "src");

$pad -> set_active(TRUE);
ok($pad -> is_active());

SKIP: {
  skip "new stuff", 0
    unless GStreamer -> CHECK_VERSION(0, 8, 9);

  $pad -> set_active_recursive(TRUE);
}

my $element = GStreamer::ElementFactory -> make("fakesink", "sink");

$pad -> set_parent($element);
is($pad -> get_parent(), $element);
is($pad -> get_real_parent(), $element);

is($pad -> get_scheduler(), undef);
is($pad -> get_ghost_pad_list(), undef);
is($pad -> get_pad_template(), $template);

is($pad -> get_event_masks(), undef);
is($pad -> get_event_masks_default(), undef);

my $source = GStreamer::ElementFactory -> make("fakesrc", "source");
my $sink = GStreamer::ElementFactory -> make("fakesink", "sink");

my $source_pad = $source -> get_pad("src");
my $sink_pad = $sink -> get_pad("sink");

my $any = GStreamer::Caps -> new_any();

ok($source_pad -> can_link($sink_pad));
ok($source_pad -> can_link_filtered($sink_pad, $any));

ok($source_pad -> link($sink_pad));
ok($source_pad -> is_linked());
ok($sink_pad -> is_linked());
$source_pad -> unlink($sink_pad);

ok($source_pad -> link_filtered($sink_pad, $any));
ok($source_pad -> is_linked());
ok($sink_pad -> is_linked());

is($source_pad -> get_peer(), $sink_pad);
is($sink_pad -> get_peer(), $source_pad);

ok(!$sink_pad -> is_negotiated());
is($sink_pad -> get_negotiated_caps(), undef);

isa_ok($pad -> get_caps(), "GStreamer::Caps");
isa_ok($pad -> get_pad_template_caps(), "GStreamer::Caps");

my $structure = {
  name => "urgs",
  fields => [
    [field_one => "Glib::String" => "urgs"],
    [field_two => "Glib::Int" => 23]
  ]
};

my $fixed_caps = GStreamer::Caps -> new_full($structure);

is($source_pad -> try_set_caps($fixed_caps), "delayed");
is($source_pad -> try_set_caps_nonfixed($caps), "delayed");

ok($source_pad -> check_compatibility($sink_pad));

$source_pad -> use_explicit_caps();
ok($source_pad -> set_explicit_caps($fixed_caps));

SKIP: {
  skip "broken stuff in 0.8.6/0.8.7", 1
    if eq_array([GStreamer -> GET_VERSION_INFO()], [0, 8, 6]) ||
       eq_array([GStreamer -> GET_VERSION_INFO()], [0, 8, 7]);

  ok($source_pad -> set_explicit_caps(undef));
}

# FIXME: ok($source_pad -> relink_filtered($sink_pad, $any));
# FIXME: ok($source_pad -> try_relink_filtered($sink_pad, $any));

isa_ok($source_pad -> get_allowed_caps(), "GStreamer::Caps");
$source_pad -> caps_change_notify();

ok(!$source_pad -> recover_caps_error($any));

=FIXME

Glib::Idle -> add(sub {
  my $buffer = GStreamer::Buffer -> new();

  $source_pad -> push($buffer);
  isa_ok(my $event = $sink_pad -> pull(), "GStreamer::Data");

  GStreamer -> main_quit();

  0;
});

GStreamer -> main();

=cut

is($source_pad -> renegotiate(), "delayed");
$source_pad -> unnegotiate();

# FIXME
# my $event = GStreamer::Event -> new("interrupt");
# ok($source_pad -> send_event($event));
# ok($source_pad -> event_default($event));

my $scheduler_factory = GStreamer::SchedulerFactory -> new("urgs", "Urgs!", "MyScheduler");
my $scheduler = $scheduler_factory -> create($element);

my ($sink_one, $sink_two) = (GStreamer::Pad -> new("urgs", "sink"),
                             GStreamer::Pad -> new("urgs", "sink"));

$sink_one -> set_parent($element);
$sink_two -> set_parent($element);

$source_pad -> unlink($sink_pad);
ok($source_pad -> link($sink_one));

SKIP: {
  skip "new stuff", 2
    unless GStreamer -> CHECK_VERSION(0, 8, 1);

  my ($data, $result_pad) = GStreamer::Pad -> collect($sink_one, $sink_two);
  isa_ok($data, "GStreamer::Data");
  isa_ok($result_pad, "GStreamer::Pad");
}

is($pad -> get_formats(), undef);
is($pad -> get_formats_default(), undef);

is_deeply([$pad -> convert("time", 23, "time")], ["time", 23]);
is($pad -> convert_default("time", 23, "time"), undef);

is($pad -> get_query_types(), undef);
is($pad -> get_query_types_default(), undef);

is($pad -> query("position", "time"), undef);
is($pad -> query_default("position", "time"), undef);

isa_ok(($pad -> get_internal_links())[0], "GStreamer::Pad");
isa_ok(($pad -> get_internal_links_default())[0], "GStreamer::Pad");

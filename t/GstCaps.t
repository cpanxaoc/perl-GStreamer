#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 21;

# $Id$

use GStreamer -init;

my $caps = GStreamer::Caps -> new_empty();
isa_ok($caps, "GStreamer::Caps");
ok($caps -> is_empty());

$caps = GStreamer::Caps -> new_any();
isa_ok($caps, "GStreamer::Caps");
ok($caps -> is_any());

my $structure = {
  name => "urgs",
  fields => [
    [field_one => "Glib::String" => "urgs"],
    [field_two => "Glib::Int" => 23]
  ]
};

$caps = GStreamer::Caps -> new_full($structure);
isa_ok($caps, "GStreamer::Caps");
ok($caps -> is_fixed());

$caps -> append($caps);
$caps -> append_structure($structure);

is($caps -> get_size(), 3);
is_deeply($caps -> get_structure(0), $structure);
is_deeply($caps -> get_structure(1), $structure);
is_deeply($caps -> get_structure(2), $structure);

$caps = GStreamer::Caps -> new_simple("audio/mpeg",
                                      field_one => "Glib::String" => "urgs",
                                      field_two => "Glib::Int" => 23);
isa_ok($caps, "GStreamer::Caps");

$caps -> set_simple(field_one => "Glib::String" => "urgs",
                    field_two => "Glib::Int" => 23);

ok($caps -> is_always_compatible($caps));

isa_ok($caps -> intersect($caps), "GStreamer::Caps");
isa_ok($caps -> union($caps), "GStreamer::Caps");
isa_ok($caps -> normalize(), "GStreamer::Caps");

SKIP: {
  skip "new stuff", 4
    unless GStreamer -> CHECK_VERSION(0, 8, 2);

  ok($caps -> is_subset($caps));
  ok($caps -> is_equal($caps));
  isa_ok($caps -> subtract($caps), "GStreamer::Caps");
  ok(!$caps -> do_simplify());
}

my $string = $caps -> to_string();
ok(defined($string));
isa_ok(GStreamer::Caps -> from_string($string), "GStreamer::Caps");

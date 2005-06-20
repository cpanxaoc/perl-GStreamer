#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 38;

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

###############################################################################

my $structure_one = {
  name => "urgs",
  fields => [
    [field_one => "Glib::String" => "urgs"],
    [field_two => "Glib::Int" => 23]
  ]
};

my $structure_two = {
  name => "sgru",
  fields => [
    [field_one => "Glib::String" => "sgru"],
    [field_two => "Glib::Int" => 32],
    [field_three => "Glib::Int" => 24]
  ]
};

my $caps_one = GStreamer::Caps -> new_full($structure_one);
my $caps_two = GStreamer::Caps -> new_full($structure_two);

$caps = $caps_one + $caps_two;
is_deeply($caps -> get_structure(0), $structure_one);
is_deeply($caps -> get_structure(1), $structure_two);

$caps += $caps;
is_deeply($caps -> get_structure(0), $structure_one);
is_deeply($caps -> get_structure(1), $structure_two);
is_deeply($caps -> get_structure(2), $structure_one);
is_deeply($caps -> get_structure(3), $structure_two);

$caps = $caps_two;
$caps += $caps_one;
is_deeply($caps -> get_structure(0), $structure_two);
is_deeply($caps -> get_structure(1), $structure_one);

SKIP: {
  skip "new stuff", 6
    unless GStreamer -> CHECK_VERSION(0, 8, 2);

  ok($caps >= $caps_one);
  ok($caps >= $caps_two);
  ok($caps_one <= $caps);
  ok($caps_two <= $caps);
  ok($caps == $caps);

  $caps -= $caps_one;
  is_deeply($caps -> get_structure(0), $structure_two);
}

$caps = $caps_one & $caps_one;
is_deeply($caps -> get_structure(0), $structure_one);

# FIXME: Why are those reversed?
$caps = $caps_one | $caps_two;
is_deeply($caps -> get_structure(0), $structure_two);
is_deeply($caps -> get_structure(1), $structure_one);

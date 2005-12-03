#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 13;

# $Id$

use Glib qw(TRUE FALSE);
use GStreamer -init;

my $plugin = GStreamer::Plugin::load_by_name("alsa");
isa_ok($plugin, "GStreamer::Plugin");

is($plugin -> get_name(), "alsa");
ok(defined $plugin -> get_description());
ok(defined $plugin -> get_filename());
ok(defined $plugin -> get_version());
ok(defined $plugin -> get_license());
ok(defined $plugin -> get_source());
ok(defined $plugin -> get_package());
ok(defined $plugin -> get_origin());

ok($plugin -> is_loaded());

ok($plugin -> name_filter("alsa"));


SKIP: {
  my $so = "/usr/lib/gstreamer-0.10/libgstalsa.so";

  skip "alsa plugin tests", 1
    unless -r $so;

  $plugin = GStreamer::Plugin::load_file($so);
  isa_ok($plugin, "GStreamer::Plugin");
}

$plugin = GStreamer::Plugin::load_by_name("alsa");
isa_ok($plugin, "GStreamer::Plugin");

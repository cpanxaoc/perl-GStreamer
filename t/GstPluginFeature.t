#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 4;

# $Id$

use GStreamer -init;

my $feature = GStreamer::ElementFactory -> find("osssink");
isa_ok($feature, "GStreamer::PluginFeature");

ok($feature -> ensure_loaded());

$feature -> set_rank(23);
is($feature -> get_rank(), 23);

$feature -> set_name("osssink");
is($feature -> get_name(), "osssink");

$feature -> unload_thyself();

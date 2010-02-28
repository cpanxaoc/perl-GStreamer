#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 2;

# $Id$

use GStreamer -init;

my $factory = (GStreamer::TypeFindFactory -> get_list())[0];
isa_ok($factory, "GStreamer::TypeFindFactory");

# Can't rely on this returning something != NULL
my @extensions = $factory -> get_extensions();

# This might be undef, too
my $caps = $factory -> get_caps();
SKIP: {
  skip 'get_caps() returned undef', 1
    unless defined $caps;
  isa_ok($caps, "GStreamer::Caps");
}

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

isa_ok($factory -> get_caps(), "GStreamer::Caps");

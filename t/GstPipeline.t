#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 1;

# $Id$

use GStreamer -init;

my $pipeline = GStreamer::Pipeline -> new("urgs");
isa_ok($pipeline, "GStreamer::Pipeline");

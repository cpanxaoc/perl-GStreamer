#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 2;

# $Id$

use GStreamer -init;

my $event = GStreamer::Event -> new("interrupt");
isa_ok($event, "GStreamer::Event");
is($event -> type(), "interrupt");

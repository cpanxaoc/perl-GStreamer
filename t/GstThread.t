#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 2;

# $Id$

use GStreamer -init;

my $thread = GStreamer::Thread -> new("urgs");
isa_ok($thread, "GStreamer::Thread");
is(GStreamer::Thread -> get_current(), undef);

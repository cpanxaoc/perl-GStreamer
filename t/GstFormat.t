#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 4;

# $Id$

use GStreamer -init;

is(GStreamer::Format::register("urgs", "Urgs!"), "urgs");
is(GStreamer::Format::get_by_nick("bytes"), "bytes");
is_deeply([GStreamer::Format::get_details("urgs")], ["urgs", "urgs", "Urgs!"]);
is_deeply((GStreamer::Format::get_definitions())[-1], ["urgs", "urgs", "Urgs!"]);

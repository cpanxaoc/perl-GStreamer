#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 4;

# $Id$

use GStreamer -init;

is(GStreamer::QueryType::register("urgs", "Urgs!"), "urgs");
is(GStreamer::QueryType::get_by_nick("total"), "total");
is_deeply([GStreamer::QueryType::get_details("urgs")], ["urgs", "urgs", "Urgs!"]);
is_deeply((GStreamer::QueryType::get_definitions())[-1], ["urgs", "urgs", "Urgs!"]);

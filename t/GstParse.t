#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 1;

# $Id$

use GStreamer -init;

my $element = GStreamer::Parse::launch(qq(filesrc location="$0" ! oggdemux ! vorbisdec ! audioconvert ! audioscale ! alsasink));
isa_ok($element, "GStreamer::Element");

# eval { $element = GStreamer::Parse::launch(qq(!!)); };
# isa_ok($@, "GStreamer::ParseError");
# is($@ -> { domain }, "gst_parse_error");
# is($@ -> { value }, "syntax");

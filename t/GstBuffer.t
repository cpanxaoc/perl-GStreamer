#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 14;

# $Id$

use GStreamer -init;

my $buffer = GStreamer::Buffer -> new();
isa_ok($buffer, "GStreamer::Buffer");
isa_ok($buffer, "GStreamer::Data");

$buffer -> set_data("urgs");
$buffer -> stamp(GStreamer::Buffer -> new());

isa_ok($buffer -> create_sub(0, 4), "GStreamer::Buffer");
isa_ok($buffer -> merge(GStreamer::Buffer -> new()), "GStreamer::Buffer");
isa_ok($buffer -> span(0, GStreamer::Buffer -> new(), 4), "GStreamer::Buffer");

SKIP: {
  skip "new stuff", 1
    unless GStreamer -> CHECK_VERSION(0, 8, 1);

  isa_ok($buffer -> join(GStreamer::Buffer -> new()), "GStreamer::Buffer");
}

like($buffer -> is_span_fast(GStreamer::Buffer -> new()), qr/^(?:1|)$/);

is($buffer -> data(), "urgs");
is($buffer -> size(), 4);
is($buffer -> maxsize(), 0);
ok($buffer -> timestamp() > 0);
ok($buffer -> duration() > 0);
ok($buffer -> offset() > 0);
ok($buffer -> offset_end() > 0);

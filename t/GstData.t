#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 2;

# $Id$

use GStreamer -init;

my $data = GStreamer::Buffer -> new();
isa_ok($data, "GStreamer::Data");
ok($data -> is_writable());

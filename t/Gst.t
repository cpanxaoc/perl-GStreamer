#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 10;

# $Id$

use_ok("GStreamer");

my $number = qr/^\d+$/;

my ($x, $y, $z) = GStreamer -> GET_VERSION_INFO();
like($x, $number);
like($y, $number);
like($z, $number);

($x, $y, $z) = GStreamer -> version();
like($x, $number);
like($y, $number);
like($z, $number);

ok(GStreamer -> CHECK_VERSION(0, 0, 0));
ok(!GStreamer -> CHECK_VERSION(100, 100, 100));

ok(GStreamer -> init_check());
GStreamer -> init();

Glib::Idle -> add(sub { GStreamer -> main_quit(); 0; });
GStreamer -> main();

#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 10;

# $Id$

use_ok("GStreamer", qw(
  GST_SECOND
  GST_MSECOND
  GST_USECOND
  GST_NSECOND
  GST_TIME_FORMAT
  GST_TIME_ARGS
  GST_RANK_NONE
  GST_RANK_MARGINAL
  GST_RANK_SECONDARY
  GST_RANK_PRIMARY
));

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

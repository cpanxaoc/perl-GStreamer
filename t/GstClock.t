#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 16;

# $Id$

use Glib qw(TRUE FALSE);
use GStreamer -init;

my $element = GStreamer::ElementFactory -> make("alsasink", "sink");
my $clock = $element -> provide_clock();

my $master_element = GStreamer::ElementFactory -> make("alsasink", "sink");
my $master = $element -> provide_clock();

is($clock -> set_resolution(1000), 0);
is($clock -> get_resolution(), 1000);

ok($clock -> get_time() >= 0);

$clock -> set_calibration(0, 2, 3, 4);
is_deeply([$clock -> get_calibration()], [0, 2, 3, 4]);

ok($clock -> set_master($master));
is($clock -> get_master(), $master);

my ($result, $r) = $clock -> add_observation(23, 42);
ok(!$result);
ok($r >= 0);

ok($clock -> get_internal_time() >= 0);
ok($clock -> adjust_unlocked(23) >= 0);

my $id = $clock -> new_single_shot_id($clock -> get_time() + 100);
isa_ok($id, "GStreamer::ClockID");

$id = $clock -> new_periodic_id($clock -> get_time(), 100);
isa_ok($id, "GStreamer::ClockID");

ok($id -> get_time() > 0);

my ($return, $jitter) = $id -> wait();
is($return, "early");
ok($jitter >= 0);

is($id -> wait_async(sub { warn @_; return TRUE; }, "bla"), "ok");

$id -> unschedule();

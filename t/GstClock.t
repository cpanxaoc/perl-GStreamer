#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 20;

# $Id$

use Glib qw(TRUE FALSE);
use GStreamer qw(-init GST_SECOND);

my $element = GStreamer::ElementFactory -> make("alsasrc", "src");
my $clock = $element -> provide_clock();

SKIP: {
  skip "clock tests", 20
    unless defined $clock;

  is($clock -> set_resolution(1000), 0);
  is($clock -> get_resolution(), 1000);

  ok($clock -> get_time() >= 0);

  $clock -> set_calibration(0, 2, 3, 4);
  is_deeply([$clock -> get_calibration()], [0, 2, 3, 4]);

 SKIP: {
    skip "master clock tests", 2
      unless undef; # FIXME

    my $master_element = GStreamer::ElementFactory -> make("alsamixer", "sink");
    my $master = $element -> provide_clock();

    ok($clock -> set_master($master));
    is($clock -> get_master(), $master);
  }

  my ($result, $r) = $clock -> add_observation(23, 42);
  ok(defined $result);
  ok(defined $r);

  ok($clock -> get_internal_time() >= 0);
  ok($clock -> adjust_unlocked(23) >= 0);

  my $id = $clock -> new_single_shot_id($clock -> get_time() + 100);
  isa_ok($id, "GStreamer::ClockID");

  $id = $clock -> new_periodic_id($clock -> get_time(), 100);
  isa_ok($id, "GStreamer::ClockID");

  ok($id -> get_time() > 0);

  my ($return, $jitter) = $id -> wait();
  is($return, "ok");
  ok($jitter >= 0);

  my $loop = Glib::MainLoop -> new();

  # FIXME: I don't like this race condition.
  $id = $clock -> new_single_shot_id($clock -> get_time() + GST_SECOND / 10);

  is($id -> wait_async(sub {
    my ($clock, $time, $id, $data) = @_;

    my $been_here = 0 if 0;
    return TRUE if $been_here++;

    isa_ok($clock, "GStreamer::Clock");
    ok($time > 0);
    isa_ok($id, "GStreamer::ClockID");
    is($data, "bla");

    $loop -> quit();

    return TRUE;
  }, "bla"), "ok");

  $loop -> run();

  $id -> unschedule();
}

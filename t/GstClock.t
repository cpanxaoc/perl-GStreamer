#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 14;

# $Id$

use Glib qw(TRUE FALSE);
use GStreamer -init;

my $element = GStreamer::ElementFactory -> make("osssink", "sink");
my $clock = $element -> get_clock();

is($clock -> set_speed(1), 1);
is($clock -> get_speed(), 1);

is($clock -> set_resolution(1000), 0);
is($clock -> get_resolution(), 1000);

# FIXME: Deprecated.  Not bind them?
# $clock -> set_active(TRUE);
# ok($clock -> is_active());
# $clock -> reset();
# $clock -> handle_discont(23);

ok($clock -> get_time() > 0);
ok($clock -> get_event_time() > 0);

SKIP: {
  skip "new stuff", 1
    unless GStreamer -> CHECK_VERSION(0, 8, 1);

  ok($clock -> get_event_time_delay(23) > 0);
}

is($clock -> get_next_id(), undef);

my $id = $clock -> new_single_shot_id($clock -> get_time() + 100);
isa_ok($id, "GStreamer::ClockID");

$id = $clock -> new_periodic_id($clock -> get_time(), 100);
isa_ok($id, "GStreamer::ClockID");

ok($id -> get_time() > 0);

my ($return, $jitter) = $id -> wait();
is($return, "stopped");
ok($jitter > 0);

is($id -> wait_async(sub { warn @_; return TRUE; }, "bla"), "early");

$id -> unlock();
$id -> unschedule();

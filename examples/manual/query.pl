#!/usr/bin/perl
use strict;
use warnings;
use GStreamer qw(-init GST_SECOND GST_TIME_FORMAT GST_TIME_ARGS);

# $Id$

# args
if ($#ARGV != 0) {
  print "Usage: $0 <filename>\n";
  exit -1;
}

# build pipeline, the easy way
my $pipeline = GStreamer::Parse::launch(
                 "filesrc location=\"$ARGV[0]\" ! " .
                 "oggdemux ! " .
                 "vorbisdec ! " .
                 "audioconvert ! " .
                 "audioscale ! " .
                 "alsasink name=sink");

my $sink = $pipeline -> get_by_name("sink");

# play
$pipeline -> set_state("playing");

# make STDOUT unbuffered
$|++;

# run pipeline
do {
  my $pos = $sink -> query("position", "time");
  my $len = $sink -> query("total", "time");

  if (defined $pos && defined $len) {
    printf "Time: %" . GST_TIME_FORMAT . " / %" . GST_TIME_FORMAT . "\r",
           GST_TIME_ARGS($pos), GST_TIME_ARGS($len);
  }
} while ($pipeline -> iterate());

# clean up
$pipeline -> set_state("null");

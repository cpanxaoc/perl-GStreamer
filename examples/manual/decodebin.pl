#!/usr/bin/perl
use strict;
use warnings;
use Glib qw(TRUE FALSE);
use GStreamer -init;

# $Id$

my ($pipeline, $audio, $audiopad);

sub cb_newpad {
  my ($decodebin, $pad, $last, $data) = @_;

  # only link audio; only link once
  return if ($audiopad -> is_linked());

  my $caps = $pad -> get_caps();
  my $str = $caps -> get_structure(0);

  return if (index($str -> { name }, "audio") == -1);

  # link'n'play
  $pad -> link($audiopad);
  $pipeline -> add($audio);
  $pipeline -> sync_children_state();
}

# make sure we have input
unless ($#ARGV == 0) {
  print "Usage: $0 <filename>\n";
  exit -1;
}

# setup
$pipeline = GStreamer::Pipeline -> new("pipeline");
$audio = GStreamer::Bin -> new("audiobin");

my ($src, $dec, $conv, $scale, $sink) =
  GStreamer::ElementFactory -> make(filesrc => "source",
                                    decodebin => "decoder",
                                    audioconvert => "aconv",
                                    audioscale => "scale",
                                    alsasink => "sink");

$audiopad = $conv -> get_pad("sink");

$src -> set(location => $ARGV[0]);
$dec -> signal_connect(new_decoded_pad => \&cb_newpad);

$audio -> add($conv, $scale, $sink);
$conv -> link($scale, $sink);
$pipeline -> add($src, $dec);
$src -> link($dec);

# run
$audio -> set_state("paused");
$pipeline -> set_state("playing");
while ($pipeline -> iterate()) { }

# cleanup
$pipeline -> set_state("null");

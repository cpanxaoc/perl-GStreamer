#!/usr/bin/perl
use strict;
use warnings;
use Glib qw(TRUE FALSE);
use GStreamer -init;

# $Id$

my ($thread, $source, $decodebin, $converter, $scale, $audiosink);

sub idle_eos {
  my ($data) = @_;

  printf "Have idle-func in thread %s\n",
         (GStreamer::Thread -> get_current() or "[none]");

  GStreamer -> main_quit();

  # do this function only once
  return FALSE;
}

# EOS will be called when the src element has an end of stream.
# Note that this function will be called in the thread context.
# We will place an idle handler to the function that really
# quits the application.
sub cb_eos {
  my ($thread, $data) = @_;

  printf "Have eos in thread %s\n", GStreamer::Thread -> get_current();

  Glib::Idle -> add(\&idle_eos);
}

# On error, too, you'll want to forward signals to the main
# thread, especially when using GUI applications.
sub cb_error {
  my ($thread, $source, $error, $debug, $data) = @_;

  printf "Error in thread %s: %s\n",
         GStreamer::Thread -> get_current(),
         $error -> message();

  Glib::Idle -> add(\&idle_eos);
}

# Link new pad from decodebin to audiosink.
# Contains no further error checking.
sub cb_newpad {
  my ($decodebin, $pad, $last, $data) = @_;

  $pad -> link($converter -> get_pad("sink"));
  $thread -> add($converter, $scale, $audiosink);
  $thread -> sync_children_state();
}


# make sure we have a filename argument
if ($#ARGV != 0) {
  print "usage: $0 <Ogg/Vorbis filename>\n";
  exit -1;
}

# create a new thread to hold the elements
$thread = GStreamer::Thread -> new("thread");
$thread -> signal_connect(eos => \&cb_eos);
$thread -> signal_connect(error => \&cb_error);

# create elements
($source, $decodebin, $converter, $scale, $audiosink) =
  GStreamer::ElementFactory -> make(filesrc => "source",
                                    decodebin => "decoder",
                                    audioconvert => "converter",
                                    audioscale => "scale",
                                    alsasink => "audiosink");

$source -> set(location => $ARGV[0]);
$decodebin -> signal_connect(new_decoded_pad => \&cb_newpad);

# setup
$thread -> add($source, $decodebin);
$source -> link($decodebin);
$converter -> link($scale, $audiosink);
$audiosink -> set_state("paused");
$thread -> set_state("playing");

# no need to iterate. We can now use a mainloop
GStreamer -> main();

# unset
$thread -> set_state("null");

#!/usr/bin/perl
use strict;
use warnings;
use Glib qw(TRUE FALSE);
use GStreamer -init;

# $Id$

sub cb_eos {
  my ($play, $data) = @_;
  GStreamer -> main_quit();
}

sub cb_error {
  my ($play, $src, $err, $debug, $data) = @_;

  printf "Error: %s\n", $err -> message();
}

# make sure we have a URI
unless ($#ARGV == 0) {
  print "Usage: $0 <URI>\n";
  exit -1;
}

# set up
my $play = GStreamer::ElementFactory -> make("playbin", "play");
$play -> set(uri => $ARGV[0]);
$play -> signal_connect(eos => \&cb_eos);
$play -> signal_connect(error => \&cb_error);

unless ($play -> set_state("playing") eq "success") {
  print "Failed to play\n";
  exit -1;
}

# now run
GStreamer -> main();

# also clean up
$play -> set_state("null");

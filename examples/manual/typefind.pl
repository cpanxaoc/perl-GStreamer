#!/usr/bin/perl
use strict;
use warnings;
use Glib qw(TRUE FALSE);
use GStreamer -init;

# $Id$

sub cb_typefound {
  my ($typefind, $probability, $caps, $data) = @_;
  my $type = $caps -> to_string();

  print "Media type $type found, probability $probability%\n";

  # done
  $$data = TRUE;
}

sub cb_error {
  my ($pipeline, $source, $error, $debug, $data) = @_;

  printf "Error: %s\n", $error -> message();

  # done
  $$data = TRUE;
}

my $done = FALSE;

# check args
unless ($#ARGV == 0) {
  print "Usage: $0 <filename>\n";
  exit -1;
}

# create a new pipeline to hold the elements
my $pipeline = GStreamer::Pipeline -> new("pipe");
$pipeline -> signal_connect(error => \&cb_error, \$done);

# create file source and typefind element
my ($filesrc, $typefind) =
  GStreamer::ElementFactory -> make(filesrc => "source",
                                    typefind => "typefinder");

$filesrc -> set(location => $ARGV[0]);
$typefind -> signal_connect(have_type => \&cb_typefound, \$done);

# setup
$pipeline -> add($filesrc, $typefind);
$filesrc -> link($typefind);
$pipeline -> set_state("playing");

# now iterate until the type is found
while (!$done) {
   last if (!$pipeline -> iterate());
}

# unset
$pipeline -> set_state("null");

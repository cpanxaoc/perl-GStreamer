#!/usr/bin/perl
use strict;
use warnings;
use GStreamer -init;

# $Id$

# Global objects are usually a bad thing. For the purpose of this
# example, we will use them, however.

my ($pipeline, $source, $parser, $decoder, $converter, $scale, $sink);

sub new_pad {
  my ($element, $pad, $data) = @_;

  # We can now link this pad with the audio decoder and
  # add both decoder and audio output to the pipeline.
  $pad -> link($decoder -> get_pad("sink"));
  $pipeline -> add($decoder, $converter, $scale, $sink);

  # This function synchronizes a bins state on all of its
  # contained children.
  $pipeline -> sync_children_state();
}

# check input arguments
if ($#ARGV != 0) {
  print "Usage: $0 <Ogg/Vorbis filename>\n";
  exit -1;
}

# create elements
$pipeline = GStreamer::Pipeline -> new("audio-player");
($source, $parser, $decoder, $converter, $scale, $sink) =
  GStreamer::ElementFactory -> make(filesrc => "file-source",
                                    oggdemux => "ogg-parser",
                                    vorbisdec => "vorbis-decoder",
                                    audioconvert => "audio-converter",
                                    audioscale => "audio-scale",
                                    alsasink => "alsa-output");

# set filename property on the file source
$source -> set(location => $ARGV[0]);

# link together - note that we cannot link the parser and
# decoder yet, becuse the parser uses dynamic pads. For that,
# we set a new-pad signal handler.
$source -> link($parser);
$decoder -> link($converter, $scale, $sink);
$parser -> signal_connect(new_pad => \&new_pad);

# put all elements in a bin - or at least the ones we will use
# instantly.
$pipeline -> add($source, $parser);

# Now set to playing and iterate. We will set the decoder and
# audio output to ready so they initialize their memory already.
# This will decrease the amount of time spent on linking these
# elements when the Ogg parser emits the new-pad signal.
$decoder -> set_state("ready");
$sink -> set_state("ready");
$pipeline -> set_state("playing");

# and now iterate - the rest will be automatic from here on.
# When the file is finished, gst_bin_iterate () will return
# FALSE, thereby terminating this loop.
while ($pipeline -> iterate()) {}

# clean up nicely
$pipeline -> set_state("null");

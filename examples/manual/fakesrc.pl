#!/usr/bin/perl
use strict;
use warnings;
use Glib qw(TRUE FALSE);
use GStreamer -init;

# $Id$

sub cb_handoff {
  my ($fakesrc, $buffer, $pad, $user_data) = @_;
  my $white = FALSE if (0);

  # this makes the image black/white
  $buffer -> set_data($white ?
                        0xff x $buffer -> size() :
                        0x0 x $buffer -> size());
  $white = !$white;
}

# setup pipeline
my $pipeline = GStreamer::Pipeline -> new("pipeline");
my ($fakesrc, $conv, $videosink) =
  GStreamer::ElementFactory -> make(fakesrc => "source",
                                    ffmpegcolorspace => "conv",
                                    ximagesink => "videosink");

# setup
my $filter = GStreamer::Caps -> new_simple("video/x-raw-rgb",
                                           width => "Glib::Int" => 384,
                                           height => "Glib::Int" => 288,
                                           framerate => "Glib::Double" => 1.0,
                                           bpp => "Glib::Int" => 16,
                                           depth => "Glib::Int" => 16,
                                           endianness => "Glib::Int" => 1234); # FIXME
$fakesrc -> link_filtered($conv, $filter);
$conv -> link($videosink);
$pipeline -> add($fakesrc, $conv, $videosink);

# setup fake source
$fakesrc -> set(signal_handoffs => TRUE,
                sizemax => 384 * 288 * 2,
                sizetype => 2);
$fakesrc -> signal_connect(handoff => \&cb_handoff);

# play
$pipeline -> set_state("playing");
while ($pipeline -> iterate()) { }

# clean up
$pipeline -> set_state("null");

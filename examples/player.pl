#!/usr/bin/perl
use strict;
use warnings;
use GStreamer -init;

# This is based on the gst123 example from gst-python.

foreach my $file (@ARGV) {
  my $thread = GStreamer::Thread -> new("player");

  $thread -> signal_connect(eos => sub { GStreamer -> main_quit(); });
  $thread -> signal_connect(error => sub {
    my ($thread, $element, $error) = @_;
    printf "An error occured: %s\n", $error -> message();
    exit(1);
  });

  my ($source, $spider, $sink) =
    GStreamer::ElementFactory -> make(filesrc => "src",
                                      spider => "spider",
                                      osssink => "sink");

  $source -> set(location => $file);
  $spider -> signal_connect(found_tag => sub {
    my ($spider, $source, $tags) = @_;

    foreach (qw(artist title album track-number)) {
      if (exists $tags -> { $_ }) {
        printf "  %12s: %s\n", ucfirst GStreamer::Tag::get_nick($_),
                               $tags -> { $_ } -> [0];
      }
    }
  });

  $thread -> add($source, $spider, $sink);
  $source -> link($spider, $sink) or die "Could not link";

  print "Playing: $file\n";

  $thread -> set_state("playing") or die "Could not start playing";
  GStreamer -> main();
  $thread -> set_state("null");
}

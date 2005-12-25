#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 2;

# $Id$

use Glib qw(TRUE FALSE);
use GStreamer -init;

my $time = 999986400; # 2001-09-09, 00:00

my $structure = {
  name => "urgs",
  fields => [
    [field_one => "GStreamer::IntRange" => [23, 42]],
    [field_two => "GStreamer::ValueList" => [[23, "Glib::Int"], [42, "Glib::Int"]]],
    [field_three => "GStreamer::ValueList" => [[[23, 42], "GStreamer::IntRange"]]],
    [field_four => "GStreamer::Date" => $time]
  ]
};

my $string = GStreamer::Structure::to_string($structure);

is($string, "urgs, field_one=(int)[ 23, 42 ], field_two=(int){ 23, 42 }, field_three=(int){ [ 23, 42 ] }, field_four=(GstDate)2001-09-09");
is_deeply((GStreamer::Structure::from_string($string))[0], $structure);

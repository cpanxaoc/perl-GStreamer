#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 6;

# $Id$

use GStreamer -init;

my $bin = GStreamer::Bin -> new("urgs");
isa_ok($bin, "GStreamer::Bin");

my $factory = GStreamer::ElementFactory -> find("osssink");
my $element_one = $factory -> create("source one");
my $element_two = $factory -> create("source two");
my $element_three = $factory -> create("source three");
my $element_four = $factory -> create("source four");

$bin -> add($element_one);
$bin -> add_many($element_two, $element_three, $element_four);
$bin -> remove($element_four);
$bin -> remove($element_three, $element_two);

is($bin -> get_by_name("source one"), $element_one);
is($bin -> get_by_name_recurse_up("source one"), $element_one);
is_deeply([$bin -> get_list()], [$element_one]);

# ok(!$bin -> iterate());

my $clock = $element_one -> get_clock();

$bin -> use_clock($clock);
is($bin -> get_clock(), undef);
$bin -> auto_clock();

is($bin -> sync_children_state(), "success");

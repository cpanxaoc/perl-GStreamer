#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 13;

# $Id$

use Glib qw(TRUE FALSE);
use GStreamer -init;

my $registry = (GStreamer::RegistryPool -> list())[0];
isa_ok($registry, "GStreamer::Registry");

GStreamer::RegistryPool -> add($registry, 23);
GStreamer::RegistryPool -> remove($registry);

isa_ok(GStreamer::RegistryPool -> get_prefered([qw/readable/]), "GStreamer::Registry");

my $plugin = GStreamer::RegistryPool -> find_plugin("volume");
isa_ok($plugin, "GStreamer::Plugin");

GStreamer::RegistryPool -> add_plugin($plugin);
GStreamer::RegistryPool -> load_all();

sub plugin_filter {
  my ($plugin, $data) = @_;

  isa_ok($plugin, "GStreamer::Plugin");
  is($data, "bla");

  return TRUE;
}

my @plugins = GStreamer::RegistryPool -> plugin_filter(\&plugin_filter, TRUE, "bla");
is($#plugins, 0);
isa_ok($plugins[0], "GStreamer::Plugin");

sub feature_filter {
  my ($feature, $data) = @_;

  isa_ok($feature, "GStreamer::PluginFeature");
  is($data, "bla");

  return TRUE;
}

my @features = GStreamer::RegistryPool -> feature_filter(\&feature_filter, TRUE, "bla");
is($#features, 0);
isa_ok($features[0], "GStreamer::PluginFeature");

isa_ok((GStreamer::RegistryPool -> plugin_list())[0], "GStreamer::Plugin");
isa_ok((GStreamer::RegistryPool -> feature_list("GStreamer::ElementFactory"))[0], "GStreamer::PluginFeature");

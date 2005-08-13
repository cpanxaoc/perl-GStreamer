#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 15;

# $Id$

use Glib qw(TRUE FALSE);
use GStreamer -init;

my $registry = GStreamer::RegistryPool -> get_prefered([qw/readable/]);

ok($registry -> load());
# ok($registry -> save());
ok($registry -> rebuild());

$registry -> add_path(".");
is_deeply([$registry -> get_path_list()], ["."]);
$registry -> clear_paths();

my $plugin = GStreamer::RegistryPool -> find_plugin("volume");
ok(!$registry -> add_plugin($plugin));
$registry -> remove_plugin($plugin);

sub plugin_filter {
  my ($plugin, $data) = @_;

  isa_ok($plugin, "GStreamer::Plugin");
  is($data, "bla");

  return TRUE;
}

TODO: {
  local $TODO = "Hrm";

  my @plugins = $registry -> plugin_filter(\&plugin_filter, TRUE, "bla");
  is($#plugins, 0);
  isa_ok($plugins[0], "GStreamer::Plugin");
}

sub feature_filter {
  my ($feature, $data) = @_;

  isa_ok($feature, "GStreamer::PluginFeature");
  is($data, "bla");

  return TRUE;
}

TODO: {
  local $TODO = "Hrm";

  my @features = $registry -> feature_filter(\&feature_filter, TRUE, "bla");
  is($#features, 0);
  isa_ok($features[0], "GStreamer::PluginFeature");
}

is($registry -> find_plugin("volume"), undef);
is($registry -> find_feature("volume", "GStreamer::ElementFactory"), undef);

isa_ok($registry -> load_plugin($plugin), "GStreamer::RegistryReturn");
isa_ok($registry -> update_plugin($plugin), "GStreamer::RegistryReturn");
isa_ok($registry -> unload_plugin($plugin), "GStreamer::RegistryReturn");

ok(!$registry -> is_loaded());
ok(!$registry -> unload());

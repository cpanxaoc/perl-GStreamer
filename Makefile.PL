#!/usr/bin/perl
use 5.008;
use strict;
use warnings;

use ExtUtils::MakeMaker;
use Cwd qw(cwd);

# $Id$

our %build_reqs = (
  'perl-ExtUtils-Depends'   => '0.205',
  'perl-ExtUtils-PkgConfig' => '1.07',
  'perl-Glib'               => '1.100',
  'GStreamer'               => '0.8.0',
);

our %PREREQ_PM = (
  'Glib'                => $build_reqs{'perl-Glib'},
  'ExtUtils::Depends'   => $build_reqs{'perl-ExtUtils-Depends'},
  'ExtUtils::PkgConfig' => $build_reqs{'perl-ExtUtils-PkgConfig'},
);

unless (eval "use ExtUtils::Depends '$build_reqs{'perl-ExtUtils-Depends'}';"
           . "use ExtUtils::PkgConfig '$build_reqs{'perl-ExtUtils-PkgConfig'}';"
           . "use Glib '$build_reqs{'perl-Glib'}';"
           . "use Glib::MakeHelper;"
           . "use Glib::CodeGen;"
           . "1") {
  warn "$@\n";
  WriteMakefile(
    PREREQ_FATAL => 1,
    PREREQ_PM    => \%PREREQ_PM,
  );
  exit 1; # not reached
}

my %pkgcfg = ExtUtils::PkgConfig->find("gstreamer-0.8 >= $build_reqs{'GStreamer'}");

mkdir 'build', 0777;

our @xs_files = <xs/*.xs>;
our %pod_files = (
	'GStreamer.pm' => '$(INST_MAN3DIR)/GStreamer.$(MAN3EXT)',
	Glib::MakeHelper->do_pod_files (@xs_files),
);

Glib::CodeGen->parse_maps('gst2perl');
Glib::CodeGen->write_boot(ignore => qr/^GStreamer$/);

ExtUtils::PkgConfig->write_version_macros (
  "build/gst2perl-version.h",
  "gstreamer-0.8" => "GST",
);

my $gst = ExtUtils::Depends->new('GStreamer', 'Glib');
$gst->set_inc($pkgcfg{cflags} . ' -I./build ');
$gst->set_libs($pkgcfg{libs});
$gst->add_xs(@xs_files);
$gst->add_pm('GStreamer.pm' => '$(INST_LIBDIR)/GStreamer.pm');
$gst->add_typemaps(map {File::Spec->catfile(cwd(), $_)} ('gst.typemap', 'build/gst2perl.typemap'));

$gst->install(qw(gst2perl.h
                 build/gst2perl-autogen.h
                 build/gst2perl-version.h
                 doctypes));
$gst->save_config('build/IFiles.pm');

WriteMakefile(
  NAME          => 'GStreamer',
  VERSION_FROM  => 'GStreamer.pm',
  ABSTRACT_FROM => 'GStreamer.pm',
  PREREQ_PM     => \%PREREQ_PM,
  XSPROTOARG    => '-noprototypes',
  MAN3PODS      => \%pod_files,
  $gst->get_makefile_vars,
);

sub MY::postamble {
  return Glib::MakeHelper->postamble_clean ()
       . Glib::MakeHelper->postamble_docs_full (
           DEPENDS => $gst,
           DOCTYPES => 'doctypes',
           COPYRIGHT_FROM => 'copyright.pod');
}

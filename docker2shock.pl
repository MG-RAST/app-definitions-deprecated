#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use local::lib "$FindBin::Bin/";

use Skyport;
eval "use USAGEPOD; 1"
or die "USAGEPOD is missing:\n sudo apt-get install cpanminus \n sudo cpanm git://github.com/wgerlach/USAGEPOD.git";



my $h = {};


my $help_text;
($h, $help_text) = &parse_options (
	'name' => 'docker2shock software',
	'version' => '1',
	'synopsis' => 'docker2shock.pl user/repo:tag',
	'examples' => 'ls',
	'authors' => 'Wolfgang Gerlach',
	'options' => [
	'options',
	['debug', 	'debug']
#'docker2shock',
#['docker2shock=s',		'upload image from docker to shock, this does not remove the baseimage!']
]);


if ($h->{'help'} ) { # || keys(%$h)==0
	print $help_text;
	exit(0);
}

#SHOCK_SERVER_URL=http://shock.metagenomics.anl.gov:80
$ENV{SHOCK_SERVER_URL} ='http://shock.metagenomics.anl.gov:80';

my $image_identifer = $ARGV[0];


unless (defined $image_identifer) {
	die "no image specified";
}

my $shocktoken = $ENV{KB_AUTH_TOKEN};
my $shock_server = $ENV{SHOCK_SERVER_URL};

Skyport::commandline_docker2shock($shock_server, $shocktoken, $h, $image_identifer);

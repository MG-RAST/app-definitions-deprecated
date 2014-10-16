package Skyport;

use strict;
use warnings;

use LWP::UserAgent;

1;

my $docker_socket = '/var/run/docker.sock';

my $docker_version_info = undef;

my $datadir=($ENV{'TMP'} ||'/mnt/tmp/' ); #'/mnt/tmp/';


unless (defined $datadir) {
	die;
}

if ($datadir eq "") {
	die;
}

sub commandline_docker2shock {
	my ($shocktoken, $image_identifer, $base_image_object) = @_;
	
	
	unless (defined $shocktoken) {
		die "no shocktoken";
	}
	
	#### save image
	print "### save image\n";
	
	my $image_obj = get_image_object($image_identifer);
	
	unless (defined $image_obj->{'Id'} && defined $image_obj->{'name'}) {
		die ;
	}
	my $image_id = $image_obj->{'Id'};
	
	my $print_name = $image_obj->{'name'};
	$print_name =~ s/[\:\_\/]/\_/g;
	
	
	my ($repo, $tag) = split(':', $image_obj->{'name'});
	
	unless (defined $datadir) {
		die;
	}
	if ($datadir eq '') {
		die;
	}
	
	
	my $image_tarfile = $datadir.$image_obj->{'Id'}.'_'.$print_name.'.tar';
	
	save_image_to_tar($image_obj->{'Id'}, $image_tarfile);
	
	
	#### modify image (add tags)
	#print "### modify image\n";
	#my $imagediff_tar_gz = remove_base_from_image_and_set_tag($image_tarfile, $repo, $tag, $image_id, $base_image_object);
	systemp("gzip ".$image_tarfile)==0 or die;
	
	##### upload
	print "### upload image\n";
	
	my $shock_node_id = upload_docker_image_to_shock($shocktoken, $image_tarfile.".gz", $repo, $tag, $image_id, undef, undef, get_docker_version());
	
	print "uploaded. shock node id: ".$shock_node_id."\n";
}

sub get_image_object{
	my ($something) = @_;
	
	my $result_hash = dockerSocket('GET', "/images/$something/json") || die "error: image \"$something\" not found";
	
	
	print "something: ".Dumper($result_hash);
	
	my $id =  $result_hash->{'Id'} || $result_hash->{'id'} || die "error: id not found in image object \"$something\"";
	
	my $obj = {};
	$obj->{'Id'} = $id;
	
	
	# if user used id to identify image, try to find a tag
	if (lc($something) eq lc(substr($id, 0 , length($something)))) {
		
		my $history = dockerSocket('GET', "/images/".$obj->{'Id'}."/history");
		
		print "history: ".Dumper($history);
		
		my $tags = $history->[0]->{'Tags'};
		
		if (! defined($tags) || @$tags == 0) {
			print STDERR "warning: no tag found for image in docker\n";
		}
		
		
		if (defined $tags && @$tags > 0) {
			
			if (@$tags == 1) {
				$obj->{'name'} = $tags->[0];
				
			} else {
				
				my $longest_tag = $tags->[0];
				foreach my $t (@{$tags}) {
					if (length($t) > length($longest_tag)) {
						$longest_tag = $t;
					}
				}
				$obj->{'name'} = $longest_tag;
			}
			
		}
		
	} else {
		# user specified image by its name
		
		$obj->{'name'} = $something;
	}
	
	
	return $obj;
	
}

sub get_docker_bin {
	
	my $docker_bin = '/usr/bin/docker.io'; # on ubuntu
	unless (-e $docker_bin) {
		$docker_bin = '/usr/bin/docker'; # normal docker binary
	}
	unless (-e $docker_bin) {
		die "docker binary not found ! ;-(";
	}
	
	return $docker_bin;
}

sub buildDockerImage {
	
	my ($repo, $tag, $dockerfile, $h) = @_;
	
	my $docker_build_context_dir = undef;
	
	
	my $repotag = $repo.':'.$tag;
	
	
	# check if image already exists
	
	my $result_hash = dockerSocket('GET', "/images/$repotag/json");
	
	my $image_id = undef;
	if (defined $result_hash) {
		$image_id = $result_hash->{'Id'};
		unless (defined $image_id) {
			die "hash defined, but not id!?";
		}
		
		print Dumper($result_hash);
		print "image already exists:\n";
		print "ID: ".$image_id." $repotag   (may reuse with --docker_reuse_image)\n";
		
		unless (defined $h->{'docker_reuse_image'}) {
			print "to delete it run docker rmi ".$image_id."\n";
			exit(1);
		}
		
		
	}
	
	
	
	
	
	
	#my $cwd = getcwd;
	
	
	unless (-d $datadir) {
		die "data dir not found";
	}
	
	
	
	### create docker image ###
	
	
	unless (defined($image_id) ) {
		
		
		my $docker_bin = get_docker_bin();
		
		#my $docker_build_cmd = 'docker build --tag='.$repotag.' -'; #--no-cache=true --rm
		my $docker_build_cmd;
		
		my $cache = '';
		if (defined ($h->{'no-cache'})) {
			$cache = ' --no-cache=true ';
		}
		
		if (defined $docker_build_context_dir) {
			# use context dir
			
			write_file($docker_build_context_dir.'/Dockerfile', $dockerfile);
			
			$docker_build_cmd = $docker_bin.' build '.$cache.' --tag='.$repotag.' '.$docker_build_context_dir;
			systemp($docker_build_cmd)==0 or die "docker build failed";
			
		} else {
			# no context, pipe dockerfile into docker client
			$docker_build_cmd = $docker_bin.' build '.$cache.' --tag='.$repotag.' -'; #--no-cache=true --rm
			
			print "docker_build_cmd: $docker_build_cmd\n";
			
			open(my $fh, "|-", $docker_build_cmd)
			or die "cannot run docker: $!";
			
			print $fh $dockerfile;
			close ($fh);
			
			sleep(3);
		}
		
		
		
		
		
		
		if (0) {
			my $docker_build_cmd = 'docker build --tag='.$repotag.' -'; #--no-cache=true --rm
			
			print "docker_build_cmd: $docker_build_cmd\n";
			
			open(my $fh, "|-", $docker_build_cmd)
			or die "cannot run docker: $!";
			
			print $fh $dockerfile;
			close ($fh);
			
			sleep(3);
		}
		
		$result_hash = undef;
		
		$result_hash = dockerSocket('GET', "/images/$repotag/json");
		
		
		if (defined $result_hash) {
			$image_id = $result_hash->{'Id'};
			
		} else {
			die "result_hash not defined, docker image was not created !?";
		}
		
	}
	
	unless (defined $image_id) {
		die "image ID not defined";
	}
	
	return $image_id;
}

sub createAndSaveDiffImage {
	my ($image_id, $repo, $tag, $docker_base_image) = @_;
	### save image as tar archive file
	
	my $repotag = $repo.':'.$tag;
	
	my $tag_converted = $repotag;
	$tag_converted =~ s/[\/]/\_/g;
	
	my $image_tarfile;
	if (defined $docker_base_image) {
		my $docker_base_image_converted = $docker_base_image->{'name'};
		$docker_base_image_converted =~ s/[\/]/\_/g;
		$image_tarfile = $datadir.$image_id.'_'.$docker_base_image_converted.'_'.$tag_converted.'.complete.tar';
	} else {
		$image_tarfile = $datadir.$image_id.'_'.$tag_converted.'.complete.tar';
	}
	
	
	
	
	#### SAVE IMAGE
	save_image_to_tar($image_id, $image_tarfile);
	
	unless (defined $repotag) {
		die;
	}
	
	#### open and modify tar archive
	
	my $imagediff_tarfile_gz = remove_base_from_image_and_set_tag($image_tarfile, $repo, $tag, $image_id, $docker_base_image);
	
	
	
	unless (-e $imagediff_tarfile_gz) {
		die;
	}
	
	systemp("rm -f ".$image_tarfile);
	
	return [$imagediff_tarfile_gz, $image_id];
}



sub save_image_to_tar {
	my ($image_id, $image_tarfile, $h) = @_;
	
	
	my $skip_saving = 0;
	
	
	if (defined $h->{'docker_reuse_image'}) {
		if (-e $image_tarfile) {
			$skip_saving = 1;
		}
	} else {
		if (-e $image_tarfile) {
			die "docker image file $image_tarfile already exists. Delete or use --docker_reuse_image";
		}
	}
	
	
	if ($skip_saving == 0) {
		
		my $docker_bin = get_docker_bin();
		
		my $docker_save_cmd = $docker_bin.' save '.$image_id.' > '.$image_tarfile; # TODO: use API
		systemp($docker_save_cmd) == 0 or die;
	}
	
}

sub remove_base_from_image_and_set_tag {
	
	
	my ($image_tarfile, $repo, $tag, $image_id, $docker_base_image) = @_;
	
	unless ($image_tarfile =~ /\.tar$/) {
		die "tar expected";
	}
	
	
	
	my ($output_tar) = $image_tarfile =~ /^(.*)\.tar$/;
	
	unless (defined $output_tar) {
		die;
	}
	
	$output_tar .= '.diff.tar';
	
	
	my $modify_tar = $output_tar;
	unless (defined $docker_base_image) {
		$modify_tar = $image_tarfile;
	}
	
	
	my $output_targz  = $modify_tar.'.gz';
	
	if (-e $output_targz) {
		die "error: \"".$output_targz."\" already exists";
	}
	
	if (defined $docker_base_image) {
		my $tartemp = File::Temp->newdir( TEMPLATE => 'SODOKU_tar_XXXXXXX' );
		
		#systemp("mkdir -p $tartemp ; rm -f ".$output_tar);
		
		
		systemp("cd $tartemp && tar xvf ".$image_tarfile) ==0 or die;
		
		
		
		
		
		my @diff_layers = get_diff_layers($image_id, $docker_base_image->{'Id'});
		
		if (@diff_layers == 0) {
			die ;
		}
		
		my $diff_layers_hash = {};
		
		
		foreach my $layer (@diff_layers) {
			
			my $layer_dir = $tartemp.'/'.$layer;
			
			unless (-d $layer_dir) {
				die "error: expected layer directory not found";
			}
			
			$diff_layers_hash->{$layer} = 1;
		}
		
		
		my @directories = glob ($tartemp.'/*');
		
		print "total layers: ".@directories." in $tartemp\n";
		if (@directories == 0) {
			die ;
		}
		
		my $count_keep_layers = 0;
		foreach my $layer_dir (@directories) {
			
			my $dir = basename($layer_dir);
			#my $layer_dir = $tartemp.$dir;
			
			unless (-d $layer_dir) {
				die "layer_dir $layer_dir not found !?";
			}
			
			unless (defined $diff_layers_hash->{$dir}) {
				print "delete non-diff layer directory $layer_dir\n";
				systemp("sudo rm -rf ".$layer_dir);
			} else {
				$count_keep_layers++;
			}
			
		}
		
		if ($count_keep_layers == 0) {
			die "all layers deleted...";
		}
		
		
		print "create new tar without the base layers\n";
		systemp("cd $tartemp && ls -la") == 0 or die;
		systemp("cd $tartemp && sudo tar -cf $output_tar *") == 0 or die;
		systemp("sudo chmod 666 ".$output_tar);
		
	}
	
	
	
	
	
	
	if (defined($tag) && defined($repo)) {
		
		print "insert tag information into tar\n";
		my $repositories_file_content = "{\\\"$repo\\\":{\\\"$tag\\\":\\\"$image_id\\\"}}";
		
		
		systemp("echo \"$repositories_file_content\" > repositories");
	} else {
		
		die "tag and repo need to be defined --tag=repo:tag"; # TODO can I save without adding file ?
		
	}
	
	
	
	
	
	my $py_cmd = "python -c \"import tarfile; f=tarfile.open('".$modify_tar."', 'a'); f.add('repositories'); f.close()\"";
	
	
	systemp($py_cmd) == 0 or die;
	
	
	print "gzip tar file\n";
	
	systemp("gzip ".$modify_tar)==0 or die;
	
	unless (-e $output_targz) {
		die;
	}
	
	return $output_targz;
}


sub upload_docker_image_to_shock {
	
	
	my ($shock_server, $token, $h , $image_file, $repo, $tag, $image_id, $base_image_object, $dockerfile, $image_docker_version_hash) = @_;
	### upload image to SHOCK ###
	#check token
	#check server
	
	unless (defined $token) {
		die;
	}
	
	unless (defined $tag) {
		die;
	}
	
	my $repotag = $repo.':'.$tag;
	
	
	require SHOCK::Client;
	
	
	unless (defined($token)) {
		die 'SHOCK token not found';
	}
	
	
	my $shock = new SHOCK::Client($shock_server, $token);
	
	
	
	my $dockerfile_encoded = '';
	
	if (defined $dockerfile && $dockerfile ne 'none') {
		require MIME::Base64;
		$dockerfile_encoded = MIME::Base64::encode_base64($dockerfile);
		$dockerfile_encoded =~ s/\n//g;
		print "dockerfile_encoded:\n$dockerfile_encoded\n";
	}
	
	
	
	my $node_attributes = {
		#	"temporary"				=> "1",
		"type"					=> "dockerimage",
		"name"					=> $repotag						|| die,
		"id"					=> $image_id					|| die,
		"docker_version"		=> $image_docker_version_hash	|| die,
		"base_image_tag"		=> $base_image_object->{'name'} || "",
		"base_image_id"			=> $base_image_object->{'Id'}	|| "",
		"dockerfile"			=> $dockerfile_encoded			|| ""
	};
	
	my $json = JSON->new;
	my $node_attributes_str = $json->encode( $node_attributes );
	
	
	
	#print "node_attributes_str:\n$node_attributes_str\n";
	print "node_attributes: ".Dumper($node_attributes) ;
	
	
	print "uploading file \"".$image_file."\" ...\n";
	
	if (defined $h->{'docker_noupload'}) {
		print "--docker_noupload invoked.\n";
		exit(0)
	}
	
	print "upload image to SHOCK docker repository\n";
	my $up_result = $shock->upload('file' => $image_file, 'attr' => $node_attributes_str) || die;
	#same as: my $curl_cmd = 'curl -X POST -H "Authorization: OAuth $GLOBUSONLINE"  -F "attributes=@sodoku_docker.json" -F "upload=@'.$image_tarfile.'" "'.$shock_server.'/node"';
	print Dumper($up_result);
	unless ($up_result->{'status'} == 200) {
		die;
	}
	
	my $shock_node_id = $up_result->{'data'}->{'id'} || die "SHOCK node id not found for uploaded image";
	
	unless (defined $h->{'private'}) {
		$shock->permisson_readable($shock_node_id) || die "error makeing node readable";
	}
	
	print "Docker image uploaded ($shock_node_id).\n";
	
	return $shock_node_id;
	
}


sub create_url {
	my ($endpoint, %query) = @_;
	
	my $my_url = 'http:'.$docker_socket.'/'.$endpoint;
	
	#build query string:
	my $query_string = "";
	
	foreach my $key (keys %query) {
		my $value = $query{$key};
		
		unless (defined $value) {
			if ((length($query_string) != 0)) {
				$query_string .= '&';
			}
			$query_string .= $key;
			next;
		}
		
		my @values=();
		if (ref($value) eq 'ARRAY') {
			@values=@$value;
		} else {
			@values=($value);
		}
		
		foreach my $value (@values) {
			if ((length($query_string) != 0)) {
				$query_string .= '&';
			}
			$query_string .= $key.'='.$value;
		}
	}
	
	
	if (length($query_string) != 0) {
		
		#print "url: ".$my_url.'?'.$query_string."\n";
		$my_url .= '?'.$query_string;#uri_escape()
	}
	
	
	
	
	return $my_url;
}


sub dockerSocket {
	my ($request_type, $endpoint, $query, $headers) = @_;
	
	my $url = create_url($endpoint, %$query);
	
	
	
	print "request: $request_type $url\n";
	
	my @method_args = ($url);
	if (defined $headers) {
		#if (defined $headers->{':content_cb'}){
		#	$is_download = 1;
		#}
		
		push(@method_args, %$headers);
	}
	
	
	my $agent = LWP::UserAgent->new;
	
	require LWP::Protocol::http::SocketUnixAlt;
	LWP::Protocol::implementor( http => 'LWP::Protocol::http::SocketUnixAlt' );
	
	
	my $json = JSON->new;
	my $response_content = undef;
	
	eval {
		
		my $response_object = undef;
		
		
		if ($request_type eq 'GET') {
			$response_object = $agent->get(@method_args);
		} elsif ($request_type eq 'POST') {
			$response_object = $agent->post(@method_args);
		} else {
			die;
		}
		
		print "content: ".$response_object->content."\n";
		
		my $content_type = $response_object->header('Content-Type');
		
		if (defined $content_type && $content_type eq 'application/json') {
			$response_content = $json->decode( $response_object->content );
		}
	};
	
	
	if ($@) {
		
		if (! ref($response_content) ) {
			print STDERR "[error] unable to connect to socket\n";
			return undef;
		} elsif (exists($response_content->{error}) && $response_content->{error}) {
			print STDERR "[error] unable to send $request_type request to socket: ".$response_content->{error}[0]."\n";
			return undef;
		}
		
	}
	
	print 'response_content: '.Dumper($response_content)."\n";
	
	
	LWP::Protocol::implementor( http => 'LWP::Protocol::http' );
	
	return $response_content;
	
}

# check if base image is in shock
sub findImageinShock {
	my ($shock_server, $token, $image_id) = @_;
	
	require SHOCK::Client;
	
	
	my $shock = new SHOCK::Client($shock_server, $token);
	
	
	my $node_obj = $shock->query('type' => 'dockerimage', 'id' => $image_id);
	print 'node: '.Dumper($node_obj);
	
	my @nodes = ();
	
	if (defined $node_obj->{'data'}) {
		push (@nodes, @{$node_obj->{'data'}});
	}
	
	return @nodes;
}


# get diff layers and check if base is in shock
sub get_diff_layers {
	my ($image_id, $base_id, $h) = @_;
	
	unless (defined $image_id) {
		die;
	}
	
	if (defined $base_id) {
		
		my @base_in_shock = findImageinShock($base_id);
		
		if (@base_in_shock > 1) {
			die "base image multiple times in shock !";
		}
		
		unless (defined $h->{'force_base'}) {
			if (@base_in_shock == 0 ) {
				die "base image not found in shock! upload base first or use --force_base";
			}
		}
	}
	
	my $history = dockerSocket('GET', "/images/$image_id/history");
	
	my $images = dockerSocket('GET', "/images/json");
	
	
	my $imageid_to_tags={};
	
	my $tag_to_imageid = {};
	foreach my $image_obj (@{$images}) {
		my $id = $image_obj->{'Id'} || die "Id not found";
		my $repotags =  $image_obj->{'RepoTags'} || die "RepoTags not found";
		$imageid_to_tags->{$id} = $repotags;
		
		foreach my $t (@{$repotags}) {
			$tag_to_imageid->{$t}=$id;
		}
	}
	
	
	print "history: ".Dumper($history);
	print "images: ". Dumper($images);
	print Dumper($imageid_to_tags);
	
	
	
	#exit(0);
	my @diff_layers= ();
	
	unless ($history->[0]->{'Id'} eq $image_id) {
		die "history broken for $image_id ?";
	}
	
	if (defined($base_id)) {
		print "base_id: $base_id\n";
	}
	
	# check history of image
	my $found_base = 0;
	for (my $i = 0; $i < @{$history}; ++$i) {
		
		my $layer = $history->[$i];
		my $id = $layer->{'Id'};
		unless (defined $id) {
			die;
		}
		
		
		if (defined($base_id) && ($id eq $base_id)) {
			$found_base = 1;
			print "found base id: $base_id\n";
			last;
		}
		
		if (defined $imageid_to_tags->{$id} && ($i > 0)) {
			print $id." layer has image tag: ".join(',', @{$imageid_to_tags->{$id}})."\n";
			
		} else {
			print $id." layer\n";
		}
		
		push(@diff_layers, $id);
		
		
	}
	
	if (defined($base_id) && ($found_base ==0) ) {
		die "did not find expected base image $base_id in history of $image_id";
	}
	
	
	
	print "found ".@diff_layers." diff layers (layers on top of base image) for image ".$image_id."\n";
	
	if (@diff_layers == 0 ) {
		die;
	}
	
	return @diff_layers;
}

1;


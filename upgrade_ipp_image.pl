#!/usr/bin/perl -w

# @filename           :  upgrade_ipp_image.pl
# @author             :  Copyright (C) Church.Zhong
# @date               :  Tue May 15 10:01:15 HKT 2018
# @function           :  upgrade IP phone binary image file
# @see                :  
# @require            :  

# https://en.wikipedia.org/wiki/Comma-separated_values

use strict;
use warnings;


sub ltrim { my $s = shift; $s =~ s/^\s+//;       return $s };
sub rtrim { my $s = shift; $s =~ s/\s+$//;       return $s };
sub  trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };


sub open_filehandle_for_write
{
	my $filename = $_[0];
	my $overWriteFilename = ">" . $filename;
	local *FH;

	open (FH, $overWriteFilename) || die "Could not open $filename";

	return *FH;
}

sub open_filehandle_for_read
{
	my $filename = $_[0];
	local *FH;

	open (FH, $filename) || die "Could not open $filename";

	return *FH;
}

use File::Spec;
sub get_abs_path
{
	# best code, get file true path.
	my $path_curf = File::Spec->rel2abs(__FILE__);
	#print ("file in PATH = ",$path_curf,"\n");
	my ($vol, $dirs, $file) = File::Spec->splitpath($path_curf);
	#print ("file in Dir = ", $dirs,"\n");

	return $dirs;
}


use Getopt::Long;
Getopt::Long::Configure("no_ignore_case");
my $version=0;
my $httpIp="172.17.179.200";
my $httpUser="admin";
my $httpPassword="1234";
my $inFilename="";
my $verbose=0;
my $help=0;
sub usage {
  print <<EndOfUsage;
  Usage: $0 [options] [files]
  --ip=IP              Set http ip to IP
  --user=USER          Set http user to USER
  --password=PASS      Set http password to PASS
  --fimage=filename    Given binary image file
  --help               Help information
  --version            Version information
EndOfUsage
}


my $http_host_ip = '';
my $http_host_port = '';
my $url_host_port = '';
my $http_url = '';


#------------------------------------------------------------------------
#  main
#------------------------------------------------------------------------
sub main()
{
	if (!GetOptions (
	'ip=s' => \$httpIp,
	'user=s' => \$httpUser,
	'password=s' => \$httpPassword,
	'fimage=s' => \$inFilename,
	'verbose'	=> \$verbose,
	'version'	=> \$version,
	'help|?' => \$help ))
	{
		usage();
		#die("Error in command line arguments\n");
		exit 0;
	}
	if ($help)
	{
		usage();
		exit 0;
	}
	if ($version)
	{
		print "1.0.0.0";
		exit 0;
	}

	if ('' eq $httpIp)
	{
		print "default ip address : ", $httpIp, "\n";
	}
	if ('' eq $httpUser)
	{
		print "default username : ", $httpUser, "\n";
	}
	if ('' eq $httpPassword)
	{
		print "default password : ", $httpPassword, "\n";
	}
	if ('' eq $inFilename)
	{
		usage();
		exit 0;
	}

	if (! -r $inFilename)
	{
		die("$inFilename not exist!\n");
	}

	print "$httpIp, $httpUser, $httpPassword, $inFilename \n";
	my $dir = get_abs_path();

	$http_host_ip = $httpIp;
	$http_host_port = '80';
	$url_host_port = $http_host_ip . ':' . $http_host_port;
	$http_url = 'http://' . $http_host_ip . ':' . $http_host_port;

	do_http_basic_auth();

	my $elapsed_time = time()- $^T;
	# $^T just like $start_time=time() put it very beginn of perl script.
	print "\n run time is: $elapsed_time second(s) \n";
}

################################################################################
### http
################################################################################

use LWP;
use LWP::Simple;
use LWP::UserAgent;
use HTTP::Cookies;
use HTTP::Headers;
use HTTP::Response;
use Encode;
use URI::Escape;
use URI::URL;
use HTTP::Request::Common;

my $ua = LWP::UserAgent->new;


my $CRLF = "\015\012";   # "\r\n" is not portable
sub boundary
{
    my $size = shift || return "xYzZY";
    require MIME::Base64;
    my $b = MIME::Base64::encode(join("", map chr(rand(256)), 1..$size*3), "");
    $b =~ s/[\W]/X/g;  # ensure alnum only
    $b;
}

# HTTP Basic Authentication
sub do_http_basic_auth
{
	# sanity check
	my $url = $http_url . '/mainform.cgi/Manu_Firmware_Upgrade.htm';
	my $request = GET $url;

	$request->authorization_basic($httpUser, $httpPassword);
	my $response = $ua->request($request);
	if ($response->is_success)
	{
		#print $response->content, "\r\n";
		print "HTTP Basic Authentication OK!\n";
	}
	else
	{
		die "HTTP Basic Authentication failed!\n";
	}

	$request = POST $url,
	Content_Type    => [ 'application/x-www-form-urlencoded' ],
	Content         => [ 'UPGRADESHOW' => "1" ];
	$request->authorization_basic($httpUser, $httpPassword);
	$response = $ua->request($request);
	if($response->is_success)
	{
		# check output
		#print $response->content;
		print "POST $url OK!\n";
	}
	else
	{
		die "POST $url failed!\n";
	}

	my $fh = open_filehandle_for_read($inFilename);
	binmode($fh);
	#ugly data
	my $data = '';
	while(<$fh>)
	{
		$data .= $_;
	}
	close($fh);

	my ($vol, $dirs, $file) = File::Spec->splitpath($inFilename);
	#print ("file ", $file, " in Dir ", $dirs,"\n"x2);
	my $boundary = '----WebKitFormBoundary' . boundary(4);
	print $boundary, "\n"x2;

	my $content = "--$boundary$CRLF" .
	qq(Content-Disposition: form-data; name="localupgrade"$CRLF$CRLF) . "20" .
	"$CRLF--$boundary$CRLF" .
	qq(Content-Disposition: form-data; name="upname"; filename="$file"$CRLF) .
	qq(Content-Type: application/octet-stream$CRLF$CRLF) .
	$data .
	"$CRLF--$boundary--$CRLF";

	$url = $http_url. '/upload.cgi';
	$request = POST $url,
	Content_Type    => [ 'multipart/form-data; boundary=' . $boundary ],
	Content         => $content
	;

	$request->authorization_basic($httpUser, $httpPassword);
	$request->header('Content-Type' => 'multipart/form-data; boundary=' . $boundary);
	$response = $ua->request($request);
	if($response->is_success)
	{
		# check output
		#print $response->content;

		print "upload $url OK!\n";
	}
	else
	{
		die "upload $url failed!\n";
	}

	return 0;
}

main();
exit 0;
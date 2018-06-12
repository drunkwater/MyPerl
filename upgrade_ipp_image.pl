#!/usr/bin/perl -w

# @filename           :  upgrade_ipp_image.pl
# @author             :  Copyright (C) Church.Zhong
# @date               :  Tue May 15 10:01:15 HKT 2018
# @function           :  upgrade IP phone binary image file
# @see                :  https://github.com/drunkwater/MyPerl
# @require            :  Perl 5.24.2

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

# https://stackoverflow.com/questions/2215049/how-do-i-enable-ipv6-support-in-lwp
use Net::INET6Glue::INET_is_INET6;
use Net::IP;

# ppm install dmake
# https://metacpan.org/pod/IO::Socket::INET6
# https://www.perl.org/about/whitepapers/perl-ipv6.html
# http://search.cpan.org/~jmehnle/Net-Address-IP-Local-0.1.2/lib/Net/Address/IP/Local.pm
# https://metacpan.org/pod/Error @Shlomi Fish
use Net::Address::IP::Local;



use Getopt::Long;
Getopt::Long::Configure("no_ignore_case");
my $version=0;
my $httpIp='172.17.179.200';
my $httpUser='admin';
my $httpPassword='1234';
my $inFilename='';
my $verbose=0;
my $help=0;
my $isNonLync=0;

sub usage {
  print <<EndOfUsage;
  Usage: $0 [options] [files]
  --ip=IP              Set http ip to IP
  --user=USER          Set http user to USER
  --password=PASS      Set http password to PASS
  --fimage=filename    Given binary image file
  --nonlync            nonlync or SFB branch
  --help               Help information
  --version            Version information
EndOfUsage
}


my $http_host_ip = '';
my $http_host_port = '';
my $url_host_port = '';
my $http_url = '';
my $http_url_no_port = '';


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
	'nonlync' => \$isNonLync,
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

	# http://search.cpan.org/dist/Net-IP/IP.pm
	my $ip = new Net::IP ($httpIp) or die (Net::IP::Error());
	print "ip->version=", $ip->version(), "\n";
	if (4 eq $ip->version())
	{
		$http_host_ip = $httpIp;
	}
	else
	{
		$http_host_ip = '[' . $httpIp . ']';
	}
	$http_host_port = '80';
	$url_host_port = $http_host_ip . ':' . $http_host_port;
	$http_url = 'http://' . $http_host_ip . ':' . $http_host_port;
	$http_url_no_port = 'http://' . $http_host_ip;

	# hey! it's weak HTTP Server
	if ($isNonLync)
	{
		print "upgrade nonLync image!\n";

		do_http_basic_auth();
	}
	else
	{
		print "upgrade SFB/Lync image!\n";
		do_http_cookie_pair();
	}



	my $elapsed_time = time()- $^T;
	# $^T just like $start_time=time() put it very beginn of perl script.
	print "\n run time is: $elapsed_time second(s) \n";
}

################################################################################
### http
################################################################################

use MIME::Base64;

use LWP;
use LWP::Simple;
use LWP::UserAgent;
use LWP::ConnCache;
use HTTP::Cookies;
use HTTP::Headers;
use HTTP::Response;
use Encode;
use URI::Escape;
use URI::URL;
use HTTP::Request::Common;

#my $ua = LWP::UserAgent->new(keep_alive => 1);
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

use LWP::Protocol::http qw( );

sub do_http_cookie_pair
{
	# User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.181 Safari/537.36
	# sanity check
	my ($url, $request, $response) = ();

	#my $UserAgent = 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.181 Safari/537.36';
	#$ua->agent( $UserAgent );


	$url = $http_url . '/mainform.cgi?go=mainframe.htm';
	$request = GET $url,
		Referer         => [ $http_url . '/mainform.cgi/login_redirect.htm' ],
		Accept          => [ 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' ],
		Connection      => [ 'keep-alive' ],
		Cache_Control   => [ 'max-age=0' ],
		Accept_Encoding => [ 'gzip, deflate' ],
		Accept_Language => [ 'zh-CN,zh;q=0.9' ],
		Upgrade_Insecure_Requests => [1]
	;
	$response = $ua->request($request);
	if ($response->is_success)
	{
		#print $response->content, "\r\n";
		print "GET $url OK!\n";
	}
	else
	{
		die "GET $url failed!\n";
	}



	$url = $http_url . '/mainform.cgi/login_redirect.htm';
	$request = GET $url,
		Referer         => [ $http_url . '/mainform.cgi/login_redirect.htm' ],
		Accept          => [ 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' ],
		Connection      => [ 'keep-alive' ],
		Cache_Control   => [ 'max-age=0' ],
		Accept_Encoding => [ 'gzip, deflate' ],
		Accept_Language => [ 'zh-CN,zh;q=0.9' ],
		Upgrade_Insecure_Requests => [1]
	;
	$request->header('Cookie' => 'session=');
	$response = $ua->request($request);
	if ($response->is_success)
	{
		#print $response->content, "\r\n";
		print "GET $url OK!\n";
	}
	else
	{
		die "GET $url failed!\n";
	}


	$url = $http_url . '/login.cgi';
	$request = GET $url,
		Referer         => [ $http_url . '/mainform.cgi/login_redirect.htm' ],
		Accept          => [ 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' ],
		Connection      => [ 'keep-alive' ],
		Cache_Control   => [ 'max-age=0' ],
		Accept_Encoding => [ 'gzip, deflate' ],
		Accept_Language => [ 'zh-CN,zh;q=0.9' ],
		Upgrade_Insecure_Requests => [1]
	;
	$request->header('Cookie' => 'session=');
	$response = $ua->request($request);
	if ($response->is_success)
	{
		#print $response->content, "\r\n";
		print "GET $url OK!\n";
	}
	else
	{
		die "GET $url failed!\n";
	}


	my $SetCookie = '';
	#@LWP::Protocol::http::EXTRA_SOCK_OPTS = (  SendTE => 0  );

	my $cookie_jar = HTTP::Cookies->new(
		file => "cookies.txt",
		autosave => 0,
		ignore_discard => 1,
		hide_cookie2 => 1
	);
	#it's not bug, famous common feature!
	my $b64 = encode_base64($httpPassword);
	$b64 =~ s/[\r\n]+//g;
	$url = $http_url . '/login.cgi';
	$request = POST $url,
		Connection          => [ 'keep-alive' ],
		Cache_Control       => [ 'max-age=0' ],
		Upgrade_Insecure_Requests => [1],
		Content_Type        => [ 'application/x-www-form-urlencoded' ],
		Accept              => [ 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' ],
		Referer             => [ $url ],
		Accept_Encoding     => [ 'gzip, deflate' ],
		Accept_Language     => [ 'zh-CN,zh;q=0.9' ],
		Content             => [ 'user' => $httpUser, 'psw' => $b64 ],
	;
	$ua->cookie_jar($cookie_jar);
	$response = $ua->request($request);
	if($response->is_success)
	{
		# check output
		#print $response->content;
		print "POST $url OK!\n";
		print "Set-Cookie:", $response->header('Set-Cookie'), "\n";
		$SetCookie = $response->header('Set-Cookie');
		if ('' eq $SetCookie)
		{
			die "I can't find 'Set-Cookie' in Server Header!\n";
		}
		else
		{
			$SetCookie =~ /session=(.*)\;\ path\=\//;
			$SetCookie = $1;
			print "Dump shiny Set-Cookie: $SetCookie\n";
		}
		#print $response->headers()->as_string;
	}
	else
	{
		die "POST $url failed!\n";
	}



	$url = $http_url . '/mainform.cgi/Manu_Firmware_Upgrade.htm';
	$request = GET $url;
	#$request->header('Cookie' => ('session=' . $SetCookie) );
	$response = $ua->request($request);
	if ($response->is_success)
	{
		#print $response->content, "\r\n";
		print "GET $url OK!\n";
	}
	else
	{
		die "GET $url failed!\n";
	}



	$request = POST $url,
	Content_Type    => [ 'application/x-www-form-urlencoded' ],
	Content         => [ 'UPGRADESHOW' => "1" ];
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

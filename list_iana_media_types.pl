#!/usr/bin/perl -w

# @filename           :  upgrade_ipp_image.pl
# @author             :  Copyright (C) Church.Zhong
# @date               :  Tue May 15 10:01:15 HKT 2018
# @function           :  upgrade IP phone binary image file
# @see                :  
# @require            :  

# https://stackoverflow.com/questions/1735659/list-of-all-mimetypes-on-the-planet-mapped-to-file-extensions
# http://www.iana.org/assignments/media-types/media-types.xhtml
# https://s-randomfiles.s3.amazonaws.com/mime/allMimeTypes.txt


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




#------------------------------------------------------------------------
#  main
#------------------------------------------------------------------------
sub main()
{
	my $dir = get_abs_path();

	my $outFileRef = open_filehandle_for_write("allMimeTypes.c");
	binmode $outFileRef, ":utf8";

	while (<DATA>)
	{
		print $outFileRef $_;
	}

	# /etc/mime.types
	my $inFileName = "allMimeTypes.txt";
	my $inFileRef = open_filehandle_for_read($inFileName);
	my $mime = '';
	my $list = '';
	my @extension = ();
	my $array = ();
	my $size = 0;

	my $MIME_TYPE_ARRAY_SIZE = 0;
	while(<$inFileRef>)
	{
		$_ =~ m/^(.*)\:\s*\[(.*)\]$/o;
		$mime = $1;
		$list = $2;
		#print STDOUT "$mime:[$list]\n";
		@extension = split /\s*,\s*/, $list;
		$size = @extension;
		$array = join (',', (map { '".' . $_ . '"' } @extension));
		if (!$array)
		{
			$array = '""';
		}
		print STDOUT "$mime:[$array]\n";
		print $outFileRef '{"' . $mime . '", {' . $array . '}, ' . $size . "},\n";
		$MIME_TYPE_ARRAY_SIZE++;
	}
	print $outFileRef "};\n";

	close($inFileRef);
	close($outFileRef);


	$outFileRef = open_filehandle_for_write("allMimeTypes.h");
	binmode $outFileRef, ":utf8";
	print $outFileRef "#define MIME_TYPE_ARRAY_SIZE ($MIME_TYPE_ARRAY_SIZE)";
	close($outFileRef);


	my $elapsed_time = time()- $^T;
	# $^T just like $start_time=time() put it very beginn of perl script.
	print STDOUT "\n run time is: $elapsed_time second(s) \n";
}


main();
exit 0;
#------------------------------------------------------------------------
#  EOF
#------------------------------------------------------------------------

__DATA__
#include<stdlib.h>
#include<stdio.h>
#include<string.h>


#include "allMimeTypes.h"


typedef struct{
	char extension[16];
}extension_t;

typedef struct{
	char mime[256];
	extension_t ext[16];
	int ext_size;
}MIME_TYPE_T;
const MIME_TYPE_T mimeTypeArray[MIME_TYPE_ARRAY_SIZE];


/* grep '.txt' */
int main()
{
	int i = 0, j = 0;
	int s = sizeof(mimeTypeArray)/sizeof(mimeTypeArray[0]);
	printf("\n mimeTypeArray size=%d \n", s);
	for (i=0; i < s; i++)
	{
		printf("%s:[", mimeTypeArray[i].mime);
		for (j=0; j < mimeTypeArray[i].ext_size;)
		{
			printf("%s", mimeTypeArray[i].ext[j].extension);
			j++;
			if (j < mimeTypeArray[i].ext_size)
			{
				printf(",");
			}
		}
		printf("]\n");
	}


	return 0;
}

const MIME_TYPE_T mimeTypeArray[MIME_TYPE_ARRAY_SIZE] = {
//};

use strict;
use warnings;
use LWP::UserAgent;
use Archive::Zip;
use File::Temp;
use File::Path;
use File::Copy;
use FindAddressJPUtil;


# For Debug Message
my $cpanmode = 1;

# Config
my $output_dir = '../';
my $output_file = 'KEN_ALL_UTF.csv';
my $url = 'http://www.post.japanpost.jp/zipcode/dl/kogaki/zip/ken_all.zip';


info("Downloading zip file");
my $client = LWP::UserAgent->new;
my $response = $client->get($url);


if ($response->is_success) {
    my $fh = File::Temp->new( CLEANUP => 0, DIR => '/tmp', SUFFIX => '.zip');
    my $filename = $fh->filename;
    $fh->print($response->content);
    $fh->flush;

    my $zip = Archive::Zip->new;
    $zip->read($filename);

    my $csv_name;
    for my $member ($zip->members()) {
	my $name = $member->fileName();

	if ($name =~ /\.csv$/i) {
	    info("Unzip $filename");
	    $csv_name = $name;
	    $zip->extractMemberWithoutPaths($name);
	    last;
	}
    }

    if ($csv_name) {
	info("Conversion...");
	FindAddressJPUtil::conversion($csv_name, $output_file);
	rmtree $csv_name;

	move $output_file, $output_dir;
    }
}
else {
    die $response->status_line;
}

info("Finish!");



sub info {
    my $message = shift;
    warn $message unless $cpanmode;
}

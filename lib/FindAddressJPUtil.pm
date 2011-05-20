package FindAddressJPUtil;
use strict;
use warnings;
use utf8;
use Encode;


sub conversion {
    my ($csv_file, $output_file, %opt) = @_;

    my $csv_encode = $opt{input_encode} ? $opt{input_encode} : 'sjis';
    my $output_encode = $opt{output_encode} ? $opt{output_file} : 'utf8';

    open my $fh, '<', $csv_file or die "Can't open file '$csv_file': $!";

    my @new_lines;
    while (my $line = <$fh>) {
	chomp($line);
	$line =~ s/\"//g;

	my ($nc1,$nc2,$zipcode,$nc3,$nc4,$nc5,$addr1,$addr2,$addr3,$nc99) = split(/\,/, $line, 10);
	next if $zipcode eq '';
	my $new_line = "$zipcode,$addr1$addr2$addr3\n";
	push @new_lines, encode($output_encode, decode($csv_encode, $new_line));
    }

    close $fh;

    open my $fh_output, '>', $output_file or die "Can't open file '$output_file': $!";
    print $fh_output @new_lines;
    close $fh_output;
}


sub find_address {
    my ($zip, $file, %opt) = @_;

    $zip =~ s/　｡/｡ /g;
    $zip =~ s/　/ /g;
    $zip =~ s/-//g;
    $zip =~ tr/\'\,\;\*\.\\//d;
    $zip = substr($zip,0,80);

    return if $zip eq '';

    my @find_s = split(/ /, $zip);
    my @pref_list = pref_list();
    my $grep_type = $opt{grep_type} ? $opt{grep_type} : 'grep';
    my $max_line  = $opt{max_line} ? $opt{max_line} : 200;
    my $find_loop = $opt{find_loop} ? $opt{find_loop} : 2;
    my $file_encode = $opt{file_encode} ? $opt{file_encode} : 'utf8';

    my $grep;
    my $counter = 0;
    foreach my $ft (@find_s) {
	last if ($find_loop < $counter);

	if ($ft eq '県'
	    || $ft eq '府'
	    || $ft eq '市'
	    || $ft eq '郡'
	    || $ft eq '町'
	    )
	{
	    $zip = '';
	    next;
	}

	if (length $ft < 2) {
	    $zip = '';
	    next;
	}

	unless ($ft =~ /[^0-9]/) {
	    $ft = '^'.$ft;
	}

	$ft = encode($file_encode, $ft);
	if ($counter == 0) {
	    $grep = "$grep_type '$ft' $file";
	} else {
	    $grep .= " | $grep_type '$ft'";
	}
	$counter++;
    }

    return if $grep eq '';


    my @lines = readpipe $grep;
    my $count = $#lines + 1;
    my (@zipcode1, @zipcode2, @pref, @add1, @pref_id);
    my @address;
    foreach (0..$max_line){
	my $line = decode($file_encode, $lines[$_]);
	if($line && $line =~ /^([0-9]{3})([0-9]{4}),(.+府|.+県|.+道|.+都)(.+)$/)
	{
	    $zipcode1[$_] = $1;
	    $zipcode2[$_] = $2;
	    $pref[$_] = "$3";
	    $add1[$_] = "$4";
	    $pref_id[$_] = "";

	    foreach my $id (0..$#pref_list){
		if($pref_list[$id] eq "$pref[$_]"){
		    $pref_id[$_] = $id;
		}
	    }

	    push @address, {
		zipcode1 => $zipcode1[$_],
		zipcode2 => $zipcode2[$_],
		pref     => $pref[$_],
		addr1     => $add1[$_],
	    };
	}
    }

    return \@address;
}


sub pref_list {
    return (""
	    ,"北海道"
	    ,"青森県"
	    ,"岩手県"
	    ,"宮城県"
	    ,"秋田県"
	    ,"山形県"
	    ,"福島県"
	    ,"茨城県"
	    ,"栃木県"
	    ,"群馬県"
	    ,"埼玉県"
	    ,"千葉県"
	    ,"東京都"
	    ,"神奈川県"
	    ,"新潟県"
	    ,"富山県"
	    ,"石川県"
	    ,"福井県"
	    ,"山梨県"
	    ,"長野県"
	    ,"岐阜県"
	    ,"静岡県"
	    ,"愛知県"
	    ,"三重県"
	    ,"滋賀県"
	    ,"京都府"
	    ,"大阪府"
	    ,"兵庫県"
	    ,"奈良県"
	    ,"和歌山県"
	    ,"鳥取県"
	    ,"島根県"
	    ,"岡山県"
	    ,"広島県"
	    ,"山口県"
	    ,"徳島県"
	    ,"香川県"
	    ,"愛媛県"
	    ,"高知県"
	    ,"福岡県"
	    ,"佐賀県"
	    ,"長崎県"
	    ,"熊本県"
	    ,"大分県"
	    ,"宮崎県"
	    ,"鹿児島県"
	    ,"沖縄県"
	);
}

1;

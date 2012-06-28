use strict;
use warnings;
use URI;
use Web::Scraper;
use utf8;

my $userid = shift;
my $baseurl = 'http://book.akahoshitakuya.com/u/' . $userid . '/commentlist';

# Get page number
my $pages = 1;
my $url = URI->new($baseurl);
my $getpage = scraper {
	process '.page_navi_hedge', 'pages' => 'HTML';
};
my $res =  $getpage->scrape($url);
if ($res->{pages} =~ /p=([0-9]+)/){
	$pages = $1;
};

# Get item data
my $getitem = scraper {
	process '.log_list_detail', 'item[]' => scraper {
		process '//a[2]', 'link' => '@href';
		process '//a[3]', 'title' => '@title';
		process '.date', 'date' => 'TEXT';
		process '//span[1]', 'comment' => 'TEXT';
	};
};
# @data is list for output

my @data = (); # list for output
for (my $i = 1; $i <= $pages; $i++ ){
	my $url = URI->new($baseurl . '&p=' . $i);
	my $res = $getitem->scrape($url);
	my $j = 1;

	# edit and push for output list
	foreach my $item (@{$res->{item}}){
		if ( $item->{link} =~ /b\/([0-9]{10})/ ){
			my $asin = $1;
			my $row = {
				'asin' => $asin,
				'title' => $item->{title},
				'date' => $item->{date},
				'comment' => $item->{comment},
			};
			push(@data, $row);
		}
	}
}

# print data (CSV)
foreach my $row (@data){
	print $row->{asin} . "," . Encode::encode('utf8', $row->{title}) . "," . $row->{date} . "," . Encode::encode('utf8', $row->{comment}) . "\n";
}

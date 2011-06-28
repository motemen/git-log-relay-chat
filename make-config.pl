use strict;
use warnings;

use URI;
use Web::Scraper;

my $id = shift || '1050889';
my $staff = scraper {
    process '//ul[contains(concat(" ",@class," ")," forks ")]/li/a[1]',
      'forks[]' => '@href';
};

my $res = $staff->scrape( URI->new("https://gist.github.com/$id") );
my %config = ( git_root => "gist-$id", pull_remote => [] );
for my $item ( @{ $res->{forks} } ) {
    push @{ $config{pull_remote} }, "git://gist.github.com" . $item->path;
}

use Data::Dumper;
$Data::Dumper::Terse  = 1;
$Data::Dumper::Indent = 1;
$Data::Dumper::Sortkeys = 1;
print Dumper \%config;

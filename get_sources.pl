use strict;
use warnings;
use lib 'lib';
use YAML;
use Encode;
use HTTP::Cookies;
use WWW::Mixi::Scraper;
use Getopt::Long;
use File::Path;

GetOptions(\my %options => qw( force|f ));

mkpath 't_live/cookies' unless -d 't_live/cookies';

my $conf = YAML::LoadFile('live_test.yml');
my $cookie_jar = HTTP::Cookies->new(
  file     => 't_live/cookies/mixi.dat',
  autosave => 1,
);
my $mixi = WWW::Mixi::Scraper->new(
  email      => $conf->{global}->{email},
  password   => $conf->{global}->{password},
  cookie_jar => $cookie_jar,
);

if ( $conf->{global}->{test_html_dir}
     && !-d $conf->{global}->{test_html_dir}
) {
  mkpath( $conf->{global}->{test_html_dir} );
}

foreach my $plugin ( keys %{ $conf->{tests} } ) {
  my $ct = '';
  foreach my $item ( @{ $conf->{tests}->{$plugin} || [] } ) {
    my $options = $item->{remote} || $item->{source} || next;
       $options = {} if $options eq '-';

    my $file = "t_live/html/$plugin$ct.html";
    $ct ||= 1; $ct++;
    next if -f $file and !$options{force};
    print $file,"\n";

    my $content = $mixi->$plugin->get_content(%{ $options });
    open my $fh, '>', $file;
    print $fh encode( 'euc-jp' => $content );
    close $fh;
  }
}
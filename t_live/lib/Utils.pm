package t_live::lib::Utils;

use strict;
use warnings;
use WWW::Mixi::Scraper;
use Encode;
use DateTime::Format::Strptime;
use File::Slurp qw( read_file );
use File::Spec;
use HTTP::Cookies;
use YAML;

our @EXPORT = qw( login_to date_format run_tests its_local );

my $conf = load_yaml('live_test.yml');
my $local;

sub its_local () { $local; }

sub load_yaml {
  my $file = shift;
  return -f $file ? YAML::LoadFile($file) : {};
}

sub run_tests {
  my $name = shift;

  my @tests = @{ $conf->{tests}->{$name} || [] };

  foreach my $test ( @tests ) {
    if ( $test->{local} ) {
      test_local( file => $test->{local} );
    }
    elsif ( $test->{remote} ) {
      my $options = $test->{remote} eq '-'
        ? {}
        : eval { $test->{remote} };
      die "configuration error: $@" if $@;
      test_remote( %{ $options } );
    }
    if ( $test->{skip} ) {
      last;
    }
  }
  return scalar @tests;
}

sub login_to {
  my $next_url = shift || '/home.pl';

  $next_url = "/$next_url" if substr($next_url, 0, 1) ne '/';

  my $file = $conf->{global}->{cookies} || 't_live/cookies/mixi.dat';

  my $cookie_jar = HTTP::Cookies->new(
    file     => $file,
    autosave => 1,
  );

  return WWW::Mixi::Scraper->new(
    next_url   => $next_url,
    email      => $conf->{global}->{email},
    password   => $conf->{global}->{password},
    cookie_jar => $cookie_jar,
  );
}

sub test_file {
  my $file = shift;

  my $html_dir = $conf->{global}->{test_html_dir} || 't_live/html';

  $file = File::Spec->catfile( $html_dir, $file ) unless -f $file;

  decode( 'euc-jp' => read_file( $file ) );
}

sub date_format {
  my $pattern = shift;

  DateTime::Format::Strptime->new(
    pattern => $pattern,
    time_zone => 'Asia/Tokyo',
  )
}

sub test_local {
  my %options = @_;

  my $file = delete $options{file} or return;
  $options{html} = test_file($file) or return;

  $local = 1;

  warn "local test";

  main::test(%options);
}

sub test_remote {
  return if $conf->{global}->{skip_remote};

  $local = 0;

  warn "remote test";

  main::test(@_);
}

1;

package # hide from PAUSE
  t_live::lib::Utils;

use strict;
use warnings;
use base qw/Exporter/;
use WWW::Mixi::Scraper;
use Encode;
use DateTime::Format::Strptime;
use File::Slurp qw( read_file );
use File::Spec;
use HTTP::Cookies;
use YAML;

our @EXPORT = qw( login_to date_format run_tests its_local matches );

my $conf = load_yaml('live_test.yml');
my $local;
my $date_format;

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
    mode       => $conf->{global}->{mode},
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

  $date_format = DateTime::Format::Strptime->new(
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

sub matches {
  my ($item, $rules) = @_;

  foreach my $key ( keys %{ $rules } ) {
    my $rule = $rules->{$key} || '';
       $rule =~ s/_if_remote// if !$local && !ref $rule;

    if ( $rule eq 'string' ) {
      _ok( $key, $item->{$key} );
    }
    if ( $rule eq 'integer' ) {
      _ok( $key, $item->{$key} );
    }
    if ( $rule eq 'datetime' ) {
      _ok( $key, $item->{$key} );
      my $dt = $date_format->parse_datetime( $item->{$key} );
      Test::More::ok defined $dt, 'proper datetime';
    }
    if ( $rule eq 'uri' ) {
      _ok( $key, $item->{$key} );
      Test::More::ok ref $item->{$key} && $item->{$key}->isa('URI'), 'proper uri';
    }
    if ( ref $rule eq 'HASH' ) {
      if ( ref $item->{$key} eq 'ARRAY' ) {
        foreach my $subitem ( @{ $item->{$key} } ) {
          matches( $subitem => $rule );
        }
      }
      if ( ref $item->{$key} eq 'HASH' ) {
        matches( $item->{$key} => $rule );
      }
    }
  }
}

sub _ok {
  my ($key, $value) = @_;

  if ( $ENV{TEST_VERBOSE} ) {
    Test::More::ok defined $value, _encode( "$key: $value" );
  }
  else {
    Test::More::ok defined $value;
  }
}

sub _encode {
  my $string = shift;
  my $encoding = $^O eq 'MSWin32' ? 'shiftjis' : 'euc-jp';
  Encode::encode( $encoding => $string );
}

1;

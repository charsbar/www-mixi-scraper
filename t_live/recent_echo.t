use strict;
use warnings;
use Test::More qw(no_plan);
use t_live::lib::Utils;

my $mixi = login_to('recent_echo.pl');

my $rules = {
  count       => 'integer',
  recents      => {
    link       => 'uri', 
    id         => 'integer',
    time       => 'integer',
    name       => 'string',
    comment    => 'string',
  },
};

run_tests('recent_echo') or ok 1, 'skipped: no tests';

sub test {
  my @items = $mixi->recent_echo->parse(@_);

  return ok 1, 'skipped: no recent echo' unless @items;

  foreach my $item ( @items ) {
    matches( $item => $rules );
  }
}

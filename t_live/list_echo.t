use strict;
use warnings;
use Test::More qw(no_plan);
use t_live::lib::Utils;

my $mixi = login_to('list_echo.pl');

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

run_tests('list_echo') or ok 1, 'skipped: no tests';

sub test {
  my @items = $mixi->list_echo->parse(@_);

  return ok 1, 'skipped: no list echo' unless @items;

  foreach my $item ( @items ) {
    matches( $item => $rules );
  }
}

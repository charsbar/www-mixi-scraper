use strict;
use warnings;
use Test::More qw(no_plan);
use Test::NoWarnings;
use t_live::lib::Utils;

my $mixi = login_to('show_log.pl');

my $rules = {
  time => 'string', # this can't be valid DateTime object as it has no year
  name => 'string',
  link => 'uri',
};

# date_format('%m-%d %H:%M');

run_tests('show_log') or ok 1, 'skipped: no tests';

sub test {
  my @items = $mixi->show_log->parse(@_);

  return ok 1, 'skipped: no logs' unless @items;

  foreach my $item ( @items ) {
    matches( $item => $rules );
  }
}

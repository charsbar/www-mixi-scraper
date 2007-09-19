use strict;
use warnings;
use Test::More qw(no_plan);
use t_live::lib::Utils;

my $mixi = login_to('show_log.pl');

my $rules = {
  time => 'datetime',
  name => 'string',
  link => 'uri',
};

date_format('%Y-%m-%d %H:%M');

run_tests('show_log') or ok 'ignored';

sub test {
  my @items = $mixi->show_log->parse(@_);

  return ok 'skipped: no logs' unless @items;

  foreach my $item ( @items ) {
    matches( $item => $rules );
  }
}

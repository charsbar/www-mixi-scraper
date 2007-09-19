use strict;
use warnings;
use Test::More qw(no_plan);
use t_live::lib::Utils;
use Encode;

my $mixi = login_to('show_calendar.pl');

my $rules = {
  subject => 'string',
  link    => 'uri',
  name    => 'string',
  time    => 'datetime',
  icon    => 'uri',
};

date_format('%Y-%m-%d');

run_tests('show_calendar') or ok 'ignored';

sub test {
  my @items = $mixi->show_calendar->parse(@_);

  return ok 'skipped: no calendar items' unless @items;

  foreach my $item ( @items ) {
    matches( $item => $rules );
  }
}

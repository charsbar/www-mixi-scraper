use strict;
use warnings;
use Test::More qw(no_plan);
use t_live::lib::Utils;

my $mixi = login_to('new_friend_diary.pl');

my $rules = {
  subject => 'string',
  name    => 'string',
  time    => 'datetime',
  link    => 'uri',
};

date_format('%Y-%m-%d %H:%M');

run_tests('new_friend_diary') or ok 'ignored';

sub test {
  my @items = $mixi->new_friend_diary->parse(@_);

  return ok 'skipped: no new diary entries' unless @items;

  foreach my $item ( @items ) {
    matches( $item => $rules );
  }
}

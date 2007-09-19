use strict;
use warnings;
use Test::More qw(no_plan);
use t_live::lib::Utils;

my $mixi = login_to('new_music.pl');

my $rules = {
  subject => 'string',
  name    => 'string',
  time    => 'datetime',
  link    => 'uri',
};

date_format('%Y-%m-%d %H:%M');

run_tests('new_music') or ok 'ignored';

sub test {
  my @items = $mixi->new_music->parse(@_);

  return ok 'skipped: no new musics' unless @items;

  foreach my $item ( @items ) {
    matches( $item => $rules );
  }
}

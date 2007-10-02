use strict;
use warnings;
use Test::More qw(no_plan);
use t_live::lib::Utils;

my $mixi = login_to('show_friend.pl');

my $rules = {
  name  => 'string',
  image => 'uri',
  count => 'integer',
  link  => 'uri_if_remote',
};

run_tests('show_friend') or ok 1, 'skipped: no tests';

sub test {
  my $friend = $mixi->show_friend->parse(@_);

  my $profile = $friend->{profile};
  foreach my $key ( keys %{ $profile } ) {
    ok $key;
    matches( $profile => { $key => 'string' } );
  }

  my $outline = $friend->{outline};
  matches( $outline => $rules );

  my $step = $outline->{step};
  ok defined $step;
  ok $outline->{description} if $step; # null if it's you
  if ( $step > 1 ) {
    ok $outline->{relation};
    matches(
      $outline->{relation} => { name => 'string', link => 'uri' }
    );
  }
}

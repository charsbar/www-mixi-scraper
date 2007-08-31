use strict;
use warnings;
use Test::More qw(no_plan);
use t_live::lib::Utils;
use Encode;

my $mixi = login_to('show_friend.pl');

run_tests('show_friend') or ok 'ignored';

sub test {
  my $friend = $mixi->show_friend->parse(@_);

  my $profile = $friend->{profile};
  foreach my $key ( keys %{ $profile } ) {
    ok $key;
    ok defined $profile->{$key}; # may be blank but at least should be defined
  }

  my $outline = $friend->{outline};
  ok $outline->{name};
  unless ( its_local ) {
    ok $outline->{link};
    ok ref $outline->{link} && $outline->{link}->isa('URI');
  }
  ok $outline->{image};  # may be 'no_photo.gif', though
  ok ref $outline->{image} && $outline->{image}->isa('URI');
  ok $outline->{count};
  my $step = $outline->{step};
  ok defined $step;
  ok $outline->{description} if $step; # null if it's you
  if ( $step > 1 ) {
    ok $outline->{relation};
    ok $outline->{relation}->{name};
    ok $outline->{relation}->{link};
    ok ref $outline->{relation}->{link} && $outline->{relation}->{link}->isa('URI');
  }
}

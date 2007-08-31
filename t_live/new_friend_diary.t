use strict;
use warnings;
use Test::More qw(no_plan);
use t_live::lib::Utils;

my $mixi = login_to('new_friend_diary.pl');
my $dateformat = date_format('%Y-%m-%d %H:%M');

run_tests('new_friend_diary') or ok 'ignored';

sub test {
  my @items = $mixi->new_friend_diary->parse(@_);

  return ok 'skipped: no new diary entries' unless @items;

  foreach my $item ( @items ) {
    ok $item->{subject};
    ok $item->{name};
    ok $item->{time};
    my $dt = $dateformat->parse_datetime( $item->{time} );
    ok defined $dt;
    ok $item->{link};
    ok ref $item->{link} && $item->{link}->isa('URI');
  }
}

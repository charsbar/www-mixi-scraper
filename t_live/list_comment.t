use strict;
use warnings;
use Test::More qw(no_plan);
use t_live::lib::Utils;

my $mixi = login_to('list_comment.pl');
my $dateformat = date_format('%Y-%m-%d %H:%M');

run_tests('list_comment') or ok 'ignored';

sub test {
  my @items = $mixi->list_comment->parse(@_);

  return ok 'skipped: no comments' unless @items;

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

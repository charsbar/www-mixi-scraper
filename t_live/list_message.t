use strict;
use warnings;
use Test::More qw(no_plan);
use t_live::lib::Utils;

my $mixi = login_to('list_message.pl');

# my $dateformat = date_format('%m-%d');

run_tests('list_message') or ok 'ignored';

sub test {
  my @items = $mixi->list_message->parse(@_) ;

  return ok 'skipped: no messages' unless @items;

  foreach my $item ( @items ) {
    ok $item->{subject};
    ok $item->{name};
    ok $item->{time};

    # this can't be valid DateTime object as it has no year
    #    my $dt = $dateformat->parse_datetime( $item->{time} );
    #    ok defined $dt;

    ok $item->{link};
    ok ref $item->{link} && $item->{link}->isa('URI');
    ok $item->{envelope};
    ok ref $item->{envelope} && $item->{envelope}->isa('URI');

if ( 0 ) { # not yet implemented
    ok $item->{status};
}

  }
}

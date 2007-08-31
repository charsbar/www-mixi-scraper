use strict;
use warnings;
use Test::More qw(no_plan);
use t_live::lib::Utils;

my $mixi = login_to('list_diary.pl');
# my $dateformat = date_format('%m-%d %H:%M');

run_tests('list_diary') or ok 'ignored';

sub test {
  my @items = $mixi->list_diary->parse(@_);

  return ok 'skipped: no diary' unless @items;

  foreach my $item ( @items ) {
    ok $item->{subject};
    ok $item->{description};
    ok $item->{time};

    # this can't be valid DateTime object as it has no year
    #    my $dt = $dateformat->parse_datetime( $item->{time} );
    #    ok defined $dt;
    ok $item->{link};
    ok ref $item->{link} && $item->{link}->isa('URI');

    ok defined $item->{count};  # this may be 0
    foreach my $image ( @{ $item->{images} || [] } ) {
      ok $image->{link};
      ok ref $image->{link} && $image->{link}->isa('URI');
      ok $image->{thumb_link};
      ok ref $image->{thumb_link} && $image->{thumb_link}->isa('URI');
    }
  }
}

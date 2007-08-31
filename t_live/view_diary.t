use strict;
use warnings;
use Test::More qw(no_plan);
use t_live::lib::Utils;

my $mixi = login_to('view_diary.pl');
my $dateformat = date_format('%Y-%m-%d %H:%M');

run_tests('view_diary') or ok 'ignored';

sub test {
  my $diary = $mixi->view_diary->parse(@_);

  ok $diary->{subject};
  ok $diary->{description};
  ok $diary->{time};
  my $dt = $dateformat->parse_datetime( $diary->{time} );
  ok defined $dt;
  unless ( its_local ) {
    ok $diary->{link};
    ok ref $diary->{link} && $diary->{link}->isa('URI');
  }

if (0) { # not yet implemented
  ok $diary->{level};
  ok $diary->{level}->{description};
  ok $diary->{level}->{link};
  ok ref $diary->{level}->{link} && $diary->{level}->{link}->isa('URI');
}
  foreach my $comment ( @{ $diary->{comments} || [] } ) {
    ok $comment->{name};
    ok $comment->{description};
    ok $comment->{time};
    my $dt = $dateformat->parse_datetime( $comment->{time} );
    ok defined $dt;
    ok $comment->{link};
    ok ref $comment->{link} && $comment->{link}->isa('URI');
  }

  foreach my $image ( @{ $diary->{images} || [] } ) {
    ok $image->{link};
    ok ref $image->{link} && $image->{link}->isa('URI');
    ok $image->{thumb_link};
    ok ref $image->{thumb_link} && $image->{thumb_link}->isa('URI');
  }
}

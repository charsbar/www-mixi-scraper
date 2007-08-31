use strict;
use warnings;
use Test::More qw(no_plan);
use t_live::lib::Utils;

my $mixi = login_to('view_bbs.pl');
my $dateformat = date_format('%Y-%m-%d %H:%M');

run_tests('view_bbs') or ok 'ignored';

sub test {
  my $bbs = $mixi->view_bbs->parse(@_);

  ok $bbs->{subject};
  ok $bbs->{name};
  ok $bbs->{description};
  ok $bbs->{time};
  my $dt = $dateformat->parse_datetime( $bbs->{time} );
  ok defined $dt;
  ok $bbs->{name_link};
  ok ref $bbs->{name_link} && $bbs->{name_link}->isa('URI');

  unless ( its_local ) {
    ok $bbs->{link};
    ok ref $bbs->{link} && $bbs->{link}->isa('URI');
  }

  foreach my $comment ( @{ $bbs->{comments} || [] } ) {
    ok defined $comment->{name};  # might be null string or zero
    ok $comment->{description};
    ok $comment->{time};
    my $dt = $dateformat->parse_datetime( $comment->{time} );
    ok defined $dt;
    ok $comment->{link};
    ok ref $comment->{link} && $comment->{link}->isa('URI');
  }

  foreach my $image ( @{ $bbs->{images} || [] } ) {
    ok $image->{link};
    ok ref $image->{link} && $image->{link}->isa('URI');
    ok $image->{thumb_link};
    ok ref $image->{thumb_link} && $image->{thumb_link}->isa('URI');
  }
}

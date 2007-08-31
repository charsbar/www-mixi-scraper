use strict;
use warnings;
use Test::More qw(no_plan);
use t_live::lib::Utils;

my $mixi = login_to('view_event.pl');
my $dateformat = date_format('%Y-%m-%d %H:%M');

run_tests('view_event') or ok 'ignored';

sub test {
  my $event = $mixi->view_event->parse(@_);

  ok $event->{subject};
if (0) { # not yet implemented
  ok $event->{link};
  ok ref $event->{link} && $event->{link}->isa('URI');
}
  ok $event->{time};
  my $dt = $dateformat->parse_datetime( $event->{time} );
  ok defined $dt;
  ok $event->{date};
  ok $event->{deadline};
  ok $event->{location};
  ok $event->{description};
  foreach my $image ( @{ $event->{images} || [] } ) {
    ok $image->{link};
    ok ref $image->{link} && $image->{link}->isa('URI');
    ok $image->{thumb_link};
    ok ref $image->{thumb_link} && $image->{thumb_link}->isa('URI');
  }
  ok $event->{name};
  ok $event->{name_link};
  ok ref $event->{name_link} && $event->{name_link}->isa('URI');

if (0) { # not yet implemented
  ok $event->{join};
}
  ok $event->{community}->{name};
  ok $event->{community}->{link};
  ok ref $event->{community}->{link} && $event->{community}->{link}->isa('URI');
  ok $event->{list}->{count};
  ok $event->{list}->{subject};
  ok $event->{list}->{link};
  ok ref $event->{list}->{link} && $event->{list}->{link}->isa('URI');
  foreach my $comment ( @{ $event->{comments} || [] } ) {
    ok $comment->{subject};
    ok $comment->{name};
    ok $comment->{description};
    ok $comment->{time};
    my $dt = $dateformat->parse_datetime( $comment->{time} );
    ok defined $dt;
    ok $comment->{link};
    ok ref $comment->{link} && $comment->{link}->isa('URI');
    foreach my $image ( @{ $comment->{images} || [] } ) {
      ok $image->{link};
      ok ref $image->{link} && $image->{link}->isa('URI');
      ok $image->{thumb_link};
      ok ref $image->{thumb_link} && $image->{thumb_link}->isa('URI');
    }
  }
if (0) { # not yet implemented
  foreach my $page ( @{ $event->{pages} || [] } ) {
    ok $page->{current};
    ok ref $page->{link} && $page->{link}->isa('URI');
    ok $page->{subject};
  }
}

}

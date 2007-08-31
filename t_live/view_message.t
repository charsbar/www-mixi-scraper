use strict;
use warnings;
use Test::More qw(no_plan);
use t_live::lib::Utils;

my $mixi = login_to('view_message.pl');
my $dateformat = date_format('%Y-%m-%d %H:%M');

run_tests('view_message') or ok 'ignored';

sub test {
  my $message = $mixi->view_message->parse(@_);

  ok $message->{subject};
  ok $message->{name};
  ok $message->{description};
  ok $message->{time};
  my $dt = $dateformat->parse_datetime( $message->{time} );
  ok defined $dt;
  ok $message->{link};
  ok ref $message->{link} && $message->{link}->isa('URI');
  ok $message->{image};
  ok ref $message->{image} && $message->{image}->isa('URI');
}

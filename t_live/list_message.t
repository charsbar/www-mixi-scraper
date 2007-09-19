use strict;
use warnings;
use Test::More qw(no_plan);
use t_live::lib::Utils;

my $mixi = login_to('list_message.pl');

my $rules = {
  subject  => 'string',
  name     => 'string',
  time     => 'string', # this can't be valid DateTime object as it has no year
  link     => 'uri',
  envelope => 'uri',
# status   => 'string', # not yet implemented
};

# date_format('%m-%d');

run_tests('list_message') or ok 'ignored';

sub test {
  my @items = $mixi->list_message->parse(@_) ;

  return ok 'skipped: no messages' unless @items;

  foreach my $item ( @items ) {
    matches( $item => $rules );
  }
}

use strict;
use warnings;
use Test::More qw(no_plan);
use t_live::lib::Utils;

my $mixi = login_to('view_bbs.pl');

my $rules = {
  subject     => 'string',
  name        => 'string',
  description => 'string',
  time        => 'datetime',
  name_link   => 'uri',
  link        => 'uri_if_remote',
  comment => {
    name        => 'string',
    description => 'string',
    time        => 'datetime',
    link        => 'uri',
  },
  images => {
    link       => 'uri',
    thumb_link => 'uri',
  },
};

date_format('%Y-%m-%d %H:%M');

run_tests('view_bbs') or ok 'ignored';

sub test {
  my $bbs = $mixi->view_bbs->parse(@_);

  matches( $bbs => $rules );
}

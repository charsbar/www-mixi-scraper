package WWW::Mixi::Scraper::Plugin::ViewEcho;

use strict;
use warnings;
use WWW::Mixi::Scraper::Plugin;
use URI;

validator {( id => 'is_number', post_time => 'is_number' )};

sub scrape {
  my ($self, $html) = @_;

  my $scraper = scraper {
      process '#echo_member_id_1', id => 'TEXT';
      process '#echo_post_time_1', time => 'TEXT';
      process '#echo_nickname_1', name => 'TEXT';
      process '#echo_body_1', comment => 'TEXT';
  };

  my $stash = $self->post_process($scraper->scrape(\$html));
  my $echo = $stash->[0] or return $stash;
  $echo->{link} = URI->new("http://mixi.jp/view_echo.pl?id=@{[$echo->{id}]}&post_time=@{[$echo->{time}]}");
  return $stash;
}

1;

__END__

=head1 NAME

WWW::Mixi::Scraper::Plugin::ViewEcho

=head1 DESCRIPTION


=head1 METHOD

=head2 scrape

returns an hash reference of

  {
    link    => 'http://mixi.jp/view_echo.pl?id=xxxx&post_time=xxxx',
    id      => 'xxxx',
    time    => 'yyyymmddhhmmss',
    name    => 'username',
    comment => 'comment',
  }

=head1 AUTHOR

Kazuhiro Osawa

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Kazuhiro Osawa.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

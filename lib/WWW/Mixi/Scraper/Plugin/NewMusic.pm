package WWW::Mixi::Scraper::Plugin::NewMusic;
use strict;
use warnings;
use WWW::Mixi::Scraper::Plugin;
use base qw( WWW::Mixi::Scraper::Plugin::NewFriendDiary );

validator {};

1;

__END__

=head1 NAME

WWW::Mixi::Scraper::Plugin::NewMusic

=head1 DESCRIPTION

This would be equivalent to WWW::Mixi->parse_new_music().
(though the latter is not implemented yet as of writing this)

=head1 METHOD

=head2 scrape

returns an array reference of

  {
    subject  => 'music title',
    name     => 'someone',
    link     => 'http://music.mixi.jp/show_playlist.pl?id=xxx',
    time     => 'yyyy-mm-dd hh:mm',
  }

=head1 AUTHOR

Kenichi Ishigaki E<lt>ishigaki at cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

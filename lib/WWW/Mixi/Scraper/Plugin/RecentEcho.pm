package WWW::Mixi::Scraper::Plugin::RecentEcho;

use strict;
use warnings;
use WWW::Mixi::Scraper::Plugin;
use URI;

validator {( page => 'is_number' )};

sub scrape {
  my ($self, $html) = @_;

  my $scraper = scraper {
    process 'div.archiveList>table>tr',
      'recents[]' => scraper {
        process '//td[@class="comment"]//div[1]', id => 'HTML';
        process '//td[@class="comment"]//div[2]', time => 'HTML';
        process '//td[@class="comment"]//div[3]', name => 'HTML';
        process '//td[@class="comment"]//div[4]', comment => 'HTML';
        process '//td[@class="thumb"]//img',      icon => '@src';
    };
  };

  my $stash = $self->post_process($scraper->scrape(\$html));
  my $data = $stash->[0] or return $stash;
  $data->{count} = 0;
  foreach my $echo ( @{ $data->{recents} } ) {
      $data->{count}++;
      $echo->{link} = URI->new("http://mixi.jp/view_echo.pl?id=@{[$echo->{id}]}&post_time=@{[$echo->{time}]}");
  }
  return $stash;
}

1;

__END__

=head1 NAME

WWW::Mixi::Scraper::Plugin::RecentEcho

=head1 DESCRIPTION


=head1 METHOD

=head2 scrape

returns an array reference of

  {
    count   => 'num of recents',
    recents  => [
      {
        link    => 'http://mixi.jp/view_echo.pl?id=xxxx&post_time=xxxx',
        id      => 'xxxx',
        time    => 'yyyymmddhhmmss',
        name    => 'username',
        comment => 'comment',
      },
    ],
  }

Recents may be a blank array reference.

=head1 AUTHOR

Kazuhiro Osawa

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Kazuhiro Osawa.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

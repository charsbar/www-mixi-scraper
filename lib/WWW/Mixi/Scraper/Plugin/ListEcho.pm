package WWW::Mixi::Scraper::Plugin::ListEcho;

use strict;
use warnings;
use WWW::Mixi::Scraper::Plugin;
use URI;

validator {( page => 'is_number', id => 'is_number' )};

sub scrape {
  my ($self, $html) = @_;

  my $scraper = scraper {
    process 'div.archiveList>table>tr>td.comment',
      'recents[]' => scraper {
        process '//div[1]', id => 'HTML';
        process '//div[2]', time => 'HTML';
        process '//div[3]', name => 'HTML';
        process '//div[4]', comment => 'HTML';
    };
    result 'recents';
  };

  my $stash = $self->post_process($scraper->scrape(\$html));
  foreach my $echo ( @{ $stash } ) {
      $echo->{link} = URI->new("http://mixi.jp/view_echo.pl?id=@{[$echo->{id}]}&post_time=@{[$echo->{time}]}");
  }
  return $stash;
}

1;

__END__

=head1 NAME

WWW::Mixi::Scraper::Plugin::ListEcho

=head1 DESCRIPTION

This would be equivalent to WWW::Mixi->parse_list_echo().
(though the latter is not implemented yet as of writing this)

=head1 METHOD

=head2 scrape

returns an array reference of

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

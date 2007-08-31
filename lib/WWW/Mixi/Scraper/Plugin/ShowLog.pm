package WWW::Mixi::Scraper::Plugin::ShowLog;

use strict;
use warnings;
use WWW::Mixi::Scraper::Plugin;

sub scrape {
  my ($self, $html) = @_;

  my %scraper;
  $scraper{logs} = scraper {
    process 'li',
      time => 'TEXT';
    process 'a',
      name => 'TEXT',
      link => '@href';
    result qw( time name link );
  };

  $scraper{list} = scraper {
    process 'div#log_color>ul>li',
      'logs[]' => $scraper{logs};
    result qw( logs );
  };

  return $self->post_process($scraper{list}->scrape(\$html));
}

1;

__END__

=head1 NAME

WWW::Mixi::Scraper::Plugin::ShowLog

=head1 DESCRIPTION

This is equivalent to WWW::Mixi->parse_show_log().

=head1 METHOD

=head2 scrape

returns an array reference of 

  {
    link => 'http://mixi.jp/show_friend.pl?id=xxxx',
    name => 'someone',
    time => 'yyyy-mm-dd hh:mm'
  }

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki at cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

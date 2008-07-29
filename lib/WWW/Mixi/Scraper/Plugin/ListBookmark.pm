package WWW::Mixi::Scraper::Plugin::ListBookmark;

use strict;
use warnings;
use WWW::Mixi::Scraper::Plugin;

validator {};

sub scrape {
  my ($self, $html) = @_;

  my %scraper;
  $scraper{bookmark} = scraper {
    process 'div.heading>a.name',
      link => '@href',
      name => 'TEXT';
    process 'div.heading>span>span',
      last_login => 'TEXT';
    result qw( link name last_login );
  };

  $scraper{list} = scraper {
    process 'ul.list>li',
      'bookmarks[]' => $scraper{bookmark};
    result qw( bookmarks );
  };

  my $results_ref = $self->post_process(
    $scraper{list}->scrape(\$html) => \&_extract_name
  );

  for (@$results_ref) {
      ($_->{id}) = $_->{link} =~ m/show_friend\.pl\?id=(\d+)$/;
      ($_->{last_login}) = $_->{last_login} =~ m/^\(?(.*?)\)?$/;
  }

  return $results_ref;
}

1;

__END__

=head1 NAME

WWW::Mixi::Scraper::Plugin::ListBookmark

=head1 DESCRIPTION

This would be equivalent to WWW::Mixi->parse_list_bookmark().
(though the latter is not implemented yet as of writing this)

=head1 METHOD

=head2 scrape

returns an array reference of

  {
    id         => 3755394,
    name       => 'ぼくちん',
    link       => 'http://mixi.jp/show_friend.pl?id=3755394',
    last_login => '5分以内'、
  }

=head1 AUTHOR

Tomohiro Hosaka E<lt>bokutin@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Tomohiro Hosaka.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

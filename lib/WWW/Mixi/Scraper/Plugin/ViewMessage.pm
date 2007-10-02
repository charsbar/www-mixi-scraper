package WWW::Mixi::Scraper::Plugin::ViewMessage;

use strict;
use warnings;
use WWW::Mixi::Scraper::Plugin;

validator {qw(
  id   is_anything
  box  is_anything
)};

sub scrape {
  my ($self, $html) = @_;

  my %scraper;
  $scraper{message_meta} = scraper {
    process 'td[background]>a>img',
      image => '@src';
    process 'td[width="445"]>table[width="440"]>tr>td[align="left"]>a',
      link => '@href',
      name => 'TEXT';
    process 'td[width="445"]>table[width="440"]>tr>td>input[name="subject"]',
      subject => '@value';
    process 'td[width="445"]>table[width="440"]>tr>td>input[name="body"]',
      description => '@value';
    result qw( subject name link image description );
  };

  $scraper{message_body} = scraper {
    process 'td',
      string => 'TEXT';
    process 'td>table',
      table => 'TEXT';
    result qw( string table );
  };

  $scraper{message} = scraper {
    process 'table[bgcolor="#CC9933"]>tr>td>table[width="555"]>tr',
      meta => $scraper{message_meta};
    process 'table[bgcolor="#CC9933"]>tr>td>table[width="555"]>tr>td[bgcolor="#FFF4E0"]',
      'body[]' => $scraper{message_body};
    result qw( meta body );
  };

  my $stash = $scraper{message}->scrape(\$html);

  my $time = ( map { $_->{string} } grep { !$_->{table} } @{ $stash->{body} } )[0];
     $time =~ s/^.*(\d{4})\D+(\d{2})\D+(\d{2})\D+(\d{2})\D+(\d{2}).*$/$1\-$2\-$3 $4:$5/;

  my $message = {
    subject     => $stash->{meta}->{subject},
    name        => $stash->{meta}->{name},
    link        => $stash->{meta}->{link},
    image       => $stash->{meta}->{image},
    description => $stash->{meta}->{description},
    time        => $time,
  };

  return $self->post_process( $message )->[0];
}

1;

__END__

=head1 NAME

WWW::Mixi::Scraper::Plugin::ViewMessage

=head1 DESCRIPTION

This is equivalent to WWW::Mixi->parse_view_message().

=head1 METHOD

=head2 scrape

returns a hash reference such as

  {
    subject => 'title of the message',
    image => 'http://img.mixi.jp/photo/member/xx/xx/xxx_xxx.jpg',
    link => 'http://mixi.jp/show_friend.pl?id=xxx',
    name => 'someone',
    time => 'yyyy-mm-dd hh:mm',
    description => 'message body',
  }

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki at cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

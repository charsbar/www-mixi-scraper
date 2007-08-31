package WWW::Mixi::Scraper::Plugin::ListMessage;

use strict;
use warnings;
use WWW::Mixi::Scraper::Plugin;

validator {qw( page is_number )};

sub scrape {
  my ($self, $html) = @_;

  my %scraper;
  $scraper{messages} = scraper {
    process 'td',
      width => '@width',
      string => 'TEXT';
    process 'td>a',
      link => '@href';
    process 'td>img',
      envelope => '@src';
    result qw( string envelope link width );
  };

  $scraper{list} = scraper {
    process 'table[width="553"]>tr[bgcolor="#FFFFFF"]>td',
      'messages[]' => $scraper{messages};
    result qw( messages );
  };

  my $stash = $self->post_process( $scraper{list}->scrape(\$html) );

  my @messages;
  while ( my ( $env, $del, $sender, $title, $date ) = splice @{ $stash }, 0, 5 ) {
    next if $env->{width}; # skip header

    push @messages, {
      subject  => $title->{string},
      name     => $sender->{string},
      link     => $title->{link},
      envelope => $env->{envelope},
      time     => $date->{string},
    };
  }

  return $self->post_process( \@messages );
}

1;

__END__

=head1 NAME

WWW::Mixi::Scraper::Plugin::ListMessage

=head1 DESCRIPTION

This is almost equivalent to WWW::Mixi->parse_list_message().

=head1 METHOD

=head2 scrape

returns an array reference of

  {
    subject  => 'message title',
    name     => 'someone',
    link     => 'http://mixi.jp/view_message.pl?id=xxxx&box=xxx',
    time     => 'mm-dd',
    envelope => 'http://mixi.jp/img/mail5.gif'
  }

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki at cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

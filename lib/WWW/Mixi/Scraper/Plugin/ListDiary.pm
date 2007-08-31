package WWW::Mixi::Scraper::Plugin::ListDiary;

use strict;
use warnings;
use WWW::Mixi::Scraper::Plugin;

validator {qw(
  id     is_number
  page   is_number
  year   is_number
  month  is_number
)};

sub scrape {
  my ($self, $html) = @_;

  my %scraper;
  $scraper{meta} = scraper {
    process 'a',
      text => 'TEXT',
      href => '@href';
    result qw( text href );
  };

  $scraper{diaries} = scraper {
    process 'td[nowrap]',
      time => 'TEXT';
    process 'td[bgcolor="#FFF4E0"]>a',
      link   => '@href',
      subject => 'TEXT';
    process 'td[bgcolor="#FFFFFF"]>table[cellpadding="3"]>tr>td[class="h120"]',
      description => 'TEXT';
    process 'td[bgcolor="#FFFFFF"]>table[cellpadding="3"]>tr>td[class="h120"]>table>tr>td>a>img',
      'images[]' => '@src';
    process 'td[align="right"]>a',
      'meta[]' => $scraper{meta};
    result qw( time link subject description images meta );
  };

  $scraper{list} = scraper {
    process 'table[width="525"]>tr',
      'diaries[]' => $scraper{diaries};
    result qw( diaries );
  };

  my $stash = $self->post_process($scraper{list}->scrape(\$html));

  my $tmp;
  my @diaries;
  foreach my $item ( @{ $stash } ) {
    if ( $item->{time} ) {  # meta
      $tmp = {
        time    => $item->{time},
        link    => $item->{link},
        subject => $item->{subject},
      };
    }
    elsif ( $item->{description} ) {
      $tmp->{description} = $item->{description};
      $tmp->{images}      = $item->{images};
    }
    elsif ( $item->{meta} ) {
      foreach my $meta ( @{ $item->{meta} || [] } ) {
        if ( ($meta->{href} || '') =~ /#(?:write|comment)$/ ) {
          my ($count) = $meta->{text} =~ /\((\d+)\)/;
          $tmp->{count} = $count;
        }
      }
      push @diaries, $tmp;
    }
  }

  return \@diaries;
}

1;

__END__

=head1 NAME

WWW::Mixi::Scraper::Plugin::ListDiary

=head1 DESCRIPTION

This is almost equivalent to WWW::Mixi->parse_list_diary().

=head1 METHOD

=head2 scrape

returns an array reference of

  {
    subject => 'title of the diary',
    link    => 'http://mixi.jp/view_diary.pl?id=xxxx&owner_id=xxxx',
    description => 'extract of the diary',
    time    => 'yyyy-mm-dd hh:mm',
    count   => 'num of comments',
    images  => [
      {
        link       => 'http://img.mixi.jp/xx/xx/xxx.jpg',
        thumb_link => 'http://img.mixi.jp/xx/xx/xxxs.jpg',
      },
    ],
  }

Images may be an blank array reference.

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki at cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

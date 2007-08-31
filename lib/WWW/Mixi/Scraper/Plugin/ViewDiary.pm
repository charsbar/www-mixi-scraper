package WWW::Mixi::Scraper::Plugin::ViewDiary;

use strict;
use warnings;
use WWW::Mixi::Scraper::Plugin;

validator {qw(
  id        is_number
  owner_id  is_number
)};

sub scrape {
  my ($self, $html) = @_;

  my %scraper;
  $scraper{images} = scraper {
    process 'a',
      link => '@onClick';
    process 'a>img',
      thumb_link => '@src';
    result qw( link thumb_link );
  };

  $scraper{diary_body} = scraper {
    process 'tr[valign="top"]>td[nowrap]',
      time => 'TEXT';
    process 'tr[valign="top"]>td[width="430"]',
      subject => 'TEXT';
    process 'tr>td>table[width="410"]>tr>td[class="h12"]',
      description => 'TEXT';
    process 'tr>td>table[width="410"]>tr>td>table>tr>td[valign="middle"]',
      'images[]' => $scraper{images};
    result qw( time subject description images );
  };

  $scraper{diary} = scraper {
    process 'td[width="540"]>table[bgcolor="#F8A448"]>tr>td[colspan="2"]>table[cellpadding="3"]',
      diary => $scraper{diary_body};
    result qw( diary );
  };

  my $stash = $self->post_process($scraper{diary}->scrape(\$html))->[0];

  # XXX: this fails when you test with local files.
  # However, this link cannot be extracted from the html,
  # at least as of writing this. ugh.
  $stash->{link} = $self->{uri};

  $scraper{comments} = scraper {
    process 'tr',
      string => 'TEXT';
    process 'td[nowrap]',
      time => 'TEXT';
    process 'td[width="430"]>table[width="410"]>tr>td>a',
      link => '@href',
      name => 'TEXT';
    process 'td[bgcolor="#ffffff"]>table[cellpadding="5"]>tr>td[class="h12"]',
      description => 'TEXT';
    result qw( string time link name description );
  };

  $scraper{list} = scraper {
    process 'a[name="comment"]+table>tr>td[colspan="2"]>table[cellpadding="3"]>tr',
      'comments[]' => $scraper{comments};
    result qw( comments );
  };

  my $stash_c = $self->post_process($scraper{list}->scrape(\$html));

  my $tmp;
  my @comments;
  foreach my $comment ( @{ $stash_c } ) {
    next if !$comment->{string} || $comment->{string} =~ /^\s*$/s;
    if ( $comment->{time} ) {  # meta
      $tmp = {
        time => $comment->{time},
        name => $comment->{name},
        link => $comment->{link},
      };
    }
    else {  # body
      $tmp->{description} = $comment->{description};
      push @comments, $tmp;
    }
  }
  $stash->{comments} = \@comments;

  return $stash;
}

1;

__END__

=head1 NAME

WWW::Mixi::Scraper::Plugin::ViewDiary

=head1 DESCRIPTION

This is almost equivalent to WWW::Mixi->parse_view_diary().

=head1 METHOD

=head2 scrape

returns a hash reference such as

  {
    subject => 'title of the entry',
    time => 'yyyy-mm-dd hh:mm',
    description => 'entry body',
    images => [
      {
        link => 'show_diary_picture.pl?img_src=http://img1.mixi.jp/photo/xx/xx.jpg',
        thumb_link => 'http://img1.mixi.jp/photo/xx/xx.jpg',
      },
    ],
    comments => [
      {
        name => 'commenter',
        link => 'http://mixi.jp/show_friend.pl?id=xxxx',
        time => 'yyyy-mm-dd hh:mm',
        description => 'comment body',
      }
    ]
  }

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki at cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

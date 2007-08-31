package WWW::Mixi::Scraper::Plugin::ViewEvent;

use strict;
use warnings;
use WWW::Mixi::Scraper::Plugin;
use utf8;

validator {qw(
  id       is_number
  comm_id  is_number
  page     is_number_or_all
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

  $scraper{topic} = scraper {
    process 'td[rowspan]',
      'time' => 'TEXT';
    process 'td[nowrap]',
      'name' => 'TEXT';
    process 'td:not([align])',
      'string' => 'TEXT';
    process 'td:not([rowspan])>a',
      'link' => '@href';
    process 'td[colspan="2"]>table>tr>td[valign="middle"]',
      'images[]' => $scraper{images};
    result qw( time name string link images );
  };

  $scraper{table} = scraper {
    process 'table[bgcolor="#F8A448"]>tr>td[colspan="2"]>table[width="630"]>tr',
      'topic[]' => $scraper{topic};
    result qw( topic );
  };

  $scraper{comment_body} = scraper {
    process 'td[rowspan]',
      'time' => 'TEXT';
    process 'td[bgcolor="#FDF9F2"]>font>b',
      'subject' => 'TEXT';
    process 'td[bgcolor="#FDF9F2"]>a',
      'link' => '@href',
      'name' => 'TEXT';
    process 'td[bgcolor="#FFFFFF"]>table>tr>td[width="500"]',
      'description' => 'TEXT';
    process 'td[bgcolor="#FFFFFF"]>table>tr>td[width="500"]>table>tr>td[valign="middle"]',
      'images[]' => $scraper{images};
    result qw( time name link subject description images );
  };

  $scraper{comment} = scraper {
    process 'table[bgcolor="#DFB479"]>tr>td>table[width="630"]>tr',
      'comments[]' => $scraper{comment_body};
    result 'comments';
  };

  my $stash = {};
  my $items = $self->post_process($scraper{table}->scrape(\$html));

  foreach my $item (@{ $items || [] }) {
    if ( $item->{time} ) {
      $stash->{time} = $item->{time};
    }
    if ( $item->{images} ) {
      $stash->{images} = $item->{images};
    }

    next unless $item->{name};

    if ( $item->{name} eq 'タイトル' ) {
      $stash->{subject} = $item->{string};
    }
    if ( $item->{name} eq '開催日時' ) {
      $stash->{date} = $item->{string};
    }
    if ( $item->{name} eq '募集期限' ) {
      $stash->{deadline} = $item->{string};
    }
    if ( $item->{name} eq '開催場所' ) {
      $stash->{location} = $item->{string};
    }
    if ( $item->{name} eq '詳細' ) {
      $stash->{description} = $item->{string};
    }
    if ( $item->{name} eq '企画者' ) {
      $stash->{name}      = $item->{string};
      $stash->{name_link} = $item->{link};
    }
    if ( $item->{name} eq '参加者' ) {
      my ($count, $subject) = $item->{string} =~ /(\d+人)\s+(\S+)/;
      $stash->{list}->{count}   = $count;
      $stash->{list}->{link}    = $item->{link};
      $stash->{list}->{subject} = $subject;
    }
    if ( $item->{name} eq '関連コミュニティ' ) {
      $stash->{community}->{name} = $item->{string};
      $stash->{community}->{link} = $item->{link};
    }
  }

  # XXX: this fails when you test with local files.
  # However, this link cannot be extracted from the html,
  # at least as of writing this. ugh.
  $stash->{link} = $self->{uri};

  my $stash_c = $self->post_process($scraper{comment}->scrape(\$html));

  my $tmp;
  my @comments;
  foreach my $comment (@{ $stash_c || [] }) {
    next if !$comment->{description} && !$comment->{time};
    if ( $comment->{time} ) { # meta
      $tmp = {
        time    => $comment->{time},
        name    => $comment->{name},
        subject => $comment->{subject},
        link    => $comment->{link},
      };
    }
    if ( $comment->{description} ) {
      $tmp->{description} = $comment->{description};
      $tmp->{images}      = $comment->{images};
      push @comments, $tmp;
      $tmp = {};
    }
  }
  $stash->{comments} = \@comments;

  return $stash;
}

1;

__END__

=head1 NAME

WWW::Mixi::Scraper::Plugin::ViewEvent

=head1 DESCRIPTION

This is almost equivalent to WWW::Mixi->parse_view_event().

=head1 METHOD

=head2 scrape

returns a hash reference such as

  {
    subject => 'title of the event',
    link => 'http://mixi.jp/view_event.pl?id=xxx',
    time => 'yyyy-mm-dd hh:mm',
    date => 'yyyy-mm-dd',
    deadline => 'sometime soon',
    location => 'somewhere',
    description => 'event description',
    name => 'who plans',
    name_link => 'http://mixi.jp/show_friend.pl?id=xxx',
    list => {
      count => '8人',
      link => 'http://mixi.jp/list_event_member.pl?id=xxx&comm_id=xxx',
      subject => '参加者一覧を見る',
    },
    comments => [
      {
        subject => 1,
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

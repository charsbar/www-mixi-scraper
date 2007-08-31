package WWW::Mixi::Scraper::Plugin::ViewBBS;

use strict;
use warnings;
use WWW::Mixi::Scraper::Plugin;

validator {qw(
  id             is_number
  comm_id        is_number
  comment_count  is_number
  page           is_number_or_all
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
    process 'table[bgcolor="#dfa473"]>tr>td[bgcolor="#ffd8b0"]',
      time => 'TEXT';
    process 'table[bgcolor="#dfa473"]>tr>td[bgcolor="#fff4e0"]',
      subject => 'TEXT';
    process 'table[bgcolor="#dfa473"]>tr>td[bgcolor="#fdf9f2"]>a',
      name      => 'TEXT',
      name_link => '@href';
    process 'table[bgcolor="#dfa473"]>tr>td[bgcolor="#ffffff"]>table[width="500"]>tr>td[class="h120"]',
      description => 'TEXT';
    process 'table[bgcolor="#dfa473"]>tr>td[bgcolor="#ffffff"]>table[width="500"]>tr>td[class="h120"]>table>tr>td[valign="middle"]',
      'images[]' => $scraper{images};
    result qw( time subject description name name_link images );
  };

  # bbs topic is not an array
  my $stash = $self->post_process($scraper{topic}->scrape(\$html))->[0];

  # XXX: this fails when you test with local files.
  # However, this link cannot be extracted from the html,
  # at least as of writing this. ugh.
  $stash->{link} = $self->{uri};

  $scraper{comments} = scraper {
    process 'tr',
      string => 'TEXT';
    process 'tr[valign="top"]>td[nowrap]',
      time => 'TEXT';
    process 'tr[valign="top"]>td[bgcolor="#fdf9f2"]>a',
      link => '@href',
      name => 'TEXT';
    process 'td[bgcolor="#ffffff"]>table[cellpadding="5"]>tr>td[class="h120"]',
      description => 'TEXT';
    result qw( string time link name description );
  };

  $scraper{list} = scraper {
    process 'table[cellpadding="3"]>tr',
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
    elsif ( $comment->{description} && $tmp->{time} ) {  # body
      $tmp->{description} = $comment->{description};
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

WWW::Mixi::Scraper::Plugin::ViewBBS

=head1 DESCRIPTION

This is almost equivalent to WWW::Mixi->parse_view_bbs().

=head1 METHOD

=head2 scrape

returns a hash reference such as

  {
    subject => 'title of the topic',
    link => 'http://mixi.jp/view_bbs.pl?id=xxxx',
    time => 'yyyy-mm-dd hh:mm',
    name => 'originator of the topic',
    name_link => 'http://mixi.jp/show_friend.pl?id=xxxx',
    description => 'topic',
    images => [
      {
        link => 'show_picture.pl?img_src=http://img1.mixi.jp/photo/xx/xx.jpg',
        thumb_link => 'http://img1.mixi.jp/photo/xx/xx.jpg',
      },
    ],
    comments => [
      {
        name => 'commenter',
        link => 'http://mixi.jp/show_friend.pl?id=xxxx',
        time => 'yyyy-mm-dd hh:mm',
        description => 'comment body',
      },
    ]
  }

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki at cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

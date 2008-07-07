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

  $scraper{diary} = scraper {
    process 'div.viewDiaryBox>div.listDiaryTitle>dl>dd',
      time => 'TEXT';
    process 'div.viewDiaryBox>div.listDiaryTitle>dl>dt',
      subject => 'TEXT';
    process 'div.viewDiaryBox>div.listDiaryTitle>dl>dt>span',
      string => 'TEXT';
    process 'div#diary_body',
      description => $self->html_or_text;
    process 'div.diaryPhoto>table>tr>td',
      'images[]' => $scraper{images};
    process 'div.personalNavigation01>ul.personalNaviHome>li.top>a',
      mylink => '@href';
    process 'div.personalNavigation01>ul.personalNaviFriend>li.top>a',
      link => '@href';
    result qw( time subject description images link mylink string );
  };

  my $stash = $self->post_process($scraper{diary}->scrape(\$html))->[0];
  $stash->{link} ||= delete $stash->{mylink};

  my $string = delete $stash->{string} || '';
  $stash->{subject} =~ s/$string$//;

  $scraper{comments} = scraper {
    process 'dl.commentList01>dt>span.commentTitleDate',
      time => 'TEXT';
    process 'dl.commentList01>dt>span.commentTitleName>a',
      link => '@href',
      name => 'TEXT';
    process 'dl.commentList01>dd',
      description => $self->html_or_text;
    result qw( time link name description );
  };

  $scraper{list} = scraper {
    process 'div.diaryCommentbox,div.diaryCommentboxLast',
      'comments[]' => $scraper{comments};
    result qw( comments );
  };

  $stash->{comments} = $self->post_process($scraper{list}->scrape(\$html));

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

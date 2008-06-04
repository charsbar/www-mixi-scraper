package WWW::Mixi::Scraper::Plugin::ShowCalendar;

use strict;
use warnings;
use WWW::Mixi::Scraper::Plugin;
use utf8;

my %Subjects = (
  'i_sc-' => '予定',
  'i_bd'  => '誕生日',
  'i_iv1' => '参加イベント',
  'i_iv2' => 'イベント',
);

validator {(
  year    => 'number',
  month   => 'number',
  pref_id => 'number',
)};

sub scrape {
  my ($self, $html) = @_;

  my %scraper;
  $scraper{ym} = scraper {
    process 'div#calendarBox>div.heading02>h3',
      ym => 'TEXT';
    result qw( ym );
  };
  my $ym = $scraper{ym}->scrape(\$html);

  my ($year, $month) = $ym =~ /^(\d{4})\D+(\d{1,2})/;

  $scraper{day} = scraper {
    process 'td',
      day => sub { $_->content and $_->content->[0] };
    process 'ul>li',
      'icons[]' => sub{
         $_->parent()->attr('class') eq 'birthday' ?
         'http://img.mixi.jp/img/calendaricon2/i_bd.gif' :
         'http://img.mixi.jp/img/basic/icon/calendar_event001.gif' ;
     }; # see http://mixi.jp/static/css/basic/home.css
    process 'ul>li>a',
      'texts[]' => 'TEXT',
      'links[]' => '@href';
    result qw( day icons links texts );
  };

  $scraper{list} = scraper {
    process 'div.calendarTable>table.calendar>tbody>tr>td', 
      'string[]' => $scraper{day};
    result qw( string );
  };

  my @items;
  foreach my $day ( @{ $scraper{list}->scrape(\$html) } ) {
    next unless $day->{day};
    my $date = sprintf '%04d/%02d/%02d', $year, $month, $day->{day};

    my @icons = @{ $day->{icons} || [] };
    my @texts = @{ $day->{texts} || [] };
    my @links = @{ $day->{links} || [] };

    next unless @icons && @texts && @links;

    my $ct = 0;
    foreach my $icon ( @icons ) {
      my ($type) = $icon =~ /([\w\-]+)\.gif$/;
      push @items, {
        subject => $Subjects{$type} || '不明',
        name => $texts[$ct],
        link => $links[$ct],
        icon => $icon,
        time => $date,
      };
      $ct++;
    }
  }

  return $self->post_process( \@items );
}

1;

__END__

=head1 NAME

WWW::Mixi::Scraper::Plugin::ShowCalendar

=head1 DESCRIPTION

This is almost equivalent to WWW::Mixi->parse_show_calendar().

=head1 METHOD

=head2 scrape

returns an array reference of

  {
    subject => 'item title',
    name    => 'someone',
    link    => 'http://mixi.jp/view_event.pl?id=xxxx',
    time    => 'yyyy-mm-dd'
    icon    => 'http://mixi.jp/img/i_bd.gif',
  }

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki at cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

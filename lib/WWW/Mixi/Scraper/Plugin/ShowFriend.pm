package WWW::Mixi::Scraper::Plugin::ShowFriend;

use strict;
use warnings;
use WWW::Mixi::Scraper::Plugin;
use WWW::Mixi::Scraper::Utils qw( _uri );
use utf8;

validator {qw( id is_number )};

sub scrape {
  my ($self, $html) = @_;

  return {
    profile => $self->_scrape_profile($html),
    outline => $self->_scrape_outline($html),
  };
}

sub _scrape_profile {
  my ($self, $html) = @_;

  my %scraper;
  $scraper{items} = scraper {
    process 'dl>dt',
      key => 'TEXT';
    process 'dl>dd',
      value => $self->html_or_text;
    result qw( key value );
  };

  $scraper{profile} = scraper {
    process 'div#profile>ul>li',
      'items[]' => $scraper{items};
    result qw( items );
  };

  my $stash = $self->post_process($scraper{profile}->scrape(\$html));

  my $profile = {};
  foreach my $item ( @{ $stash } ) {
    next unless $item->{key};
    $profile->{$item->{key}} = $item->{value};
  }

  return $profile;
}

sub _scrape_outline {
  my ($self, $html) = @_;

  my %scraper;
  $scraper{relations} = scraper {
    process 'a',
      link => '@href',
      name => 'TEXT';
    result qw( link name );
  };

  $scraper{outline} = scraper {
    process 'div#myProfile>div.contents01>h3',
      'string' => 'TEXT';
    process 'div#myProfile>div.contents01>p.loginTime',
      'description' => 'TEXT';
    process 'div#myProfile>p.friendPath>a',
      'relations[]' => $scraper{relations};
    process 'div#myProfile>div.contents01>img',
      image => '@src';
    process 'div#localNavigation>ul.localNaviFriend>li.top>a',
      link  => '@href';
    result qw( image string relations description link );
  };

  my $stash = $self->post_process($scraper{outline}->scrape(\$html))->[0];

  my @relations;
  foreach my $rel (@{ delete $stash->{relations} || [] }) {
    next unless $rel->{link} =~ /^show_friend/;
    $rel->{link} = _uri( $rel->{link} );
    push @relations, $rel;
  }
  $stash->{step} = scalar @relations;
  $stash->{relation} = shift @relations if @relations > 1;

  my $string = delete $stash->{string} || '';
  if ( $string =~ s/\((\d+)\)$// ) {
    $stash->{name}  = $string;
    $stash->{count} = $1;
  }
  if ( $stash->{description} ) {
    $stash->{description} =~ s/^（//;
    $stash->{description} =~ s/）$//;
  }

  return $stash;
}

1;

__END__

=head1 NAME

WWW::Mixi::Scraper::Plugin::ShowFriend

=head1 DESCRIPTION

This is almost equivalent to WWW::Mixi->parse_show_friend_profile() and WWW::Mixi->parse_show_friend_outline(), though you need one more step to get the hash reference(s) you want.

=head1 METHOD

=head2 scrape

returns a hash reference of the person's profile.

  {
    profile => { 'profile' => 'hash' },
    outline => {
      name => 'name',
      link => 'http://mixi.jp/show_friend.pl?id=xxx',
      image => 'http://img.mixi.jp/photo/member/xx/xx/xxx.jpg',
      description => 'last login time',
      count => 20,
      step => 2,
      relation => {
        name => 'someone who knows him/her directly',
        link => 'http://mixi.jp/show_friend.pl?id=yyy',
      },
    },
  }

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki at cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

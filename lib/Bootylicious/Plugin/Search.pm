package Bootylicious::Plugin::Search;

use strict;
use warnings;

use base 'Mojo::Base';

use Mojo::ByteStream 'b';

our $VERSION = '0.900101';

__PACKAGE__->attr('before_context' => 20);
__PACKAGE__->attr('after_context'  => 20);
__PACKAGE__->attr('min_length'     => 2);
__PACKAGE__->attr('max_length'     => 256);

sub hook_init {
    my $self = shift;
    my $app  = shift;

    my $r = $app->routes;

    $r->route('/search')
      ->to(callback => sub { my $c = shift; _search($self, $c) })
      ->name('search');
}

sub _search {
    my $self = shift;
    my $c    = shift;

    my $q = $c->req->param('q');

    my $results = [];

    $c->stash(error => '');

    if (defined $q && length($q) < $self->min_length) {
        $c->stash(error => 'Has to be '
              . $self->min_length
              . ' characters minimal');
    }
    elsif (defined $q && length($q) > $self->max_length) {
        $c->stash(error => 'Has to be '
              . $self->max_length
              . ' characters maximal');
    }
    else {
        if (defined $q) {
            $q = b($q)->xml_escape;

            my ($articles) = main::get_articles;

            my $before_context = $self->before_context;
            my $after_context  = $self->after_context;

            foreach my $article (@$articles) {
                my $found = 0;

                my $title = $article->{title};
                if ($title =~ s/(\Q$q\E)/<font color="red">$1<\/font>/isg) {
                    $found = 1;
                }

                my $parts   = [];
                my $content = $article->{content};
                while ($content
                    =~ s/((?:.{$before_context})?\Q$q\E(?:.{$after_context})?)//is
                  )
                {
                    my $part = $1;
                    $part = b($part)->xml_escape->to_string;
                    $part =~ s/(\Q$q\E)/<font color="red">$1<\/font>/isg;
                    push @$parts, $part;

                    $found = 1;
                }

                push @$results, {%$article, title => $title, parts => $parts}
                  if $found;
            }
        }
    }

    $c->stash(
        articles       => $results,
        format         => 'html',
        template_class => __PACKAGE__,
        layout         => 'wrapper'
    );
}

1;
__DATA__

@@ search.html.ep
% stash template_class => 'main', title => 'Search';
<div style="text-align:center;padding:2em">
<form method="get">
<input type="text" name="q" value="<%= param('q') || '' %>" />
<input type="submit" value="Search" />
% if ($error) {
<div style="color:red"><%= $error %></div>
% }
</form>
</div>
% if (!$error && param('q')) {
<h1>Search results: <%== @$articles %></h1>
<br />
% }
% foreach my $article (@$articles) {
<div class="text">
    <a href="<%= url article => $article %>"><%== $article->{title} %></a><br />
    <div class="created"><%= date $article->{created} %></div>
%   foreach my $part (@{$article->{parts}}) {
    <span style="font-size:small"><%== $part %></span> ...
%   }
</div>
% }

__END__

=head1 NAME

Bootylicious::Plugin::Search - search plugin for bootylicious

=head1 SYNOPSIS

    # In your bootylicious.conf

    "plugins" : [
        "search"
    ]

    # or with configuration

    "plugins" : [
        "search", {"min_length" : 3}
    ]

=head1 DESCRIPTION

Plugins adds C</search/> path to your L<bootylicious> blog. The simple full
text search is done through all the articles.

=head1 ATTRIBUTES

=head2 C<before_context>

    How many symbols are shown before the matched string.

=head2 C<after_context>

    How many symbols are shown after the matched string.

=head2 C<min_length>

    Minimum length search string.

=head2 C<max_length>

    Maximum length search string.

=head1 METHODS

=head2 C<hook_init>

    Plugin is run just after L<bootylicious> routes initialization.

=head1 SEE ALSO

    L<bootylicious>, L<Mojo>, L<Mojolicious>

=head1 AUTHOR

Viacheslav Tykhanovskyi, C<vti@cpan.org>.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009, Viacheslav Tykhanovskyi.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut

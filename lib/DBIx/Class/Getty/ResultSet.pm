package DBIx::Class::Getty::ResultSet;
# ABSTRACT: Base ResultSet class

use Moo;
extends 'DBIx::Class::ResultSet';

sub BUILDARGS { $_[2] }

__PACKAGE__->load_components(qw(
  Helper::ResultSet::Me
  Helper::ResultSet::OneRow
  Helper::ResultSet::Shortcut::Limit
  Helper::ResultSet::Shortcut::OrderBy
  Helper::ResultSet::Shortcut::Prefetch
  Helper::ResultSet::CorrelateRelationship
));

sub schema { shift->result_source->schema }
sub rs { shift->resultset(@_) }

sub ids {
  my ( $self ) = @_;
  map { $_->id } $self->search_rs(undef,{
    columns => [qw( id )],
  })->all;
}

sub paging {
  my ( $self, $page, $rows ) = @_;
  return $self->search_rs(undef, {
    page => $page,
  })->limit($rows);
}

1;

package DBIx::Class::Getty::Result;
# ABSTRACT: Base Result class

use Moo;
extends 'DBIx::Class::Core';

use DateTime;
use DateTime::TimeZone;
use Digest::MD5 qw( md5_hex );

sub random_key {
  my ( $self ) = @_;
  return md5_hex(sprintf('%09d',rand(900_000_000)).sprintf('%09d',rand(900_000_000)).sprintf('%09d',rand(900_000_000)).sprintf('%09d',rand(900_000_000)).sprintf('%09d',rand(900_000_000)).$$);
}

sub add_notes_data_created_updated {
  my ( $class ) = @_;
  $class->add_notes;
  $class->add_data_created_updated;
}

sub add_data_created_updated {
  my ( $class ) = @_;
  $class->add_column(data => {
    data_type => $class->schema_config->{default_serialized_data_type},
    is_nullable => 1,
    serializer_class => $class->schema_config->{default_serializer_class},
  });
  $class->add_hash_accessor( d => 'data' );
  $class->add_created_updated;
}

sub add_created_updated {
  my ( $class ) = @_;
  $class->add_created;
  $class->add_column(updated => {
    data_type => $class->schema_config->{default_datetime_data_type},
    set_on_create => 1,
    set_on_update => 1,
  });
}

sub add_notes {
  my ( $class ) = @_;
  $class->add_column(notes => {
    data_type => $class->schema_config->{default_text_data_type},
    is_nullable => 1,
  });
}

sub add_notes_created_updated {
  my ( $class ) = @_;
  $class->add_notes;
  $class->add_created_updated;
}

sub add_created {
  my ( $class ) = @_;
  $class->add_column(created => {
    data_type => $class->schema_config->{default_datetime_data_type},
    set_on_create => 1,
  });
}

sub add_meta_tags {
  my ( $class ) = @_;
  $class->add_column(meta_description => {
    data_type => $class->schema_config->{default_text_data_type},
    is_nullable => 1,
  });
  $class->add_column(meta_title => {
    data_type => $class->schema_config->{default_text_data_type},
    is_nullable => 1,
  });
}

sub get_timestamp {
  my ( $self ) = @_;
  my $timezone_offset = DateTime::TimeZone->new( name => $self->schema_config->{time_zone} )->offset_for_datetime(DateTime->now);
  return \"UTC_TIMESTAMP() + INTERVAL $timezone_offset SECOND";
}

sub schema { shift->result_source->schema }

sub belongs_to {
  my ( $self, @args ) = @_;

  $args[3] = {
    is_foreign => 1,
    on_update => 'cascade',
    on_delete => 'cascade',
    %{$args[3]||{}}
  };

  $self->next::method(@args);
}

sub has_many {
  my ( $self, @args ) = @_;

  $args[3] = {
    cascade_delete => 0,
    %{$args[3]||{}}
  };

  $self->next::method(@args);
}

sub indices {
  my ( $class, @args ) = @_;
  $class->next::method(@args) unless $ENV{DBIC_GETTY_NO_INDICES};
}

around update => sub {
  my $orig = shift;
  my $self = shift;
  if ($_[0]) {
    my %changes = %{+shift};
    for my $k (keys %changes) {
      $self->set_column($k, $changes{$k});
    }
  }
  return $self->_execute_changed($orig);
};

around insert => sub {
  my $orig = shift;
  my $self = shift;
  return $self->_execute_changed($orig, @_);
};

sub _execute_changed {
  my ( $self, $orig, @args ) = @_;
  $self->before_execute_change if $self->can('before_execute_change');
  if ($self->can('notes')) {
    $self->notes("") unless defined $self->notes;    
  }
  my @return = $self->$orig(@args);
  $self->after_execute_change if $self->can('after_execute_change');
  return @return;
}

use overload '""' => sub {
  my $self = shift;
  return (ref $self).( $self->id ? ' #'.$self->id : ' new' );
}, fallback => 1;

1;

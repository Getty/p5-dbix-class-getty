package DBIx::Class::Getty;
# ABSTRACT: Gettys custom DBIx::Class setup

use strict;
use warnings;

use Import::Into;
use Package::Stash;
use Moo ();
use DBIx::Class::Candy ();
use Module::Runtime qw( use_module );

my %loaded_schemas;

sub import {
  my ( $class, %config ) = @_;
  my $target = caller;
  my $schema;
  for my $loaded_schema (keys %loaded_schemas) {
    my $q_loaded_schema = quotemeta($loaded_schema);
    if ($target =~ m/^$q_loaded_schema/) {
      $schema = $loaded_schema;
      last;
    }
  }
  if ($schema) {
    my %schema_config = %{$loaded_schemas{$schema}};
    $config{schema} = $schema;
    $config{_} = { %schema_config };
    my $inner_class = substr($target, length($schema)+2);
    my $result_namespace = ( $schema_config{result_namespace} || 'Result' );
    my $resultset_namespace = ( $schema_config{resultset_namespace} || 'ResultSet' );
    if ($inner_class =~ m/^${result_namespace}::(.+)$/) {
      $config{result_class} = $1;
      DBIx::Class::Getty::import_result($class,$target,%config);
    } elsif ($inner_class =~ m/^${resultset_namespace}::(.+)$/) {
      $config{resultset_class} = $1;
      DBIx::Class::Getty::import_resultset($class,$target,%config);
    }
  } else {
    DBIx::Class::Getty::import_schema($class,$target,%config);
  }
}

sub import_result {
  my ( $class, $target, %config ) = @_;
  my $no_id = delete $config{no_id};
  my $table = delete $config{table};
  my $ps = Package::Stash->new($target);
  $ps->add_symbol('&schema_config',sub { $loaded_schemas{$config{schema}} });
  Moo->import::into($target);
  $target->can('extends')->($config{_}->{base_result_class});
  DBIx::Class::Candy->import::into($target);
}

sub import_resultset {
  my ( $class, $target, %config ) = @_;
  my $ps = Package::Stash->new($target);
  $ps->add_symbol('&schema_config',sub { $loaded_schemas{$config{schema}} });
  Moo->import::into($target);
  my $default_resultset_class = $config{_}->{default_resultset_class};
  if (substr($default_resultset_class,0,1) eq '+') {
    $default_resultset_class =~ s/^\+//;
  } else {
    $default_resultset_class = $config{schema}.'::'.$default_resultset_class;
  }
  $target->can('extends')->($default_resultset_class);
}

sub import_schema {
  my ( $class, $target, %config ) = @_;
  my $ps = Package::Stash->new($target);
  Moo->import::into($target);
  my $dbic_schema_class = $config{dbic_schema_class} || 'DBIx::Class::Schema';
  $target->can('extends')->($dbic_schema_class);
  $config{default_resultset_class} = '+DBIx::Class::Getty::ResultSet' unless $config{default_resultset_class};
  $config{base_result_class} = 'DBIx::Class::Getty::Result' unless $config{base_result_class};
  $config{time_zone} = 'UTC' unless $config{time_zone};
  $config{default_serializer_class} = 'JSON' unless $config{default_serializer_class};
  $config{default_serialized_data_type} = 'text' unless $config{default_serialized_data_type};
  $config{default_datetime_data_type} = 'timestamp with time zone' unless $config{default_datetime_data_type};
  $config{default_text_data_type} = 'text' unless $config{default_text_data_type};
  $config{table_name_generator} = sub {

  } unless $config{table_name_generator};
  $loaded_schemas{$target} = { %config };
  $ps->add_symbol('&schema_config',sub { $loaded_schemas{$target} });
  $target->load_namespaces(
    default_resultset_class => $config{default_resultset_class},
    result_namespace => ( $config{result_namespace} || 'Result' ),
    resultset_namespace => ( $config{resultset_namespace} || 'ResultSet' ),
  );
  $target->load_components(qw(
    Getty::Schema
  ));
}

1;

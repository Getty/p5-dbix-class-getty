
requires 'DBIx::Class', '0.082840';
requires 'DBIx::Class::Candy', '0';
requires 'DBIx::Class::Cursor::Cached', '0';
requires 'DBIx::Class::EncodedColumn', '0.00012';
requires 'DBIx::Class::HashAccessor', '0';
requires 'DBIx::Class::Helpers', '0';
requires 'DBIx::Class::InflateColumn::Serializer', '0';
requires 'DBIx::Class::TimeStamp', '0';
requires 'DBICx::Indexing', '0';
requires 'Import::Into', '0';

on test => sub {
  requires 'DBD::SQLite', '0';
  requires 'DBIx::Class::InflateColumn::Serializer::JSON', '0.09';
  requires 'SQL::Translator', '0.11018';
  requires 'Test::More', '0.96';
};

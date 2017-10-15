package TestSchema::Result::Data;

use DBIx::Class::Getty;

table 'data';

primary_column id => {
  data_type => "integer",
  is_nullable => 0,
  is_auto_increment => 1,
};

column name => {
  data_type => "text",
  is_nullable => 0,
};

__PACKAGE__->add_notes_data_created_updated;

1;

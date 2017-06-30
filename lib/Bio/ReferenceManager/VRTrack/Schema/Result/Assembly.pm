package Bio::ReferenceManager::VRTrack::Schema::Result::Assembly;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('assembly');
__PACKAGE__->add_columns(
  "assembly_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "reference_size",
  { data_type => "bigint", is_nullable => 1 },
  "taxon_id",
  {
    data_type => "mediumint",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "translation_table",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 1 },
);
__PACKAGE__->set_primary_key('assembly_id');

1;




#!/usr/bin/env perl
use strict;
use warnings;

use lib 't/lib';
use Test::More;

use_ok('TestSchema','Loading TestSchema');

my $schema = TestSchema->deploy_or_connect();

isa_ok($schema,'TestSchema');
isa_ok($schema->resultset('Data'),'DBIx::Class::Getty::ResultSet');
isa_ok($schema->resultset('Data')->new_result({}),'TestSchema::Result::Data');

done_testing;

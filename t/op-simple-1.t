use strict;
use Dcel;
use Test::Simple tests => 5;

my $dcel = Dcel->new();

ok($dcel, 'expect $dcel is object');

my $triangle_edge = $dcel->create_triangle;


ok($dcel->vertex_count == 3,
    sprintf('expected vertex count 3 but %d',
        $dcel->vertex_count));

ok($dcel->edge_count == 3,
    sprintf('expected edge count 3 but %d',
        $dcel->edge_count));

ok($dcel->face_count == 2,
    sprintf('expected face count 2 but %d',
        $dcel->face_count));


my $actual = $dcel->eular_characteristic; 

ok($actual == 2,
    sprintf('expected eular characteristic 2 but %d', $actual));

# vi: se ts=4 sw=4 et:

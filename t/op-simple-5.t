use strict;
use Dcel;
use Dcel::Operation;
use Test::Simple tests => 9;

my $dcel = Dcel->new();

my $triangle_edge = $dcel->create_triangle;

my $res;
my $last_point_edge = $triangle_edge->prev->prev;

$triangle_edge->twin->face->set_data(1);
$triangle_edge->face->set_data(2);


$res = $dcel->split_vertex(
    e1 => $last_point_edge,
    e2 => $last_point_edge->next->twin);

{
    my $tmp_idx = 1;
    Dcel::Operation->each_edge_next($triangle_edge, sub {
        $_[0]->set_data($tmp_idx);
        $_[0]->origin->set_data($tmp_idx++);
        0;
    });
}

$res = $dcel->split_face(
    e1 => $triangle_edge->next,
    e2 => $triangle_edge->prev);


ok(!defined($triangle_edge->face->data),
    'expect triangle edge has new face');


my $new_edge = $triangle_edge->next->next;

$new_edge->set_data(5);

ok($res, 'expected succeed to split face');


ok($dcel->face_count == 3, 'expected face count is 3');


ok($dcel->eular_characteristic == 2,
    'expected eular characteristic is 2');

$triangle_edge->face->set_data(3);

{
    $res = 1; 
    Dcel::Operation->each_edge_next($new_edge, sub {
        $res = $_[0]->face->data == 3;
        
        $res ? 0 : -1;
    });
    ok($res, 'expected new face has number 3'); 
}

{
    $res = 1; 
    Dcel::Operation->each_edge_next($new_edge->twin, sub {
        $res = $_[0]->face->data == 2;
        
        $res ? 0 : -1;
    });

    ok($res, 'expected splited face has number 2'); 
}

ok($dcel->edge_count == 5, sprintf('expected edge count is 5, but %d',
    $dcel->edge_count));

{
    my @indices;
    Dcel::Operation->each_edge_next($new_edge, sub {
        push @indices, $_[0]->data;
        
        $res ? 0 : -1;
    });
    my @expected = (5, 1, 2);
    while (my ($idx, $number) = each @indices) {
        
        $res = $expected[$idx] == $number;
        last if !$res;
    }
    ok($res, sprintf('expected edge numbers are (%s), but (%s)',
        join(',', @expected), join(',', @indices)));
}
{
    my @indices;
    Dcel::Operation->each_edge_next($new_edge->twin, sub {
        push @indices, $_[0]->data;
        
        $res ? 0 : -1;
    });
    my @expected = (5, 3, 4);
    while (my ($idx, $number) = each @indices) {
        
        $res = $expected[$idx] == $number;
        last if !$res;
    }
    ok($res, sprintf('expected edge numbers are (%s), but (%s)',
        join(',', @expected), join(',', @indices)));
}



# vi: se ts=4 sw=4 et:

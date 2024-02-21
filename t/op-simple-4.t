use strict;
use Dcel;
use Dcel::Operation;
use Test::Simple tests => 3;

my $dcel = Dcel->new();

my $triangle_edge = $dcel->create_triangle;

my $res;
my $last_point_edge = $triangle_edge->prev->prev;

$res = $dcel->split_vertex(
    e1 => $last_point_edge,
    e2 => $last_point_edge->next->twin);

{
    my $tmp_idx = 1;
    Dcel::Operation->each_edge_next($triangle_edge, sub {
        $_[0]->origin->set_data($tmp_idx++);
        0;
    });
}


$res = $dcel->join_vertices(
    $triangle_edge->next);


ok($res, 'expected succeeded to join vertices');

{
    my @indices;
    Dcel::Operation->each_edge_next($triangle_edge, sub {
        push @indices, $_[0]->origin->data;
        0;
    });
    my @expected = (1, 2, 4);

    while (my ($idx, $number) = each @indices) {
        $res = $expected[$idx] == $number;
        last if !$res;
    }
    
    ok($res, sprintf('expected vertice numbers are (%s), but (%s).',
        join(',', @expected), join(',', @indices)));
}

ok($dcel->eular_characteristic == 2,
    'expected eular characteristic is 2');


# vi: se ts=4 sw=4 et:

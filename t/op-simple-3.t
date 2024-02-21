use strict;
use Dcel;
use Dcel::Operation;
use Test::Simple tests => 10;

my $dcel = Dcel->new();

my $triangle_edge = $dcel->create_triangle;

{
    my $tmp_idx = 1;
    Dcel::Operation->each_edge_next($triangle_edge, sub {
        $_[0]->origin->set_data($tmp_idx++);
        0;
    });
}

my $res;
my $last_point_edge = $triangle_edge->prev->prev;

ok ($last_point_edge->origin->data == 2, 
    sprintf('We expected last point edge origin is 2, but %d', 
        $last_point_edge->origin->data));
$res = $dcel->split_vertex(
    e1 => $last_point_edge,
    e2 => $last_point_edge->next->twin);

ok ($res, 'We expect split vertex operation is succeeded.');

my $new_data = $last_point_edge->next->origin->data;

ok ($new_data == 3,
    sprintf('We expected new edge data is 3 but %d.', $new_data));

$new_data = $last_point_edge->next->twin->origin->data;

ok (!defined($new_data),
    sprintf('We expected new edge data is undefined but %d.', $new_data));

$last_point_edge->next->twin->origin->set_data(4);

{
    my @indices;
    Dcel::Operation->each_edge_next($triangle_edge, sub {
        push @indices, $_[0]->origin->data;
        0;
    });

    my @expected = (1, 2, 3, 4);
    my $res = 1;
    while (my ($idx, $number) = each @indices) {
        $res = $expected[$idx] == $number;
        last if !$res;
    }
    ok ($res, sprintf('Expected vetex number are = (%s), but (%s)',
        join(',', @expected), join(',', @indices)));
}

{
    my @indices;
    Dcel::Operation->each_edge_next($triangle_edge->twin, sub {
        push @indices, $_[0]->origin->data;
        0;
    });

    my @expected = (2, 1, 4, 3);
    my $res = 1;
    while (my ($idx, $number) = each @indices) {
        $res = $expected[$idx] == $number;
        last if !$res;
    }
    ok ($res, sprintf('Expected vetex number are = (%s), but (%s)',
        join(',', @expected), join(',', @indices)));
}


{
    my $a_face = $triangle_edge->face;
    my $res = 1;    
    Dcel::Operation->each_edge_next($triangle_edge, sub {
        $res = $_[0]->face == $a_face;
        $res ? 0 : -1;
    });

    ok ($res, 'Expected each edges share same face');
}    
{
    my $a_face = $triangle_edge->twin->face;
    my $res = 1;    
    Dcel::Operation->each_edge_next($triangle_edge->twin, sub {
        $res = $_[0]->face == $a_face;
        $res ? 0 : -1;
    });

    ok ($res, 'Expected each edges share same face');
}
{
    ok ($triangle_edge->face != $triangle_edge->twin->face
        && $triangle_edge->face && $triangle_edge->twin->face,
        'Expected edge has different face from edge twin');
}

ok ($dcel->eular_characteristic == 2, 
    sprintf('Expected eular characteristic is 2 but &d',
        $dcel->eular_characteristic));




# vi: se ts=4 sw=4 et:

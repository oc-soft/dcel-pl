use strict;
use Dcel;
use Dcel::Operation;
use Test::Simple tests => 34;

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


sub check_loop {
    my ($edge, @expected) = @_;
    my @indices;
    Dcel::Operation->each_edge_next(
        $edge, sub {
            push @indices, $_[0]->data;
            0;
        });
    my $res = 1;
    while (my ($idx, $number) = each @indices) {
        $res = $expected[$idx] == $number; 
        last if !$res;
    } 
    ok($res, sprintf('expected edge loop is (%s), actual loop (%s).',
        join(',', @expected),
        join(',', @indices)));
    $res;
}

sub check_loop_reverse {
    my ($edge, @expected) = @_;
    my @indices;
    Dcel::Operation->each_edge_prev(
        $edge, sub {
            push @indices, $_[0]->data;
            0;
        });
    my $res = 1;
    while (my ($idx, $number) = each @indices) {
        $res = $expected[$idx] == $number; 
        last if !$res;
    } 
    ok($res, sprintf('expected edge loop is (%s), actual loop is (%s).',
        join(',', @expected),
        join(',', @indices)));
    $res;
}


check_loop($triangle_edge, 1, 2, 3, 4);
check_loop_reverse($triangle_edge, 1, 4, 3, 2);

check_loop($triangle_edge->twin, 1, 4, 3, 2);
check_loop_reverse($triangle_edge->twin, 1, 2, 3, 4);

$res = $dcel->split_face(
    e1 => $triangle_edge->next,
    e2 => $triangle_edge->prev);

ok(!defined($triangle_edge->next->next->data),
    'expected new edge dose not have number.');


$triangle_edge->next->next->set_data(5);
$triangle_edge->face->set_data(3);


check_loop($triangle_edge, 1, 2, 5);
check_loop_reverse($triangle_edge, 1, 5, 2);

check_loop($triangle_edge->twin, 1, 4, 3, 2);
check_loop_reverse($triangle_edge->twin, 1, 2, 3, 4);


ok($triangle_edge->twin->face->data == 1,
    'expected triangle twin face has number 1');

$res = $dcel->split_face(
    e1 => $triangle_edge->twin,
    e2 => $triangle_edge->twin->next->next);

ok($res,
    'expected succeeded to split face operation');

ok(!defined($triangle_edge->twin->face->data),
    'expected triangle edge twin has new face');
$triangle_edge->twin->face->set_data(4);

ok(!defined($triangle_edge->twin->next->data),
    'expected triangle edge twin next is new edge');

$triangle_edge->twin->next->set_data(6);

check_loop($triangle_edge->twin, 1, 6, 2);
check_loop_reverse($triangle_edge->twin, 1, 2, 6);


$res = $dcel->split_vertex(
    e1 => $triangle_edge->twin,
    e2 => $triangle_edge->twin->next->twin);

ok($res, 'expected succeeded to split vertex operation');


my $new_edge = $triangle_edge->twin->next;

ok(!defined($new_edge->data),
    'expected triangle edge twin next is new edge');


ok(!defined($new_edge->next->origin->data),
    'expected triangle edge twin next is new edge');

$new_edge->twin->set_data(5);
$new_edge->set_data(7);


ok($new_edge->face->data == 4,
    'expected new edge has the face having number 4');

ok($new_edge->twin->face->data == 1,
    'exptected new edge twin has the face having number 1');

check_loop($triangle_edge->twin, 1, 7, 6, 2);
check_loop_reverse($triangle_edge->twin, 1, 2, 6, 7);

$dcel->split_face(
    e1 => $triangle_edge->twin->prev,
    e2 => $triangle_edge->twin->next);



$new_edge = $triangle_edge->twin->next->next;

ok(!defined($new_edge->data),
    'expected edge twin prev next is new edge');

$new_edge->set_data(8);


check_loop($triangle_edge->twin, 1, 7, 8);
check_loop_reverse($triangle_edge->twin, 1, 8, 7);

check_loop($new_edge->twin, 8, 6, 2);
check_loop_reverse($new_edge->twin, 8, 2, 6);


ok(!defined($new_edge->twin->face->data),
    'expected edge twin prev next has new face');

$new_edge->twin->face->set_data(5);

my $prev_edge = $triangle_edge->prev;
my $next_edge = $triangle_edge->twin->next;

ok($prev_edge->face->data == 3,
    'expected the face number 3 will be removed');

ok($next_edge->face->data == 4,
    'expected the face number 4 will ocupy merged region');

$dcel->join_faces($triangle_edge);


ok($prev_edge->face->data == 4,
    'expected previous edge has face 4');

ok($next_edge->face->data == 4,
    'expected next edge has also face 4');


ok($prev_edge->next == $next_edge,
    'expected revious edge next is next edge');

ok($dcel->eular_characteristic == 2,
    'expected eular characteristic is 2');


# vi: se ts=4 sw=4 et:

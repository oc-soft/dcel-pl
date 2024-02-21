use strict;
use Dcel;
use Dcel::Operation;
use Test::Simple tests => 2;

my $dcel = Dcel->new();


my $triangle_edge = $dcel->create_triangle;


{
    my $tmp_idx = 1;
    Dcel::Operation->each_edge_next($triangle_edge, sub {
        $_[0]->origin->set_data($tmp_idx++);
        0;
    });
}

my @indices;
{
    Dcel::Operation->each_edge_next($triangle_edge, sub {
        push @indices, $_[0]->origin->data;
        0;
    });
}
{
    my @expected = (1, 2, 3);

    my $res = 1;
    while (my ($idx, $actual) = each @indices) {
        $res = $expected[$idx] == $actual;
        last if !$res;
    }
    ok($res, sprintf('expected (%s) but (%s)',
        join(',', @expected), join(',', @indices)));
}
@indices = ();
{
    Dcel::Operation->each_edge_next($triangle_edge->twin, sub {
        push @indices, $_[0]->origin->data;
        0;
    });
}
{
    my @expected = (2, 1, 3);

    my $res = 1;
    while (my ($idx, $actual) = each @indices) {
        $res = $expected[$idx] == $actual;
        last if !$res;
    }
    ok($res, sprintf('expected (%s) but (%s)',
        join(',', @expected), join(',', @indices)));
}



# vi: se ts=4 sw=4 et:

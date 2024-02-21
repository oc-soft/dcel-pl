package Dcel::Operation;
use strict;

use Exporter 'import';



sub connect_edge {
    my @edges = splice(@_, 0, 2);
     
    $edges[0]->_set_next($edges[1]);

}

# set new origin to all edges whiche are sharing origin
sub set_origin {
    my ($class, $edge, $vertex) = @_;
    _each_edge_around_origin($edge, sub {
        $_[0]->_set_origin($vertex); 
        0;
    });
    $vertex->_set_edge($edge);
}

# It set a face to edge. it set a face to all linked edges.
sub set_face {
    my ($self, $edge, $face) = @_;

    _each_edge_next($edge, sub {
        $_[0]->_set_face($face);
        0;
    });
    $face->_set_edge($edge); 
}

# iterate edge forward
sub each_edge_next {
    my ($class, $edge, $action) = @_;
    _each_edge_next($edge, $action);
}

# iterate edge backward
sub each_edge_prev {
    my ($class, $edge, $action) = @_;
    _each_edge_prev($edge, $action);
}

# iterate each edges around origin
sub each_edge_around_origin {

    my ($class, $edge, $action) = @_;
    _each_edge_around_origin($edge, $action);
}


# iterate edge forward
sub _each_edge_next {
    my ($edge, $action) = @_;

    my $current_edge = $edge;

    my $res = 0;

    while (1) {
        $res = $action->($current_edge);
        last if $res; 
        $current_edge = $current_edge->next;
        last if $current_edge == $edge; 
    }
    $res;
}

# iterate edge backward
sub _each_edge_prev {
    my ($edge, $action) = @_;

    my $current_edge = $edge;

    my $res = 0;

    while (1) {
        $res = $action->($current_edge);
        last if $res; 
        $current_edge = $current_edge->prev;
        last if $current_edge == $edge; 
    }
    $res;
}


# each 
sub _each_edge_around_origin {

    my ($edge, $action) = @_;

    my $current_edge = $edge;
    my $res = 0;
    while (1) {
        $res = $action->($current_edge); 
        last if $res; 
        $current_edge = $current_edge->twin->next;
        last if $current_edge == $edge;
    }
    $res;
}

1;
__END__

=head1 Dcel::Operation

operation for Dobly connect edge list elements.


=head2 set_face

It set a face to edge. it set a face to all linked edges.

 # create face
 my $face = Dcel::Face->new();
 # create edge
 my $edge = Dcel::Edge->new();
 # set face
 Dcel::Operation->set_face($edge, $face);



# vi: se ts=4 sw=4 et:

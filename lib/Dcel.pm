package Dcel;
use strict;
use feature 'isa';
use Dcel::Edge;
use Dcel::Operation;
use Scalar::Util 'refaddr';

our $VERSION = '1.0';

# create create doubly connected linked list
sub new {
    my $class = shift;
    
    my $res = bless {}, $class;
	
    $res->{vertices} = {};
    $res->{faces} = {};
    $res->{edges} = {};
    $res;
}

# get edge count
sub edge_count {
    my $self = shift;

    scalar(keys(%{$self->{edges}})) / 2;
}

# get face count
sub face_count {
    my $self = shift;
    scalar(keys(%{$self->{faces}}));
}

# get vertex count
sub vertex_count {
    my $self = shift;
    scalar(keys(%{$self->{vertices}}));
}

# get eular characteristic
sub eular_characteristic {
    my $self = shift;
    $self->vertex_count - $self->edge_count + $self->face_count;
}

# split face
sub split_face {
    my ($self, %args) = @_;

    my @edges = ($args{e1}, $args{e2});
   
    my $res = 1;
    for (@edges) {
        $res = $_ ? 1 : 0;
        last if !$res;
    }
    if ($res) {
        $res = $edges[0]->face == $edges[1]->face;
    }
    if ($res) {
        $res = $edges[0]->next != $edges[1]
            && $edges[1]->next != $edges[0];
    } 
    if ($res) {
        $self->_split_face(\@edges);
    }
    $res; 
}

# split vertex
sub split_vertex {
    my ($self, %args) = @_;

    my @edges = ($args{e1}, $args{e2});

    my $res = 1;
    for (@edges) {
        $res = $_ ? 1 : 0;
        last if !$res;
    }
    if ($res) {
        $res = $edges[0] != $edges[1];
    } 
    if ($res) {
        $res = $edges[0]->next->origin == $edges[1]->next->origin;
    }
    if ($res) {
        $self->_split_vertex(\@edges);
    }
    
    $res;     
}

# join face
sub join_faces {
    my ($self, $edge) = @_;
    my $res = 1;

    $edge->next->_set_prev($edge->twin->prev);
    $edge->prev->_set_next($edge->twin->next); 

    $edge->twin->next->_set_prev($edge->prev);
    $edge->twin->prev->_set_next($edge->next);

    Dcel::Operation->set_face($edge->prev, $edge->twin->face); 
    
    $self->_unregister_face($edge->face);
    $self->_unregister_edge($edge);
    $self->_unregister_edge($edge->twin);
    $edge->_tear_down;
    $res;
}

# join vertices
sub join_vertices
{
    my ($self, $edge) = @_;

    my $edge_count = 0;
    Dcel::Operation->each_edge_next($edge, sub {
        $edge_count++;
        0;
    }); 
    my $res = $edge_count > 3;
    if ($res) {
        $edge_count = 0;
        Dcel::Operation->each_edge_prev($edge->twin, sub {
            $edge_count++;
            0;
        }); 
        $res = $edge_count > 3;
    }

    if ($res) {
 
        $edge->next->_set_prev($edge->prev);
        $edge->prev->_set_next($edge->next);

        $edge->twin->next->_set_prev($edge->twin->prev);
        $edge->twin->prev->_set_next($edge->twin->next);

        my $removed_vertex = $edge->twin->origin;

        Dcel::Operation->set_origin($edge->next, $edge->origin);
        
        $self->_unregister_vertex($removed_vertex);
        $self->_unregister_edge($edge);
        $self->_unregister_edge($edge->twin);
         
        $edge->_tear_down;
    }
    
    $res;
}


# split face
sub _split_face {
    my ($self, $edges) = @_;

    my $new_edge = Dcel::Edge->new;

    $new_edge->_set_next($edges->[1]->next);
    $new_edge->_set_prev($edges->[0]);

    $new_edge->twin->_set_next($edges->[0]->next);
    $new_edge->twin->_set_prev($edges->[1]);

    $edges->[1]->next->_set_prev($new_edge);
    $edges->[0]->next->_set_prev($new_edge->twin);

    $edges->[0]->_set_next($new_edge);
    $edges->[1]->_set_next($new_edge->twin);

    $new_edge->_set_origin($new_edge->twin->next->origin);
    $new_edge->twin->_set_origin($new_edge->next->origin);

    Dcel::Operation->set_face($new_edge->twin,
        $new_edge->twin->prev->face); 
    Dcel::Operation->set_face($new_edge,
        $new_edge->face);

    $self->_register_face($new_edge->face); 
    $self->_register_edge($new_edge); 
    $self->_register_edge($new_edge->twin); 
      
}

# split vertex
sub _split_vertex {

    my ($self, $edges) = @_;

    my $new_edge = Dcel::Edge->new;
    
    $new_edge->_set_next($edges->[0]->next);
    $new_edge->_set_prev($edges->[0]);
    $edges->[0]->next->_set_prev($new_edge);
    $edges->[0]->_set_next($new_edge);

    $new_edge->twin->_set_next($edges->[1]->next);
    $new_edge->twin->_set_prev($edges->[1]);
    $edges->[1]->next->_set_prev($new_edge->twin);
    $edges->[1]->_set_next($new_edge->twin);

    $new_edge->_set_face($edges->[0]->face);
    $new_edge->twin->_set_face($edges->[1]->face);

    # let call new vert edges which have splited new vertex.
    # Following two operations argument seems to do nothing. but new vert
    # edges have new origin. 

    # new edge origin is deleted and has next origin which is source
    # vertex
    Dcel::Operation->set_origin($new_edge, $new_edge->prev->twin->origin);
    # Then, new vert edges have new edge twin origin.
    Dcel::Operation->set_origin($new_edge->twin, $new_edge->twin->origin);

    $self->_register_edge($new_edge);
    $self->_register_edge($new_edge->twin);
    $self->_register_vertex($new_edge->twin->origin);
}


# create triangle
sub create_triangle {

    my $self = shift;

    my @edges = (
        Dcel::Edge->new,
        Dcel::Edge->new,
        Dcel::Edge->new
    );

    while (my ($idx, $edge) = each @edges) { 
        $edge->_set_next($edges[($idx + 1) % scalar(@edges)]); 
        $edge->_set_prev($edges[($idx - 1) % scalar(@edges)]);
    }

    my @twins;
    for (@edges) {
        push @twins, $_->twin;
    }
    while (my ($idx, $edge) = each @twins) { 
        $edge->_set_next($twins[($idx - 1) % scalar(@twins)]); 
        $edge->_set_prev($twins[($idx + 1) % scalar(@twins)]);
    }

    for (@edges) {
        Dcel::Operation->set_origin($_->twin, $_->next->origin); 
    }
    Dcel::Operation->set_face($edges[0], $edges[0]->face);
    Dcel::Operation->set_face($twins[-1], $twins[-1]->face);

    for (@edges) {
        $self->_register_edge($_);
        $self->_register_edge($_->twin);
        $self->_register_vertex($_->origin);
        $self->_register_vertex($_->twin->origin);
    }
    $self->_register_face($edges[0]->face); 
    $self->_register_face($twins[-1]->face);
    $edges[0];
}




# register edge
sub _register_edge {
    my ($self, $edge) = @_;

    $self->{edges}{refaddr($edge)} = $edge;
}

# unregsiter edge
sub _unregister_edge {
    my ($self, $edge) = @_;

    undef $self->{edges}{refaddr($edge)};
}


# register face
sub _register_face {
    my ($self, $face) = @_;

    $self->{faces}{refaddr($face)} = $face;
}

# unregister face
sub _unregister_face {
    my ($self, $face) = @_;

    undef $self->{faces}{refaddr($face)};
}

# register vertex 
sub _register_vertex {
    my ($self, $vertex) = @_;

    $self->{vertices}{refaddr($vertex)} = $vertex;
}

# unregister vertex 
sub _unregister_vertex {
    my ($self, $vertex) = @_;

    undef $self->{vertices}{refaddr($vertex)};
}

1;
__END__

=pod

=head1 DCEL - Doubly connected edge list

This library manage connected simple planar graph.

To make eular characteristics is eqauls 2, You have to start hava three edges
triangle graph.

triangle graph property.  

=over

=item 1 It has 3 edges.

=item 2 It has 2 faces.

=item 3 It has 3 vertices

=back

eular euqage x = v - e + f = 3

=head2 new

create doubly edged linked list

 my $dcel = Decl->new;
 my $triangle_edge = $decel->create_triangle;
 my $twin = $triangle_edge->twin;

=head2 create_triangle 

create triangle

 my $triagle = $dcel->create_triangle;

=head2 face_count

get count of faces which belong to dcel object

 my $face_count = $dcel->face_count;


=head2 vertex_count

get count of vertices which belog to dcel object

 my $vert_count = $dcel->vertex_count;


=head2 eular_characteristic

get eular characteristic.

Eular characteristic is calculated by followings.
vertices count: c(v)
edges count: c(e)
faces count: c(f)

Eular characteristics: c(v) - c(e) + c(f)

 my $ec1 = $decl->vertex_count - $decl->edge_count + $dcel->face_count;
 my $res = $ec1 == $decl->eular_characteristic;
 # we will always get true from $res
  

=head2 split_face

split a face into two faces.

 my $succeeded = $dcel->split_face(e1 => $edge1, $e2 => $edge2);
 if ($succeeded) {
    # you get new face and edge from $edge1
    my $new_face = $edge1->face;
    my $new_ege = $edge1->next;
 }

=head2 join_faces

join two faces into a face

 # you will not get the face of edge if you do join_faces operation.
 my $old_face = $edge->face;
 my $the_face = $edge->twin->face;

 my $succeeded = $dcel->join_facefaces($edge);
 if ($succeeded) {
    my $is_same_face = $the_face == $edge->face;
    # $is_same_face is 1
 }


You will understand this operation clearly, if you see operation 
diagrams(split-face.svg, join-face.svg).

=begin html

<div class="split-join-opetation">
  <img src="split-face.svg" />
  <img src="join-face.svg" />
</div>

=end html


=head2 split_vertex

split a vertex into two vertices
prerequisite

=over

=item 1 edge1 and edge2 share same origin.

=item 2 edge1 and edge2 is not same

=back

 my $next_edge = $edge->next;

 my $succeeded = $dcel->split_vertex(e1 => $edge1, e2 => $edege2);
 
 if ($succeeded) {
     my $new_edge = $edge1->next;
  
     my $same_edge = $next_edge->prev == $new_edge;
     # $same_edge is 1
 }

=head2 join_vertices

join two vertices into a vertex

 my $removed_vertex = $edge->twin->origin;
 my $prev_edge = $edge->prev;
 my $succeeded = $dcel->join_vertices($edge);

 if ($succeeded) {
     my $new_edge = $prev_edge->next;
     my $is_not_same = $new_edge != $edge;  
     # $is_not_same is 1 
 }

You will understand this operation clearly, if you see operation 
diagrams(split-vertex.svg, join-vertices.svg).

=begin html

<div class="split-join-opetation">
  <img src="split-vertex.svg" />
  <img src="join-vertices.svg" />
</div>

=end html

=cut
# vi: se ts=4 sw=4 et:

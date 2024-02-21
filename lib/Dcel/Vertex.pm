package Dcel::Vertex;
use strict;

use Scalar::Util qw(weaken);

# create instance
sub new {
    my $class = shift;

    my $res = bless {}, $class;

    $res;
}

# set edge
sub _set_edge {
    my ($self, $edge) = @_;

    if ($edge) {
        $self->{edge} = weaken $edge;
    } else {
        undef $self->{edge};
    }
}

# get edge
sub edge {
    my $self = shift;
    $self->{edge};
}

# set data 
sub set_data {
    my ($self, $data) = @_;

    if (defined $data) {
        $self->{data} = $data;
    } else {
        delete $self->{data};
    }
}

# get data
sub data {
    my $self = shift;
    $self->{data};
}

1;
__END__

=pod

=head1 Doubly connected edge list (Dcel)

=head2 new

create vertex

 my $vtx = Dcel::Vertex->new();

=head2 set_data

set data
 
 # $vtx is Decl::Vertex
 $vtx->set_data([0, 1]);
 my $coord = $vtx->data;

 printf "(x, y) = (%d, %d)", $coord->[0], $coord[1];


=head2 data

get data
 
 # $vtx is Decl::Vertex
 $vtx->set_data([0, 1]);
 my $coord = $vtx->data;

 printf "(x, y) = (%d, %d)", $coord->[0], $coord[1];

#! vi: se ts=4 sw=4 et:

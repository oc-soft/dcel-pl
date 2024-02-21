package Dcel::Edge;
use strict;
use Scalar::Util;
use Dcel::Vertex;
use Dcel::Face;
use Dcel::Operation;


# forward declarations
sub _create_single_edge;
sub _set_origin;

# constructor
sub new {
    my @twins = (
        _create_single_edge(@_),
        _create_single_edge(@_)
    );

    _connect_twins(@twins);
    Dcel::Operation->set_face($twins[0], Dcel::Face->new());
    Dcel::Operation->set_face($twins[1], Dcel::Face->new());
    $twins[0];
}


# destroy edge
sub _tear_down {
    my $self = shift;
    my @twins = ($self, $self->{twin});
    for (@twins) {
        delete $_->{twin};
        delete $_->{next};
        delete $_->{prev};
        delete $_->{origin};
    }
}


# create single edge
sub _create_single_edge {
    my $class = shift;

    my $res = bless {}, $class;

    my $vertex = Dcel::Vertex->new();
    $vertex->_set_edge($res);

    $res->_set_origin($vertex);
    $res;
}

# connect twins each other
sub _connect_twins
{
    my @twins = ($_[0], $_[1]);

    $twins[0]->{twin} = $twins[1];
    $twins[1]->{twin} = $twins[0];

    $twins[0]->{next} = $twins[0];
    $twins[1]->{next} = $twins[1];

    $twins[0]->{prev} = $twins[0];
    $twins[1]->{prev} = $twins[1];
     
}


# set face
sub _set_face {
    my ($self, $face) = @_;
    $self->{face} = $face;
}

# get face
sub face {
    my $self = shift;
    $self->{face};
}


# get twin
sub twin {
    my $self = shift;
    $self->{twin};
}

# set next
sub _set_next {
    my $self = shift;
    $self->{next} = shift;
}


# get next
sub next {
    my $self = shift;
    $self->{next};
}

# set prev 
sub _set_prev {
    my $self = shift;
    $self->{prev} = shift;
}


# get prev
sub prev {
    my $self = shift;
    $self->{prev};
}


# get origin vertex
sub origin {
    my $self = shift;
    $self->{origin};
}

# set origin
sub _set_origin {
    my ($self, $origin) = @_;
    $self->{origin} = $origin;
}

# set data
sub set_data {
    my ($self, $data) = @_;

    my @twins = ($self, $self->twin);
    for (@twins) {
        $_->_set_data($data);
    }
}


# set data 
sub _set_data {
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

=head1 Edge element

represent DCEL edge 

=head2 new

create a edge which has one twin edge 

 my $edge = Edge->new();

 # get face
 my $face = $edge->face;
 # get twin
 my $twin = $edge->twin;


=head2 twin 

get oposit directon edge

 # get twin
 my $twin = $edge->twin;


=head2 face

get attached face

 # get face
 my $face = $edge->face;

#! vi: se ts=4 sw=4 et:

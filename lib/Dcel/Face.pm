package Dcel::Face;
use strict;
use Scalar::Util qw(weaken);

# constructor
sub new {
    my $class = shift;

    my $res = bless {}, $class;

    $res;
}

# set edge. The edge is held as weak reference object.
sub _set_edge {
    my ($self, $edge) = @_;

    if ($edge) {
        $self->{edge} = weaken($edge);
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

=head1 new

create face instance

 # create face
 $face = Dcel::Face->new();



# vi: se ts=4 sw=4 et:

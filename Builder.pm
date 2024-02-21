package Builder;

use File::Basename;
use File::Spec;


use parent qw(Module::Build);


sub _root_dirs {

    my ($self, $type) = @_;
    
    my @rootdirs;
    if ($type eq 'bin') {
        push @rootdirs, ($type); 
    } elsif ($self->installdirs eq 'core') {
        push @rootdirs, ('lib');
    } else {
        push @rootdirs, qw(site lib);
    }
    \@rootdirs;
}

sub htmlify_pods {

    my $self = shift;
    my $result = $self->SUPER::htmlify_pods(@_);

    if ($result) {
        my ($type, $htmldir) = @_;
        $htmldir = File::Spec->catdir($self->blib, "${type}html") if !$htmldir;

        my $pods = $self->_find_pods(
            $self->{properties}{"${type}doc_dirs"},
            exclude => [
                $self->file_qr('\.(?:bat|com|html)$')
            ]);

        my $root_dirs = $self->_root_dirs($type);
        while (my ($pod, $value) = each %$pods) {
            my ($name, $path) = File::Basename::fileparse($value,
                $self->file_qr('\.(?:pm|plx?|pod)$'));  
            my @dirs = File::Spec->splitdir(File::Spec->canonpath($path));
            pop @dirs if scalar(@dirs) && $dirs[-1] eq File::Spec->curdir;
            my $fulldir = File::Spec->catdir($htmldir, @$root_dirs, @dirs);
            my $pod_rel = File::Spec->abs2rel($pod);
            $self->copy_html_resource($fulldir, $pod_rel, $name);
            $self->modify_html($fulldir, $pod_rel, $name);
        }
    }
    $result;
}


sub read_img_srcs
{
    my ($self, $dom) = @_;

    my $doc_elm = $dom->documentElement;
    my $bodies = $doc_elm->getChildrenByTagName('body');
    my $body = $bodies->get_node(1);

    $body->findnodes('//img[@src]'); 
}

# copy html related resource
sub copy_html_resource
{
    use File::Copy;
    use XML::LibXML;
    my ($self, $out_dir, $src_file, $pod_name) = @_;
    my $html_file = File::Spec->catfile($out_dir, "${pod_name}.html");

    my $dom = XML::LibXML->load_html(
        location => $html_file,
        recover => 1);

    my $res_dir = 'resource';


    my $img_srcs = $self->read_img_srcs($dom);

    my @img_srcs;
    for (1 .. $img_srcs->size()) {
        my $img = $img_srcs->get_node($_);
        push @img_srcs, $img->getAttribute("src");
    }

    for (@img_srcs) {
        my $img_file = File::Spec->catdir($res_dir, 'img', $_);

        if ( -f $img_file ) {
           copy $img_file, $out_dir; 
        }
    }

    my $css_file = File::Spec->catdir($res_dir, 'pod.css');

    if ( -f $css_file ) {
        my @src_stat = stat _;
        my $dst_file = File::Spec->catdir($out_dir, 'pod.css');
        my $do_copy = 0;
        if ( -f $dst_file ) {
            @dst_stat = stat _;
            $do_copy = $dst_stat[9] < $src_stat[9];
        } else {
            $do_copy = 1;
        }

        copy($css_file, $out_dir) if $do_copy; 
    }

}

sub modify_html
{
    use XML::LibXML;
    my ($self, $out_dir, $src_file, $pod_name) = @_;
    my $html_file = File::Spec->catfile($out_dir, "${pod_name}.html");

    my $dom = XML::LibXML->load_html(
        location => $html_file,
        recover => 1);
    
    my $link_elm = $dom->createElement('link');
    $link_elm->setAttribute('href', 'pod.css');
    $link_elm->setAttribute('rel', 'stylesheet');
    my $doc_elm = $dom->documentElement;
    
    my $heads = $doc_elm->getChildrenByTagName('head');

    my $head = $heads->get_node(1);
    
    $head->appendChild($link_elm);
    
    open FH, '>', $html_file or die "can not open $html_file.";

    print FH $dom->toStringHTML;
    
    close FH;
}

1;
# vi: se ts=4 sw=4 et:

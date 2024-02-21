
use Builder;

my $build = Builder->new(
    module_name => 'Dcel',
    license => 'apache',
    dist_abstract => 'lib/Dcel.pm',
    dist_version_from => 'lib/Dcel.pm'
);

$build->create_build_script;
# vi: se ts=4 sw=4 et:

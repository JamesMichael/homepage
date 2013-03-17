package Homepage::ConfigFile;

use warnings;
use strict;

use local::lib;
use YAML ();
use Readonly;

Readonly my $CONFIG_FILENAME => 'site.yaml';

sub new {
    my ($pkg, $directory) = @_;
    my $self = bless {}, ref $pkg || $pkg;

    $self->{path} = _config_path($directory);
    $self->_load_config;

    return $self;
}

sub _config_path {
    my $directory = shift;
    return "$directory/$CONFIG_FILENAME";
}

sub _load_config {
    my $self = shift;
    $self->{config} = YAML::LoadFile($self->{path});
}

# $config->title( default => 'Title' )
sub title {
    my ($self, %args) = shift;
    my $default = $args{default} || 'Default Title';
    return $self->{config}{title} || $default;
}

sub theme {
    my ($self, %args) = shift;
    my $default = $args{default} || 'default';
    return $self->{config}{theme} || $default;
}

# $config->links( )
sub links {
    my $self = shift;
    return grep { $_->{title} and $_->{url} } @{ $self->{config}{links} };
}

# $config->content( )
# returns array of category => [ pages ]
sub content {
    my $self = shift;
    return grep { $_->{category} and $_->{pages} } map { {
        category    => $_->{category},
        pages       => [ pages($_->{pages}) ],
    } } @{ $self->{config}{content} };
}

sub pages {
    my $pages_ref = shift;
    return grep { $_->{title} and $_->{source} } @{ $pages_ref };
}

# $config->sources( )
sub sources {
    my $self = shift;
    return map { $_->{source} } map { pages($_->{pages}) } $self->content;
}

1;

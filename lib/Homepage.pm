package Homepage;

use warnings;
use strict;

use local::lib;
use Readonly;
use File::Copy::Recursive qw(rcopy);
use Template;

use Homepage::ConfigFile;
use Homepage::Util;

our $VERBOSE = 0;

Readonly my $DEFAULT_THEME_DIR  => 'themes';
Readonly my $DEFAULT_THEME      => 'default';
Readonly my $VENDOR_DIR         => 'vendor';
Readonly my $PAGES_DIR          => 'pages';

sub new {
    my ($pkg, %args) = @_;
    my $self = bless {}, ref $pkg || $pkg;

    die "Input path does not exist or is not a directory" unless $args{input} and -d $args{input};
    info "Starting $args{input}";
    $self->{config}      = Homepage::ConfigFile->new($args{input});
    $self->{input_path}  = $args{input};
    $self->{output_path} = $args{output};

    return $self;
}

sub build {
    my $self = shift;

    $self->_create_build_directory;
    $self->_build_source($_) foreach $self->{config}->sources;
    $self->_create_index;
}

sub _create_build_directory {
    my $self = shift;

    info "Creating build directory: $self->{output_path}";
    mkdir $self->{output_path} unless -d $self->{output_path};

    info "Creating pages directory: $self->{output_path}/$PAGES_DIR";
    mkdir "$self->{output_path}/$PAGES_DIR";
}

sub _build_source {
    my ($self, $source) = @_;

    my $input_path      = "$self->{input_path}/$PAGES_DIR/$source";
    my $output_filename = input_filename_to_output_filename $source;
    my $output_path     = "$self->{output_path}/$PAGES_DIR/$output_filename";

    info "Building $input_path to $output_path";
    system "$VENDOR_DIR/markdown/Markdown.pl $input_path > $output_path";
}

sub _create_index {
    my $self = shift;

    my $theme_name      = $self->{config}->theme($DEFAULT_THEME);
    my $theme_path      = "$DEFAULT_THEME_DIR/$theme_name";
    my $theme_filename  = 'index.tt';

    if (-e "$self->{input_path}/themes/$theme_name/$theme_filename") {
        $theme_path = "$self->{input_path}/themes";
    }
    die "Invalid theme: $theme_path/$theme_filename" unless -e "$theme_path/$theme_filename";

    info "Creating $self->{output_path}/index.html from $theme_path/$theme_filename";

    my $tt = Template->new({
        INCLUDE_PATH => $theme_path,
        OUTPUT_PATH  => $self->{output_path}
    }) or die $Template::ERROR;

    $tt->process($theme_filename, {
        title   => $self->{config}->title,
        navigation  => [ $self->{config}->links ],
        content     => [ $self->{config}->content ],
    }, 'index.html') or die $tt->error;

    info "Copying theme resources to $self->{output_path}";
    rcopy $theme_path, $self->{output_path};
}

1;

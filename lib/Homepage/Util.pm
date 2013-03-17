package Homepage::Util;

use warnings;
use strict;

use Homepage;

use Exporter 'import';
our @EXPORT = qw(
    input_filename_to_output_filename
    title_to_name
    info
);

sub input_filename_to_output_filename {
    my $source_filename = shift;

    # convert file extension to html
    $source_filename =~ s/\.md$/.html/;

    return $source_filename;
}

sub title_to_name {
    my $title = shift;

    # lowercase
    $title = lc $title;

    # remove leading or trailing non-word characters
    $title =~ s/^\W+//;
    $title =~ s/\W+$//;

    # replace non-word characters with a single hypen
    $title =~ s/\W+/-/g;
    return $title;
}

sub info {
    return unless $Homepage::VERBOSE;
    my $message = shift;

    my $time = localtime;
    print "[$time] $message\n";
}

1;

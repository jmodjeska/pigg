#!/bin/perl

### -------------------------------------------------------------------------
# PIGG: Progressive Image Grid Generator for PIG.js
# (c) 2018 Jeremy Modjeska
# Source: https://github.com/jmodjeska/pigg/
# Instructions: https://modjeska.us/diy-image-gallery/
#
# Command line usage:
# perl pigg.pl /path/to/full-size-photos
#
# Output structure (original files untouched):
#
# ├── /$dir/
#   ├── [ original photos ]
#   ├── . . .
#   ├── index.html
#   ├── img/
#     ├── 20/
#     ├── 100/
#     ├── 250/
#     └── 500/
#
# PIG docs and code: https://github.com/schlosser/pig.js
# Swipebox mod: https://github.com/mark-rodgers/pig.js
### -------------------------------------------------------------------------

use strict;
use warnings;
use Image::Size;
use Image::Scale;
use File::Slurp qw(read_file write_file);
use File::Basename;

###
### CONFIG
###

# Path to where pig.js is located on the internet
# You can use my version on Github, or upload and serve your own
# on your website (I recommend the second thing, in case I change
# or break my version in the future!)
our $pig = 'https://raw.githubusercontent.com/jmodjeska/pigg/master/js/pig.js';

# Base URI to where the images will live
# Do not use WordPress's media uploader; upload the finished product
# directly to your server
our $uri = 'https://yourwebsite.com/galleries/';

# Do you want to generate an index.html file when you create a gallery?
our $flag_html = 'yes';

# Do you want to output a WordPress shortcode when you create a gallery?
our $flag_wordpress = 'no';

###
### Globals
###

( our $dir = $ARGV[0] ) =~ s!/*$!/!; # ensure trailing slash
our $img_root = $dir . "img/";
our @img_dirs;
our @img_sizes = qw( 20 100 250 500 );
our %manifest = ();
our $manifest_js;
our $shortcode;
our $basename = basename($dir);

###
### Helper functions
###

### Error handler
sub err {
  my $err = $_[0];
  print "[ ERROR ]\n\n    $err\n\n    Exiting.\n\n";
  exit 0;
}

### Override warning behavior
$SIG{__WARN__} = sub {
  my( $e, $d ) = @_;
  $e =~ s/($dir|\n)//g;
  print "    \xe2\x9c\x96 $e";
};

### Success handler
sub ok {
  print "[ OK ]\n";
}

### Get aspect ratio
sub aspect_ratio {
  my $image = $_[0];
  my ( $x, $y ) = imgsize($image);
  return sprintf( "%.4f", $x / $y );
}

### Resize an image
sub resize_image {
  my ( $input_path, $output_path, $new_height ) = @_;
  if ( my $img = Image::Scale->new($input_path) ) {
    $img->resize_gd( { height => $new_height } );
    $img->save_jpeg( $output_path, 100 );
  }
  else { die "Failed to create '$output_path'"; }
}

### List image files in a directory
sub list_image_files {
  my $directory = $_[0] || $dir;
  my @files;
  opendir( my $dh, $directory );
    @files = grep { /\.(jpg|jpeg|gif|png)$/ } readdir $dh;
  closedir( $dh );
  return @files;
}

### Generate a friendly page title
sub create_page_title {
  my $title = $basename;
  $title =~ s/[^a-zA-Z0-9,]//g;
  return ucfirst($title);
}

### Build the JavaScript image array
sub create_manifest {
  # For faster performance, get the ratios from small images;
  # this also ensures we only include successfully-created
  # images in the final array.
  my $loc = $img_root . '100/';
  my $arr;
  foreach ( &list_image_files($loc) ) {
    my $R = &aspect_ratio($loc . $_);
    $arr .= sprintf( "%-8s{\"%s\": \"%s\", \"%s\": \"%s\"},\n", "",
      "filename", $_, "aspectRatio", $R );
    $manifest{$_} = $R; # Hash
  }
  chop($arr);
  $manifest_js = $arr;
  return "OK";
}

###
### Main execution functions
###

### Validate Source Directory
sub check_dir {
  my $status;
  if ( ! defined($dir) || $dir eq '/' ) {
    $status = "Usage: perl $0 /full/path/to/source-image-directory";
  }
  elsif( ! -e $dir ) {
    $status = "Can't find directory '$dir'";
  }
  elsif ( ! -w $dir ) {
    $status = "Can't write to '$dir', and we're going to need to";
  }
  elsif ( &list_image_files < 1 ) {
    $status = "Can't find any images in '$dir'";
  }
  else {
    $status = "OK";
  }
  return $status;
}

### Setup directory structure inside target directory
sub setup_dir {
  my $status;
  @img_dirs = ( map { $img_root . $_ } @img_sizes );
  foreach ( $img_root, @img_dirs ) {
    if( -e $_ && -w $_ ) {
      $status = "OK";
    }
    elsif( mkdir($_, 0755) ) {
      $status = "OK";
    }
    else {
      $status = "Failed to create '$_'";
    }
  }
  return $status;
}

### Generate new images
sub generate_imgs {
  foreach my $img_name ( &list_image_files ) {
    foreach my $img_size ( @img_sizes ) {
      my $output_path = "$img_root/$img_size/$img_name";
      print "\n";
      # Capture result of image resize; skip if error
      eval { &resize_image( $dir . $img_name, $output_path, $img_size ); };
      $@ ? warn "$@" : print "    \xE2\x9C\x94 $img_size/$img_name";
    }
  }
  printf( "\n%60s", "" );
  return "OK";
}

### Generate an HTML file for the image gallery
sub write_html {
  my $js = $manifest_js;
  my $title = &create_page_title;
  my @data = <DATA>;
  my %subs = (
    '__TITLE__'          => $title,
    '__PIG_PATH__'       => $pig,
    '__IMAGE_MANIFEST__' => $js,
    '__PATH__'           => $dir,
  );
  foreach my $k ( keys %subs ) { s/$k/$subs{$k}/g for @data };
  eval {
    write_file $dir . 'index.html', {binmode => ':utf8'}, map { "$_" } @data;
  };
  $@ ? &err($@) : return "OK";
}

### Generate a WordPress shortcode for pigg_wp.php
sub wp_shortcode {
  $shortcode = "[pig gallery=\"$basename\" images=\"" .
    join(q{,}, map{qq{$_/$manifest{$_}}} keys %manifest) . "\"]";
  return "OK";
}

###
### Runtime
###

# Start
print "\n";

# Define runtime steps
my %runtime_functions = (
  check_dir       => [ "Checking source directory", \&check_dir ],
  setup_dir       => [ "Setting up new gallery structure", \&setup_dir ],
  generate_imgs   => [ "Generating new images", \&generate_imgs ],
  create_manifest => [ "Creating image manifest", \&create_manifest ],
  write_html      => [ "Writing index.html file", \&write_html ],
  wp_shortcode    => [ "Creating WordPress shortcode",  \&wp_shortcode ],
);

# Execute runtime steps and report
my @runtime_steps = (
  'check_dir',
  'setup_dir',
  'generate_imgs',
  'create_manifest',
);

push @runtime_steps, 'write_html' if $flag_html eq 'yes';
push @runtime_steps, 'wp_shortcode' if $flag_wordpress eq 'yes';

foreach ( @runtime_steps ) {
  my $pad = 50 - length($runtime_functions{$_}[0]);
  printf ( "-=> $runtime_functions{$_}[0] ... %${pad}s ", '' );
  my $result = $runtime_functions{$_}[1]->();
  $result eq "OK" ? &ok : &err($result);
}

# Finish
print "\nDone!\n\n" . "-" x 64;
print "\nUpload $basename to $uri$basename\n";
if ( $flag_wordpress eq 'yes' ) {
  print "\nWordPress shortcode for this gallery:\n\n" . $shortcode . "\n";
}
print "\n";
exit 1;

###
### HTML Index Template
###

__DATA__
<!DOCTYPE html>
<html>
  <head>
    <title>__TITLE__</title>
  </head>
  <body>
    <div id="pig">
      <img id='gsPreviewImg'>
    </div>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/jquery.swipebox/1.4.4/css/swipebox.min.css">
    <script src="https://code.jquery.com/jquery-2.0.3.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.swipebox/1.4.4/js/jquery.swipebox.min.js"></script>
    <script type="text/javascript" src="__PIG_PATH__"></script>
    <script type="text/javascript">
      var imageData = [
__IMAGE_MANIFEST__
      ];
      var pig = new Pig(imageData, {
        urlForSize: function(filename, size) {
        return '__PATH__' + 'img/' + size + '/' + filename;
      },
      addAnchorTag: true,
      anchorTargetDir: "__PATH__",
      anchorClass: "swipebox"
      }).enable();
      ;( function( $ ) {
      	$( '.swipebox' ).swipebox();
      } )( jQuery );
    </script>
  </body>
</html>

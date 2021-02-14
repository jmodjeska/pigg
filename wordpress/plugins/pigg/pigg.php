<?php

/**
* Plugin Name: Progressive Image Grid Generator (PIGG)
* Description: PIGG: Progressive Image Grid Generator for PIG.js
* Author: Jeremy Modjeska
* Version: 0.1
*/

/*
    Source: https://github.com/jmodjeska/pigg/
    Instructions: https://modjeska.us/diy-image-gallery/

    Example usage:
      generate gallery: perl pigg.pl /path/to/china-2016/
      place gallery structure in: https://yourserver.com/galleries/china-2016/
      place shortcode in your post:
      [gallery name="china-2016" images="a.jpg, b.jpg, c.jpg . . ."]
*/

$pig_template = <<<HTML
    <div id="pig">
      <img id='gsPreviewImg'>
    </div>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/jquery.swipebox/1.4.4/css/swipebox.min.css">
    <script src="https://i.modjeska.us/js/jquery.swipebox.min.js"></script>
    <script type="text/javascript" src="https://raw.githubusercontent.com/jmodjeska/pigg/master/js/pig.js"></script>
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
HTML;

function pig_function($atts) {
  extract(shortcode_atts(array(
    'gallery' => "",
    'images' => array(),
  ), $atts));
  $images = explode(',', $atts[images]);
  $gallery = 'https://yourserver.com/galleries/' . $gallery;
  global $pig_template;

  if ($gallery && $images) {
    $manifest = array_map(function ($e) {
      $img_parts = explode("/", $e);
      return sprintf( "%-8s{\"%s\": \"%s\", \"%s\": \"%s\"},\n",
        "", "filename", $img_parts[0], "aspectRatio", $img_parts[1] );
    }, $images);
    $pig_html = str_replace("__IMAGE_MANIFEST__",
      rtrim(implode($manifest)), $pig_template);
    $pig_html = str_replace("__PATH__", rtrim($gallery, '/') . '/', $pig_html);
    return $pig_html;
  } else {
    return "<!-- No gallery specified -->";
  }
}
add_shortcode('pig', 'pig_function');

?>

# PIGG Perl

As of December 2024, YMMV on this. I'm no longer able to get Image::Scale to work on MacOS.

#### Configure `utils/pigg.pl` for your server

```
# Path to where pig.js is located on the internet
# You can use my version on Github, or upload and serve your own
# on your website (I recommend the second thing, in case I change
# or break my version in the future!)
our $pig = 'https://raw.githubusercontent.com/jmodjeska/pigg/master/js/pig.js';

# Base URI to where the images will live
# Do not use WordPress's media uploader; upload the finished product
# directly to your server
our $uri = 'https://yourwebsite.com/galleries/';
```

#### Command line usage

```
[jm@macbook /]$ cd /path/to/pigg/perl/util/
[jm@macbook util]$ perl pigg.pl /path/to/pigg/example-project-3/
```

#### Output

```
-=> Checking source directory ...                           [ OK ]
-=> Setting up new gallery structure ...                    [ OK ]
-=> Generating new images ...
    ✔ 20/vn.jpg
    ✔ 100/vn.jpg
    ✔ 250/vn.jpg
    ✔ 500/vn.jpg
    ✔ 20/vn4.jpg
    ✔ 100/vn4.jpg
    ✔ 250/vn4.jpg
    ✔ 500/vn4.jpg
    ✔ 20/vn3.jpg
    ✔ 100/vn3.jpg
    ✔ 250/vn3.jpg
    ✔ 500/vn3.jpg
    ✔ 20/vn2.jpg
    ✔ 100/vn2.jpg
    ✔ 250/vn2.jpg
    ✔ 500/vn2.jpg
                                                            [ OK ]
-=> Creating image manifest ...                             [ OK ]
-=> Creating WordPress shortcode ...                        [ OK ]

Done!

----------------------------------------------------------------
Upload example-project-3 to https://yourwebsite.com/galleries/example-project-3
```

**Directory structure, before:**

```
 ├── /$dir/
   ├── [ original photos ]
```

**Directory structure, after:**

```
 ├── /$dir/
   ├── [ original photos ]
   ├── index.html
   ├── img/
     ├── 20/
       └── [ 20 px photos ]
     ├── 100/
       └── [ 100 px photos ]
     ├── 250/
       └── [ 250 px photos ]
     └── 500/
       └── [ 500 px photos ]
```

## WordPress

#### Configure `util/pigg.pl` for WordPress


```
# Do you want to generate an index.html file when you create a gallery?
our $flag_html = 'no';

# Do you want to output a WordPress shortcode when you create a gallery?
our $flag_wordpress = 'yes';
```

#### Configure `wordpress/plugins/pigg.php` for your server

**Line 27**

```
    <script type="text/javascript" src="https://raw.githubusercontent.com/jmodjeska/pigg/master/js/pig.js"></script>
```

**Line 52**

```
  $gallery = 'https://yourserver.com/galleries/' . $gallery;
```

#### Add the plugin
Add `pigg.php` to your WordPress installation by uploading it to `/path/to/wp-content/plugins/pigg/pigg.php`. Verify the plugin appears in your dashboard.

#### Re-run `pigg.pl` and get your shortcode

Restore the example project to its original state, then re-run the `pigg.pl` script:

```
[jm@macbook /]$ cd /path/to/pigg/example-project-3/
[jm@macbook example-project-3]$ rm index.html
[jm@macbook example-project-3]$ rm -rf img
[jm@macbook example-project-3]$ ls
vn.jpg	vn2.jpg	vn3.jpg	vn4.jpg
[jm@macbook /]$ cd /path/to/pigg/perl/util/
[jm@macbook util]$ perl pigg.pl /path/to/pigg/example-project-3/
```

Examine the output for the shortcode:

```
. . .
Done!

----------------------------------------------------------------
Upload example-project-3 to https://yourwebsite.com/galleries/example-project-3

WordPress shortcode for this gallery:

[pig gallery="example-project-3" images="vn.jpg/1.3300,vn4.jpg/1.3300,vn2.jpg/1.6300,vn3.jpg/1.3300"]
```

#### Upload your images
Upload the whole directory (in this example, `example-project-3`) to your server.

#### Use your shortcode
Create a new WordPress post, and paste the shortcode provided.

[![Build Status](https://travis-ci.org/Basemm/batch-img-resizer.png?branch=master)](https://travis-ci.org/Basemm/batch-img-resizer)

Experimental HTML5 image resizer running completely in the browser with no
uploads & generate zip file

![HTML5 Img Resizer Screenshot](https://raw.githubusercontent.com/Basemm/html5-img-resizer/master/screenshot.png "HTML5 Img Resizer Screenshot")

####Features:
  - Quick way to resize images no need to download & install a dedicated app
  also you won't need to upload your files to any of online image resizing
  websites
  - Fast "tested in Chrome, quite as fast as ImageMagik convert!"
  - Accept png and jpeg
  - Set jpeg quality
  - Resize to fixed dimensions "preserve aspect ratio" or percentage scale


####Caveats:
  - Unlike ImageMagick, browsers can’t directly persist each resized image
  on disk so the whole process run in memory & generate zip file for all of
  them at the end. Obviously it won't scale when used with hundreds of large
  images.
  - Repeating the test several times without page refresh it become slower
  probably due to memory leak, it need further checks


####Benchmark in Chrome vs ImageMagick convert:

Scaling 100 PNG images "424 MB" down by 50%

  - Chrome: 1 minute, 12 seconds "72851 millisecond "
  - ImageMagick convert: 1 minute, 10 seconds

Test run in

Chrome version: 35.0.1916.153

OS: ubuntu 14.04LTS, 64bit

Processor: Intel® Pentium(R) CPU G630 @ 2.70GHz × 2

Memory: 8 GB

**Notes:**
  - Chrome numbers cover also generating & saving the zip file, so it
  could actually perform better if there’s a way to provide the images to user
  directly in a friendly way without zip compression.
  - The 100 images in the above test is not a limit by any means, it depends
  on your machine and you can go beyond this number!

####Development
  - To build & test run

> npm install

> bower install

> grunt



MIT License

Feel free to fork & contribute!
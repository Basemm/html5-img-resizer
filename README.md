[![Build Status](https://travis-ci.org/Basemm/batch-img-resizer.png?branch=master)](https://travis-ci.org/Basemm/batch-img-resizer)

Experimental HTML5 image resizer running completely in the browser with no uploads & generate zip file

![HTML5 Img Resizer Screenshot](https://raw.githubusercontent.com/Basemm/html5-img-resizer/master/screenshot.png "HTML5 Img Resizer Screenshot")

####Features:
  - Quick way to resize images no need to download & install a dedicated app also you won't need to upload your files to any of online image resizing websites
  - Fast "Tested in Chrome, quite as fast as ImageMagik convert!"
  - Accept png and jpeg
  - Set jpeg quality
  - Resize to fixed dimensions "preserve aspect ratio" or percentage scale


####Caveats:
  - Unlike ImageMagick u can't persist data on disk using the browser so the whole process run in memory and apparently can't be used with hundreds of large images.  Note that the 100 images in above test is not a limit by any means, it depends on your machine and u can go beyond this number!
  - Repeating the test several times without page refresh it become slower probably due to memory leak it need further checks


####Benchmark in Chrome vs ImageMagick convert:

scaling 100 PNG images "424 MB" 50%

  - chrome: 1 minute, 12 seconds "72851 millisecond "
  - ImageMagick convert: 1 minute, 10 seconds

Note that chrome numbers cover also generating the zip file so it could actually perform better
if there's a way to provide the images to user directly in a friendly way without zip compression.

Test run in

Chrome version: 35.0.1916.153

OS: ubuntu 14.04LTS, 64bit

Processor: Intel® Pentium(R) CPU G630 @ 2.70GHz × 2

Memory: 8 GB


####Development
  - To build & test run

> npm install

> bower install

> grunt



MIT License

Feel free to fork & contribute!
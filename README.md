[![Build Status](https://travis-ci.org/Basemm/batch-img-resizer.png?branch=master)](https://travis-ci.org/Basemm/batch-img-resizer)

Experimental HTML5 image resizer running completely in the browser with no uploads & generate zip file

![HTML5 Img Resizer Screenshot](https://raw.githubusercontent.com/Basemm/html5-img-resizer/master/screenshot.png "HTML5 Img Resizer Screenshot")

####Features:
  - No need to upload your images everthing is done in in your machine!
  - Fast **in Chrome** "faster than ubuntu [nautilus-image-converter](http://packages.ubuntu.com/precise/nautilus-image-converter) and quite as fast as windows [Image Reizer](https://imageresizer.codeplex.com/)
  - Accept png and jpeg
  - Set jpeg quality
  - Resize to fixed dimensions or percentage scale
  - Preserve aspect ratio
  - Cool :)


####Caveats:
  - As the whole resizing process is done in memory & no way to persist on disk you are limited by number of images
  u can resize depending on you system i was able to resize 130 high resolution images (3264 x 2448)
  each 2.7MB by 50% on a ubuntu 14.04LTS 64bit "Intel® Pentium(R) CPU G630 @ 2.70GHz × 2" with "8 GB memory".



####Development
  - To build & test run

> npm install

> bower install

> grunt


MIT License

Feel free to fork & contribute!
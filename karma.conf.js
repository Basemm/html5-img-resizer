'use strict';

// Karma configuration
// http://karma-runner.github.io/0.10/config/configuration-file.html
module.exports = function (config) {
    var browsers = ['Chrome', 'Firefox'];

    //add IE if running in Windows
    if ( /^win/.test(process.platform) ) {
        browsers.push('IE');
    }

    config.set({
        // testing framework to use (jasmine/mocha/qunit/...)
        frameworks: ['mocha', 'chai'],

        // list of files / patterns to load in the browser
        files: [
            {
                pattern: 'test/**/*.*',
                watched: false,
                included: false,
                served: true
            },
            'app/scripts/vendor/*.js',
            '.tmp/scripts/*.js',
            '.tmp/spec/*.js'
        ],

        // web server port
        port: 8080,

        // level of logging
        // possible values: LOG_DISABLE || LOG_ERROR || LOG_WARN || LOG_INFO || LOG_DEBUG
        logLevel: config.LOG_INFO,

        reporters: ['coverage', 'dots'],

        preprocessors: { '.tmp/scripts/App.js': ['coverage'] },

        // enable / disable watching file and executing tests whenever any file changes
        autoWatch: false,


        // Start these browsers, currently available:
        // - Chrome
        // - ChromeCanary
        // - Firefox
        // - Opera
        // - Safari (only Mac)
        // - PhantomJS
        // - IE (only Windows)
        //replace with 'browsers' variable when testing in your machine
        browsers: browsers,


        // Continuous Integration mode
        // if true, it capture browsers, run tests and exit
        singleRun: true
    });
};

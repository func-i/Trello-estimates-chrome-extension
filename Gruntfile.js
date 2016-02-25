module.exports = function(grunt) {

  // Load the plugins
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  // grunt.loadNpmTasks('grunt-contrib-uglify');


  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    // clean /dist folder
    clean: ["dist"],

    // copy html, image and vendor files to /dist
    copy: {
      main: {
        files: [
          { expand: true, cwd: 'src/html', src: '**', dest: 'dist/html/' },
          { expand: true, cwd: 'src/image', src: '**', dest: 'dist/img/' }
        ]
      }
    }, // copy

    // concatenate CSS and vendor JS files
    concat: {
      css_vendor: {
        options: { separator: '\n' },
        src: [
          'src/stylesheet/vendor/jquery-ui-1.10.3.custom.min.css',
          'src/stylesheet/vendor/bootstrap.min.css'
        ],
        dest: 'dist/css/vendor.css'
      },
      css_styles: {
        options: { separator: '\n' },
        src: [
          'src/stylesheet/board.css',
          'src/stylesheet/card.css',
          'src/stylesheet/card_spinner.css'
        ],
        dest: 'dist/css/styles.css'
      },
      js_vendor: {
        options: { separator: ';\n' },
        src: [
          'src/script/vendor/jquery-1.10.1.min.js',
          'src/script/vendor/jquery-ui-1.10.3.custom.min.js'
        ],
        dest: 'dist/js/vendor.js'
      }
    }, // concat

    // Compile CoffeeScript then concatenate the resulting JS files
    coffee: {
      compileJoin: {
        options: {
          join: true
        },
        files: {
          'dist/js/background.js': 'src/script/background.coffee',
          'dist/js/content.js': 'src/script/content.coffee',
          'dist/js/app.js': [
            'src/script/app.coffee',
            'src/script/board.coffee',
            'src/script/card.coffee',
            'src/script/estimation-modal.coffee'
          ] // concat then compile into single file
        }
      }
    } // coffee

  });

  // Grunt tasks
  grunt.registerTask('build', [
    'clean',
    'copy',
    'concat',
    'coffee'
  ]);

};

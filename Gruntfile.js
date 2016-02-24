module.exports = function(grunt) {

  // Load the plugins
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-uglify');


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
          { expand: true, cwd: 'src/image', src: '**', dest: 'dist/image/' },
          { expand: true, cwd: 'src/vendor', src: '**', dest: 'dist/vendor/' }
        ]
      }
    }, // copy

    // concatenate CSS files
    concat: {
      options: {
        separator: '\n',
      },
      dist: {
        src: [
          'src/stylesheet/vendor/jquery-ui-1.10.3.custom.min.css',
          'src/stylesheet/vendor/bootstrap.min.css',
          'src/stylesheet/board.css',
          'src/stylesheet/card.css',
          'src/stylesheet/card_spinner.css'
        ],
        dest: 'dist/styles.css',
      }
    }, // concat

    // Compile CoffeeScript then concatenate the resulting JS files
    coffee: {
      compileJoin: {
        options: {
          join: true
        },
        files: {
          'dist/background.js': 'src/script/background.coffee',
          'dist/content.js': [
            'src/script/app.coffee',
            'src/script/board.coffee',
            'src/script/card.coffee',
            'src/script/estimation-modal.coffee',
            'src/script/main.coffee'
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

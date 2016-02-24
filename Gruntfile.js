module.exports = function(grunt) {

  // Load the plugins
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-coffee');


  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    // concatenate CSS files
    concat: {
      options: {
        separator: '\n',
      },
      dist: {
        src: [
          'src/stylesheet/vendor/ui-lightness/jquery-ui-1.10.3.custom.css',
          'src/stylesheet/vendor/ui-lightness/jquery-ui-1.10.3.custom.min.css',
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
            'src/script/shared.coffee',
            'src/script/board.coffee',
            'src/script/card.coffee',
            'src/script/main.coffee'
          ] // concat then compile into single file
        }
      }
    } // coffee

  });

  // Grunt tasks
  grunt.registerTask('build', [
    'concat',
    'coffee:compileJoin'
  ]);

};

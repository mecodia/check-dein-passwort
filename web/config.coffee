exports.config =
  # See http://brunch.io/#documentation for docs.
  files:
    javascripts:
      joinTo:
        'js/app.js': /^app/
        'js/vendor.js': /^vendor\/js/
        'js/ie.js': /^vendor\/ie/
      order:
        before: [
          'vendor/js/jquery.js',
          'vendor/js/underscore.js',
          'vendor/js/backbone.js'
        ]
    stylesheets:
      joinTo:
        'css/app.css': /^app/
        'css/vendor.css': /^vendor/

  plugins:
      stylus:
        imports: ['nib']

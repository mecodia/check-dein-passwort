exports.config =
  paths:
    public: 'www'
  files:
    javascripts:
      joinTo:
        'javascripts/app.js': /^app[\\/](?!vendor)/
        'javascripts/vendor.js': /^app[\\/]vendor/
      order:
        before: [
          'app/vendor/jquery/jquery.js'
          'app/vendor/underscore/underscore.js'
        ]
    stylesheets:
      joinTo:
        'styles/app.css': /^app[\\/]styles/
        'styles/vendor.css': /^app[\\/]vendor/
      order:
        before: [
          'app/vendor/bootstrap/css/bootstrap.css'
        ]

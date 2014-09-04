exports.config =
  # See http://brunch.io/#documentation for docs.
  modules:
    wrapper: false
    definition: false
  paths:
    watched: ['src']
    public: 'build'
  files:
    javascripts:
      joinTo: 'cdplib.js': /^src/
      order: ['models.coffee']
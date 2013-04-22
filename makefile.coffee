module.exports =

  compiler:
    useGitTag: true
    minify   : true
    sourceMap: true

  src:
    dir  : 'src'
#    files: [
#      'deferred.coffee'
#      'display.coffee'
#      'events.coffee'
#      'geom.coffee'
#      'path.coffee'
#      'ui.coffee'
#    ]

  dst:
    dir : 'lib'
    file: 'sc.ript'

  jsdoc:
    src     :
      dir  : 'src'
      files: [
      ]
    engine  : 'ejs'
    template: 'README.ejs'
    filename: 'README.md'
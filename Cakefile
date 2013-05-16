{spawn} = require 'child_process'

task 'compile', 'compile with coffeemill', (options) ->
  spawn '../coffeemill/bin/coffeemill', [
    '-n', 'sc.ript'
    '-v', 'gitTag'
    '-o', ['lib','../jquery-tm/src'].join(',')
    '-wm'
  ],
    stdio: 'inherit'


invoke 'compile'

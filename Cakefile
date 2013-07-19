{ spawn } = require 'child_process'

option '-o', '--output [filename]', 'Additional output path'

task 'compile', 'compile with coffeemill', ({output}) ->
  outputs = [ 'lib' ]
  outputs.push output if output?
  spawn '../coffeemill/bin/coffeemill', [
    '-n', 'sc.ript'
    '-v', 'gitTag'
    '-o', outputs.join(',')
    '-wmu'
  ],
    stdio: 'inherit'

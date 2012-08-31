fs = require 'fs'
{exec} = require 'child_process'

appFiles  = [
  'main'
  'snake'
]

outputFile = 'game'

task 'build', 'Build single javascript file from source files', ->
  exec "mkdir -p lib"
  appContents = new Array remaining = appFiles.length
  for file, index in appFiles then do (file, index) ->
    fs.readFile "src/#{file}.coffee", 'utf8', (err, fileContents) ->
      throw err if err
      appContents[index] = fileContents
      process() if --remaining is 0
  process = ->
    fs.writeFile "lib/#{outputFile}.coffee", appContents.join('\n\n'), 'utf8', (err) ->
      throw err if err
      exec "coffee --compile lib/#{outputFile}.coffee", (err, stdout, stderr) ->
        throw err if err
        console.log stdout + stderr
        fs.unlink "lib/#{outputFile}.coffee", (err) ->
          throw err if err
          console.log 'Done.'

task 'clean', 'Clean output files', ->
    exec "rm -rf lib"
    console.log 'Done.'

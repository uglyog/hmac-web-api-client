fs     = require 'fs'
{exec} = require 'child_process'

appFiles  = [
  'src/coffee/client.coffee'
]

cssFiles = [
  'src/css/client.less'
]

task 'build', 'Build hmac-client.js and css', ->
  exec "coffee -c -m -j lib/hmac-client.js #{appFiles.join(' ')} ", (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr

  exec "lessc --source-map --source-map-rootpath=src/css #{cssFiles.join(' ')} lib/hmac-client.css", (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr


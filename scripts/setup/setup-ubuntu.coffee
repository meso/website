# gets the team's joyent box deploy ready

spawn = require('child_process').spawn
async = require 'async'
readFileSync = require('fs').readFileSync
path = require('path')

# only read the setup script once
setupScript = readFileSync(path.join(__dirname, './setup-ubuntu.sh'), 'utf8')

module.exports = setupUbuntu = (options, next) ->
  team = options.team

  uploadSetupScript = (next) ->
    console.log team.slug, 'uploading setup script'

    ssh = spawnssh "cat /dev/stdin > ~/setup-ubuntu.sh", next
    ssh.stdin.write(setupScript)
    ssh.stdin.end()

  runSetupScript = (next) ->
    console.log team.slug, 'running setup script'
    spawnssh "bash setup-ubuntu.sh", next

  spawnssh = (cmd, next)->
    login = "root@#{team.ip}"
    ssh = spawn "ssh", [login, cmd],
      stdio: ['pipe', process.stdout, process.stderr]
    ssh.on 'error', (err) -> next(err)
    ssh.on 'exit', (err) -> next(err)
    ssh

  async.waterfall [uploadSetupScript, runSetupScript], (err) -> next(err)

# initialize a github repo for a single team

github = require('../../config/github')
spawn = require('child_process').spawn
async = require 'async'
path = require 'path'

rootDir = path.join(__dirname, '..', '..')

module.exports = setupGitHub = (options, next) ->
  team = options.team

  if team.github.id
    console.log team.slug, 'github already setup!'
    return next()

  async.waterfall [
    (next) ->                 # create repo
      console.log team.slug, 'create repo'
      github.post 'orgs/nko4/repos',
        name: team.slug
        homepage: "http://2013.nodeknockout.com/teams/#{team}"
        private: false
      , next
    (res, body, next) ->      # create push hook
      return next(Error(JSON.stringify(body))) unless body.id

      console.log team.slug, 'create hook'
      github.post "repos/nko4/#{team.slug}/hooks",
        name: 'web'
        active: true
        config:
          url: "http://nodeknockout.com/teams/#{team.code}/commits"
          content_type: 'json'
      , next
    (res, body, next) ->      # create team
      return next(Error(JSON.stringify(body))) unless body.id

      console.log team.slug, 'create team'
      github.post 'orgs/nko4/teams',
        name: team.name
        repo_names: [ "nko4/#{team.slug}" ]
        permission: 'admin'
      , next
    (res, body, next) ->      # save team id
      return next(Error(JSON.stringify(body))) unless body.id

      console.log team.slug, 'save github info'
      team.github = body
    (team, n, next) ->        # get people
      console.log team.slug, 'get people'
      team.people (err, people) ->
        next err, team, people
    (team, people, next) ->   # add members
      async.forEach people, (person, next) ->
        console.log team.slug, 'add people', person.github.login
        github.put "teams/#{team.github.id}/members/#{person.github.login}", next
      , next
    (next) ->                 # seed repo
      console.log team.slug, 'seed repo'
      createRepo = spawn path.join(__dirname, './setup-repo.sh'),
        [ team.slug, team.code, team.name, team.github.id ],
        cwd: rootDir
      createRepo.stdout.on 'data', (s) -> console.log s.toString()
      createRepo.stderr.on 'data', (s) -> console.log s.toString()
      createRepo.on 'error', (err) -> next(err)
      createRepo.on 'exit', (err) -> next(err)
    (next) ->                 # save team
      team.save (err) -> next(err)
  ], (err) -> next(err)

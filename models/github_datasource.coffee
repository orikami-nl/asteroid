class Repo extends Minimongoid
  @_collection: new Meteor.Collection 'repos'

class Commit extends Minimongoid
  @_collection: new Meteor.Collection 'commits'

if Meteor.isServer
  Meteor.methods 
    getGithubCommits: (repo) ->
      result = undefined

      if (lastCommitDate = Commit.findOne({},{sort: {"commit.committer.date"}}).date)
        lastCommitDate = lastCommitDate.toJSON
      else
        lastCommitDate = null

      @unblock()
      result = Meteor.http.call("GET", "https://api.github.com/repos/dreamyourweb/#{repo.name}/commits",
        params:
          client_id: _GITHUB_ID,
          client_secret: _GITHUB_SECRET
          since: lastCommitDate
      )
      if result.statusCode is 200
        for i, commit of result.data
          commit.repo_id = repo._id
          console.log (old_commit = Commit.findOne({sha: commit.sha}))
          if old_commit != undefined
            console.log old_commit.update commit
          else
            console.log Commit.create commit

        return result

      false

    getGithubRepos: ->
      result = undefined
      @unblock()
      result = Meteor.http.call("GET", "https://api.github.com/orgs/dreamyourweb/repos",
        params:
          client_id: _GITHUB_ID,
          client_secret: _GITHUB_SECRET
      )
      if result.statusCode is 200
        for i, repo of result.data
          repo.github_id = repo.id
          delete repo['id']
          console.log (old_repo = Repo.findOne({github_id: repo.github_id}))
          if old_repo != undefined
            console.log old_repo.update repo
          else
            console.log Repo.create repo

        return result

      false

    getAllGithubCommits: ->
      for i, repo of Repo.all()
        Meteor.call 'getGithubCommits', repo

    destroyGithubRepos: ->
      Repo.destroyAll()

    destroyGithubCommits: ->
      Commit.destroyAll()

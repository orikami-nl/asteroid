Meteor.methods populateUsers: ->

  Meteor.users.remove({})
  Accounts.createUser({profile: {full_name: "Andres Lamont"}, username: "andres", email: "andres@dreamyourweb.nl", password:"dreamyourasteroid"})
  Accounts.createUser({profile: {full_name: "Bram den Teuling"}, username: "bram", email: "bram@dreamyourweb.nl", password:"dreamyourasteroid"})
  Accounts.createUser({profile: {full_name: "Luc Vandewall"}, username: "luc", email: "luc@dreamyourweb.nl", password:"dreamyourasteroid"})
  Accounts.createUser({profile: {full_name: "Mark Marijnissen"}, username: "mark", email: "mark@dreamyourweb.nl", password:"dreamyourasteroid"})
  Accounts.createUser({profile: {full_name: "Thijs van de Laar"}, username: "thijs", email: "thijs@dreamyourweb.nl", password:"dreamyourasteroid"})

Meteor.methods getTrelloUserData: ->

  result = undefined
  @unblock()
  result = Meteor.http.call("GET", "https://api.trello.com/1/boards/4f7b0a856f0fc2d24dabec36/members",
    params:
      key: "b21235703575c2c2844154615e41c3d4"
      token: "dff76c247049f7706a8c190252f3b9b60e4e51f40f7a9b06103111d64c22809b"
  )
  if result.statusCode is 200
    members = []
    for i, member of result.data
      do (member) ->
        members.push member
        Meteor.users.update {'profile.full_name': member.fullName} , {$set: {'trello.id': member.id, 'trello.username': member.username}}
    return members

  false

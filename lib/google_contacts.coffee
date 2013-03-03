GoogleClientLogin = require('googleclientlogin').GoogleClientLogin

module.exports = class GoogleContacts
  constructor: (@options = {}) ->
    @options.service = 'contacts'

  connect: (callback) ->
    @auth = new GoogleClientLogin(@options)
    @auth.on GoogleClientLogin.events.login, =>
      callback?(null)
    @auth.on GoogleClientLogin.events.error, (err) =>
      callback?(err)
    @auth.login()



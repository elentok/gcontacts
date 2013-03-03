GoogleClientLogin = require('googleclientlogin').GoogleClientLogin

module.exports = class GoogleContacts
  connect: (options = {}, callback) ->
    options.service = 'contacts'
    @auth = new GoogleClientLogin(options)
    @auth.on GoogleClientLogin.events.login, =>
      callback?(null)
    @auth.on GoogleClientLogin.events.error, (err) =>
      callback?(err)
    @auth.login()



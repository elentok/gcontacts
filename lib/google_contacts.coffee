GoogleClientLogin = require('googleclientlogin').GoogleClientLogin
request = require 'request'

module.exports = class GoogleContacts
  constructor: (@options = {}) ->
    @options.service = 'contacts'
    @url = "https://google.com/m8/feeds/contacts/#{@options.email}/thin?alt=json"

  connect: (callback) ->
    @auth = new GoogleClientLogin(@options)
    @auth.on GoogleClientLogin.events.login, =>
      callback?(null)
    @auth.on GoogleClientLogin.events.error, (err) =>
      callback?(err)
    @auth.login()

  getContacts: (callback) ->
    params =
      url: @url
      headers:
        'Authorization': "GoogleLogin auth=#{@auth.getAuthId()}"
    request params, (err, response, body) =>
      if err?
        callback?(err, null)
      else
        page = @_parseBody(body)
        callback?(null, page)

  _parseBody: (body) ->
    feed = JSON.parse(body).feed
    page =
      startIndex: feed.openSearch$startIndex.$t
      itemsPerPage: feed.openSearch$itemsPerPage.$t
      totalResults: feed.openSearch$totalResults.$t
      contacts: []
    for entry in feed.entry
      page.contacts.push(
        name: entry.title.$t
        email: entry.gd$email[0].address)
    page




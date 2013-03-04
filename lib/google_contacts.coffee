GoogleClientLogin = require('googleclientlogin').GoogleClientLogin
request = require 'request'

module.exports = class GoogleContacts
  constructor: (@options = {}) ->
    @options.service = 'contacts'
    @url = "https://google.com/m8/feeds/contacts/#{@options.email}/thin?alt=json&max-results=9999"

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
    (require 'fs').writeFileSync('contacts1.json', body)
    feed = JSON.parse(body).feed
    page =
      startIndex: feed.openSearch$startIndex.$t
      itemsPerPage: feed.openSearch$itemsPerPage.$t
      totalResults: feed.openSearch$totalResults.$t
      contacts: []
    for entry in feed.entry
      contact = @_parseEntry(entry)
      page.contacts.push(contact) if contact?
    page

  _parseEntry: (entry) ->
    emails = entry.gd$email
    return null unless emails?
    return null if emails.length == 0
    {
      id: @_parseId(entry.id.$t),
      name: entry.title.$t
      email: entry.gd$email[0].address
    }

  _parseId: (id) ->
    match = /\/base\/(.+)$/.exec(id)
    if match? then match[1] else null




require './spec_helper'

GoogleContacts = null

class GoogleClientLogin
  constructor: (@options) ->
    GoogleClientLogin.last = this
  on: ->
  login: ->

GoogleClientLogin.events =
  login: 'login-event'
  error: 'error-event'

describe "GoogleContacts", ->
  beforeEach ->
    @request = @stub()

    GoogleClientLogin.last = null
    GoogleContacts = sandbox.require '../lib/google_contacts',
      requires:
        googleclientlogin:
          GoogleClientLogin: GoogleClientLogin
        request: =>
          @request.apply(global, arguments)

  describe "#connect", ->
    beforeEach ->
      @options =
        email: 'the-email'
        password: 'the-password'
      @googleContacts = new GoogleContacts()

    it "returns a promise", ->
      @googleContacts.connect(@options).then.should.be.a.function

    it "creates a new GoogleClientLogin", ->
      @googleContacts.connect(@options)
      login = GoogleClientLogin.last
      expect(login).to.exist

    it "stores the options in @options", ->
      @googleContacts.connect(@options)
      expect(GoogleClientLogin.last.options).to.eql {
        email: 'the-email'
        password: 'the-password'
        service: 'contacts'
      }

    it "calls GoogleClientLogin.login", ->
      @stub(GoogleClientLogin.prototype, 'login')
      @googleContacts.connect(@options)
      expect(GoogleClientLogin.prototype.login).to.have.been.calledOnce

    describe "when success", ->
      it "resolves the promise", ->
        GoogleClientLogin.prototype.on = (event, callback) ->
          callback?() if event == 'login-event'
        @googleContacts.connect(@options).should.be.fulfilled

    describe "when error", ->
      it "rejects the promise with the error", (done) ->
        GoogleClientLogin.prototype.on = (event, callback) ->
          callback?('an-error') if event == 'error-event'

        @googleContacts.connect(@options).fail (err) =>
          err.should.equal 'an-error'
          done()

  describe "#getContacts", ->
    beforeEach ->
      @options =
        email: 'the-email'
      @contacts = new GoogleContacts()
      @contacts.options = @options
      @contacts.auth =
        getAuthId: -> 'the-auth-id'
        
    it "makes a request to /m8/feeds/contacts/{email}/thin?alt=json&max-results=9999", ->
      @contacts.getContacts()
      expect(@request).to.have.been.calledOnce
      expect(@request.getCall(0).args[0]).to.eql {
        url: 'https://google.com/m8/feeds/contacts/the-email/thin?alt=json&max-results=9999'
        headers:
          Authorization: 'GoogleLogin auth=the-auth-id'
      }

    describe "on success", ->
      it "resolves the promise with the page", (done) ->
        responseBody = JSON.stringify({
          feed:
            openSearch$totalResults:
              $t: 124
            openSearch$startIndex:
              $t: 1
            openSearch$itemsPerPage:
              $t: 25
            entry: [
              {
                id:
                  $t: 'http://www.google.com/m8/feeds/contacts/bob@bob.com/base/this-is-the-id'
                title:
                  $t: 'bob'
                gd$email: [
                  { address: 'bob@bob.com' }
                ]
              }
            ]
              
        })
        @request.callsArgWith(1, null, null, responseBody)
        @contacts.getContacts().then (page) =>
          expect(page).to.eql {
            startIndex: 1
            itemsPerPage: 25
            totalResults: 124
            contacts: [ { id: 'this-is-the-id', name: 'bob', email: 'bob@bob.com' } ]
          }
          done()

    describe "on error", ->
      it "rejects the promise", (done) ->
        @request.callsArgWith(1, 'the-error')
        @contacts.getContacts().fail -> done()


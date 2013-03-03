require './spec_helper'

GoogleClientLogin = sinon.stub()
GoogleClientLogin.events =
  login: 'login-event'
  error: 'error-event'

request = sinon.stub()

GoogleContacts = sandbox.require '../lib/google_contacts',
  requires:
    googleclientlogin:
      GoogleClientLogin: GoogleClientLogin
    request: ->
      request.apply(global, arguments)


describe "GoogleContacts", ->
  beforeEach ->
    GoogleClientLogin.prototype.on = sinon.stub()
    GoogleClientLogin.prototype.login = sinon.stub()
  describe "#connect", ->
    beforeEach ->
      @options =
        email: 'the-email'
        password: 'the-password'
      @googleContacts = new GoogleContacts(@options)

    it "creates a new GoogleClientLogin", ->
      @googleContacts.connect()
      expect(GoogleClientLogin).to.have.been.calledOnce
      expect(GoogleClientLogin.getCall(0).args[0]).to.eql {
        email: 'the-email'
        password: 'the-password'
        service: 'contacts'
      }

    it "calls GoogleClientLogin.login", ->
      @googleContacts.connect()
      expect(GoogleClientLogin.prototype.login).to.have.been.calledOnce

    describe "when success", ->
      it "calls the callback with (null)", ->
        GoogleClientLogin.prototype.on = (event, callback) ->
          callback?() if event == 'login-event'

        callback = sinon.spy()
        @googleContacts.connect(callback)

        expect(callback).to.have.been.calledWith(null)

    describe "when error", ->
      it "calls the callback with (errorObject)", ->
        GoogleClientLogin.prototype.on = (event, callback) ->
          callback?('an-error') if event == 'error-event'

        callback = sinon.spy()
        @googleContacts.connect(callback)

        expect(callback).to.have.been.calledWith('an-error')

  describe "#getContacts", ->
    beforeEach ->
      @options =
        email: 'the-email'
      @contacts = new GoogleContacts(@options)
      @contacts.auth =
        getAuthId: -> 'the-auth-id'
        
    it "makes a request to /m8/feeds/contacts/{email}/thin?alt=json", ->
      @contacts.getContacts()
      expect(request).to.have.been.calledOnce
      expect(request.getCall(0).args[0]).to.eql {
        url: 'https://google.com/m8/feeds/contacts/the-email/thin?alt=json'
        headers:
          Authorization: 'GoogleLogin auth=the-auth-id'
      }

    describe "on success", ->
      it "calls the callback with (null, contacts)", ->
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
                title:
                  $t: 'bob'
                gd$email: [
                  { address: 'bob@bob.com' }
                ]
              }
            ]
              
        })
        request = sinon.stub().callsArgWith(1, null, null, responseBody)
        callback = sinon.spy()
        @contacts.getContacts(callback)
        expect(callback).to.have.been.calledOnce
        page =
          startIndex: 1
          itemsPerPage: 25
          totalResults: 124
          contacts: [ { name: 'bob', email: 'bob@bob.com' } ]
        expect(callback.getCall(0).args).to.eql [null, page]


    describe "on error", ->
      it "calls the callback with (error, null)", ->
        request = sinon.stub().callsArgWith(1, 'the-error')
        callback = sinon.spy()
        @contacts.getContacts(callback)
        expect(callback).to.have.been.calledOnce
        expect(callback.getCall(0).args).to.eql ['the-error', null]






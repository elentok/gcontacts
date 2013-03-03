require './spec_helper'

GoogleClientLogin = sinon.stub()
GoogleClientLogin.events =
  login: 'login-event'
  error: 'error-event'

GoogleContacts = sandbox.require '../lib/google_contacts',
  requires:
    'googleclientlogin':
      GoogleClientLogin: GoogleClientLogin

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


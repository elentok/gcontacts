chai = require 'chai'
chai.use (require 'sinon-chai')
chai.should()

global.expect = chai.expect
global.sinon = require 'sinon'
global.sandbox = require 'sandboxed-module'

beforeEach ->
  @sandbox = sinon.sandbox.create(
    injectInto: this,
    properties: ['spy', 'stub'])

afterEach ->
  @sandbox.restore()

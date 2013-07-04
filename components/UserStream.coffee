
noflo = require "noflo"
chai = require "chai"
twitstream = require "../lib/twitstream"
querystring = require "querystring"

class UserStream extends noflo.LoggingComponent
  constructor: ->
    super

    @inPorts =
      in: new noflo.Port()

    @outPorts.out = new noflo.Port()

    @inPorts.in.on "data", (requestDoc) =>
      try
        requestDoc = JSON.parse(requestDoc) if typeof requestDoc is "string"
      catch e
        @sendLog
          logLevel: "error"
          context: "Processing a string message on the IN port."
          problem: "The request document was not valid JSON: " + e
          solution: "The request document must either be an object or can be string with valid JSON content."

        @disconnectAllPorts()
        return

      try
        chai.expect(requestDoc).to.have.deep.property("auth.token")
        chai.expect(requestDoc).to.have.deep.property("auth.tokenSecret")
        chai.expect(requestDoc).to.have.deep.property("auth.consumerKey")
        chai.expect(requestDoc).to.have.deep.property("auth.consumerSecret")

        @twitterStream(requestDoc)
      catch e
        @sendLog
          logLevel: "error"
          context: "Processing a message requesting a user's stream of Twitter information."
          problem: "The request document was missing required information: " + e
          solution: "Check the examples documentation for how to request work from this component."

        @disconnectAllPorts()

  twitterStream: (requestDoc) =>
    stream = twitstream.Userstream(requestDoc)

    stream.on "readable", =>
      tweet = stream.read()
      @outPorts.out.send tweet
    stream.on "end", =>
      @disconnectAllPorts()

  disconnectAllPorts: =>
    @outPorts.out.disconnect()
    @outPorts.log.disconnect()

exports.getComponent = -> new UserStream

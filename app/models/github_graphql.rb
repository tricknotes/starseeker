require 'net/http'

# A thin client for GitHub's GraphQL API.
#
# Callers build their own query strings; this module only takes care of the
# HTTP round-trip so that every GraphQL request in the application is sent the
# same way.
module GithubGraphql
  HOST = 'api.github.com'
  PATH = '/graphql'

  # GitHub answered, but not with query data (e.g. "Bad credentials").
  Error = Class.new(StandardError)

  # What #execute raises when GitHub cannot be reached or does not answer
  # properly, for callers that want to carry on without the answer.
  CONNECTION_ERRORS = [
    Timeout::Error, # Net::OpenTimeout, Net::ReadTimeout
    SocketError,
    SystemCallError, # ECONNREFUSED, ECONNRESET, ...
    IOError,
    OpenSSL::SSL::SSLError,
    Net::HTTPBadResponse,
    JSON::ParserError,
  ].freeze

  class << self
    # Open one persistent HTTPS connection and yield it.
    #
    # Re-using a connection for several queries avoids repeated TLS handshakes
    # and OpenSSL context allocations, which add up when many batches are sent
    # in a row.
    def connect(&block)
      Net::HTTP.start(HOST, 443, use_ssl: true, open_timeout: 15, read_timeout: 60, &block)
    end

    # POST a query over an already-open connection and return the parsed JSON
    # body.
    def execute(http, token, query)
      request = Net::HTTP::Post.new(PATH)
      request['Authorization'] = "bearer #{token}"
      request['Content-Type']  = 'application/json'
      request['User-Agent']    = 'Starseeker'
      request.body             = { query: query }.to_json

      response = http.request(request)
      JSON.parse(response.body)
    end
  end
end

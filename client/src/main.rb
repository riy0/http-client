require 'net/http'
require 'uri'

# Method: get, post.
class HttpClient
  def initialize(input)
    @url = input[0]
    @method = input[1]
    @parameter = input[2]
    @thread_number = input[3]
    @times = input[4]
    @response = input[5]
  end

  # get request
  def request
    puts 'get called'
    uri = URI.parse(@url)
    response = Net::HTTP.get_response(uri)

    puts "[url]: #{uri}"
    puts "[status]: #{response.code}"
    puts "[body]:  #{response.body}"
  end

  def post_request
    print 'post called'
  end

  def execute
    case @method
    when 'get', 'GET', 'g'
      request
    when 'post', 'POST', 'p'
      post_request
    else
      usage
    end
  end

  private

  # [todo] write usage  & validation method
  def validate_arguments
    print 'validate input'
  end

  def usage
    print 'usage'
  end
end

def main
  client = HttpClient.new(ARGV)
  client.execute
end

if __FILE__ == $0
  main
end

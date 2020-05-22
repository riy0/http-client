require 'net/http'
require 'uri'

# Method: get, post.
class HttpClient
  def initialize(input)
    @url = input[0] # 'https://jsonplaceholder.typicode.com/todos'
    @method = input[1]
    @parameter = input[2]
    @thread_number = input[3]
    @times = input[4]
    @response = input[5]
  end

  def get
    print 'get called'
  end

  def post
    print 'get called'
  end

  def execute
    case @method
    when 'get', 'GET', 'g'
      get
    when 'post', 'POST', 'p'
      get
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

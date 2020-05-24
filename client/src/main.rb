require 'net/http'

# Method: get, post.
class HttpClient
  attr_reader :method

  def initialize(input)
    @url = input[0]
    @method = input[1]
    @parameter = format_parameter(input[2])
    @thread_number = input[3].to_i
    @times = input[4]
    @response = input[5]
  end

  # get
  def request
    uri = URI.parse(@url)
    uri.query = URI.encode_www_form(@parameter) if @parameter.is_a?(Hash)

    res = Net::HTTP.get_response(uri)
    puts res.code
  end

  private

  # format parameter to hash class.
  def format_parameter(parameters)
    return unless parameters.include?('=')

    formatted_params = {}
    parameters.each_line('&&') do |param|
      param.delete!('&&')
      key, value = param.split('=')
      value = value.to_i if /^[+-]?[0-9]+$/ =~ value

      formatted_params[key.intern] = value
    end
    formatted_params
  end

  def show_response(result)
    puts result.body if @response == 'body'

    # [todo] correspond to show the number of each status code
    puts result.code if @response == 'status'
  end
end

def usage
  print 'コマンドライン引数が正しくありません'
end

# [todo] validation method
def validate_arguments
  return unless ARGV.size == 6

  'validate input'
end

def main
  if validate_arguments.nil?
    usage
    exit
  end

  client = HttpClient.new(ARGV)

  case client.method
  when 'get', 'GET', 'g'
    client.request
  else
    usage
    exit
  end
end

if __FILE__ == $0
  main
end

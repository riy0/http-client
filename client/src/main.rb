require 'net/http'

# Method: get, post.
class HttpClient
  def initialize(input)
    @url = input[0]
    @method = input[1]
    @parameter = format_parameter(input[2])
    @thread_number = input[3]
    @times = input[4]
    @response = input[5]
  end

  def execute
    case @method
    when 'get', 'GET', 'g'
      request
    else
      puts 'No method'
      usage
    end
  end

  # get
  def request
    puts @parameter.class

    uri = URI.parse(@url)
    uri.query = URI.encode_www_form(@parameter) if @parameter.is_a?(Hash)
    res = Net::HTTP.get_response(uri)

    show_response(res)
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
    puts result.code if @response == 'total'
  end

  # [todo] write usage  & validation method
  def validate_arguments
    puts 'validate input'
  end
end

def usage
  print 'コマンドライン引数が正しくありません'
end

def main
  if ARGV.size != 6
    usage
    exit
  end

  client = HttpClient.new(ARGV)
  puts client.execute
end

if __FILE__ == $0
  main
end

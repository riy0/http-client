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

    results = parallelize_request(uri)

    show_response(results)
  end

  # paralleization with thread
  def parallelize_request(uri)
    threads = []
    results = []
    @thread_number.times do
      threads << Thread.new do
        res = Net::HTTP.get_response(uri)
        results.push(res.body) if @response == 'body'
        results.push(res.code) if @response == 'status'
      end
    end

    threads.each(&:join)
    results
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

  def show_response(results)
    if @response == 'status'
      status_codes = results.uniq

      status_codes.each_index do |index|
        total = results.count(status_codes[index])
        puts "#{status_codes[index]} : #{total}"
      end
    end

    if @response == 'body'
      puts results[0]
    end
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

if __FILE__ == $0
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

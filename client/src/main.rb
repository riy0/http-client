require 'net/http'

# Method: get, post.
class HttpClient
  attr_reader :method

  def initialize(input)
    @url = input[0]
    @method = input[1]
    @parameter = format_parameter(input[2])
    @thread_number = input[3].to_i
    @times = input[4].to_i
    @response = input[5]
  end

  # get
  def request
    uri = URI.parse(@url)
    uri.query = URI.encode_www_form(@parameter) if @parameter.is_a?(Hash)

    results = parallelize_request(uri)

    display_results(results)
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

  # paralleization with thread
  def parallelize_request(uri)
    threads = []
    results = []
    @thread_number.times do
      threads << Thread.new do
        res = Net::HTTP.get_response(uri)
        results.push(res) if @response == 'body'
        results.push(res.code) if @response == 'status'
      end
    end

    threads.each(&:join)
    results
  end
 
  def display_results(results)
    puts "run #{@method} request"
    puts "url: #{@url}"
    puts "thread: #{@thread_number}, reputation: #{@times}"

    puts show_response_body(results) if @response == 'body'
    puts show_total_status(results) if @response == 'status'
  end

  def show_response_body(results)
    results.each do |result|
      if result.is_a?(Net::HTTPSuccess)
        body = result.body
        return body
      end
    end

    "All requests has failed, can't get body"
  end

  def show_total_status(results)
    status_codes = results.uniq
    messages = []

    status_codes.each do |status|
      total = results.count(status)
      messages.push("#{status} : #{total}")
    end

    messages
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

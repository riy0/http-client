require 'net/http'

# Method: get, post.
class HTTPClient
  def initialize(url, method, parameter, thread_number, repeat_count, response)
    @url = url
    @method = method
    @parameter = format_parameter_to_hash(parameter)
    @thread_number = thread_number.to_i
    @repeat_count = repeat_count.to_i
    @response = response
  end

  def execute
    case @method
    when 'get', 'GET', 'g'
      http_get_request
    else
      my_exit
    end
  end

  # get
  def http_get_request
    uri = URI.parse(@url)
    uri.query = URI.encode_www_form(@parameter) if @parameter.is_a?(Hash)

    results = parallelize_requests(uri)
    display_results(results)
  end

  private

  def format_parameter_to_hash(parameters)
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

  def parallelize_requests(uri)
    threads = []
    responses = []
    count = 0

    until count == @repeat_count
      @thread_number.times do 
        break if count == @repeat_count

        threads << Thread.new do
          res = Net::HTTP.get_response(uri)
          responses << res if @response == 'body'
          responses << res.code if @response == 'status'
        end
        count += 1
      end

      threads.each(&:join)
    end
    responses
  end

  def display_results(results)
    # puts "run #{@method} request"
    # puts "url: #{@url}"
    # puts "thread: #{@thread_number}, iteration: #{@iteration_count} times"

    check_response_body(results) if @response == 'body'
    count_each_status(results) if @response == 'status'
  end

  # if get response body, return it
  def check_response_body(results)
    results.each do |result|
      next unless result.is_a?(Net::HTTPSuccess)
      next if result.body == '[]'

      return result.body
    end

    'unmatched parameter value'
  end

  def count_each_status(results)
    messages = []
    status_codes = results.uniq

    status_codes.each do |status|
      total = results.count(status)
      # messages.push("#{status} : #{total}")
      messages.push(status, total)
    end
    messages
  end
end

# exit with display usage
def my_exit
  print 'コマンドライン引数が正しくありません'
  exit
end

if __FILE__ == $0
  my_exit unless ARGV.size == 6
  my_exit unless ARGV[5] == 'body' || ARGV[5] == 'status'

  url = ARGV[0]
  method = ARGV[1]
  parameter = ARGV[2]
  thread_number = ARGV[3]
  repeat_count = ARGV[4]
  response = ARGV[5]

  client = HTTPClient.new(url, method, parameter, thread_number, repeat_count, response)
  client.execute
end

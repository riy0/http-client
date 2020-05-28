require 'net/http'

# Method: get, post.
class HTTPClient
  def initialize(url, method, parameter, thread_number, repeat_count, response)
    @uri = URI.parse(url)
    @method = method
    @parameter = parameter_to_hash(parameter)
    @thread_number = thread_number.to_i
    @repeat_count = repeat_count.to_i
    @response = response

    @req_options = { use_ssl: @uri.scheme == 'https' }
  end

  def run
    case @method
    when 'get', 'g'
      http_get_request
    when 'post', 'p'
      post_request
    when 'delete', 'd'
      delete_request
    else
      my_exit
    end
  end

  def http_get_request
    @uri.query = URI.encode_www_form(@parameter) if @parameter.is_a?(Hash)
    request = Net::HTTP::Get.new(@uri.request_uri)

    results = parallelize_requests(request)
    display_results(results)
  end

  def post_request
    request = Net::HTTP::Post.new(@uri)
    request.set_form_data(@parameter)

    results = parallelize_requests(request)
    display_results(results)
  end

  def delete_request
    request = Net::HTTP::Delete.new(@uri)

    result = execute_request(request)
    display_results([result])
  end

  private

  def parameter_to_hash(parameter)
    parameter = parameter.split(/[=&]/)
    formatted_params = parameter.each_slice(2).map do |key, value|
      value = value.to_i if /^[+-]?[0-9]+$/ =~ value
      [key.to_sym, value]
    end

    formatted_params.to_h
  end

  def parallelize_requests(request)
    threads = []
    responses = []

    @repeat_count.times do
      @thread_number.times do 
        threads << Thread.new do
          responses << execute_request(request)
        end
      end

      threads.each(&:join)
    end
    responses
  end

  def execute_request(request)
    result = Net::HTTP.start(@uri.hostname, @uri.port, @req_options) do |http|
      http.request(request)
    end

    result = result.code if @response == 'status'
    result
  end

  def display_results(results)
    puts "run #{@method} request"
    puts "url: #{@url}"
    puts "thread: #{@thread_number}, iteration: #{@repeat_count} times"

    puts check_response_body(results) if @response == 'body'
    puts count_each_status(results) if @response == 'status'
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
      messages.push("#{status} : #{total}")
    end
    messages
  end
end

# exit with display usage
def my_exit
  print 'コマンドライン引数が正しくありません'
  exit
end

def valid_input?
  return unless ARGV.size == 6
  return unless ARGV[2].include?('=') || ARGV[2].empty?
  return unless ARGV[3] =~ /\A[0-9]+\z/
  return unless ARGV[4] =~ /\A[0-9]+\z/
  return unless ARGV[5] == 'body' || ARGV[5] == 'status'

  true
end

if __FILE__ == $0
  my_exit unless valid_input?

  client = HTTPClient.new(ARGV[0], ARGV[1], ARGV[2], ARGV[3], ARGV[4], ARGV[5])
  client.run
end

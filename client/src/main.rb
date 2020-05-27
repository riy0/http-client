require 'net/http'

# Method: get, post.
class HTTPClient
  def initialize(url, method, parameter, thread_number, repeat_count, response)
    @url = url
    @method = method
    @parameter = parameter_to_hash(parameter)
    @thread_number = thread_number.to_i
    @repeat_count = repeat_count.to_i
    @response = response
  end

  def execute
    case @method
    when 'get', 'g', 'post', 'p'
      http_request
    else
      my_exit
    end
  end

  # get & post
  def http_request
    uri = URI.parse(@url)
    uri.query = URI.encode_www_form(@parameter) if @parameter.is_a?(Hash)

    results = parallelize_requests(uri)
    display_results(results)
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

  def parallelize_requests(uri)
    threads = []
    responses = []

    @repeat_count.times do
      @thread_number.times do 
        threads << Thread.new do
          res = Net::HTTP.get_response(uri) if @method == 'get'
          res = Net::HTTP.post_form(uri, @parameter) if @method == 'post'
          responses << res if @response == 'body'
          responses << res.code if @response == 'status'
        end
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

def valid_input?
  return unless ARGV.size == 6
  return unless ARGV[2].include?('=')
  return unless ARGV[3] =~ /\A[0-9]+\z/
  return unless ARGV[4] =~ /\A[0-9]+\z/
  return unless ARGV[5] == 'body' || ARGV[5] == 'status'

  true
end

if __FILE__ == $0
  my_exit unless valid_input?

  client = HTTPClient.new(ARGV[0], ARGV[1], ARGV[2], ARGV[3], ARGV[4], ARGV[5])
  client.execute
end

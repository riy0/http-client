require 'net/http'

# Method: get, post.
class HttpClient
  attr_reader :method

  def initialize(input)
    @url = input[0]
    @method = input[1]
    @parameter = format_parameter(input[2])
    @thread_number = input[3]
    @times = input[4]
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

  def parallelize_request(uri)
    threads = []
    results = []
    count = 0

    until count == @times 
      @thread_number.times do 
        break if count == @times

        threads << Thread.new do
          res = Net::HTTP.get_response(uri)
          results << res if @response == 'body'
          results << res.code if @response == 'status'
        end
        count += 1
      end

      threads.each(&:join)
    end
    results
  end

  def display_results(results)
    # puts "run #{@method} request"
    # puts "url: #{@url}"
    # puts "thread: #{@thread_number}, reputation: #{@times}"

    show_response_body(results) if @response == 'body'
    show_total_status(results) if @response == 'status'
  end

  # if get response body, return it
  def show_response_body(results)
    results.each do |result|
      next unless result.is_a?(Net::HTTPSuccess)
      next if result.body == '[]'

      return result.body
    end

    'unmatched parameter value'
  end

  def show_total_status(results)
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

def validate_arguments
  return unless ARGV.size == 6
  return unless ARGV[5] == 'body' || ARGV[5] == 'status'

  thread_number = ARGV[3].to_i
  times = ARGV[4].to_i
  thread_number = times if thread_number > times
  ARGV[3] = thread_number
  ARGV[4] = times
end

if __FILE__ == $0
  my_exit if validate_arguments.nil?

  client = HttpClient.new(ARGV)

  case client.method
  when 'get', 'GET', 'g'
    client.request
  else
    my_exit
    exit
  end
end

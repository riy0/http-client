require_relative '../src/main'

RSpec.describe HttpClient do
  it 'message return hello' do
    url = "http://localhost:80"
    client = HttpClient.new([url, 'get', 1, 1, 1, body])
    expect(client.message).to eq 'hello'
  end
end

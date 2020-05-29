require_relative '../src/main'

RSpec.describe HTTPClient do
  let(:url) { 'http://jsonplaceholder.typicode.com/posts' }
  let(:wrong_url) { 'http://jsonplaceholder.typicode.com/post' }
  let(:delete_url) { 'http://jsonplaceholder.typicode.com/post/1' }
  let(:parameter) { 'userId=1' }

  describe '#http_get_request' do
    context 'when success get request' do
      it 'with a parameter success get status 200' do
        client = HTTPClient.new(url, 'get', parameter, 1, 1, 'status')
        expect(client.http_get_request).to eq ['200', 1]
      end

      it 'with two parameters status 200' do
        parameter = 'userId=1&id=1'
        client = HTTPClient.new(url, 'get', parameter, 1, 1, 'status')
        expect(client.http_get_request).to eq ['200', 1]
      end
    end

    context 'when wrong uri' do
      it 'with wrong url get status 404' do
        client = HTTPClient.new(wrong_url, 'get', parameter, 1, 1, 'status')
        expect(client.http_get_request).to eq ['404', 1]
      end

      it 'with unmatched parameter value return empty' do
        wrong_parameter = 'userId=value'
        client = HTTPClient.new(url, 'get', wrong_parameter, 1, 1, 'body')
        expect(client.http_get_request).to eq nil
      end
    end

    context 'when the number of repetitions is specified' do
      it 'with 10 times reputation' do
        client = HTTPClient.new(url, 'get', parameter, 1, 10, 'status')
        expect(client.http_get_request).to eq ['200', 10]
      end
    end
  end
  
  describe '#post_request' do
    context 'when success post data' do
      it 'with a parameter & status 201' do
        parameter = 'title=test'
        client = HTTPClient.new(url, 'post', parameter, 1, 1, 'status')
        expect(client.post_request).to eq ['201', 1]
      end

      it 'with 2 parameters & status 201' do
        parameter = 'userId=1&title=test'
        client = HTTPClient.new(url, 'post', parameter, 1, 1, 'status')
        expect(client.post_request).to eq ['201', 1]
      end
    end
  end

  describe '#delete_request' do
    context 'when' do
      it 'with a correct url' do
        client = HTTPClient.new(delete_url, 'delete', '', 1, 1, 'status')
        expect(client.delete_request).to eq ['200', 1]
      end
    end
  end
end

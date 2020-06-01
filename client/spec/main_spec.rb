require_relative '../src/main'

RSpec.describe HTTPClient do
  let(:url) { 'http://jsonplaceholder.typicode.com/posts' }
  let(:data_url) { 'http://jsonplaceholder.typicode.com/posts/1' }

  describe '#http_get_request' do
    let(:wrong_url) { 'http://jsonplaceholder.typicode.com/post' }
    
    context 'when execute proper url request' do
      it 'with a parameter status 200' do
        parameter = 'userId=1'
        client = HTTPClient.new(url, 'get', parameter, 1, 1, 'status')
        expect(client.http_get_request).to eq ['200', 1]
      end

      it 'with two parameters' do
        parameter = 'userId=1&id=1'
        client = HTTPClient.new(url, 'get', parameter, 1, 1, 'status')
        expect(client.http_get_request).to eq ['200', 1]
      end
    end

    context 'when execute wrong request' do
      it 'with wrong url get status 404' do
        parameter = 'userId=1'
        client = HTTPClient.new(wrong_url, 'get', parameter, 1, 1, 'status')
        expect(client.http_get_request).to eq ['404', 1]
      end

      it 'with unmatched parameter value' do
        wrong_parameter = 'userId=value'
        client = HTTPClient.new(url, 'get', wrong_parameter, 1, 1, 'body')
        expect(client.http_get_request).to eq nil
      end
    end

    context 'when specified the number of repetitions' do
      it 'with 10 times reputation' do
        parameter = 'userId=1'
        client = HTTPClient.new(url, 'get', parameter, 1, 10, 'status')
        expect(client.http_get_request).to eq ['200', 10]
      end
    end
  end
  
  describe '#post_request' do
    context 'when success post data' do
      it 'with a parameter' do
        parameter = 'title=test'
        client = HTTPClient.new(url, 'post', parameter, 1, 1, 'status')
        expect(client.post_request).to eq ['201', 1]
      end

      it 'with 2 parameters' do
        parameter = 'userId=1&title=test'
        client = HTTPClient.new(url, 'post', parameter, 1, 1, 'status')
        expect(client.post_request).to eq ['201', 1]
      end
    end

    context 'when fail to post data' do
      it 'with no post method' do
        parameter = 'userId=1'
        client = HTTPClient.new(url, 'post', parameter, 1, 1, 'status')
        expect(client.post_request).to eq ['503', 1]
      end
    end
  end

  describe '#delete_request' do
    context 'when success delete data' do
      it 'with a correct url' do
        client = HTTPClient.new(data_url, 'delete', '', 1, 1, 'status')
        expect(client.delete_request).to eq ['200', 1]
      end
    end

    context 'when fail to delete data' do
      it 'with no delete method' do
        parameter = 'userId=1'
        client = HTTPClient.new(url, 'delete', parameter, 1, 1, 'status')
        expect(client.post_request).to eq ['503', 1]
      end
    end
  end
end

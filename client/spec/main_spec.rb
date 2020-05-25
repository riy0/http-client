require_relative '../src/main'

RSpec.describe HttpClient do
  let(:url) { 'http://jsonplaceholder.typicode.com/comments' }
  let(:wrong_url) { 'http://jsonplaceholder.typicode.com/comment' }
  let(:parameter) { 'postId=1' }

  describe '#request' do
    context 'when success get request' do
      it 'with a parameter success get status 200' do
        client = HttpClient.new([url, 'get', parameter, 1, 1, 'status'])
        expect(client.request).to eq ['200', 1]
      end

      it 'with two parameters status 200' do
        parameter = 'postId=1&&id=1'
        client = HttpClient.new([url, 'get', parameter, 1, 1, 'status'])
        expect(client.request).to eq ['200', 1]
      end
    end

    context 'when wrong uri' do
      it 'with wrong url get status 404' do
        client = HttpClient.new([wrong_url, 'get', parameter, 1, 1, 'status'])
        expect(client.request).to eq ['404', 1]
      end

      it 'with unmatched parameter value return empty' do
        wrong_parameter = 'postId=value'
        client = HttpClient.new([url, 'get', wrong_parameter, 1, 1, 'body'])
        expect(client.request).to eq nil
      end
    end

    context 'when the number of repetitions is specified' do
      it 'with 100 times reputation' do
        client = HttpClient.new([url, 'get', parameter, 1, 100, 'status'])
        expect(client.request).to eq ['200', 100]
      end
    end
  end
end

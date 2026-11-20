describe 'Health check' do
  it 'answers 200 without logging in' do
    get '/up'

    expect(response).to have_http_status(:ok)
  end
end

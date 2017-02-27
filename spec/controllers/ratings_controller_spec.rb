require 'rails_helper'

describe ::UserFeedback::RatingsController, type: :controller do
  routes { ::UserFeedback::Engine.routes }
  let(:user) { log_in }
  let(:other_user) { Fabricate :user }

  describe 'GET #index' do
    it 'creates the feedback topic if non existent' do
      topics_count = user.topics.size
      xhr :get, :index, user_id: user.id
      user.topics.reload
      expect(user.topics.size).to eq(topics_count+1)
    end
  end

  describe 'POST #create' do
    it 'posts the rating to the right user' do
      message = 'this is a message for the feedback section of a user in discourse'
      xhr :post, :create, user_id: user.id, raw: message, rating: 3
      topic = Topic.find(json_response[:topic_id])
      expect(topic.user_id).to eq(other_user.id)
      expect(json_response[:user_id]).to eq(user.id)
    end

    it 'responds with 201' do
      message = 'this is a message for the feedback section of a user in discourse'
      xhr :post, :create, user_id: other_user.id, raw: message, rating: 3
      is_expected.to respond_with 201
    end

  end
end

def json_response
  @json_response ||= JSON.parse(response.body, symbolize_names: true)
end
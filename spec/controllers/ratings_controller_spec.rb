require 'rails_helper'

describe ::UserFeedback::RatingsController, type: :controller do
  routes { ::UserFeedback::Engine.routes }
  let(:user) { log_in }
  let(:other_user) { Fabricate :user }

  before do
    ActiveRecord::Base.observers.enable :all
  end

  describe 'GET #index' do
    it 'creates the feedback topic if non existent' do
      system_user = User.find Discourse::SYSTEM_USER_ID
      topics_count = system_user.topics.size
      xhr :get, :index, user_id: user.id
      expect(system_user.topics.reload.size).to eq(topics_count + 1)
    end

    it 'sets feedback_topic_id in the user if no existent' do
      before = user.custom_fields['feedback_topic_id']
      xhr :get, :index, user_id: user.id
      expect(user.reload.custom_fields['feedback_topic_id']).not_to eq(before)
    end
  end

  describe 'POST #create' do
    let!(:user) { log_in }

    it "creates a new post in the user's feedback topic" do
      message = 'this is a message for the feedback section of a user'
      xhr :post, :create, user_id: other_user.id, raw: message, rating: 3
      topic = Topic.find(other_user.custom_fields['feedback_topic_id'])
      expect(topic.posts.size).to eq(2)
    end

    it 'creates a new rating with a value and a comment' do
      message = 'this is a message for the feedback section of a user'
      xhr :post, :create, user_id: other_user.id, raw: message, rating: 3
      expect(json_response[:rating][:raw]).not_to be_nil
      expect(json_response[:rating][:rating]).not_to be_nil
    end
  end
end

def json_response
  @json_response ||= JSON.parse(response.body, symbolize_names: true)
end
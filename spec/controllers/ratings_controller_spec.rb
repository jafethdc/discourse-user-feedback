require 'rails_helper'

describe ::UserFeedback::RatingsController, type: :controller do
  routes { ::UserFeedback::Engine.routes }
  let(:user) { log_in }

  describe 'GET #index' do
    it 'creates the feedback topic if non existent' do
      topics_count = user.topics.size
      xhr :get, :index, params: { user_id: user.id }
      user.topics.reload
      expect(user.topics.size).to eq(topics_count+1)
    end
  end

  describe 'POST #create' do
  end
end
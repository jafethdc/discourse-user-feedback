UserSummary.class_eval do
  module RemoveChatTopics
    def topics
      super.where('archetype <> ?', 'feedback')
    end

    def replies
      super.where('topics.archetype <> ?', 'feedback')
    end

    def links
      super.where('topics.archetype <> ?', 'feedback')
    end
  end
  prepend RemoveChatTopics
end

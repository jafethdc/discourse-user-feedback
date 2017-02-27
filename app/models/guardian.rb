class ::Guardian
  module CanSeeTopic
    # By default, a new archetype is only visible by admins. (See more in models/archetype)
    # This method is overridden so all users are allowed to see the feedbacks
    def can_see_topic?(topic, hide_deleted=true)
      super || topic.archetype == 'feedback'
    end
  end
  prepend CanSeeTopic
end
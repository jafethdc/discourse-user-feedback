UserAction.instance_eval do
  def ratings(opts)
    opts ||= {}

    action_types = opts[:action_types]
    target_topic_id = opts[:target_topic_id]
    offset = opts[:offset] || 0
    limit = opts[:limit] || 60

    action_id = opts[:action_id]

    # The weird thing is that target_post_id can be null, so it makes everything
    #  ever so more complex. Should we allow this, not sure.
    builder = SqlBuilder.new <<-SQL
        SELECT
          a.id,
          t.title, a.action_type, a.created_at, t.id topic_id,
          t.closed AS topic_closed, t.archived AS topic_archived,
          a.user_id AS target_user_id, au.name AS target_name, au.username AS target_username,
          coalesce(p.post_number, 1) post_number, p.id as post_id,
          p.reply_to_post_number,
          pu.username, pu.name, pu.id user_id,
          pu.uploaded_avatar_id,
          u.username acting_username, u.name acting_name, u.id acting_user_id,
          u.uploaded_avatar_id acting_uploaded_avatar_id,
          coalesce(p.cooked, p2.cooked) cooked,
          p.raw,
          CASE WHEN coalesce(p.deleted_at, p2.deleted_at, t.deleted_at) IS NULL THEN false ELSE true END deleted,
          p.hidden,
          p.post_type,
          p.action_code,
          p.edit_reason,
          t.category_id
        FROM user_actions as a
        JOIN topics t on t.id = a.target_topic_id
        LEFT JOIN posts p on p.id = a.target_post_id
        JOIN posts p2 on p2.topic_id = a.target_topic_id and p2.post_number = 1
        JOIN users u on u.id = a.acting_user_id
        JOIN users pu on pu.id = COALESCE(p.user_id, t.user_id)
        JOIN users au on au.id = a.user_id
        LEFT JOIN categories c on c.id = t.category_id
        /*where*/
        /*order_by*/
        /*offset*/
        /*limit*/
    SQL

    if action_id
      builder.where("a.id = :id", id: action_id.to_i)
    else
      builder.where("a.action_type in (:action_types)", action_types: action_types) if action_types && action_types.length > 0
      builder.where("a.target_topic_id = :target_topic_id", target_topic_id: target_topic_id)
      builder
          .order_by("a.created_at desc")
          .offset(offset.to_i)
          .limit(limit.to_i)
    end

    builder.map_exec(UserAction::UserActionRow)
  end
end

class ::UserAction
  module ApplyCommonFilters
    def apply_common_filters(builder, user_id, guardian, ignore_private_messages=false)
      builder.where("t.archetype <> :archetype", archetype: 'feedback')
      super(builder, user_id, guardian, ignore_private_messages)
    end
  end
  singleton_class.prepend ApplyCommonFilters
end
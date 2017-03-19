class ::TopicQuery
  module DefaultResults
    def default_results(options={})
      super(options).where('archetype <> ?', 'feedback')
    end
  end
  prepend DefaultResults
end

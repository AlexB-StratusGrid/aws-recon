class SNS < Mapper
  #
  # Returns an array of resources.
  #
  def collect
    resources = []

    #
    # list_topics
    #
    @client.list_topics.each_with_index do |response, page|
      log(response.context.operation_name, page)

      response.topics.each do |topic|
        log(response.context.operation_name, topic.topic_arn, page)

        # get_topic_attributes
        struct = OpenStruct.new(@client.get_topic_attributes({ topic_arn: topic.topic_arn }).attributes.to_h)
        struct.type = 'topic'
        struct.arn = topic.topic_arn
        struct.policy = JSON.parse(CGI.unescape(struct.Policy))
        struct.effective_delivery_policy = JSON.parse(CGI.unescape(struct.EffectiveDeliveryPolicy))
        struct.subscriptions = []

        # list_subscriptions_by_topic
        @client.list_subscriptions_by_topic({ topic_arn: topic.topic_arn }).each_with_index do |response, page|
          log(response.context.operation_name, topic.topic_arn, page)

          response.subscriptions.each do |sub|
            struct.subscriptions.push(sub.to_h)
          end
        end

        resources.push(struct.to_h)
      end
    end

    resources
  end
end

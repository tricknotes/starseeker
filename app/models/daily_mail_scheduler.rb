module DailyMailScheduler
  TABLE_NAME = 'users_to_be_sent_email'

  module Status
    SCHEDULED  = 'scheduled'
    FAILED     = 'failed'
    PROCESSING = 'processing'
  end

  # A user in either of these states still has today's mail coming.
  PENDING_STATUSES = [Status::SCHEDULED, Status::FAILED].freeze

  class << self
    attr_accessor :logger

    def schedule(users)
      statuses = users.flat_map {|user| [user.id, Status::SCHEDULED] }

      redis.call 'HMSET', TABLE_NAME, *statuses
    end

    def send_mail_to_scheduled_users
      # TODO Use thread
      scheduled_users.each do |user|
        # TODO Use transaction
        next unless PENDING_STATUSES.include?(status_for_user(user))

        start_processing user
        deliver_hot_repositories_to user
      end
    end

    def clear!
      redis.call 'DEL', TABLE_NAME
    end

    def scheduled_users
      user_ids = redis.call('HKEYS', TABLE_NAME)

      User.find(user_ids)
    end

    private

    # Deliver today's mail to one user and take them off the schedule.
    #
    # The user goes back on the schedule only when the failure looks
    # retriable. An expired token never becomes valid on a retry, so that case
    # is dropped with a log line instead.
    def deliver_hot_repositories_to(user)
      if user_has_starred?(user)
        MyHotRepository.notify(user).deliver_now

        logger.info "Send hot repositories mail to \033[36m%s\033[39m." % [label_for(user)]
      else
        logger.info "Skip sending mail to \033[33m%s\033[39m. Because star events to him are empty." % [label_for(user)]
      end

      finish_sending_mail user
    rescue Octokit::Unauthorized
      finish_sending_mail user

      logger.info "Skip sending mail to \033[31m%s\033[39m. Because of unauthorized Token." % [label_for(user)]
    rescue => e
      schedule_as_retry user

      logger.error ["#{e.class} #{e.message}:", *e.backtrace.map {|m| '  '+m }].join("\n")
    end

    def label_for(user)
      '%s(%s)' % [user.username, user.email]
    end

    def redis
      @redis ||=
        begin
          config = RedisClient.config(
            url: Settings.redis_url,
            ssl_params: {
              verify_mode: OpenSSL::SSL::VERIFY_NONE
            }
          )

          config.new_client
        end
    end

    def status_for_user(user)
      redis.call('HMGET', TABLE_NAME, user.id).first
    end

    def start_processing(user)
      redis.call('HMSET', TABLE_NAME, user.id, Status::PROCESSING)
    end

    def finish_sending_mail(user)
      redis.call('HDEL', TABLE_NAME, user.id)
    end

    def schedule_as_retry(user)
      redis.call('HMSET', TABLE_NAME, user.id, Status::FAILED)
    end

    def user_has_starred?(user)
      user.daily_star_events_by_followings.present?
    end
  end

  self.logger = Rails.logger
end

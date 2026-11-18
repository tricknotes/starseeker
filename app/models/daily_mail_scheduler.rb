module DailyMailScheduler
  # Rails.cache cannot list its keys, so the ids of the scheduled users are
  # kept in one entry and the status of each user in an entry of its own.
  # A user is on the schedule for as long as the latter exists, which lets a
  # single write or delete move one user without touching the others.
  USER_IDS_KEY = 'daily_mail_schedule/user_ids'

  WriteError = Class.new(StandardError)

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
      user_ids = users.map(&:id)

      user_ids.each {|user_id| write status_key(user_id), Status::SCHEDULED }
      write USER_IDS_KEY, scheduled_user_ids | user_ids
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
      Rails.cache.delete_multi(user_ids.map {|user_id| status_key(user_id) })
      Rails.cache.delete(USER_IDS_KEY)
    end

    def scheduled_users
      User.find(scheduled_user_ids)
    end

    private

    # Deliver today's mail to one user and take them off the schedule.
    #
    # The user goes back on the schedule only when the failure looks
    # retriable. An expired token never becomes valid on a retry, so that case
    # is dropped and the user is left out until they log in again.
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
      user.revoke_token!

      logger.info "Skip sending mail to \033[31m%s\033[39m. Because of unauthorized Token." % [label_for(user)]
    rescue => e
      schedule_as_retry user

      logger.error ["#{e.class} #{e.message}:", *e.backtrace.map {|m| '  '+m }].join("\n")
    end

    def label_for(user)
      '%s(%s)' % [user.username, user.email]
    end

    def user_ids
      Rails.cache.read(USER_IDS_KEY) || []
    end

    def scheduled_user_ids
      user_ids = self.user_ids
      statuses = Rails.cache.read_multi(*user_ids.map {|user_id| status_key(user_id) })

      user_ids.select {|user_id| statuses.key?(status_key(user_id)) }
    end

    def status_key(user_id)
      "daily_mail_schedule/statuses/#{user_id}"
    end

    def status_for_user(user)
      Rails.cache.read(status_key(user.id))
    end

    def start_processing(user)
      write status_key(user.id), Status::PROCESSING
    end

    def finish_sending_mail(user)
      Rails.cache.delete(status_key(user.id))
    end

    def schedule_as_retry(user)
      write status_key(user.id), Status::FAILED
    end

    # A cache store reports a failing backend and carries on, which is right
    # for a cache but would let a mail that could not be scheduled, or one
    # that is about to be sent twice, go unnoticed.
    def write(key, value)
      Rails.cache.write(key, value) or raise WriteError, "Could not write #{key}"
    end

    def user_has_starred?(user)
      user.daily_star_events_by_followings.present?
    end
  end

  self.logger = Rails.logger
end

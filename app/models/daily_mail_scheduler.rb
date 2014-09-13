module DailyMailScheduler
  TABLE_NAME = 'users_to_be_sent_email'

  module Status
    SCHEDULED   = 'scheduled'
    FAILED      = 'failed'
    PROCESSIONG = 'processing'
  end

  class << self
    attr_accessor :logger

    def schedule(users)
      statuses = users.flat_map {|user| [user.id, Status::SCHEDULED] }

      redis.hmset TABLE_NAME, *statuses
    end

    def send_mail_to_scheduled_users
      # TODO Use thread
      scheduled_users.each do |user|
        # TODO Use transaction
        case status_for_user(user)
        when Status::SCHEDULED, Status::FAILED
          start_processing user

          label = '%s(%s)' % [user.username, user.email]

          begin
            if user_has_starred?(user, 1.day.ago)
              MyHotRepository.notify(user).deliver_now

              self.logger.info "Send hot repositories mail to \033[36m%s\033[39m." % [label]
            else
              self.logger.info "Skip sending mail to \033[33m%s\033[39m. Because star events to him are empty." % [label]
            end

            finish_sending_mail user
          rescue Octokit::Unauthorized
            finish_sending_mail user

            self.logger.info "Skip sending mail to \033[31m%s\033[39m. Because of unauthorized Token." % [label]
          rescue => e
            schedule_as_retry user

            self.logger.error ["#{e.class} #{e.message}:", *e.backtrace.map {|m| '  '+m }].join("\n")
          end
        else
          # noop
        end
      end
    end

    def clear!
      redis.del TABLE_NAME
    end

    def scheduled_users
      user_ids = redis.hkeys(TABLE_NAME)

      User.find(user_ids)
    end

    private

    def redis
      @redis ||= begin
        uri = URI.parse(Settings.redis.url)
        Redis.new(host: uri.host, port: uri.port, password: uri.password)
      end
    end

    def status_for_user(user)
      redis.hmget(TABLE_NAME, user.id).first
    end

    def start_processing(user)
      redis.hmset(TABLE_NAME, user.id, Status::PROCESSIONG)
    end

    def finish_sending_mail(user)
      redis.hdel(TABLE_NAME, user.id)
    end

    def schedule_as_retry(user)
      redis.hmset(TABLE_NAME, user.id, Status::FAILED)
    end

    def user_has_starred?(user, term)
      user.star_events_by_followings_with_me.latest(term).present?
    end
  end

  self.logger = Rails.logger

end

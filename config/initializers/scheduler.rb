require 'rufus-scheduler'

s = Rufus::Scheduler.singleton


unless defined?(Rails::Console) || File.split($0).last == 'rake'

  # only schedule when not running from the Ruby on Rails console
  # or from a rake task

  s.every '1m' do

    Rails.logger.info "hello, it's #{Time.now}"
    Rails.logger.flush
  end
end

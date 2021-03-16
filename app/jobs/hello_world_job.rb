class HelloWorldJob < ApplicationJob
  class HelloWorldException < RuntimeError; end

  after_perform { HelloWorldJob.set(wait: 1.minute).perform_later }

  def perform
    sleep(5.minutes)
    raise HelloWorldException
    
    File.open(Rails.root.join('tmp/active_job.hello_world.log'), 'a') do |f|
      f << "[#{self.class.name}][#{Time.zone.now}] Hello World!\n"
    end
  end
end

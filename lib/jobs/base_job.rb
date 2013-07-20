# To replace with sidekiq and
# - sidekiq throttler (https://github.com/gevans/sidekiq-throttler)
# - unique jobs (https://github.com/form26/sidekiq-unique-jobs, **https://github.com/krasnoukhov/sidekiq-middleware)
# - job chaining (custom middleware)


# require 'chainable_job/manager'

module Smoothie
  class BaseJob

    include Sidekiq::Worker


    def perform(*args)
      init(*args)
      do_perform unless ready?
    end


    def ready?
      raise "#{self.class.name}#ready? must be defined"
    end


    def init(*args)
      # Do nothing by default
    end


    def do_perform
      raise "#{self.class.name}#do_perform must be defined"
    end


    # Syntax : 
    # - wait_for  :class => PlaylistSyncer, :args => 1
    def wait_for(jobs)

      throw self.inspect
      
      # TODO : HANDLE DEPENDENCIES AND CALLBACKS

      jobs = [jobs] unless jobs.is_a? Array

      jobs.each do |job|

        Sidekiq::Client.push('class' => job[:class], 'args' => [*job[:args]])

      end

      #   unready_jobs = [*jobs].select{|job|!job.is_ready?}

      #   unless unready_jobs.empty?
      #     if @async
      #       unready_jobs.each do |job|
      #         job.manager.enqueue(self)
      #       end

      #       # Remove self from the queue (keep its callbacks and dependencies though)
      #       manager.waiting

      #       throw :stop_job # Halt the execution of the current worker
      #     else
      #       unready_jobs.each(&:run)
      #     end
      #   end
    end

    # attr_accessor :arguments

    # def initialize(opts = {})
    #   @arguments = opts
    # end

    # def run
    #   catch(:stop_job) do
    #     perform unless is_ready?
    #     manager.finished
    #   end
    # end

    # def is_ready?
    #   force_execution? ? false : ready?
    # end

    # def async_run
    #   begin
    #     @async = true
    #     run
    #   rescue
    #     manager.failed
    #   end
    # end

    # def perform
    #   raise "#{self.class.name}#perform must be defined"
    # end

    # def wait_for(jobs)
    #   unready_jobs = [*jobs].select{|job|!job.is_ready?}

    #   unless unready_jobs.empty?
    #     if @async
    #       unready_jobs.each do |job|
    #         job.manager.enqueue(self)
    #       end

    #       # Remove self from the queue (keep its callbacks and dependencies though)
    #       manager.waiting

    #       throw :stop_job # Halt the execution of the current worker
    #     else
    #       unready_jobs.each(&:run)
    #     end
    #   end
    # end


    # # Resque
    # def self.perform(opts = {})
    #   new(opts).async_run
    # end

    # # Manager accessor
    # def manager
    #   @manager ||= Manager.new(self)
    # end

    # # Equality : only class name and arguments are important here
    # def ==(job)
    #   (self.class == job.class) && (self.arguments == job.arguments)
    # end

    # private

    # def aync?
    #   !!@arguments['async']
    # end

    # def ready?
    #   raise "#{self.class.name}#ready? must be defined"
    # end

    # def force_execution?
    #   !!@arguments['force']
    # end

  end
end

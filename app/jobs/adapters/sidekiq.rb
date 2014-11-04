require 'sidekiq'

module Jobs
  module Adapters
    class Sidekiq
      include ::Sidekiq::Worker
      sidekiq_options retry: false
    end
  end
end

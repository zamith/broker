require 'sidekiq'

module Jobs
  module Adapters
    class Sidekiq
      include ::Sidekiq::Worker
    end
  end
end

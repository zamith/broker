class DistsController < ::ApplicationController
  before_filter :authorize

  def index
    @dists = Dist.all
  end
end

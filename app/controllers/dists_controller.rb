require_relative "#{Rails.root}/app/jobs/generate_dist"

class DistsController < ::ApplicationController
  before_filter :authorize

  def index
    @dists = Dist.all.order(created_at: :desc)
  end

  def create
    if admin?
      Jobs::GenerateDist.perform_async(true, params[:branch_name])
    end

    redirect_to dists_path
  end

  def show
    @dist = Dist.find(params[:id])
  end

  def download
    dist = Dist.find(params[:id])
    send_file dist.path
  end
end

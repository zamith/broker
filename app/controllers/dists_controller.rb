require_relative "#{Rails.root}/app/jobs/generate_dist"

class DistsController < ::ApplicationController
  before_filter :authorize

  def index
    @dists = Dist.all.order(created_at: :desc)
  end

  def create
    Jobs::GenerateDist.perform_async
    redirect_to dists_path
  end

  def download
    dist = Dist.find(params[:id])
    file_path = "#{Rails.root}/public/dists/#{dist.url}.zip"
    send_file file_path
  end
end

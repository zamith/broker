class Dist < ActiveRecord::Base
  before_destroy :remove_files

  DIST_LIMIT = 10

  def dist_path
    "#{Rails.root}/public/dists/#{url}.zip"
  end

  private
  def remove_files
    FileUtils.rm_f dist_path
  end
end

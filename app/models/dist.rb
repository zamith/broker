class Dist < ActiveRecord::Base
  before_destroy :remove_files
  after_create :remove_older_dist

  DIST_LIMIT = 10

  def path
    "#{Rails.root}/public/dists/#{url}.zip"
  end

  def release_manifest
    read_attribute(:release_manifest) && read_attribute(:release_manifest).split("\n")
  end

  private
  def remove_files
    FileUtils.rm_f dist_path
  end

  def remove_older_dist
    if Dist.count > DIST_LIMIT
      Dist.first.destroy
    end
  end
end

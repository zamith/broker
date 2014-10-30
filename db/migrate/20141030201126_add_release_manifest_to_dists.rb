class AddReleaseManifestToDists < ActiveRecord::Migration
  def change
    add_column :dists, :release_manifest, :text
  end
end

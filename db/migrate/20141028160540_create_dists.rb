class CreateDists < ActiveRecord::Migration
  def change
    create_table :dists do |t|
      t.string :branch_name
      t.string :url

      t.timestamps
    end
  end
end

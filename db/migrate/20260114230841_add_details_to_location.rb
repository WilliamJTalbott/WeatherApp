class AddDetailsToLocation < ActiveRecord::Migration[8.1]
  def change
    add_column :locations, :city, :string
    add_column :locations, :longitude, :float
    add_column :locations, :latitude, :float
  end
end

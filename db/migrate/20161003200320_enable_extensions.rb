class EnableExtensions < ActiveRecord::Migration[5.0]
  def change
    enable_extension "hstore"
    enable_extension "uuid-ossp"
    enable_extension "postgis"
  end
end

# Provides private class methods to query the database for intersections
# of a location with a hubzone layer
module AssertionHelper
  private

  def assertion_by_type(type, location)
    res = ActiveRecord::Base.connection.execute(assertion_query(location, type))
    hubzones = []
    res.each do |r|
      r.delete('geom')
      r[:hz_type] = type
      hubzones << r
    end
    hubzones
  end

  def assertion_query(location, type)
    <<-SQL
      SELECT *
        FROM #{type}
       WHERE ST_Intersects(geom,
         ST_GeomFromText('POINT(#{location['lng']} #{location['lat']})',4326));
    SQL
  end
end

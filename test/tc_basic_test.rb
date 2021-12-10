# -----------------------------------------------------------------------------
#
# Tests for basic Kml usage
#
# -----------------------------------------------------------------------------

require 'test/unit'
require 'rgeo/kml'


module RGeo
  module Kml
    module Tests  # :nodoc:

      class TestKml < ::Test::Unit::TestCase  # :nodoc:


        def setup
          @geo_factory = ::RGeo::Cartesian.simple_factory(:srid => 4326)
          @geo_factory_z = ::RGeo::Cartesian.simple_factory(:srid => 4326, :has_z_coordinate => true)
          @geo_factory_m = ::RGeo::Cartesian.simple_factory(:srid => 4326, :has_m_coordinate => true)
          @geo_factory_zm = ::RGeo::Cartesian.simple_factory(:srid => 4326, :has_z_coordinate => true, :has_m_coordinate => true)
          @entity_factory = ::RGeo::Kml::EntityFactory.instance
        end


        def test_has_version
          assert_not_nil(::RGeo::Kml::VERSION)
        end


        def test_nil
          assert_nil(::RGeo::Kml.encode(nil))
          assert_nil(::RGeo::Kml.decode(nil, :geo_factory => @geo_factory))
        end


        def test_point
          object_ = @geo_factory.point(10, 20)
          kml_ = "<Point>\n<coordinates>10.0,20.0</coordinates>\n</Point>\n"

          assert_equal(kml_, ::RGeo::Kml.encode(object_))
          assert(::RGeo::Kml.decode(kml_, :geo_factory => @geo_factory) == object_ )
        end


        def test_point_z
          object_ = @geo_factory_z.point(10, 20, -1)
          kml_ = "<Point>
<coordinates>10.0,20.0,-1.0</coordinates>
</Point>\n"
          
          assert_equal(kml_, ::RGeo::Kml.encode(object_))
          assert(::RGeo::Kml.decode(kml_, :geo_factory => @geo_factory_z).equals?(object_))
        end

        def test_point_2
          object_ = @geo_factory_z.point(14.5441725690769, 56.26101253776282, 0)
          kml_ = "<Point>\n<extrude>0</extrude><altitudeMode>clampToGround</altitudeMode>\n<coordinates> 14.5441725690769,56.26101253776282,0</coordinates>\n</Point>"

          assert(::RGeo::Kml.decode(kml_, :geo_factory => @geo_factory_z) == object_ )
        end

        def test_line_string
          object_ = @geo_factory.line_string([@geo_factory.point(10, 20), @geo_factory.point(12, 22), @geo_factory.point(-3, 24)])
          kml_ = "<LineString>
<coordinates>
10.0,20.0
12.0,22.0
-3.0,24.0
</coordinates>
</LineString>\n"

          assert_equal(kml_, ::RGeo::Kml.encode(object_))
          assert(::RGeo::Kml.decode(kml_, :geo_factory => @geo_factory) == object_ )
        end


        def test_polygon
          object_ = @geo_factory.polygon(@geo_factory.linear_ring([@geo_factory.point(10, 20), @geo_factory.point(12, 22), @geo_factory.point(-3, 24), @geo_factory.point(10, 20)]))
          kml_ = "<Polygon>
<outerBoundaryIs><LinearRing><coordinates>
10.0,20.0
12.0,22.0
-3.0,24.0
10.0,20.0
</coordinates></LinearRing></outerBoundaryIs>
</Polygon>\n"

          assert_equal(kml_, ::RGeo::Kml.encode(object_))
          assert(::RGeo::Kml.decode(kml_, :geo_factory => @geo_factory) == object_ )
        end


        def test_polygon_complex
          object_ = @geo_factory.polygon(@geo_factory.linear_ring([@geo_factory.point(0, 0), @geo_factory.point(10, 0), @geo_factory.point(10, 10), @geo_factory.point(0, 10), @geo_factory.point(0, 0)]), [@geo_factory.linear_ring([@geo_factory.point(4, 4), @geo_factory.point(6, 5), @geo_factory.point(4, 6), @geo_factory.point(4, 4)])])

          kml_ = "<Polygon>
<outerBoundaryIs><LinearRing><coordinates>
0.0,0.0
10.0,0.0
10.0,10.0
0.0,10.0
0.0,0.0
</coordinates></LinearRing></outerBoundaryIs>
<innerBoundaryIs><LinearRing><coordinates>
4.0,4.0
6.0,5.0
4.0,6.0
4.0,4.0
</coordinates></LinearRing></innerBoundaryIs>
</Polygon>\n"
          
          assert_equal(kml_, ::RGeo::Kml.encode(object_))
          assert(::RGeo::Kml.decode(kml_, :geo_factory => @geo_factory) == object_ )
        end


        def test_multi_point
          object_ = @geo_factory.multi_point([@geo_factory.point(10, 20), @geo_factory.point(12, 22), @geo_factory.point(-3, 24)])

          kml_ = "<MultiGeometry>
<Point>
<coordinates>10.0,20.0</coordinates>
</Point>
<Point>
<coordinates>12.0,22.0</coordinates>
</Point>
<Point>
<coordinates>-3.0,24.0</coordinates>
</Point>
</MultiGeometry>\n"

          assert_equal(kml_, ::RGeo::Kml.encode(object_))
          assert(::RGeo::Kml.decode(kml_, :geo_factory => @geo_factory) == object_ )
        end


        def test_multi_line_string
          object_ = @geo_factory.multi_line_string([@geo_factory.line_string([@geo_factory.point(10, 20), @geo_factory.point(12, 22), @geo_factory.point(-3, 24)]), @geo_factory.line_string([@geo_factory.point(1, 2), @geo_factory.point(3, 4)])])
          kml_ = "<MultiGeometry>
<LineString>
<coordinates>
10.0,20.0
12.0,22.0
-3.0,24.0
</coordinates>
</LineString>
<LineString>
<coordinates>
1.0,2.0
3.0,4.0
</coordinates>
</LineString>
</MultiGeometry>\n"
          assert_equal(kml_, ::RGeo::Kml.encode(object_))
          assert(::RGeo::Kml.decode(kml_, :geo_factory => @geo_factory) == object_ )
        end


        def test_multi_polygon
          object_ = @geo_factory.multi_polygon([@geo_factory.polygon(@geo_factory.linear_ring([@geo_factory.point(0, 0), @geo_factory.point(10, 0), @geo_factory.point(10, 10), @geo_factory.point(0, 10), @geo_factory.point(0, 0)]), [@geo_factory.linear_ring([@geo_factory.point(4, 4), @geo_factory.point(6, 5), @geo_factory.point(4, 6), @geo_factory.point(4, 4)])]), @geo_factory.polygon(@geo_factory.linear_ring([@geo_factory.point(-10,-10), @geo_factory.point(-15, -10), @geo_factory.point(-10, -15), @geo_factory.point(-10, -10)]))])
          kml_ = "<MultiGeometry>
<Polygon>
<outerBoundaryIs><LinearRing><coordinates>
0.0,0.0
10.0,0.0
10.0,10.0
0.0,10.0
0.0,0.0
</coordinates></LinearRing></outerBoundaryIs>
<innerBoundaryIs><LinearRing><coordinates>
4.0,4.0
6.0,5.0
4.0,6.0
4.0,4.0
</coordinates></LinearRing></innerBoundaryIs>
</Polygon>
<Polygon>
<outerBoundaryIs><LinearRing><coordinates>
-10.0,-10.0
-15.0,-10.0
-10.0,-15.0
-10.0,-10.0
</coordinates></LinearRing></outerBoundaryIs>
</Polygon>
</MultiGeometry>\n"
          assert_equal(kml_, ::RGeo::Kml.encode(object_))
          assert(::RGeo::Kml.decode(kml_, :geo_factory => @geo_factory) == object_ )
        end


        def test_geometry_collection
          object_ = @geo_factory.collection([@geo_factory.point(10, 20), @geo_factory.line_string([@geo_factory.point(12, 22), @geo_factory.point(-3, 24)])])
          kml_ = "<MultiGeometry>
<Point>
<coordinates>10.0,20.0</coordinates>
</Point>
<LineString>
<coordinates>
12.0,22.0
-3.0,24.0
</coordinates>
</LineString>
</MultiGeometry>\n"
          assert_equal(kml_, ::RGeo::Kml.encode(object_))
          assert(::RGeo::Kml.decode(kml_, :geo_factory => @geo_factory) == object_ )
        end

      end

    end
  end
end

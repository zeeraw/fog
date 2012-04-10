require 'fog/core/collection'
require 'fog/osrackspace/models/compute/flavor'

module Fog
  module Compute
    class OSRackspace

      class Flavors < Fog::Collection

        model Fog::Compute::OSRackspace::Flavor

        def all
          data = connection.list_flavors_detail.body['flavors']
          load(data)
        end

        def get(flavor_id)
          data = connection.get_flavor_details(flavor_id).body['flavor']
          new(data)
        rescue Fog::Compute::OSRackspace::NotFound
          nil
        end

      end

    end
  end
end

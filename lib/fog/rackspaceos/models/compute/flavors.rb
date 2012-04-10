require 'fog/core/collection'
require 'fog/rackspaceos/models/compute/flavor'

module Fog
  module Compute
    class RackspaceOS

      class Flavors < Fog::Collection

        model Fog::Compute::RackspaceOS::Flavor

        def all
          data = connection.list_flavors_detail.body['flavors']
          load(data)
        end

        def get(flavor_id)
          data = connection.get_flavor_details(flavor_id).body['flavor']
          new(data)
        rescue Fog::Compute::RackspaceOS::NotFound
          nil
        end

      end

    end
  end
end

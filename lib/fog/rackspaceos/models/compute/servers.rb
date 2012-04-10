require 'fog/core/collection'
require 'fog/rackspaceos/models/compute/server'

module Fog
  module Compute
    class RackspaceOS

      class Servers < Fog::Collection

        model Fog::Compute::RackspaceOS::Server

        def all
          data = connection.list_servers_detail.body['servers']
          load(data)
        end

        def bootstrap(new_attributes = {})
          server = create(new_attributes)
          server.wait_for { ready? }
          server.setup(:password => server.password)
          server
        end

        def get(server_id)
          if server = connection.get_server_details(server_id).body['server']
            new(server)
          end
        rescue Fog::Compute::RackspaceOS::NotFound
          nil
        end

      end

    end
  end
end

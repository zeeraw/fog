module Fog
  module Compute
    class IBM
      class Real

        # Delete an address
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>
        # TODO: docs
        def delete_address(address_id)
          options = {
            :method   => 'DELETE',
            :expects  => 200,
            :path     => "/addresses/#{address_id}",
          }
          request(options)
        end

      end
    end
  end
end

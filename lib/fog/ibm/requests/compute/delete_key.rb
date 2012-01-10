module Fog
  module Compute
    class IBM
      class Real

        # Delete a key
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>
        # TODO: docs
        def delete_key(key_name)
          options = {
            :method   => 'DELETE',
            :expects  => 200,
            :path     => "/keys/#{key_name}",
          }
          request(options)
        end

      end
    end
  end
end

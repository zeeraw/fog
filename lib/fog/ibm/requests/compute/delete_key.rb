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
      class Mock

        def delete_key(key_name)
          response = Excon::Response.new
          if key_exists? key_name
            self.data[:keys].delete(key_name)
            response.status = 200
            response.body = {"success"=>true}
          else
            response.status = 404
          end
          response
        end

      end
    end
  end
end

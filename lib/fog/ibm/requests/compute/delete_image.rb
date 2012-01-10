module Fog
  module Compute
    class IBM
      class Real

        # Delete an image
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>
        # TODO: docs
        def delete_image(image_id)
          options = {
            :method   => 'DELETE',
            :expects  => 200,
            :path     => "/offerings/image/#{image_id}",
          }
          request(options)
        end

      end
    end
  end
end

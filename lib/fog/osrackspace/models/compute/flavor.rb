require 'fog/core/model'

module Fog
  module Compute
    class OSRackspace

      class Flavor < Fog::Model

        identity :id

        attribute :disk
        attribute :name
        attribute :ram
        attribute :swap
        attribute :vcpus
        attribute :rxtx_factor
        attribute :links
      end

    end
  end
end

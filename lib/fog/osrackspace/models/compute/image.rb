require 'fog/core/model'
require 'fog/osrackspace/models/compute/metadata'

module Fog
  module Compute
    class OSRackspace

      class Image < Fog::Model

        identity :id

        attribute :name
        attribute :created_at,  :aliases => 'created'
        attribute :updated_at,  :aliases => 'updated'
        attribute :progress
        attribute :status
        attribute :minDisk
        attribute :minRam
        attribute :server,   :aliases => 'server'
        attribute :metadata
        attribute :links

        def initialize(attributes)
          @connection = attributes[:connection]
          super
        end

        def metadata
          @metadata ||= begin
            Fog::Compute::OSRackspace::Metadata.new({
              :connection => connection,
              :parent => self
            })
          end
        end

        def metadata=(new_metadata={})
          metas = []
          new_metadata.each_pair {|k,v| metas << {"key" => k, "value" => v} }
          metadata.load(metas)
        end

        def destroy
          requires :id
          connection.delete_image(id)
          true
        end

        def ready?
          status == 'ACTIVE'
        end

        def metadata_value(key)
          metadata.each do |md|
            if md.key.eql?(key)
              return md.value
            end
          end
        end

      end

    end
  end
end

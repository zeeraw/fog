require 'fog/core/collection'
require 'fog/rackspaceos/models/meta_parent'
require 'fog/rackspaceos/models/compute/meta'
require 'fog/rackspaceos/models/compute/image'
require 'fog/rackspaceos/models/compute/server'

module Fog
  module Compute
    class RackspaceOS

      class Metadata < Fog::Collection

        model Fog::Compute::RackspaceOS::Meta

        include Fog::Compute::RackspaceOS::MetaParent

        def all
          requires :parent
          metadata = connection.list_metadata(collection_name, @parent.id).body['metadata']
          metas = []
          metadata.each_pair {|k,v| metas << {"key" => k, "value" => v} }
          load(metas)
        end

        def get(key)
          requires :parent
          data = connection.get_meta(collection_name, @parent.id, key).body["meta"]
          metas = []
          data.each_pair {|k,v| metas << {"key" => k, "value" => v} }
          new(metas[0])
        rescue Fog::Compute::RackspaceOS::NotFound
          nil
        end

        def update(data=nil)
          requires :parent
          connection.update_metadata(collection_name, @parent.id, meta_hash(data))
        end

        def set(data=nil)
          requires :parent
          connection.set_metadata(collection_name, @parent.id, meta_hash(data))
        end

        def new(attributes = {})
          requires :parent
          super({ :parent => @parent }.merge!(attributes))
        end

        private
        def meta_hash(data=nil)
          if data.nil?
            data={}
            self.each do |meta|
              if meta.is_a?(Fog::Compute::RackspaceOS::Meta) then
                data.store(meta.key, meta.value)
              else
                data.store(meta["key"], meta["value"])
              end
            end
          end
          data
        end

      end

    end
  end
end

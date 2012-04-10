require 'fog/core/model'
require 'fog/rackspaceos/models/meta_parent'

module Fog
  module Compute
    class RackspaceOS
      class Meta < Fog::Model

        include Fog::Compute::RackspaceOS::MetaParent

        identity :key
        attribute :value

        def destroy
          requires :identity
          connection.delete_meta(collection_name, @parent.id, key)
          true
        end

        def save
          requires :identity, :value
          connection.update_meta(collection_name, @parent.id, key, value)
          true
        end

      end
    end
  end
end

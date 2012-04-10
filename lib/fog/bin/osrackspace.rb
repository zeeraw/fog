class OSRackspace < Fog::Bin
  class << self

    def class_for(key)
      case key
      when :compute
        Fog::Compute::OSRackspace
      else
        raise ArgumentError, "Unrecognized service: #{key}"
      end
    end

    def [](service)
      @@connections ||= Hash.new do |hash, key|
        hash[key] = case key
        when :compute
          Fog::Logger.warning("OSRackspace[:compute] is not recommended, use Compute[:rackspace] for portability")
          Fog::Compute.new(:provider => 'OSRackspace')
        else
          raise ArgumentError, "Unrecognized service: #{key.inspect}"
        end
      end
      @@connections[service]
    end

    def services
      Fog::OSRackspace.services
    end

  end
end

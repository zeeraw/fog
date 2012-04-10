require(File.expand_path(File.join(File.dirname(__FILE__), 'core')))

module Fog
  module OSRackspace
    extend Fog::Provider

    module Errors
      class ServiceError < Fog::Errors::Error
        attr_reader :response_data

        def self.slurp(error)
          if error.response.body.empty?
            data = nil
            message = nil
          else
            data = MultiJson.decode(error.response.body)
            message = data['message']
          end

          new_error = super(error, message)
          new_error.instance_variable_set(:@response_data, data)
          new_error
        end
      end

      class InternalServerError < ServiceError; end
      class Conflict < ServiceError; end
      class NotFound < ServiceError; end
      class ServiceUnavailable < ServiceError; end

      class BadRequest < ServiceError
        attr_reader :validation_errors

        def self.slurp(error)
          new_error = super(error)
          unless new_error.response_data.nil?
            new_error.instance_variable_set(:@validation_errors, new_error.response_data['validationErrors'])
          end
          new_error
        end
      end
    end

    service(:compute,         'osrackspace/compute',        'Compute')

    # keystone style auth
    def self.authenticate_v2(options, connection_options = {})
      rackspace_auth_url = options[:rackspace_auth_url] || "https://identity.api.rackspacecloud.com/v2.0/tokens"
      uri = URI.parse(rackspace_auth_url)
      connection = Fog::Connection.new(rackspace_auth_url, false, connection_options)
      @rackspace_username = options[:rackspace_username]
      @rackspace_api_key  = options[:rackspace_api_key]
      @compute_service_name = options[:rackspace_compute_service_name] || "cloudServersOpenStack"

      req_body= {
        'auth' => {
          'RAX-KSKEY:apiKeyCredentials'  => {
            'username' => @rackspace_username,
            'apiKey' => @rackspace_api_key
          }
        }
      }

      response = connection.request({
          :expects  => [200, 204],
          :headers => {'Content-Type' => 'application/json'},
          :body  => MultiJson.encode(req_body),
          :host     => uri.host,
          :method   => 'POST',
          :path     =>  (uri.path and not uri.path.empty?) ? uri.path : 'v2.0'
        })
      body=MultiJson.decode(response.body)

      Fog::Logger.debug("OSRackspace[:compute] body: #{body}")

      if svc = body['access']['serviceCatalog'].detect{|x| x['name'] == @compute_service_name}
        mgmt_url = svc['endpoints'].detect{|x| x['publicURL']}['publicURL']
        token = body['access']['token']['id']
        return {
          :token => token,
          :server_management_url => mgmt_url
        }
      else
        raise "Unable to parse service catalog."
      end

    end

  end
end

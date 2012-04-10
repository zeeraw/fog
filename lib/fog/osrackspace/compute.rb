require File.expand_path(File.join(File.dirname(__FILE__), '..', 'osrackspace'))
require 'fog/compute'
require 'fog/osrackspace'

module Fog
  module Compute
    class OSRackspace < Fog::Service

      requires :osrackspace_api_key, :osrackspace_username, :osrackspace_auth_url
      recognizes :osrackspace_auth_token, :osrackspace_management_url, :persistent, :osrackspace_compute_service_name, :osrackspace_tenant

      model_path 'fog/osrackspace/models/compute'
      model       :flavor
      collection  :flavors
      model       :image
      collection  :images
      model       :server
      collection  :servers
      model       :meta
      collection  :metadata

      request_path 'fog/osrackspace/requests/compute'
      request :create_server
      request :delete_image
      request :delete_server
      request :get_flavor_details
      request :get_image_details
      request :get_server_details
      request :list_addresses
      request :list_private_addresses
      request :list_public_addresses
      request :list_flavors
      request :list_flavors_detail
      request :list_images
      request :list_images_detail
      request :list_servers
      request :list_servers_detail

      request :server_action
      request :change_password_server
      request :reboot_server
      request :rebuild_server
      request :resize_server
      request :confirm_resized_server
      request :revert_resized_server
      request :create_image

      request :update_server

      request :set_metadata
      request :update_metadata
      request :list_metadata

      request :get_meta
      request :update_meta
      request :delete_meta

      class Mock

        def self.data
          @data ||= Hash.new do |hash, key|
            hash[key] = {
              :last_modified => {
                :images  => {},
                :servers => {}
              },
              :images  => {
                "1" => {
                  'id'        => "1",
                  'name'      => "img1",
                  'progress'  => 100,
                  'status'    => "ACTIVE",
                  'updated'   => "",
                  'minRam'    => 0,
                  'minDisk'   => 0,
                  'metadata'  => {},
                  'links'     => []
                }
              },
              :servers => {}
            }
          end
        end

        def self.reset
          @data = nil
        end

        def initialize(options={})
          require 'multi_json'
          @osrackspace_username = options[:osrackspace_username]
        end

        def data
          self.class.data[@osrackspace_username]
        end

        def reset_data
          self.class.data.delete(@osrackspace_username)
        end

      end

      class Real

        def initialize(options={})
          require 'multi_json'
          @osrackspace_api_key = options[:osrackspace_api_key]
          @osrackspace_username = options[:osrackspace_username]
          @osrackspace_tenant = options[:osrackspace_tenant]
          @osrackspace_compute_service_name = options[:osrackspace_compute_service_name] || 'nova'
          @osrackspace_auth_url = options[:osrackspace_auth_url]
          @osrackspace_auth_token = options[:osrackspace_auth_token]
          @osrackspace_management_url = options[:osrackspace_management_url]
          @osrackspace_must_reauthenticate = false
          @connection_options = options[:connection_options] || {}
          authenticate
          @persistent = options[:persistent] || false
          @connection = Fog::Connection.new("#{@scheme}://#{@host}:#{@port}", @persistent, @connection_options)
        end

        def reload
          @connection.reset
        end

        def request(params)
          begin
            response = @connection.request(params.merge({
              :headers  => {
                'Content-Type' => 'application/json',
                'X-Auth-Token' => @auth_token
              }.merge!(params[:headers] || {}),
              :host     => @host,
              :path     => "#{@path}/#{params[:path]}",
              :query    => ('ignore_awful_caching' << Time.now.to_i.to_s)
            }))
          rescue Excon::Errors::Unauthorized => error
            if error.response.body != 'Bad username or password' # token expiration
              @osrackspace_must_reauthenticate = true
              authenticate
              retry
            else # bad credentials
              raise error
            end
          rescue Excon::Errors::HTTPStatusError => error
            raise case error
            when Excon::Errors::NotFound
              Fog::Compute::OSRackspace::NotFound.slurp(error)
            else
              error
            end
          end
          unless response.body.empty?
            response.body = MultiJson.decode(response.body)
          end
          response
        end

        private

        def authenticate
          if @osrackspace_must_reauthenticate || @osrackspace_auth_token.nil?
            options = {
              :osrackspace_api_key  => @osrackspace_api_key,
              :osrackspace_username => @osrackspace_username,
              :osrackspace_auth_url => @osrackspace_auth_url,
              :osrackspace_tenant => @osrackspace_tenant,
              :osrackspace_compute_service_name => @osrackspace_compute_service_name
            }
            if @osrackspace_auth_url =~ /\/v2.0\//
              credentials = Fog::OSRackspace.authenticate_v2(options, @connection_options)
            else
              credentials = Fog::OSRackspace.authenticate_v1(options, @connection_options)
            end
            @auth_token = credentials[:token]
            url = credentials[:server_management_url]
            uri = URI.parse(url)
          else
            @auth_token = @osrackspace_auth_token
            uri = URI.parse(@osrackspace_management_url)
          end
          @host   = uri.host
          @path   = uri.path
          @path.sub!(/\/$/, '')
          unless @path.match(/1\.1/)
            raise Fog::Compute::OSRackspace::ServiceUnavailable.new(
                    "OSRackspace binding only supports version 1.1")
          end
          @port   = uri.port
          @scheme = uri.scheme
        end

      end
    end
  end
end

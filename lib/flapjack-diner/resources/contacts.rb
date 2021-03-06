require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Contacts

        def create_contacts(*args)
          ids, data = unwrap_create_ids_and_data(*args)
          data.each do |d|
            validate_params(d) do
              validate :query => [:first_name, :last_name, :email], :as => [:required, :string]
              validate :query => :timezone,   :as => :string
              validate :query => :tags,       :as => :array_of_strings
            end
          end
          perform_post('/contacts', nil, :contacts => data)
        end

        def contacts(*ids)
          perform_get('contacts', '/contacts', ids)
        end

        def update_contacts(*args)
          ids, params, data = unwrap_ids_params_and_data(*args)
          raise "'update_contacts' requires at least one contact id parameter" if ids.nil? || ids.empty?
          validate_params(params) do
              validate :query => [:first_name, :last_name,
                                  :email, :timezone], :as => :string
              validate :query => :tags,       :as => :array_of_strings
          end
          ops = params.inject([]) do |memo, (k,v)|
            case k
            when :add_entity
              memo << {:op    => 'add',
                       :path  => '/contacts/0/links/entities/-',
                       :value => v}
            when :remove_entity
              memo << {:op    => 'remove',
                       :path  => "/contacts/0/links/entities/#{v}"}
            when :add_notification_rule
              memo << {:op    => 'add',
                       :path  => '/contacts/0/links/notification_rules/-',
                       :value => v}
            when :remove_notification_rule
              memo << {:op    => 'remove',
                       :path  => "/contacts/0/links/notification_rules/#{v}"}
            when :first_name, :last_name, :email, :timezone
              memo << {:op    => 'replace',
                       :path  => "/contacts/0/#{k.to_s}",
                       :value => v}
            end
            memo
          end
          raise "'update_contacts' did not find any valid update fields" if ops.empty?
          perform_patch("/contacts/#{escaped_ids(ids)}", nil, ops)
        end

        def delete_contacts(*ids)
          raise "'delete_contacts' requires at least one contact id parameter" if ids.nil? || ids.empty?
          perform_delete('/contacts', ids)
        end

      end

    end
  end
end

require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module MaintenancePeriods

        ['entities', 'checks'].each do |data_type|

          define_method("create_scheduled_maintenances_#{data_type}") do |*args|
            ids, data = unwrap_create_ids_and_data(*args)
            raise "'create_scheduled_maintenances_#{data_type}' requires at least one #{data_type} id parameter" if ids.nil? || ids.empty?
            data.each do |d|
              validate_params(d) do
                validate :query => :start_time, :as => [:required, :time]
                validate :query => :duration,   :as => [:required, :integer]
                validate :query => :summary,    :as => :string
              end
            end
            perform_post("/scheduled_maintenances/#{data_type}", ids,
              :scheduled_maintenances => data)
          end

          define_method("create_unscheduled_maintenances_#{data_type}") do |*args|
            ids, data = unwrap_create_ids_and_data(*args)
            raise "'create_unscheduled_maintenances_#{data_type}' requires at least one #{data_type} id parameter" if ids.nil? || ids.empty?
            data.each do |d|
              validate_params(d) do
                validate :query => :duration,   :as => [:required, :integer]
                validate :query => :summary,    :as => :string
              end
            end
            perform_post("/unscheduled_maintenances/#{data_type}", ids,
              :unscheduled_maintenances => data)
          end

          define_method("update_unscheduled_maintenances_#{data_type}") do |*args|
            ids, params, data = unwrap_ids_params_and_data(*args)
            raise "'update_unscheduled_maintenances_#{data_type}' requires at least one #{data_type} id parameter" if ids.nil? || ids.empty?
            validate_params(params) do
              validate :query => :end_time, :as => :time
            end
            ops = params.inject([]) do |memo, (k,v)|
              case k
              when :end_time
                memo << {:op    => 'replace',
                         :path  => "/unscheduled_maintenances/0/#{k.to_s}",
                         :value => v}
              end
              memo
            end
            raise "'update_unscheduled_maintenances_#{data_type}' did not find any valid update fields" if ops.empty?
            perform_patch("/unscheduled_maintenances/#{data_type}", ids, ops)
          end

          define_method("delete_scheduled_maintenances_#{data_type}") do |*args|
            ids, params, data = unwrap_ids_params_and_data(*args)
            raise "'delete_scheduled_maintenances_#{data_type}' requires at least one #{data_type} id parameter" if ids.nil? || ids.empty?
            validate_params(params) do
              validate :query => :start_time, :as => [:required, :time]
            end
            perform_delete("/scheduled_maintenances/#{data_type}", ids, params)
          end

        end

      end

    end
  end
end

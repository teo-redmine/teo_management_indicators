require_dependency 'settings_controller'
require_dependency 'projects_controller'

module TeoManagementIndicatorsSettings
	def self.included(base)
		base.send(:include, InstanceMethods)

		base.class_eval do
			# Con esto sobreescribimos el metodo plugin del controlador de settings
			alias_method_chain :plugin, :managementindicators
		end
	end

	module InstanceMethods
		def plugin_with_managementindicators
			if params[:id] == 'teo_management_indicators'
				@project_custom_fields = IssueCustomField.sorted

				@fields = Hash.new

				tracker_fields = Tracker::CORE_FIELDS

				if !tracker_fields.empty?
					tracker_fields.each do |field|
						@fields["core__" + field] = I18n.t(("field_" + field).sub(/_id$/, ''))
					end
				end

				if !@project_custom_fields.empty?
					@project_custom_fields.each do |field|
						@fields["custom__" + field.id.to_s] = I18n.t("field_" + field.name)
					end
				end
			end

		    plugin_without_managementindicators
		end
	end
end

module TeoManagementIndicatorsProjects
	def self.included(base)
		base.send(:include, InstanceMethods)

		base.class_eval do
			before_filter :get_settings
			# Con esto sobreescribimos el metodo show del controlador de projects
			alias_method_chain :show, :managementindicators
		end
	end

	module InstanceMethods
		def show_with_managementindicators
			calculaGraficas("projects")

		    show_without_managementindicators
		end

		def get_settings
			@settings = Setting.plugin_teo_management_indicators
		end
	end
end

SettingsController.send(:include, TeoManagementIndicatorsSettings::InstanceMethods)
ProjectsController.send(:include, TeoManagementIndicatorsProjects::InstanceMethods)
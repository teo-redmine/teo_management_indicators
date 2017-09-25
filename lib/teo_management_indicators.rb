require_dependency 'settings_controller'

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
				@fieldsDate = Hash.new
				@fieldsFloat = Hash.new
				@fieldsProject = Hash.new

				tracker_fields = Tracker::CORE_FIELDS

				if !tracker_fields.empty?
					tracker_fields.each do |field|
						@fields["core__" + field] = I18n.t(("field_" + field).sub(/_id$/, ''))

						if Issue.columns_hash[field].to_s != nil && Issue.columns_hash[field].to_s != '' && Issue.columns_hash[field].type != nil && Issue.columns_hash[field.to_s].type.to_s != nil && Issue.columns_hash[field.to_s].type.to_s != ''
							if Issue.columns_hash[field.to_s].type.to_s == 'float'
								@fieldsFloat["core__" + field] = I18n.t(("field_" + field).sub(/_id$/, ''))
							end
							if Issue.columns_hash[field.to_s].type.to_s == 'date'
								@fieldsDate["core__" + field] = I18n.t(("field_" + field).sub(/_id$/, ''))
							end
							if Issue.columns_hash[field.to_s].type.to_s == 'project'
								@fieldsProject["core__" + field] = I18n.t(("field_" + field).sub(/_id$/, ''))
							end
						end
					end
				end

				if !@project_custom_fields.empty?
					@project_custom_fields.each do |field|
						@fields["custom__" + field.id.to_s] = I18n.t("field_" + field.name, default: field.name)

						if field.field_format != nil && field.field_format.to_s != nil && field.field_format.to_s != ''
							if field.field_format.to_s == 'float'
								@fieldsFloat["custom__" + field.id.to_s] = I18n.t("field_" + field.name, default: field.name)
							end
							if field.field_format.to_s == 'date'
								@fieldsDate["custom__" + field.id.to_s] = I18n.t("field_" + field.name, default: field.name)
							end
							if field.field_format.to_s == 'project'
								@fieldsProject["custom__" + field.id.to_s] = I18n.t("field_" + field.name, default: field.name)
							end
						end
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
			# Con esto sobreescribimos el metodo show del controlador de projects
			alias_method_chain :show, :managementindicators
		end
	end

	module InstanceMethods
		def show_with_managementindicators
			calculaGraficas("projects")

		    show_without_managementindicators
		end
	end
end

SettingsController.send(:include, TeoManagementIndicatorsSettings::InstanceMethods)
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
				@fieldsDateImpEjec = Hash.new
				@fieldsFloat = Hash.new
				@fieldsProject = Hash.new

				tracker_fields = Tracker::CORE_FIELDS
				closed_on_issue = Issue::_default_attributes['closed_on'].name

				if !tracker_fields.empty?
					tracker_fields.each do |field|
						@fields["core__" + field] = I18n.t(("field_" + field).sub(/_id$/, ''))

						if Issue.columns_hash[field].to_s != nil && Issue.columns_hash[field].to_s != '' && Issue.columns_hash[field].type != nil && Issue.columns_hash[field.to_s].type.to_s != nil && Issue.columns_hash[field.to_s].type.to_s != ''
							if Issue.columns_hash[field.to_s].type.to_s == 'float'
								@fieldsFloat["core__" + field] = I18n.t(("field_" + field).sub(/_id$/, ''))
							end
							if Issue.columns_hash[field.to_s].type.to_s == 'date'
								@fieldsDate["core__" + field] = I18n.t(("field_" + field).sub(/_id$/, ''))
								@fieldsDateImpEjec["core__" + field] = I18n.t(("field_" + field).sub(/_id$/, ''))
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
								@fieldsDateImpEjec["custom__" + field.id.to_s] = I18n.t("field_" + field.name, default: field.name)
							end
							if field.field_format.to_s == 'project'
								@fieldsProject["custom__" + field.id.to_s] = I18n.t("field_" + field.name, default: field.name)
							end
						end
					end
				end

				if !closed_on_issue.nil?
					@fieldsDateImpEjec["issue__" + closed_on_issue] = I18n.t("field_" + closed_on_issue, default: closed_on_issue)
				end
			end

=begin
			#Esto se estaba montando para pasar unas validaciones en la configuracion del plugin
			if params.include? 'settings'
				valorLG4_1 = params['settings']['limit_g4_1']
				valorLG4_2 = params['settings']['limit_g4_2']
				valorLG4_3 = params['settings']['limit_g4_3']
				valorLG4_4 = params['settings']['limit_g4_4']
				valorLG4_5 = params['settings']['limit_g4_5']
				valorLG5_1 = params['settings']['limit_g5_1']
				valorLG5_2 = params['settings']['limit_g5_2']
				valorLG5_3 = params['settings']['limit_g5_3']
				valorLG5_4 = params['settings']['limit_g5_4']
				valorLG5_5 = params['settings']['limit_g5_5']

				if verificarNuloYvacio(valorLG4_1) || verificarNuloYvacio(valorLG4_2) 
					flash[:error] = l(:error_limitsg4_1_2)
				else
					if valorLG4_1.to_i > valorLG4_2.to_i
						flash[:error] = l(:error_limitsg4_1)
					end
				end

				if verificarNuloYvacio(valorLG4_2) || verificarNuloYvacio(valorLG4_3) 
					flash[:error] = l(:error_limitsg4_2_3)
				else
					if valorLG4_2.to_i > valorLG4_3.to_i
						flash[:error] = l(:error_limitsg4_2)
					end
				end

				if verificarNuloYvacio(valorLG4_3) || verificarNuloYvacio(valorLG4_4) 
					flash[:error] = l(:error_limitsg4_3_4)
				else
					if valorLG4_3.to_i > valorLG4_4.to_i
						flash[:error] = l(:error_limitsg4_3)
					end
				end

				if verificarNuloYvacio(valorLG4_4) || verificarNuloYvacio(valorLG4_5) 
					flash[:error] = l(:error_limitsg4_4_5)
				else
					if valorLG4_4.to_i > valorLG4_5.to_i
						flash[:error] = l(:error_limitsg4_4)
					end
				end

				if verificarNuloYvacio(valorLG5_1) || verificarNuloYvacio(valorLG5_2)
					flash[:error] = l(:error_limitsg5_1_2)
				else
					if valorLG5_1.to_i > valorLG5_2.to_i
						flash[:error] = l(:error_limitsg5_1)
					end
				end

				if verificarNuloYvacio(valorLG5_2) || verificarNuloYvacio(valorLG5_3)
					flash[:error] = l(:error_limitsg5_2_3)
				else
					if valorLG5_2.to_i > valorLG5_3.to_i
						flash[:error] = l(:error_limitsg5_2)
					end
				end

				if verificarNuloYvacio(valorLG5_3) || verificarNuloYvacio(valorLG5_4)
					flash[:error] = l(:error_limitsg5_3_4)
				else
					if valorLG5_3.to_i > valorLG5_4.to_i
						flash[:error] = l(:error_limitsg5_3)
					end
				end

				if verificarNuloYvacio(valorLG5_4) || verificarNuloYvacio(valorLG5_5)
					flash[:error] = l(:error_limitsg5_4_5)
				else
					if valorLG5_4.to_i > valorLG5_5.to_i
						flash[:error] = l(:error_limitsg5_4)
					end
				end
			end
=end
			
		    plugin_without_managementindicators
		end

		def verificarNuloYvacio (valor)
			return valor.nil? || valor.empty?			
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
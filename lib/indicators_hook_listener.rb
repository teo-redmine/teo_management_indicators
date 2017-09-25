class IndicatorsHookListener < Redmine::Hook::ViewListener
	render_on :view_projects_show_right, :partial => "indicadores/indicadores"
	#render_on :view_issues_show_description_bottom, :partial => "indicadores/indicadores_issue"
	#render_on :view_issues_show_description_bottom, :partial => "indicadores/indicadores"
end
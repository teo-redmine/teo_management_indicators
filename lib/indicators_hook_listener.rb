class IndicatorsHookListener < Redmine::Hook::ViewListener
	render_on :view_projects_show_right, :partial => "indicadores/indicadores"
end
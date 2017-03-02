class IndicadoresController < ApplicationController
  unloadable

  before_filter :find_project, :get_settings, :authorize, :only => :index

  def index
    calculaGraficas("indicadores")
  end

  private

  def find_project
  	# @project variable must be set before calling the authorize filter
  	@project = Project.find(params[:project_id])
  end

  def get_settings
    @settings = Setting.plugin_teo_management_indicators
  end
end
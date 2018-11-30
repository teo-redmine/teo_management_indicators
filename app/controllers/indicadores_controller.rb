class IndicadoresController < ApplicationController
  unloadable

  before_filter :find_project, :authorize, :only => :index

  def index
    calculaGraficas("indicadores")
  end

  def actualizar
    update_issues(Project.find(params[:project_id]))
    #Al pasarle el render le decimos que esa pagina es la que queremos mostrar
    #en el archivo routes le hacemos el action controller para llamar a este metodo
    render "indicadores/actissues"
  end

  private

  def find_project
  	# @project variable must be set before calling the authorize filter
  	@project = Project.find(params[:project_id])
  end

  def update_issues project
    tipoPetG4 = nil
    tipoPetG5 = nil
    listaIssues = nil

    if !project.nil?
      condicion = project.project_condition(true)
      whereProject = Project.where(condicion)

      proyectoPadre = whereProject[0]
      while proyectoPadre.parent_id != nil do
         proyectoPadre = Project.where({id: proyectoPadre.parent_id})[0]
      end

      esSis = proyectoPadre.identifier.downcase.include?(I18n.t("proy_sis_info").downcase)

      @settings = IndicatorsUtils::Settings.new
      if !@settings.tipospeticiong4n1.nil? && @settings.tipospeticiong4n1.any?
        tipoPetG4 = @settings.tipospeticiong4n1[0]
      end

      if !@settings.tipospeticiong5n1.nil? && @settings.tipospeticiong5n1.any?
        tipoPetG5 = @settings.tipospeticiong5n1[0]
      end

      if tipoPetG4.id == tipoPetG5.id        
        listaIssues = obtenerListaIssuesCompleta(esSis, tipoPetG4, whereProject)
      else
        listaIssues = obtenerListaIssuesCompleta(esSis, tipoPetG4, whereProject)
        listaIssues2 = obtenerListaIssuesCompleta(esSis, tipoPetG5, whereProject)

        listaIssues2.each do |issu|
          listaIssues.push(issu)
        end
      end

      puts 'Se comprueba que la lista de Issues no esta vacia'
      if !listaIssues.nil? && !listaIssues.empty?
        puts 'EMPIEZA actualizar las issues'
        listaIssues.each do |issu|
          issu.reload
          issu.save
        end
        puts 'Termina de actualizar las issues'
      end
    end    
  end

  def obtenerListaIssuesCompleta esSis, tipoPet, whereProject
    listaIssues = Array.new

    if esSis
      listaIssues = Issue.where({tracker: tipoPet.id, project: whereProject})
    else
      listaIdsIssues = CustomValue.where('value in (' + whereProject.ids.join(",")+')')
      if listaIdsIssues != nil && !listaIdsIssues.empty?
        listaIssues = Array.new
        listaIdsIssues.each do |issueL|
          issueGood = Issue.where({id: issueL.customized_id, tracker: tipoPet.id})[0]
          if issueGood != nil
            listaIssues.push(issueGood)
          end
        end        
      end
    end
    return listaIssues
  end
end
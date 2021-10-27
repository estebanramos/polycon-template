module Polycon
  module Commands
    module Professionals

      
      class Create < Dry::CLI::Command
        desc 'Create a professional'

        argument :name, required: true, desc: 'Full name of the professional'

        example [
          '"Alma Estevez"      # Creates a new professional named "Alma Estevez"',
          '"Ernesto Fernandez" # Creates a new professional named "Ernesto Fernandez"'
        ]

        def call(name:, **)
          begin
            professional = Professional.new(name)
            FileUtils.mkdir ".polycon/#{professional.get_professional_format}" #unless Dir.entries('.polycon/'+directory_name)
            warn "Se ha creado el profesional correctamente"
            return
          rescue Errno::EEXIST => exception 
            warn 'ERROR: Ya existe un profesional con ese nombre'
            return
        end
        end
      end

      class Delete < Dry::CLI::Command
        desc 'Delete a professional (only if they have no appointments)'

        argument :name, required: true, desc: 'Name of the professional'

        example [
          '"Alma Estevez"      # Deletes a new professional named "Alma Estevez" if they have no appointments',
          '"Ernesto Fernandez" # Deletes a new professional named "Ernesto Fernandez" if they have no appointments'
        ]

        def call(name: nil)
          begin
            professional = Professional.new(name)
            filename = professional.get_professional_format
            directorios = Dir.entries("./.polycon/#{filename}")
            # Borro el . y ..
            directorios.delete(".")
            directorios.delete("..")
            begin
              Dir.delete("./.polycon/#{professional.get_professional_format}")
              warn "Profesional Borrado"
            rescue Errno::ENOTEMPTY => exception
              warn "ERROR: No se ha podido borrar el Profesional, tiene turnos asignados"
            end
          rescue => exception
            warn "ERROR: No se ha encontrado un Profesional con ese nombre: #{professional.name}"
        end
        end
      end

      class List < Dry::CLI::Command
        desc 'List professionals'

        example [
          "          # Lists every professional's name"
        ]

        def call(*)
          begin
            directorios = Dir.entries("./.polycon")
            # Borro el . y ..
            directorios.delete(".")
            directorios.delete("..")
            warn "[#] Profesionales [#]"
            directorios.each do |d|
              d = d.split("-")
             warn "  #{d[0]+' '+d[1]}  "
            end
          rescue => exception
            warn "ERROR: Ha surgido un error desconocido: #{exception}"
          end 
        end
      end

      class Rename < Dry::CLI::Command
        desc 'Rename a professional'

        argument :old_name, required: true, desc: 'Current name of the professional'
        argument :new_name, required: true, desc: 'New name for the professional'

        example [
          '"Alna Esevez" "Alma Estevez" # Renames the professional "Alna Esevez" to "Alma Estevez"',
        ]

        def call(old_name:, new_name:, **)
          old_professional =  Professional.new(old_name)
          new_professional =  Professional.new(new_name)

          old_name = old_professional.get_professional_format
          new_name = new_professional.get_professional_format
          begin
            FileUtils.mv ".polycon/#{old_name}", ".polycon/#{new_name}"
            warn "Profesional Renombrado"
          rescue => exception
            warn "ERROR: Ha surgido un problema renombrando al Profesional: #{exception}"
          end    
        end
      end
    end
  end
end

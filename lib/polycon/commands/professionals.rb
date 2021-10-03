module Polycon
  module Commands
    module Professionals
      def get_professional_format(name)
        professional_name = name.split(" ")
        directory_name = professional_name[0]+'-'+professional_name[1]
        return directory_name
      end
      
      class Create < Dry::CLI::Command
        include Professionals
        desc 'Create a professional'

        argument :name, required: true, desc: 'Full name of the professional'

        example [
          '"Alma Estevez"      # Creates a new professional named "Alma Estevez"',
          '"Ernesto Fernandez" # Creates a new professional named "Ernesto Fernandez"'
        ]

        def call(name:, **)
          begin
            FileUtils.mkdir ".polycon/#{get_professional_format(name)}" #unless Dir.entries('.polycon/'+directory_name)
          rescue Errno::EEXIST => exception 
            warn 'ERROR: Ya existe un profesional con ese nombre'
          end
        end
      end

      class Delete < Dry::CLI::Command
        include Professionals
        desc 'Delete a professional (only if they have no appointments)'

        argument :name, required: true, desc: 'Name of the professional'

        example [
          '"Alma Estevez"      # Deletes a new professional named "Alma Estevez" if they have no appointments',
          '"Ernesto Fernandez" # Deletes a new professional named "Ernesto Fernandez" if they have no appointments'
        ]

        def call(name: nil)
          begin
            directorios = Dir.entries("./.polycon/#{get_professional_format(name)}")
            # Borro el . y ..
            directorios.delete(".")
            directorios.delete("..")
            begin
              Dir.delete("./.polycon/#{get_professional_format(name)}")
              warn "Profesional Borrado"
            rescue SystemCallError => exception
              warn "ERROR: No se ha podido borrar el Profesional, tiene turnos asignados"
            end
          rescue => exception
            warn "ERROR: No se ha encontrado un Profesional con ese nombre: #{get_professional_format(name)}"
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
             warn "#{d[0]+' '+d[1]}"
            end
          rescue => exception
            warn "ERROR: Ha surgido un error desconocido: #{exception}"
          end
        end
      end

      class Rename < Dry::CLI::Command
        include Professionals
        desc 'Rename a professional'

        argument :old_name, required: true, desc: 'Current name of the professional'
        argument :new_name, required: true, desc: 'New name for the professional'

        example [
          '"Alna Esevez" "Alma Estevez" # Renames the professional "Alna Esevez" to "Alma Estevez"',
        ]

        def call(old_name:, new_name:, **)
          old_name = get_professional_format(old_name)
          new_name = get_professional_format(new_name)
          begin
          FileUtils.mv ".polycon/#{old_name}", ".polycon/#{new_name}"
          rescue => exception
            warn "ERROR: Ha surgido un problema renombrando al Profesional"
          end
        end
      end
    end
  end
end

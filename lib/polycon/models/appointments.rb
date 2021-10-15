module Polycon
    class Appointment
        require 'time'
        
        def self.get_professional_format(name)
          begin
            professional_name = name.split(" ")
            directory_name = professional_name[0]+'-'+professional_name[1]
            return directory_name
          rescue => exception
            warn "ERRROR: Ha ocurrido un error parseando el nombre del profesional"
            warn exception
          end
        end
  
        def self.get_filename_date(date)
          begin
            date = Time.parse(date)
            return date.strftime("%Y-%m-%d_%k-%M")
          rescue => exception
            warn "ERROR: Mal formato de fecha"
            exit
          end
        end

        def self.create_appointment(date:, professional:, name:, surname:, phone:, notes: nil)
            filename = get_filename_date(date)
            directory_name = get_professional_format(professional)
  
            #TODO estandarizar path 
            if File.exists?("./.polycon/#{directory_name}/#{filename}")
              warn "ERROR: El Profesional ya tiene un turno asignado para ese horario"
            else
              begin
                file = File.open("./.polycon/#{directory_name}/#{filename}", "w")
                file.write("#{surname}\n#{name}\n#{phone}\n#{notes}")
                file.close()
                warn "Turno asignado correctamente"
              rescue Errno::ENOENT => exception
                warn "ERROR: No se encuentra un Profesional con ese nombre"
              rescue => exception
                warn "ERROR: Ha surgido un error desconocido"
              end          
            end
        end
    end
end
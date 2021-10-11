module Polycon
  module Commands
    module Appointments
      require 'time'
      def get_professional_format(name)
        professional_name = name.split(" ")
        directory_name = professional_name[0]+'-'+professional_name[1]
        return directory_name
      end
      class Create < Dry::CLI::Command
        include Appointments

        desc 'Create an appointment'

        argument :date, required: true, desc: 'Full date for the appointment'
        option :professional, required: true, desc: 'Full name of the professional'
        option :name, required: true, desc: "Patient's name"
        option :surname, required: true, desc: "Patient's surname"
        option :phone, required: true, desc: "Patient's phone number"
        option :notes, required: false, desc: "Additional notes for appointment"

        example [
          '"2021-09-16 13:00" --professional="Alma Estevez" --name=Carlos --surname=Carlosi --phone=2213334567'
        ]

        def call(date:, professional:, name:, surname:, phone:, notes: nil)
          begin
            date = Time.parse(date)
            filename = date.strftime("%Y-%m-%d_%k-%M")
            directory_name = get_professional_format(professional)
          rescue => exception
            warn "ERROR: Mal formato de fecha"
            exit
          end

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

      class Show < Dry::CLI::Command
        include Appointments
        desc 'Show details for an appointment'

        argument :date, required: true, desc: 'Full date for the appointment'
        option :professional, required: true, desc: 'Full name of the professional'

        example [
          '"2021-09-16 13:00" --professional="Alma Estevez" # Shows information for the appointment with Alma Estevez on the specified date and time'
        ]

        def call(date:, professional:)
          warn "TODO: Implementar detalles de un turno con fecha '#{date}' y profesional '#{professional}'.\nPodés comenzar a hacerlo en #{__FILE__}:#{__LINE__}."
          begin
            date = Time.parse(date)
            filename = date.strftime("%Y-%m-%d_%k-%M")
            directory_name = get_professional_format(professional)
          rescue => exception
            warn "ERROR: Mal formato de fecha"
            warn exception
            exit
          end
          if File.exists?("./.polycon/#{directory_name}/#{filename}")
            file = File.open("./.polycon/#{directory_name}/#{filename}")
            warn file.read

          else
            warn "ERROR: No hay un Appointment para la fecha especificada o el Profesional no existe"
          end

        end
      end

      class Cancel < Dry::CLI::Command
        include Appointments
        desc 'Cancel an appointment'

        argument :date, required: true, desc: 'Full date for the appointment'
        option :professional, required: true, desc: 'Full name of the professional'

        example [
          '"2021-09-16 13:00" --professional="Alma Estevez" # Cancels the appointment with Alma Estevez on the specified date and time'
        ]

        def call(date:, professional:)
          warn "TODO: Implementar borrado de un turno con fecha '#{date}' y profesional '#{professional}'.\nPodés comenzar a hacerlo en #{__FILE__}:#{__LINE__}."
          begin
            date = Time.parse(date)
            filename = date.strftime("%Y-%m-%d_%k-%M")
            directory_name = get_professional_format(professional)
          rescue => exception
            warn "ERROR: Mal formato de fecha"
            warn exception
            exit
          end
          if File.exists?("./.polycon/#{directory_name}/#{filename}")
            begin
              File.delete("./.polycon/#{directory_name}/#{filename}")
              warn "Appointment borrado"
            rescue => exception
              warn "ERROR: Ya surgido un error borrando el Appointment"
              warn exception
            end      
          else
            warn "ERROR: No hay un Appointment para la fecha especificada o el Profesional no existe"
          end
        end
      end

      class CancelAll < Dry::CLI::Command
        include Appointments
        desc 'Cancel all appointments for a professional'

        argument :professional, required: true, desc: 'Full name of the professional'

        example [
          '"Alma Estevez" # Cancels all appointments for professional Alma Estevez',
        ]

        def call(professional:)
          warn "TODO: Implementar borrado de todos los turnos de la o el profesional '#{professional}'.\nPodés comenzar a hacerlo en #{__FILE__}:#{__LINE__}."
          begin
            directory_name = get_professional_format(professional)
          rescue => exception
            warn "ERROR: Mal formato de fecha"
          end
          if Dir.exists?("./.polycon/#{directory_name}")
            begin
              FileUtils.rm_rf(Dir["./.polycon/#{directory_name}/*"])
              warn "Appointments borrados"
            rescue => exception
              warn "ERROR: Ya surgido un error borrando el Appointment"
              warn exception
            end      
          else
            warn "ERROR: No hay un Appointment para la fecha especificada o el Profesional no existe"
          end
        end
      end

      class List < Dry::CLI::Command
        include Appointments
        desc 'List appointments for a professional, optionally filtered by a date'

        argument :professional, required: true, desc: 'Full name of the professional'
        option :date, required: false, desc: 'Date to filter appointments by (should be the day)'

        example [
          '"Alma Estevez" # Lists all appointments for Alma Estevez',
          '"Alma Estevez" --date="2021-09-16" # Lists appointments for Alma Estevez on the specified date'
        ]

        def call(professional:, date: nil)
          warn "TODO: Implementar listado de turnos de la o el profesional '#{professional}'.\nPodés comenzar a hacerlo en #{__FILE__}:#{__LINE__}."
          begin
            directory_name = get_professional_format(professional)
          rescue => exception
            warn "ERROR: Mal formato de fecha"
          end
          warn directory_name
          if Dir.exists?("./.polycon/#{directory_name}")
            directorios = Dir.entries("./.polycon/#{directory_name}")
            # Borro el . y ..
            directorios.delete(".")
            directorios.delete("..")
            if date 
              directorios.each do |d|
                date_filename = d.split("_")[0]
                if date == date_filename
                  file = File.open("./.polycon/#{directory_name}/#{d}")
                  warn file.read
                end
              end
            else 
              directorios.each do |d|
                file = File.open("./.polycon/#{directory_name}/#{d}")
                warn file.read
              end
              
            end
          else
            warn "ERROR: No hay un Appointment para la fecha especificada o el Profesional no existe"
          end
        end
      end

      class Reschedule < Dry::CLI::Command
        include Appointments
        desc 'Reschedule an appointment'

        argument :old_date, required: true, desc: 'Current date of the appointment'
        argument :new_date, required: true, desc: 'New date for the appointment'
        option :professional, required: true, desc: 'Full name of the professional'

        example [
          '"2021-09-16 13:00" "2021-09-16 14:00" --professional="Alma Estevez" # Reschedules appointment on the first date for professional Alma Estevez to be now on the second date provided'
        ]

        def call(old_date:, new_date:, professional:)
          warn "TODO: Implementar cambio de fecha de turno con fecha '#{old_date}' para que pase a ser '#{new_date}'.\nPodés comenzar a hacerlo en #{__FILE__}:#{__LINE__}."
          begin
            old_date = Time.parse(old_date)
            old_date_filename = old_date.strftime("%Y-%m-%d_%k-%M")
            new_date = Time.parse(new_date)
            new_date_filename = new_date.strftime("%Y-%m-%d_%k-%M")
          rescue => exception
            warn "ERROR: Mal formato de fecha"
            exit
          end
          begin
            directory_name = get_professional_format(professional)
          rescue => exception
            warn "ERROR: Mal formato de fecha"
          end
          warn directory_name
          warn old_date_filename
          if File.exists?("./.polycon/#{directory_name}/#{old_date_filename}")
            begin
              File.rename("./.polycon/#{directory_name}/#{old_date_filename}","./.polycon/#{directory_name}/#{new_date_filename}")
            rescue => exception
              warn "ERROR: No se ha podido cambiar la fecha del turno"
              warn exception
            end      
          else
            warn "ERROR: No hay un Appointment para la fecha especificada o el Profesional no existe"
          end
        end
      end

      class Edit < Dry::CLI::Command
        desc 'Edit information for an appointments'

        argument :date, required: true, desc: 'Full date for the appointment'
        option :professional, required: true, desc: 'Full name of the professional'
        option :name, required: false, desc: "Patient's name"
        option :surname, required: false, desc: "Patient's surname"
        option :phone, required: false, desc: "Patient's phone number"
        option :notes, required: false, desc: "Additional notes for appointment"

        example [
          '"2021-09-16 13:00" --professional="Alma Estevez" --name="New name" # Only changes the patient\'s name for the specified appointment. The rest of the information remains unchanged.',
          '"2021-09-16 13:00" --professional="Alma Estevez" --name="New name" --surname="New surname" # Changes the patient\'s name and surname for the specified appointment. The rest of the information remains unchanged.',
          '"2021-09-16 13:00" --professional="Alma Estevez" --notes="Some notes for the appointment" # Only changes the notes for the specified appointment. The rest of the information remains unchanged.',
        ]

        def call(date:, professional:, **options)
          warn "TODO: Implementar modificación de un turno de la o el profesional '#{professional}' con fecha '#{date}', para cambiarle la siguiente información: #{options}.\nPodés comenzar a hacerlo en #{__FILE__}:#{__LINE__}."
        end
      end
    end
  end
end

module Polycon
  module Commands
    module Appointments
      require 'time'
      def get_professional_format(name)
        begin
          professional_name = name.split(" ")
          directory_name = professional_name[0]+'-'+professional_name[1]
          return directory_name
        rescue => exception
          warn "ERRROR: Ha ocurrido un error parseando el nombre del profesional"
          warn exception
        end
      end

      def get_filename_date(date)
        begin
          date = Time.parse(date)
          return date.strftime("%Y-%m-%d_%k-%M")
        rescue => exception
          warn "ERROR: Mal formato de fecha"
          exit
        end
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
          appointment = Appointment.new(date: date, professional: professional, name: name, surname: surname, phone: phone, notes: notes)
          professional = Professional.new(professional)

          filename = appointment.get_filename_date
          directory_name = professional.get_professional_format

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
          professional = Professional.new(professional)
          directory_name = professional.get_professional_format

          filename = Appointment.get_filename_date(date)
               
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
          professional = Professional.new(professional)
          directory_name = professional.get_professional_format
          
          filename = Appointment.get_filename_date(date)

          if File.exists?("./.polycon/#{directory_name}/#{filename}")
            begin
              File.delete("./.polycon/#{directory_name}/#{filename}")
              warn "Appointment borrado"
            rescue => exception
              warn "ERROR: Ha surgido un error borrando el Appointment"
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
          professional = Professional.new(professional)
          directory_name = professional.get_professional_format

          if Dir.exists?("./.polycon/#{directory_name}")
            begin
              FileUtils.rm_rf(Dir["./.polycon/#{directory_name}/*"])
              warn "Appointments borrados"
            rescue => exception
              warn "ERROR: Ha surgido un error borrando todos los Appointments"
              warn exception
            end      
          else
            warn "ERROR: El Profesional no existe"
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
          if date 
            date = Appointment.get_filename_date(date) 
          end
          
          professional = Professional.new(professional)
          directory_name = professional.get_professional_format

          if Dir.exists?("./.polycon/#{directory_name}")
            directorios = Dir.entries("./.polycon/#{directory_name}")
            # Borro el . y ..
            directorios.delete(".")
            directorios.delete("..")
            if date 
              directorios.each do |d|
                if date.split("_")[0] == d.split("_")[0]
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
            warn "ERROR: El Profesional no existe"
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
          old_date_filename = Appointment.get_filename_date(old_date)
          new_date_filename = Appointment.get_filename_date(new_date)
          professional = Professional.new(professional)
          directory_name = professional.get_professional_format
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
          filename = Appointment.get_filename_date(date)
          professional = Professional.new(professional)
          appointment = Appointment.new(date: date, professional: professional, **options)
          data = File.readlines(".polycon/#{professional.get_professional_format}/#{filename}", chomp: true)
          old_appointment_data = Hash.new
          old_appointment_data = {:date => date, :professional => professional, :surname => data[0], :name => data[1], :phone => data[2], :notes => data[3]}
          old_appointment = Appointment.new(old_appointment_data)
          options.each do |key, value|
            old_appointment.send("#{key}=", value)
          end

          file = File.open(".polycon/#{professional.get_professional_format}/#{filename}", "w")
          file.write("#{old_appointment.surname}\n#{old_appointment.name}\n#{old_appointment.phone}\n#{old_appointment.notes}")       
        end
      end

      class Export < Dry::CLI::Command
        require "erb"
        desc 'Exports Appointment(s) details in rich format'

        argument :date, required: true, desc: 'Full date for the appointment'
        option :professional, required: false, desc: 'Full name of the professional'

        def call(date:, professional: nil)
          date = Appointment.get_filename_date(date).split("_")[0]
          if professional
            appointments_on_date = []
            directory_name = Professional.new(professional).get_professional_format
            directorios = Dir.entries("./.polycon/#{directory_name}")
            directorios.delete(".")
            directorios.delete("..")
            directorios.each do |d|              
              if date.split("_")[0] == d.split("_")[0]
                lines = File.foreach("./.polycon/#{directory_name}/#{d}").first(2)
                pacient_name = "#{lines[1]} #{lines[0]}".delete("\n")
                appointment_date = d.split("_")[1].gsub("-", ":")
                element = {:date => appointment_date, :pacient_name => pacient_name}
                appointments_on_date.push(element)               
              end             
            end
          else
            appointments_on_date = []
            master_directory = Dir.entries("./.polycon/")
            master_directory.delete(".")
            master_directory.delete("..")
            master_directory.each do |m|
              directorios = Dir.entries("./.polycon/#{m}")
              directorios.delete(".")
              directorios.delete("..")              
              directorios.each do |d|
                if date.split("_")[0] == d.split("_")[0]
                  lines = File.foreach("./.polycon/#{m}/#{d}").first(2)
                  pacient_name = "#{lines[1]} #{lines[0]}".delete("\n")
                  appointment_date = d.split("_")[1].gsub("-", ":")
                  element = {:date => appointment_date, :pacient_name => pacient_name, :professional_name => m.gsub("-", " ")}
                  appointments_on_date.push(element)               
                end                
              end
            end
          end
          
          hour_list = ["9:00", "9:15", "9:30", "9:45","10:00", "10:15", "10:30", "10:45", "11:00", "11:15", "11:30", "11:45", "12:00"]
          for_template = []
          hour_list.each do |h|
            appointment_list = []
            appointments_on_date.each do |a|
              real_time = Time.parse(h)
              appointment_hour = Time.parse(a[:date]).hour
              appointment_minute = Time.parse(a[:date]).min
              #puts "Hour On List: #{real_time.hour}, Hour On Appointment: #{appointment_hour}"
              if real_time.hour == appointment_hour && (appointment_minute <= real_time.min+15 && appointment_minute >= real_time.min)
                appointment_list.push(a)
              end
            end
            hash = {:hour => h, :a_list => appointment_list}
            for_template.push(hash)
          end


          puts for_template


          
          
          
          

                                                 
          template = ERB.new <<-EOF
Date            Appointment
<% for_template.each do |val| %>
<%= val[:hour]%><% val[:a_list].each do |val1| %>             <%= val1[:pacient_name]%>
    <% end %><% end %>          
          EOF
          File.open(".polycon/exports/#{date}-export", 'w') do |f|
            f.write template.result(binding)
          end

        end

      end
    end
  end
end

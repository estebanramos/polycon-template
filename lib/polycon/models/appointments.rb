module Polycon
    class Appointment
        require 'time'

        def get_filename_date
          begin
            date = Time.parse(self.date)
            return date.strftime("%Y-%m-%d_%k-%M")
          rescue => exception
            warn "ERROR: Mal formato de fecha"
            exit
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

        def initialize(**options)
          @date = options[:date]
          @professional = options[:professional]
          @name = options[:name]
          @surname = options[:surname]
          @phone = options[:phone]
          @notes = options[:notes]
        end
        
        def date
          @date
        end

        def professional
          @professional
        end

        def name
          @name
        end

        def surname
          @surname
        end

        def phone
          @phone
        end

        def notes
          @notes
        end

        def name=(name)
          @name = name
        end

        def surname=(surname)
          @surname = surname
        end

        def notes=(notes)
          @notes = notes
        end

        def phone=(phone)
          @phone = phone
        end

        



    end
end
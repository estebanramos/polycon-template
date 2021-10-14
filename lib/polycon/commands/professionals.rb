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
          Professional.create_professional(name)
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
          Professional.delete_professional(name)
        end
      end

      class List < Dry::CLI::Command
        desc 'List professionals'

        example [
          "          # Lists every professional's name"
        ]

        def call(*)
          Professional.list_professionals()
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
          Professional.rename_professional(old_name, new_name)
        end
      end
    end
  end
end

module Polycon
        class Professional
          def self.get_professional_format(name)
            professional_name = name.split(" ")
            directory_name = professional_name[0]+'-'+professional_name[1]
            return directory_name
          end
      
            def initialize(name)
              @name = get_professional_format(name)
            end

            def name
              @name
            end
            

        end
end


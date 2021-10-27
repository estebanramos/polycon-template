module Polycon
        class Professional
          def get_professional_format
            professional_name = self.name.split(" ")
            if professional_name.length > 1
              professional_with_format = ""
              professional_name.each do |n|
                professional_with_format.concat(n)
                professional_with_format.concat('-') unless professional_name.index(n)+1 == professional_name.length
              end
            end
            return professional_with_format
          end
      
            def initialize(name)
              @name = name
            end

            def name
              @name
            end
            

        end
end


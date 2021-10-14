module Polycon
        class Professional
            def self.get_professional_format(name)
                professional_name = name.split(" ")
                directory_name = professional_name[0]+'-'+professional_name[1]
                return directory_name
            end
            
            def self.create_professional(name)
                begin
                    FileUtils.mkdir ".polycon/#{get_professional_format(name)}" #unless Dir.entries('.polycon/'+directory_name)
                    warn "Profesional Creado: #{name}"
                    return
                rescue Errno::EEXIST => exception 
                    warn 'ERROR: Ya existe un profesional con ese nombre'
                    return
                end
            end
            
            def self.delete_professional(name)
                begin
                    directorios = Dir.entries("./.polycon/#{get_professional_format(name)}")
                    # Borro el . y ..
                    directorios.delete(".")
                    directorios.delete("..")
                    begin
                      Dir.delete("./.polycon/#{get_professional_format(name)}")
                      warn "Profesional Borrado"
                    rescue Errno::ENOTEMPTY => exception
                      warn "ERROR: No se ha podido borrar el Profesional, tiene turnos asignados"
                    end
                  rescue => exception
                    warn "ERROR: No se ha encontrado un Profesional con ese nombre: #{get_professional_format(name)}"
                end
            end

            def self.list_professionals(*)
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

            def self.rename_professional(old_name, new_name)
                old_name = get_professional_format(old_name)
                new_name = get_professional_format(new_name)
                begin
                  FileUtils.mv ".polycon/#{old_name}", ".polycon/#{new_name}"
                  warn "Profesional Renombrado"
                rescue => exception
                  warn "ERROR: Ha surgido un problema renombrando al Profesional: #{exception}"
                end            
            end
        end
end


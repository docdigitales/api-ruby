module Docdigitales
  class Certificado
    def contenido_certificado(path_certificado)
      OpenSSL::X509::Certificate.new File.read path_certificado
    end

    def contenido_llave(path_llave)
      file = File.open(path_llave, "rb")
      contenido = file.read
      file.close
      contenido
    end

    def password_llave(path_password)
      file = File.open(path_password, "rb")
      contenido = file.read
      file.close
      contenido
    end
  end
end
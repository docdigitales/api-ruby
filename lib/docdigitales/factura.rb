module Docdigitales
  class Factura
    API_KEY = "123123123"
    
    def generacion_factura(data)
      begin
        uri = "http://api.docdigitales.com/v1/facturas/generar";
        return get_post_response(uri, data)
      rescue => exception
        puts exception
        return nil
      end
    end

    def cancelacion_factura(data)
      begin
        uri = "http://api.docdigitales.com/v1/facturas/cancelar";
        return get_post_response(uri, data)
      rescue => exception
        puts exception
        return nil
      end
    end

    def envio_factura(data)
      begin
        uri = "http://api.docdigitales.com/v1/facturas/enviar";
        return get_post_response(uri, data)
      rescue => exception
        puts exception
        return nil
      end
    end

    def descargar_factura(data)
      begin
        uri = "http://api.docdigitales.com/v1/facturas/descargar";
        return get_post_response(uri, data)
      rescue => exception
        puts exception
        return nil
      end
    end

    private
    def get_post_response(uri, data)
      headers = {"Authorization": "Token token=#{API_KEY}", "Accept": "application/json", "Content-Type": "application/json", "Access-Control-Allow-Origin" => "*"}
      response = Unirest.post uri, headers:headers, parameters:data.to_json
      return response.body
    end
  end
end
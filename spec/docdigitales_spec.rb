RSpec.describe Docdigitales do
  before(:each) do
    @api  = Docdigitales::Factura.new
    @cert = Docdigitales::Certificado.new
    @path_certificado = 'vendor/certificados/certificado.cer'
    @path_llave       = 'vendor/certificados/llave.pem'
    @path_password = 'vendor/certificados/password.txt'
  end

  it "Genera Factura Exitosamente" do
    json = '{"meta":{"empresa_uid":"asd123asd","empresa_api_key":"123123123","ambiente":"S","objeto":"factura"},"data":[{"datos_fiscales":{"certificado_pem":"","llave_pem":"","llave_password":""},"cfdi":{"cfdi__comprobante":{"folio":"123","fecha":"2018-03-25T12:12:12","tipo_comprobante":"I","lugar_expedicion":"21100","forma_pago":"01","metodo_pago":"PUE","moneda":"MXN","tipo_cambio":"1","subtotal":"99.00","total":"99.00","cfdi__emisor":{"rfc":"DDM090629R13","nombre":"Emisor Test","regimen_fiscal":"601"},"cfdi__receptor":{"rfc":"XEXX010101000","nombre":"Receptor Test","uso_cfdi":"G01"},"cfdi__conceptos":{"cfdi__concepto":[{"clave_producto_servicio":"01010101","clave_unidad":"KGM","cantidad":"1","descripcion":"descripcion test","valor_unitario":"99.00","importe":"99.00","unidad":"unidad","no_identificacion":"KGM123","cfdi__impuestos":{"cfdi__traslados":{"cfdi__traslado":[{"base":"99.00","impuesto":"002","tipo_factor":"Exento"}]}}}]}}}}]}';
    factura = JSON.parse(json)
    factura["data"][0]["datos_fiscales"]["certificado_pem"] = @cert.contenido_certificado(@path_certificado)
    factura["data"][0]["datos_fiscales"]["llave_pem"]       = @cert.contenido_llave(@path_llave)
    factura["data"][0]["datos_fiscales"]["llave_password"]  = @cert.password_llave(@path_password)
    factura["data"][0]["cfdi"]["cfdi__comprobante"]["fecha"]= Time.now.strftime("%FT%T")

    # Generar y validar que venga un UUID en la respuesta
    factura_generada = @api.generacion_factura(factura)
    expect(factura_generada["data"][0]["cfdi_complemento"]).to have_key("uuid")
  end

  it "Genera Recepcion Pago Exitosamente" do
    json = '{"meta":{"empresa_uid":"asd123asd","empresa_api_key":"123123123","ambiente":"S","objeto":"recepcion"},"data":[{"datos_fiscales":{"certificado_pem":"","llave_pem":"","llave_password":"DDM090629R13"},"cfdi":{"cfdi__comprobante":{"folio":"793","serie":"C","fecha":"","tipo_comprobante":"P","lugar_expedicion":"83448","moneda":"XXX","subtotal":"0","total":"0","cfdi__emisor":{"rfc":"DDM090629R13","nombre":"CARLOS CESAR OCHOA GAXIOLA","regimen_fiscal":"601"},"cfdi__receptor":{"rfc":"GNP9211244P0","nombre":"GRUPO NACIONAL PROVINCIAL S.A.B.","uso_cfdi":"P01"},"cfdi__conceptos":{"cfdi__concepto":[{"clave_producto_servicio":"84111506","clave_unidad":"ACT","cantidad":"1","descripcion":"Pago","valor_unitario":"0","importe":"0"}]},"cfdi__complemento":{"pago10__pagos":{"pago10__pago":{"fecha-pago":"2018-08-10T11:21:09","forma-pago":"01","tipo-cambio":"","moneda":"MXN","monto":"5000.00","rfc-emisor-ordenante":"","rfc-emisor-beneficiario":"","nombre-banco-ordenante":"","cuenta-ordenante":"","cuenta-beneficiario":"","tipo-cadena-pago":"","num-operacion":"1123121241","certificado-pago":"","cadena-pago":"","sello-pago":"","pago10__docto_relacionado":[{"id-documento":"682C60DC-2A2F-47CD-A34D-39180EFAB2B1","serie":"ASD","folio":"53452","moneda-dr":"MXN","tipo-cambio-dr":"","metodo-pago-dr":"PPD","numero-parcialidad":"1","importe-pagado":"5000.00","importe-saldo-anterior":"7000.00","importe-saldo-insoluto":"2000.00"}]}}}}}}]}'
    recepcion = JSON.parse(json)
    recepcion["data"][0]["datos_fiscales"]["certificado_pem"] = @cert.contenido_certificado(@path_certificado)
    recepcion["data"][0]["datos_fiscales"]["llave_pem"]       = @cert.contenido_llave(@path_llave)
    recepcion["data"][0]["datos_fiscales"]["llave_password"]  = @cert.password_llave(@path_password)
    recepcion["data"][0]["cfdi"]["cfdi__comprobante"]["fecha"]= Time.now.strftime("%FT%T")

    # Generar y validar que venga un UUID en la respuesta
    recepcion_generada = @api.generacion_recepcion_pago(recepcion)
    expect(recepcion_generada["data"][0]["cfdi_complemento"]).to have_key("uuid")
  end

  it "Cancela Factura Exitosamente" do
    json = '{"meta":{"empresa_uid":"asd123asd","empresa_api_key":"123123123","ambiente":"S","objeto":"factura"},"data":[{"rfc":"","uuid":[""],"datos_fiscales":{"certificado_pem":"","llave_pem":"","password_llave":""},"acuse": false}]}';
    uuid = "7ECA8EF2-9AB1-42A4-ACEE-EE23145209FE";
    cancelacion = JSON.parse(json)

    # Llenar los datos fiscales y la informacion de la cancelacion
    cancelacion["data"][0]["rfc"] = "DDM090629R13"
    cancelacion["data"][0]["uuid"][0] = uuid
    cancelacion["data"][0]["datos_fiscales"]["certificado_pem"] = @cert.contenido_certificado(@path_certificado)
    cancelacion["data"][0]["datos_fiscales"]["llave_pem"]       = @cert.contenido_llave(@path_llave)
    cancelacion["data"][0]["datos_fiscales"]["llave_password"]  = @cert.password_llave(@path_password)

    # Cancelar
    factura_cancelada = @api.cancelacion_factura(cancelacion)
    expect(factura_cancelada["data"][0]["descripcion"]).to eq("Cancelado Exitosamente")
  end

  it "Envia Factura Exitosamente" do
    json = '{"meta":{"empresa_uid":"asd123asd","empresa_api_key":"123123123","ambiente":"S","objeto":"factura"},"data":[{"uuid":[""],"destinatarios":[{"correo":"sandbox@docdigitales.com"}],"titulo":"Envio de Factura: 123","texto":"Envio de Factura con folio 123, para su revision.","pdf":"true"}]}';
    uuid = "7ECA8EF2-9AB1-42A4-ACEE-EE23145209FE";
    envio = JSON.parse(json)

    # Llenar informacion
    envio["data"][0]["uuid"][0] = uuid

    # Generar envio
    factura_enviada = @api.envio_factura(envio)
    expect(factura_enviada["meta"]["respuesta_uid"]).not_to eq(nil)
  end

  it "Descarga Factura Exitosamente" do
    json = '{"meta":{"empresa_uid":"asd123asd","empresa_api_key":"123123123","ambiente":"S","objeto":"factura"},"data":[{"uuid":[""],"destinatarios":[{"correo":"sandbox@docdigitales.com"}],"titulo":"Descargar factura","texto":"Adjunto factura generada","pdf":"true"}]}';
    uuid = "3BCE81B0-0870-4E26-87D4-3574FF6CFD83";
    descarga = JSON.parse(json)
    # Establecer parametros de envio
    descarga["data"][0]["uuid"][0] = uuid
    # Descargar
    factura_descargada = @api.descargar_factura(descarga)
    expect(factura_descargada["data"][0]["link"]).not_to eq(nil)
  end
end

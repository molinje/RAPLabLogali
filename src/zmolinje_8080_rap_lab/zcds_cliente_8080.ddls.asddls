@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Clientes'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity ZCDS_CLIENTE_8080 
as select from ztb_cliente_8080 as Clientes
 inner join ztb_cln_lib_8080 as RelClLib on RelClLib.id_cliente = Clientes.id_cliente

{
    key RelClLib.id_libro as IDLibro,
    key Clientes.id_cliente as IdCliente,
    key Clientes.tipo_acceso as Acceso,
    Clientes.nombre as Nombre,
    Clientes.apellidos as Apellidos,
    Clientes.email as Email,
    Clientes.url as Imagen
}

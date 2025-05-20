@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Clientes Libros'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZCDS_CLN_LIB_8080 as select from ztb_cln_lib_8080
{
     key id_libro as IdLibro,
     count( distinct id_cliente ) as Ventas
  
   
} group by id_libro;

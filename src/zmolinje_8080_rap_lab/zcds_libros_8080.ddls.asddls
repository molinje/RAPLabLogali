@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Libros'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity ZCDS_LIBROS_8080 
 as select from ztb_libros_8080 as Libros
 inner join ZCDS_CATEG_8080 as Categ on Libros.bi_categ = Categ.Categoria
 left outer join ZCDS_CLN_LIB_8080 as Ventas on Libros.id_libro = Ventas.IdLibro
 association [0..*] to ZCDS_CLIENTE_8080 as _Clientes on $projection.IdLibro = _Clientes.IDLibro
    
{
    key Libros.id_libro as IdLibro,
    key Libros.bi_categ as Categoria,
    Categ.Descripcion,
    Libros.titulo       as Titulo,
    Libros.autor        as Autor,
    Libros.editorial    as Editorial,
    Libros.idioma       as Idioma,
    Libros.paginas      as Paginas,
    @Semantics.amount.currencyCode: 'Moneda'
    Libros.precio       as Precio,
    Libros.moneda       as Moneda,
    
    case
    
    when Ventas.Ventas < 1 then 0
    when Ventas.Ventas = 1 then 1
    when Ventas.Ventas = 2 then 2
    when Ventas.Ventas > 2 then 3
    else 0
    end                 as ventas,
    ''                  as VentasValue,
    
    Libros.formato      as Formato,
    Libros.url          as Imagen,
    _Clientes
}

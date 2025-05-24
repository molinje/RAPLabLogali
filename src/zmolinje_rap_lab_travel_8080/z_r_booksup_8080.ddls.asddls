@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Suplements - Root Entity'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity z_r_booksup_8080 as select from ztb_booksup_8080
// dse define como PADRE a la entidad Z_R_BOOKING_8080 (Reserva) por medio del ID
association to parent Z_R_BOOKING_8080 as _Booking on $projection.BookingUUID = _Booking.BookingUUID

// Asociacion para Navegar al ABUELO (Viaje)
  association [1..1] to Z_R_TRAVEL_8080         as _Travel         on $projection.TravelUUID = _Travel.TravelUUID

  association [1..1] to /DMO/I_Supplement         as _Product        on $projection.SupplementID = _Product.SupplementID
  association [1..*] to /DMO/I_SupplementText     as _SupplementText on $projection.SupplementID = _SupplementText.SupplementID

{
    key booksuppl_uuid as BookSupplUUID,
    root_uuid as TravelUUID, // Travel ID (Viaje)
    parent_uuid as BookingUUID, // ID del Booking(reserva)
    
    booking_supplement_id as BookingSupplementID,
    supplement_id as SupplementID,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    price as Price,
    currency_code as CurrencyCode,
    // local ETAG Field
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    last_changed_at as LastChangedAt,
    
    _Booking,
    _Travel, 
    _Product,
    _SupplementText
}

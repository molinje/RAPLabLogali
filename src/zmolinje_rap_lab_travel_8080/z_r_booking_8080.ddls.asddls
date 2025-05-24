@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking - Root Entity'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z_R_BOOKING_8080 
as select from ztb_booking_8080
// -------PADRE---------------
// Con la siguiente association esta entidad Booking reconoce a su entidad PADRE Travel 
association to parent Z_R_TRAVEL_8080 as _Travel on $projection.TravelUUID = _Travel.TravelUUID

// -------HIJOS---------------
// declara a entidad z_r_booksup_8080 (Suplementos de la reserva) como HIJO
composition [0..*] of z_r_booksup_8080 as _BookingSupplement
// Relaciones con otros Datos
association [0..1] to /DMO/I_Customer as _Customer on $projection.CustomerID = _Customer.CustomerID
association [1..1] to /DMO/I_Carrier           as _Carrier       on  $projection.AirlineID = _Carrier.AirlineID
association [1..1] to /DMO/I_Connection        as _Connection    on  $projection.AirlineID    = _Connection.AirlineID
                                                                 and $projection.ConnectionID = _Connection.ConnectionID
association [1..1] to /DMO/I_Booking_Status_VH as _BookingStatus on  $projection.BookingStatus = _BookingStatus.BookingStatus

{
    key booking_uuid as BookingUUID, // Booking ID (ID de la reserva)
    parent_uuid as TravelUUID, // Travel ID (ID del Viaje)
     
    booking_id as BookingID,
    booking_date as BookingDate,
    customer_id as CustomerID,
    carrier_id as AirlineID,
    connection_id as ConnectionID,
    flight_date as FlightDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    flight_price as FlightPrice,
    currency_code as CurrencyCode,
    booking_status as BookingStatus,
    // Local ETag field
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    last_changed_at as LastChangedAt,
    
    _Travel,
    _BookingSupplement,
    _Customer,
    _Carrier,
    _Connection,
    _BookingStatus
}

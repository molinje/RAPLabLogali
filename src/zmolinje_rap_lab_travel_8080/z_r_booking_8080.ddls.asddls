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
{
    key booking_uuid as BookingUUID,
    parent_uuid as TravelUUID,
    booking_id as BookingID,
    booking_date as BookingDate,
    customer_id as CustomerID,
    carrier_id as CarrierId,
    connection_id as ConnectionID,
    flight_date as FlightDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    flight_price as FlightPrice,
    currency_code as CurrencyCode,
    booking_status as BookingStatus,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    last_changed_at as LastChangedAt
}

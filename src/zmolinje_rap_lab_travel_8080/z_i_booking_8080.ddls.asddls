@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking - Interface Entity'
@Metadata.ignorePropagatedAnnotations: true
define view entity Z_I_BOOKING_8080 as projection on Z_R_BOOKING_8080
{
    key BookingUUID,
    TravelUUID,
    BookingID,
    BookingDate,
    CustomerID,
    AirlineID,
    ConnectionID,
    FlightDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    FlightPrice,
    CurrencyCode,
    BookingStatus,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    LastChangedAt,
    /* Associations */
    _BookingStatus,
    _BookingSupplement : redirected to composition child Z_I_BOOKSUP_8080,
    _Carrier,
    _Connection,
    _Customer,
    _Travel : redirected to parent Z_I_TRAVEL_8080
}

@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Suplements - Interface Entity'
@Metadata.ignorePropagatedAnnotations: true
define view entity Z_I_BOOKSUP_8080 as projection on z_r_booksup_8080
{
    key BookSupplUUID,
    TravelUUID,
    BookingUUID,
    BookingSupplementID,
    SupplementID,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    Price,
    CurrencyCode,
    
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    LastChangedAt,
    /* Associations */
    _Booking : redirected to parent Z_I_BOOKING_8080,
    _Product,
    _SupplementText,
    _Travel : redirected to Z_I_TRAVEL_8080
}

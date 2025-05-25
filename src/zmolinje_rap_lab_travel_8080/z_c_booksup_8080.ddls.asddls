@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Suplements - Consumption Entity'
@Metadata.ignorePropagatedAnnotations: true

@Metadata.allowExtensions: true
@Search.searchable: true

define view entity Z_C_BOOKSUP_8080 
 as projection on z_r_booksup_8080
{
    key BookSupplUUID,
    TravelUUID,
    BookingUUID,
    @Search.defaultSearchElement: true
    BookingSupplementID,
   
    @ObjectModel.text.element: [ 'SupplementDescription' ]
    @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Supplement_StdVH',
                                                           element: 'SupplementID'},
                                        additionalBinding: [{ localElement: 'Price',
                                                                   element: 'Price',
                                                                     usage: #RESULT },
                                                      { localElement: 'CurrencyCode',
                                                             element: 'CurrencyCode',
                                                               usage: #RESULT }],
                                           useForValidation: true }]
    SupplementID,
    _SupplementText.Description as SupplementDescription : localized,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    Price,
    @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CurrencyStdVH',
                                                     element: 'Currency'},
                                           useForValidation: true }]
    CurrencyCode,
    LastChangedAt,
    /* Associations */
    _Booking: redirected to parent Z_C_BOOKING_8080,
    _Product,
    _SupplementText,
    _Travel: redirected to Z_C_TRAVEL_8080
}

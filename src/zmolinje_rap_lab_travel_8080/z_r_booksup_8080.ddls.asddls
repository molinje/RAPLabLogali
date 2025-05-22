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
{
    key booksuppl_uuid as BooksupplUUID,
    root_uuid as TravelUUID,
    parent_uuid as BookingUUID,
    booking_supplement_id as BookingSupplementID,
    supplement_id as SupplementID,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    price as Price,
    currency_code as CurrencyCode,
    // local ETAG Field
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    last_changed_at as LastChangedAt
}

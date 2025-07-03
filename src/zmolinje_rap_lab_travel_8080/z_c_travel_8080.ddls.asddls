@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel - Consumption Entity'
@Metadata.ignorePropagatedAnnotations: true

@Metadata.allowExtensions: true
@Search.searchable: true
define root  view entity Z_C_TRAVEL_8080 
provider contract transactional_query
as projection on Z_R_TRAVEL_8080
{
    key TravelUUID,
    
    @Search.defaultSearchElement: true
    TravelID,
    
    @Search.defaultSearchElement: true
    @ObjectModel.text.element: [ 'AgencyName' ]
    @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Agency_StdVH',
                                                         element: 'AgencyID'},
                                               useForValidation: true }]
    AgencyID,
    _Agency.Name as AgencyName,
    
     @Search.defaultSearchElement: true
     @ObjectModel.text.element: [ 'CustomerName' ]
     @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Customer_StdVH',
                                                         element: 'CustomerID'},
                                               useForValidation: true }]
    CustomerID,
    _Customer.LastName        as CustomerName,
    BeginDate,
    EndDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    BookingFee,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    TotalPrice,
    
    @EndUserText.label: 'VAT Included'
    @Semantics.amount.currencyCode: 'CurrencyCode'
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_349_VIRT_EL_LGL'
    virtual PriceWithVAT : /dmo/total_price,    
    
    @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CurrencyStdVH',
                                                         element: 'Currency'},
                                               useForValidation: true }]
    CurrencyCode,
    Description,
    
     @ObjectModel.text.element: [ 'OverallStatusText' ]
     @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Overall_Status_VH',
                                                         element: 'OverallStatus'},
                                               useForValidation: true }]
    OverallStatus,
    // localized aplica un Filtro por la clave del Idioma 
    _OverallStatus._Text.Text as OverallStatusText : localized,
    
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,
    /* Associations */
    _Agency,
    _Booking : redirected to composition child Z_C_BOOKING_8080,
    _Currency,
    _Customer,
    _OverallStatus
}

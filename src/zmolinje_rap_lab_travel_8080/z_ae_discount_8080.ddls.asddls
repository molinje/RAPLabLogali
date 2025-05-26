@EndUserText.label: 'Discount Percentage - CDS Abastracta'
define abstract entity Z_AE_DISCOUNT_8080

{
    @EndUserText.label: 'Discount'
    discount_percent : /DMO/BT_DiscountPercentage;
    
    // Si queremos mas campos en el formulario es tan facil 
    // como multiplcar esto mismo:
    
    // @EndUserText.label: 'Discount 2'
    // discount_percent2 : /DMO/BT_DiscountPercentage;
    //  @EndUserText.label: 'Discount 3'
    // discount_percent3 : /DMO/BT_DiscountPercentage;
    //  @EndUserText.label: 'Discount 4'
    // discount_percent4 : /DMO/BT_DiscountPercentage;
    
    
}

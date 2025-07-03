CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

   constants:
      begin of travel_status,
        open     type c length 1 value 'O',
        accepted type c length 1 value 'A',
        rejected type c length 1 value 'X',
      end of travel_status.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE Travel.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE Travel.


    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result.

    METHODS deductDiscount FOR MODIFY
      IMPORTING keys FOR ACTION Travel~deductDiscount RESULT result.

    METHODS reCalcTotalPrice for modify
      IMPORTING keys FOR ACTION Travel~reCalcTotalPrice.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.



  types:
      t_keys_accept   type table for action import z_r_travel_8080\\travel~acceptTravel,
      t_keys_reject   type table for action import z_r_travel_8080\\travel~rejectTravel,

      t_result_accept type table for action result z_r_travel_8080\\travel~acceptTravel,
      t_result_reject type table for action result z_r_travel_8080\\travel~rejectTravel.


    METHODS changeTravelStatus importing keys_accept   type t_keys_accept optional
                                         keys_reject   type t_keys_reject optional
                               exporting result_accept type t_result_accept
                                         result_reject type t_result_reject.


    METHODS Resume FOR MODIFY
      IMPORTING keys FOR ACTION Travel~Resume.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~calculateTotalPrice.

    METHODS setStatusToOpen FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~setStatusToOpen.

    METHODS setTravelNumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR Travel~setTravelNumber.

    METHODS validateAgency FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateAgency.

    METHODS validateBookingFee FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateBookingFee.

    METHODS validateCurrency FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCurrency.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDates.

** Nuevo master:
    types:
      t_entities_create type table for create z_r_travel_8080\\travel,
      t_entities_update type table for update z_r_travel_8080\\travel,
      t_failed_travel   type table for failed   early z_r_travel_8080\\travel,
      t_reported_travel type table for reported early z_r_travel_8080\\travel.


     methods precheck_auth
      importing
        entities_create type t_entities_create optional
        entities_update type t_entities_update optional
      changing
        failed          type t_failed_travel
        reported        type t_reported_travel.

    methods is_create_granted
      importing country_code          type land1 optional
      returning value(create_granted) type abap_bool.

    methods is_update_granted
      importing country_code          type land1 optional
      returning value(update_granted) type abap_bool.

    methods is_delete_granted
      importing country_code          type land1 optional
      returning value(delete_granted) type abap_bool.


ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_features.

** Leemos de la entity  z_r_travel_8080 los registros que fueron seleccionados
** o que llegaron por la API a este metodo
  read entities of z_r_travel_8080 in local mode
          entity Travel
          fields ( OverallStatus )
          with corresponding #( keys )
          result data(travels).

   result = value #( for travel in travels (  %tky                      =  travel-%tky
                                              %field-BookingFee         = cond #( when travel-OverallStatus = travel_status-accepted
                                                                          then if_abap_behv=>fc-f-read_only
                                                                          else if_abap_behv=>fc-f-unrestricted )
**                                            Habilitar o deshabilitar Boton Aceptar
                                              %action-acceptTravel      = cond #( when travel-OverallStatus = travel_status-accepted
                                                                          then if_abap_behv=>fc-o-disabled
                                                                          else if_abap_behv=>fc-o-enabled )
**                                            Habilitar o deshabilitar Boton Rechazar
                                              %action-rejectTravel      = cond #( when travel-OverallStatus = travel_status-rejected
                                                                          then if_abap_behv=>fc-o-disabled
                                                                          else if_abap_behv=>fc-o-enabled )
**                                            Habilitar o deshabilitar Boton Discount
                                              %action-deductDiscount    = cond #( when travel-OverallStatus = travel_status-accepted
                                                                          then if_abap_behv=>fc-o-disabled
                                                                          else if_abap_behv=>fc-o-enabled )
                                              %assoc-_Booking           = cond #( when travel-OverallStatus = travel_status-rejected
                                                                          then if_abap_behv=>fc-o-disabled
                                                                          else if_abap_behv=>fc-o-enabled ) ) ).



  ENDMETHOD.

  METHOD get_instance_authorizations.

*    " NOTHING to do with the CREATE operation
*    data: update_requested type abap_bool,
*          update_granted   type abap_bool,
*          delete_requested type abap_bool,
*          delete_granted   type abap_bool.
*
*    read entities of z_r_travel_8080  in local mode
*          entity Travel
*          fields ( AgencyID )
*          with corresponding #( keys )
*          result data(travels).
*
*    update_requested  = cond #( when requested_authorizations-%update      = if_abap_behv=>mk-on
*                                  or requested_authorizations-%action-Edit = if_abap_behv=>mk-on
*                                then abap_true
*                                else abap_false ).
*
*
*    delete_requested  = cond #( when requested_authorizations-%delete = if_abap_behv=>mk-on
*                                then abap_true
*                                else abap_false ).
*
*    data(lv_technical_name) = cl_abap_context_info=>get_user_technical_name(  ).
*
*    loop at travels into data(travel). "70014
*
*
*      if travel-AgencyID is not initial.
*
*        if update_requested eq abap_true.
*
*          if lv_technical_name = 'CB9980008080' and travel-AgencyID ne '70014'.
*            update_granted = abap_true.
*          else .
*
*            update_granted = abap_false.
*
*            append value #( %tky = travel-%tky
*                            %msg = new /dmo/cm_flight_messages( textid    = /dmo/cm_flight_messages=>not_authorized_for_agencyid
*                                                                agency_id = travel-AgencyID
*                                                                severity  = if_abap_behv_message=>severity-error )
*                            %element-AgencyID = if_abap_behv=>mk-on ) to reported-travel.
*
*          endif.
*        endif.
*
*        if delete_requested eq abap_true.
*
*          if lv_technical_name = 'CB9980008080' and travel-AgencyID ne '70014'.
*            delete_granted = abap_true.
*          else .
*
*            delete_granted = abap_false.
*
*            append value #( %tky = travel-%tky
*                            %msg = new /dmo/cm_flight_messages( textid    = /dmo/cm_flight_messages=>not_authorized_for_agencyid
*                                                                agency_id = travel-AgencyID
*                                                                severity  = if_abap_behv_message=>severity-error )
*                            %element-AgencyID = if_abap_behv=>mk-on ) to reported-travel.
*
*          endif.
*        endif.
*
**      else.
**
**        if lv_technical_name = 'CB9980000785'.
**           update_granted = abap_true.
**        endif.
*
*      endif.
*
*      append value #( let upd_auth = cond #( when update_granted eq abap_true
*                                             then if_abap_behv=>auth-allowed
*                                             else if_abap_behv=>auth-unauthorized )
*                          del_auth = cond #( when delete_granted eq abap_true
*                                             then if_abap_behv=>auth-allowed
*                                             else if_abap_behv=>auth-unauthorized )
*                      in
*                          %tky         = travel-%tky
*                          %update      = upd_auth
*                          %action-Edit = upd_auth
*                          %delete      = del_auth ) to result.
*
*    endloop.


  ENDMETHOD.

  METHOD get_global_authorizations.

*   check 1 = 2. "DELETE ME
*
*    data(lv_technical_name) = cl_abap_context_info=>get_user_technical_name(  ).
*
***    lv_technical_name = 'DIFFERENT'.
*
*    if requested_authorizations-%create eq if_abap_behv=>mk-on.
*
*      if lv_technical_name = 'CB9980008080'.
*        result-%create = if_abap_behv=>auth-allowed.
*      else.
*        result-%create = if_abap_behv=>auth-unauthorized.
*
*        append value #( %msg     = new /dmo/cm_flight_messages( textid   = /dmo/cm_flight_messages=>not_authorized
*                                                                            severity = if_abap_behv_message=>severity-error )
*                         %global = if_abap_behv=>mk-on ) to reported-travel.
*
*      endif.
*
*    endif.
*
*    if requested_authorizations-%update      eq if_abap_behv=>mk-on or
*       requested_authorizations-%action-Edit eq if_abap_behv=>mk-on.
*
*      if lv_technical_name = 'CB9980008080'.
*        result-%update      = if_abap_behv=>auth-allowed.
*        result-%action-Edit = if_abap_behv=>auth-allowed.
*      else.
*        result-%update      = if_abap_behv=>auth-unauthorized.
*        result-%action-Edit = if_abap_behv=>auth-unauthorized.
*
*        append value #( %msg     = new /dmo/cm_flight_messages( textid   = /dmo/cm_flight_messages=>not_authorized
*                                                                            severity = if_abap_behv_message=>severity-error )
*                         %global = if_abap_behv=>mk-on ) to reported-travel.
*
*      endif.
*
*    endif.
*
*    if requested_authorizations-%delete eq if_abap_behv=>mk-on.
*
*      if lv_technical_name = 'CB9980008080'.
*        result-%delete = if_abap_behv=>auth-allowed.
*      else.
*        result-%delete = if_abap_behv=>auth-unauthorized.
*
*        append value #( %msg     = new /dmo/cm_flight_messages( textid   = /dmo/cm_flight_messages=>not_authorized
*                                                                            severity = if_abap_behv_message=>severity-error )
*                         %global = if_abap_behv=>mk-on ) to reported-travel.
*
*      endif.
*
*    endif.


  ENDMETHOD.

  METHOD precheck_create.

   me->precheck_auth( exporting entities_create = entities
                       changing  failed          = failed-travel
                                 reported        = reported-travel ).


  ENDMETHOD.

  METHOD precheck_update.

  me->precheck_auth( exporting entities_update = entities
                       changing  failed          = failed-travel
                                 reported        = reported-travel ).

  ENDMETHOD.

  METHOD acceptTravel.


** Leemos los datos de la entidad (Registros seleccionados o que llegan a este metodo por medio de la API)
** y les modificamos el estado a Accepted (A)
   modify entities of z_r_travel_8080 in local mode
           entity Travel
           update fields ( OverallStatus )
           with value #( for key in keys ( %tky           = key-%tky
                                            OverallStatus = travel_status-accepted ) ).
** Leemos los datos y los colocamos en la coleccion travels para luego devolverlos en results
    read entities of  z_r_travel_8080 in local mode
         entity Travel
         all fields with
         corresponding #( keys )
         result data(travels).

    result = value #( for travel in travels ( %tky   = travel-%tky
                                              %param = travel ) ).


  ENDMETHOD.

  METHOD rejectTravel.

** Leemos los datos de la entidad (Registros seleccionados o que llegan a este metodo por medio de la API)
** y les modificamos el estado a Accepted (A)
   modify entities of z_r_travel_8080 in local mode
           entity Travel
           update fields ( OverallStatus )
           with value #( for key in keys ( %tky           = key-%tky
                                            OverallStatus = travel_status-rejected ) ).
** Leemos los datos y los colocamos en la coleccion travels para luego devolverlos en results
    read entities of  z_r_travel_8080 in local mode
         entity Travel
         all fields with
         corresponding #( keys )
         result data(travels).

    result = value #( for travel in travels ( %tky   = travel-%tky
                                              %param = travel ) ).

  ENDMETHOD.

  METHOD deductDiscount.

    data travels_for_update type table for update z_r_travel_8080.
    data(keys_with_valid_discount) = keys.

    loop at keys_with_valid_discount assigning field-symbol(<key_with_valid_discount>)
            where %param-discount_percent is initial
               or %param-discount_percent > 100
               or %param-discount_percent <= 0.

      append value #( %tky = <key_with_valid_discount>-%tky ) to failed-travel.

      append value #( %tky                       = <key_with_valid_discount>-%tky
                      %msg                       = new /dmo/cm_flight_messages(
                                                       textid = /dmo/cm_flight_messages=>discount_invalid
                                                       severity = if_abap_behv_message=>severity-error )
                      %element-TotalPrice        = if_abap_behv=>mk-on
                      %op-%action-deductDiscount = if_abap_behv=>mk-on
                    ) to reported-travel.

      delete keys_with_valid_discount.
    endloop.

    check keys_with_valid_discount is not initial.

    "get total price
    "read rows selected for discount
    read entities of z_r_travel_8080 in local mode
         entity Travel
         fields ( BookingFee )
         with corresponding #( keys_with_valid_discount )
         result data(travels).
"   calculate discount
    loop at travels assigning field-symbol(<travel>).
      data percentage type decfloat16.
      data(discount_percent) = keys_with_valid_discount[ key id  %tky = <travel>-%tky ]-%param-discount_percent.
      percentage =  discount_percent / 100 .
      data(reduced_fee) = <travel>-BookingFee * ( 1 - percentage ) .

      append value #( %tky       = <travel>-%tky
                      BookingFee = reduced_fee
                    ) to travels_for_update.
    endloop.

    "update total price with reduced price
    modify entities of z_r_travel_8080 in local mode
      entity Travel
       update fields ( BookingFee )
       with travels_for_update.

    "Read changed data for action result
    read entities of z_r_travel_8080 in local mode
      entity Travel
        all fields with
        corresponding #( travels )
      result data(travels_with_discount).

"   Return result
    result = value #( for travel in travels_with_discount ( %tky   = travel-%tky
                                                            %param = travel ) ).

  ENDMETHOD.

  METHOD reCalcTotalPrice.

    types: begin of ty_amount_per_currencycode,
             amount        type /dmo/total_price,
             currency_code type /dmo/currency_code,
           end of ty_amount_per_currencycode.

    data: amount_per_currencycode type standard table of ty_amount_per_currencycode.

    read entities of z_r_travel_8080  in local mode
         entity Travel
         fields ( BookingFee CurrencyCode )
         with corresponding #( keys )
         result data(travels).

    delete travels where CurrencyCode is initial.

    loop at travels assigning field-symbol(<travel>).

      " Set the start for the calculation by adding the booking fee.
      amount_per_currencycode = value #( ( amount        = <travel>-BookingFee
                                           currency_code = <travel>-CurrencyCode ) ).

      " Read all associated bookings
      read entities of z_r_travel_8080 in local mode
           entity Travel by \_Booking
           fields ( FlightPrice CurrencyCode )
           with value #( ( %tky = <travel>-%tky ) )
           result data(bookings).

      " Add bookings to the total price.
      loop at bookings into data(booking) where CurrencyCode is not initial.
        collect value ty_amount_per_currencycode( amount        = booking-FlightPrice
                                                  currency_code = booking-CurrencyCode ) into amount_per_currencycode.
      endloop.

      " Read all associated booking supplements
      read entities of z_r_travel_8080 in local mode
        entity Booking by \_BookingSupplement
          fields ( Price CurrencyCode )
        with value #( for rba_booking in bookings ( %tky = rba_booking-%tky ) )
        result data(bookingsupplements).

      " Add booking supplements to the total price.
      loop at bookingsupplements into data(bookingsupplement) where CurrencyCode is not initial.
        collect value ty_amount_per_currencycode( amount        = bookingsupplement-Price
                                                  currency_code = bookingsupplement-CurrencyCode ) into amount_per_currencycode.
      endloop.

      clear <travel>-TotalPrice.
      loop at amount_per_currencycode into data(single_amount_per_currencycode).
        " Currency Conversion
        if single_amount_per_currencycode-currency_code = <travel>-CurrencyCode.
          <travel>-TotalPrice += single_amount_per_currencycode-amount.
        else.
          /dmo/cl_flight_amdp=>convert_currency(
             exporting
               iv_amount                   =  single_amount_per_currencycode-amount
               iv_currency_code_source     =  single_amount_per_currencycode-currency_code
               iv_currency_code_target     =  <travel>-CurrencyCode
               iv_exchange_rate_date       =  cl_abap_context_info=>get_system_date( )
             importing
               ev_amount                   = data(total_booking_price_per_curr)
            ).
          <travel>-TotalPrice += total_booking_price_per_curr.
        endif.
      endloop.
    endloop.

    " update the modified total_price of travels
    modify entities of z_r_travel_8080 in local mode
      entity travel
        update fields ( TotalPrice )
        with corresponding #( travels ).

  ENDMETHOD.



  METHOD changetravelstatus.

  ENDMETHOD.

  METHOD Resume.

    data entities_update type t_entities_update.

    read entities of z_r_travel_8080 in local mode
         entity Travel
         fields ( AgencyID )
         with value #( for key in keys
                        %is_draft = if_abap_behv=>mk-on
                        ( %key = key-%key )
                     )
         result data(travels).

    entities_update = corresponding #( travels changing control ).

    if entities_update is not initial.
      precheck_auth(
        exporting
          entities_update = entities_update
        changing
          failed          = failed-travel
          reported        = reported-travel
      ).
    endif.


  ENDMETHOD.

  METHOD calculateTotalPrice.

   modify entities of z_r_travel_8080 in local mode
           entity Travel
           execute reCalcTotalPrice
           from corresponding #( keys ).

  ENDMETHOD.

  METHOD setStatusToOpen.

** Leemos de la entity  z_r_travel_8080 los registros que fueron seleccionados
** o que llegaron por la API a este metodo
  read entities of z_r_travel_8080 in local mode
          entity Travel
          fields ( OverallStatus )
          with corresponding #( keys )
          result data(travels).
**  Eliminamos los que ya tienen un estado
    delete travels where OverallStatus is not initial.
** Validamos que hayan quedado registros en travels
    check travels is not initial.
** Los registrso que no tienen estado les modificamos el estado a "open" (O)
    modify entities of z_r_travel_8080 in local mode
           entity Travel
           update fields ( OverallStatus )
           with value #( for travel in travels ( %tky          = travel-%tky
                                                 OverallStatus = travel_status-open ) ).


  ENDMETHOD.

  METHOD setTravelNumber.

     read entities of z_r_travel_8080  in local mode
         entity Travel
         fields ( TravelID )
         with corresponding #( keys )
         result data(travels).

    delete travels where TravelID is not initial.

    check travels is not initial.

    select single from ztb_travel_8080
           fields max( travel_id )
           into @data(max_TravelId).

    modify entities of z_r_travel_8080 in local mode
           entity Travel
           update fields ( TravelID )
           with value #( for travel in travels index into i ( %tky     = travel-%tky
                                                              TravelID = max_TravelId + i ) ).

  ENDMETHOD.

  METHOD validateAgency.
  ENDMETHOD.

  METHOD validateBookingFee.
  ENDMETHOD.

  METHOD validateCurrency.
  ENDMETHOD.

  METHOD validateCustomer.

**  // declaramos una tabla interna basado en la tabla donde estan los customer /dmo/customer
    data customers type sorted table of /dmo/customer with unique key client customer_id.

**  En la tabla interna bookings colocamos los registros que ingresaron a este metodo, ya sea por la
**  aplicación o por consumo de la API
    read entities of   z_r_travel_8080 in local mode
         entity Booking
         fields (  CustomerID )
         with corresponding #( keys )
         result data(bookings).

    read entities of z_r_travel_8080 in local mode
         entity Booking by \_Travel
         from corresponding #( bookings )
         link data(travel_booking_links).


**  En la tabla customers me quedo colo con los id de cliente a validar , eliminando los initial y los duplicados
    customers = corresponding #( bookings discarding duplicates mapping customer_id = CustomerID except * ).
    delete customers where customer_id is initial.

**  Si hay clientes que validar hacemos el select de los datos maestros y los colocamos en la tabla interna
**  valid_customers, aqui tenemos los clientes que realmente existen
    if customers is not initial.

      select from /dmo/customer as db
             inner join @customers as it on db~customer_id = it~customer_id
             fields db~customer_id
             into table @data(valid_customers).

    endif.

    loop at bookings into data(booking).


***   Appen a reported (Tabla del metodo de tipo export para el  Reporte)
      append value #( %tky        = booking-%tky
                      %state_area = 'VALIDATE_CUSTOMER' ) to reported-booking.

      if booking-CustomerID is initial.

**      Si el booking-CustomerID viene sin valor o  Inicial lo adicionamos a la tabla failed
**      con esto ya la logica de RAP lo bloquea para su tratamiento, no continua ejecución para este registro
        append value #( %tky = booking-%tky ) to failed-booking.

**      Se adiciona igualmente este registro al Reporte con un mensaje de error
        append value #( %tky                = booking-%tky
                        %state_area         = 'VALIDATE_CUSTOMER'
                        %msg                = new /dmo/cm_flight_messages( textid   = /dmo/cm_flight_messages=>enter_customer_id
                                                                           severity = if_abap_behv_message=>severity-error )
                        %element-CustomerID = if_abap_behv=>mk-on ) to reported-booking.

**    Si el booking-CustomerID no existe en la tabla de customers validados 'valid_customers'
      elseif not line_exists( valid_customers[ customer_id = booking-CustomerID ] ).

**      adicionamos este registro en la tabla de fallos 'failed' con esto ya la logica de RAP lo bloquea para su tratamiento,
**      no continua ejecución para este registro
        append value #( %tky = booking-%tky ) to failed-booking.

**      Se adiciona igualmente este registro al Reporte con un mensaje de error
        append value #( %tky                = booking-%tky
                        %state_area         = 'VALIDATE_CUSTOMER'
                        %msg                = new /dmo/cm_flight_messages( textid   = /dmo/cm_flight_messages=>customer_unkown
                                                                           customer_id = booking-CustomerID
                                                                           severity = if_abap_behv_message=>severity-error )
                        %element-CustomerID = if_abap_behv=>mk-on ) to reported-booking.

      endif.

    endloop.


  ENDMETHOD.

  METHOD validateDates.
  ENDMETHOD.

  METHOD precheck_auth.

    data: entities          type t_entities_update,
          operation         type if_abap_behv=>t_char01,
          agencies          type sorted table of /dmo/agency with unique key client agency_id,
          is_modify_granted type abap_bool.

    " Either entities_create or entities_update is provided.  NOT both and at least one.
    assert not ( entities_create is initial equiv entities_update is initial ).

    if entities_create is not initial.
      entities = corresponding #( entities_create mapping %cid_ref = %cid ).
      operation = if_abap_behv=>op-m-create.
    else.
      entities = entities_update.
      operation = if_abap_behv=>op-m-update.
    endif.

    delete entities where %control-AgencyID = if_abap_behv=>mk-off.

    agencies = corresponding #( entities discarding duplicates mapping agency_id = AgencyID except * ).

    check agencies is not initial.

    select from /dmo/agency as db
           inner join @agencies as it on db~agency_id = it~agency_id
           fields db~agency_id,
                  db~country_code
           into table @data(agency_country_codes).

    loop at entities into data(entity).
      is_modify_granted = abap_false.

      read table agency_country_codes with key agency_id = entity-AgencyID
                   assigning field-symbol(<agency_country_code>).

      "If invalid or initial AgencyID -> validateAgency
      check sy-subrc = 0.

      case operation.

        when if_abap_behv=>op-m-create.
          is_modify_granted = is_create_granted( <agency_country_code>-country_code ).

        when if_abap_behv=>op-m-update.
          is_modify_granted = is_update_granted( <agency_country_code>-country_code ).

      endcase.

      if is_modify_granted = abap_false.
        append value #(
                         %cid      = cond #( when operation = if_abap_behv=>op-m-create then entity-%cid_ref )
                         %tky      = entity-%tky
                       ) to failed.

        append value #(
                         %cid      = cond #( when operation = if_abap_behv=>op-m-create then entity-%cid_ref )
                         %tky      = entity-%tky
                         %msg      = new /dmo/cm_flight_messages(
                                                 textid    = /dmo/cm_flight_messages=>not_authorized_for_agencyid
                                                 agency_id = entity-AgencyID
                                                 severity  = if_abap_behv_message=>severity-error )
                         %element-AgencyID   = if_abap_behv=>mk-on
                      ) to reported.
      endif.
    endloop.

  ENDMETHOD.

  METHOD is_create_granted.

    if country_code is supplied.

      authority-check object '/DMO/TRVL'
                          id '/DMO/CNTRY' field country_code
                          id 'ACTVT'      field '01'.

      create_granted = cond #( when sy-subrc eq 0
                               then abap_true
                               else abap_false ).

    endif.

    "Giving Full Access
    create_granted = abap_true.

  ENDMETHOD.


  METHOD is_update_granted.

    if country_code is supplied.

      authority-check object '/DMO/TRVL'
                          id '/DMO/CNTRY' field country_code
                          id 'ACTVT'      field '02'.

      update_granted = cond #( when sy-subrc eq 0
                               then abap_true
                               else abap_false ).

    endif.

    "Giving Full Access
    update_granted = abap_true.

  ENDMETHOD.

  METHOD is_delete_granted.

    if country_code is supplied.

      authority-check object '/DMO/TRVL'
                          id '/DMO/CNTRY' field country_code
                          id 'ACTVT'      field '06'.

      delete_granted = cond #( when sy-subrc eq 0
                               then abap_true
                               else abap_false ).

    endif.

    "Giving Full Access
    delete_granted = abap_true.

  ENDMETHOD.

ENDCLASS.

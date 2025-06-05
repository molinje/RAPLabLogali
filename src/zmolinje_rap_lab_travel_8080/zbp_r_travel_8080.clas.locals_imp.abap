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

    METHODS recalTotalPrice FOR MODIFY
      IMPORTING keys FOR ACTION Travel~recalTotalPrice.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.

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

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD precheck_create.
  ENDMETHOD.

  METHOD precheck_update.
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

  METHOD deductDiscount.
  ENDMETHOD.

  METHOD recalTotalPrice.
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

  METHOD Resume.
  ENDMETHOD.

  METHOD calculateTotalPrice.
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

ENDCLASS.

*&---------------------------------------------------------------------*
*& Report  ZADVD_CURRENCYCONVERSION
*&
*&---------------------------------------------------------------------*
*&  Program will convert currency to desired currency key using the CONVERT_TO_FOREIGN_CURRENCY function.
*&
*&
*& COMPANY: Desired company code
*& DATE: Posting date
*& AMOUNT: Amount of currency
*& TARGET_C: The currency type that the amount is being converted to.
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZADVD_CURRENCYCONVERSION.


PARAMETERS: COMPANY TYPE BUKRS OBLIGATORY,
            DATE TYPE DATS OBLIGATORY,
            AMOUNT TYPE I OBLIGATORY,
            TARGET_C TYPE WAERS OBLIGATORY.


INITIALIZATION.
DATA FINALAMOUNT TYPE I.
DATA WAERSHOLDER TYPE WAERS.

* ------------- Internal table that holds the BUKRS value given from user to validate -------------------
* Structure Internal Table a (header line)
TYPES: BEGIN OF TY_VALIDATE,
       BUKRS TYPE BUKRS,
END OF TY_VALIDATE.

* Create a table type (You create a table type so that to make an IT, you just use "type" instead of "TYPE STANDARD TABLE"
TYPES: TT_VALIDATE TYPE STANDARD TABLE OF TY_VALIDATE.

* Define the structure type (WORKAREA)
DATA: ST_VALIDATE TYPE TY_VALIDATE.

* Define Internal Table a
DATA: IT_VALIDATE TYPE TT_VALIDATE.

* ------------- Internal table that holds the Local Currency or Currency key of the Company code given --------------
* Structure Internal Table a (header line)
TYPES: BEGIN OF TY_CURKEY,
       WAERS TYPE WAERS,
END OF TY_CURKEY.

* Create a table type (You create a table type so that to make an IT, you just use "type" instead of "TYPE STANDARD TABLE")
TYPES: TT_CURKEY TYPE STANDARD TABLE OF TY_CURKEY.

* Define the structure type (WORKAREA)
DATA: ST_CURKEY TYPE TY_CURKEY.

* Define Internal Table a
DATA: IT_CURKEY TYPE TT_CURKEY.



AT SELECTION-SCREEN.
* Validate the Company Code (BUKRS) given by the user
SELECT BUKRS
       FROM T001
       UP TO 1 ROWS
       INTO ST_VALIDATE
       WHERE BUKRS = COMPANY.
       APPEND ST_VALIDATE TO IT_VALIDATE.
ENDSELECT.

IF sy-subrc <> 0.
    MESSAGE 'No records found with this Company Code '(007) TYPE 'E' DISPLAY LIKE 'S'.
    EXIT.
ENDIF.


END-OF-SELECTION.
* Grabs the Company code's currency key (WAERS)
SELECT WAERS
       FROM T001
       UP TO 1 ROWS
       INTO ST_CURKEY
       WHERE BUKRS = COMPANY.
       APPEND ST_CURKEY TO IT_CURKEY.
ENDSELECT.

* Sets the Company code's currency key (WAERS) to a local variable
IF sy-subrc = 0.
  loop at IT_CURKEY into ST_CURKEY.
    WAERSHOLDER = ST_CURKEY-WAERS.
    WRITE: 'The local currency is: ', WAERSHOLDER.
    NEW-LINE.
  ENDLOOP.


  NEW-LINE.
  WRITE: 'The foriegn currency is: ', TARGET_C.
  NEW-LINE.
  WRITE: 'The initial amount is: ', AMOUNT.
  NEW-LINE.

* Once we have all the parameters, we just pass it to the function that does the heavywork for us.
  CALL FUNCTION 'CONVERT_TO_FOREIGN_CURRENCY'
      EXPORTING
                date             = DATE
                local_amount     = AMOUNT
                foreign_currency = TARGET_C
                local_currency   = ST_CURKEY-WAERS

      IMPORTING
                FOREIGN_AMOUNT = FINALAMOUNT.
  IF SY-SUBRC = 0.
     WRITE: 'The converted amount is: ', FINALAMOUNT.
  ENDIF.
ELSE.
   WRITE: 'Did not find any Currency Key for the given Company Code.'.
ENDIF.


*&-----------------------------END OF SCRIPT -----------------------*

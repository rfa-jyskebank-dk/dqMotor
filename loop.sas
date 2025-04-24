%metalib(&inlibdqres);
/*%metareg(&inlibdqres);*/
%inc '/home/JB4555/dqMotor/resolve_code.sas';
%include '/home/JB4555/dqMotor/check_data.sas';
%let afviklingsdato='14nov2023 00:00:00'dt; *sættes globalt et eller andet sted;
/* finder alle regler i et givent spor */
proc sql;
  create table regler_i_spor
    as select regel_id
      from &inlibdqres..regel_koerselsliste
        where spor=1;
quit;

/* for en given regel findes relevant data */
proc sql;
  create table regel_data as
    SELECT rb.regel_id,
      rb.status_id,
      rb.afviklingsfrekvens,
      rb.opslagsdato,
      rb.regel_type_id,
      rdk.kolonne_navn,
      rdt.tabel_navn,
      rdt.tidsafgraensnings_kolonne,
      rdsl.libname
    FROM &inlibdqres..regel_beskrivelse AS rb
      left JOIN &inlibdqres..regel_data_map AS rdm
        ON rdm.regel_id = rb.regel_id
      left JOIN &inlibdqres..regel_data_kolonne AS rdk
        ON rdk.kolonne_id = rdm.kolonne_id
      left JOIN &inlibdqres..regel_data_tabel AS rdt
        ON rdt.tabel_id = rdk.tabel_id
      left JOIN &inlibdqres..regel_data_schema_libname AS rdsl
        ON	rdsl.schema_libname_id = rdt.schema_libname_id
      WHERE rb.regel_id=23

  ;
quit;

/* tjekker om der er datar for alle datasæt */
%check_data(inputdata=regel_data, debug=0);

%put &=exitcode;
data _null_;
  set regel_data;
  call symputx('opslagsdato',opslagsdato);
  call symputx('kolonne_navn', kolonne_navn);
  call symputx('tabel_navn',tabel_navn);
  call symputx('tidsafgraensnings_kolonne',tidsafgraensnings_kolonne);
  call symputx('libname',libname);
run;

/* finder relevante datoer */
proc sql noprint;
  select catt('"',put(&opslagsdato,datetime25.6),'"dt')  into :udtraeksdato trimmed
    from &inlibdqres..kalender
      where dato=&afviklingsdato
  ;
quit;



%resolve_code(regelnr=1,debug=0);

&regel_kode;

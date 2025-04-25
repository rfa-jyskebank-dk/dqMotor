/**
  @file
  @brief <Your brief here>
  <h4> SAS Macros </h4>
**/
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
      rdsl.libname,
      coalesce(rs.regel_kode, ra.regel_kode) as regel_kode
    FROM &inlibdqres..regel_beskrivelse AS rb
      inner JOIN &inlibdqres..regel_data_map AS rdm
        ON rdm.regel_id = rb.regel_id
      inner JOIN &inlibdqres..regel_data_kolonne AS rdk
        ON rdk.kolonne_id = rdm.kolonne_id
      inner JOIN &inlibdqres..regel_data_tabel AS rdt
        ON rdt.tabel_id = rdk.tabel_id
      inner JOIN &inlibdqres..regel_data_schema_libname AS rdsl
        ON rdsl.schema_libname_id = rdt.schema_libname_id
      left JOIN &inlibdqres..regel_avanceret AS ra
        ON ra.regel_id = rb.regel_id
      left join &inlibdqres..regel_standard AS rs
        ON rs.regel_type_id = rb.regel_type_id
      WHERE rb.regel_id=26

  ;
quit;

/* tjekker om der er datar for alle datasæt */
%check_data(inputdata=regel_data, debug=0);

data _null_;
  call symputx('regel_type_id',regel_type_id);
run;

data _null_;
  set regel_data;
  call symputx('opslagsdato',opslagsdato);
run;

/* finder relevante datoer */
proc sql noprint;
  select catt('"',put(&opslagsdato,datetime25.6),'"dt')  into :udtraeksdato trimmed
    from &inlibdqres..kalender
      where dato=&afviklingsdato
  ;
quit;

/* erstat macro var med værdier fra regel_data */
%resolve_code(regelnr=1,debug=0);


/* afvikler koden */
&regel_kode;


/*log data*/
proc sql;
   insert into &inlibdqres..regel_koerselsliste_log(afviklingsdato, exit_code, regel_kode)
   values( &afviklingsdato, &syscc, %tslit(&regel_kode));
;
quit;
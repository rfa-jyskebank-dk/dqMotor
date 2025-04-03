%metalib(&inlibdqres);

proc sql;
  create table test as
    SELECT rb.regel_id,
      rb.status_id,
      rb.afviklingsfrekvens,
      rb.oplsaagsdato,
      rb.regel_type_id,
      rdk.kolonne_navn,
      rdt.tabel_navn,
      rdt.tidsafgraensnings_kolonne,
      rdsl.libname
    FROM &inlibdqres..regel_beskrivelse AS rb
      INNER JOIN &inlibdqres..regel_data_map AS rdm
        ON rdm.regel_id = rb.regel_id
      INNER JOIN &inlibdqres..regel_data_kolonne AS rdk
        ON rdk.kolonne_id = rdm.kolonne_id
      INNER JOIN &inlibdqres..regel_data_tabel AS rdt
        ON rdt.tabel_id = rdk.tabel_id
      INNER JOIN &inlibdqres..regel_data_schema_libname AS rdsl
        ON	rdsl.schema_libname_id = rdt.schema_libname_id
      WHERE rb.regel_id=5

  ;
quit;

%let optaellingsdato=&datokortdt.;

data _null_;
  set test;
  call symputx('oplsaagsdato',oplsaagsdato);
  call symputx('kolonne_navn', kolonne_navn);
  call symputx('tabel_navn',tabel_navn);
  call symputx('tidsafgraensnings_kolonne',tidsafgraensnings_kolonne);
  call symputx('libname',libname);
run;

proc sql noprint;
  select &oplsaagsdato format=best32. into :udtraeksdato trimmed
    from &inlibdqres..kalender
      where dato=&optaellingsdato
  ;
quit;

%put &udtraeksdato;

data regel;
set test(keep=regel_id);
  udtraeksdato=putn(&udtraeksdato,'datetime25.6');
  length kode $32760;
  kode = '%metalib(' || "&libname.);" || '0A'x || catx('0A'x,
    "proc sql;",
    "    create table dq_resultat as",
    "      select",
    "        datetime() format datetime25.6 as OPRETTET_TMS,",
    "        count(&kolonne_navn.) as ANTAL,",
    "        case",
    "          when count(&kolonne_navn.)>0 then 100.00",
    "          else 0",
    "        end as ANTAL_PCT,",
    "        count(*) as ANTAL_I_ALT",
    "      from &libname..&tabel_navn",
    "      where &tidsafgraensnings_kolonne=&udtraeksdato",
    "    ;",
    "  quit;"
    );
  output;
run;

data _null_;
set regel;
call symput('regel_kode',kode);
run;

&regel_kode;

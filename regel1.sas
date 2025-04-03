/**
@file regel1.sas
@brief tæller antal rækker i en tabel
@details regel1.sas
**/

%metalib(&libname.);

proc sql;
      create table dq_resultat as
        select
          datetime() format datetime25.6 as OPRETTET_TMS,
          count(&kolonne_navn.) as ANTAL,
          case
            when count(&kolonne_navn.)>0 then 100.00
            else 0
          end as ANTAL_PCT,
          count(*) as ANTAL_I_ALT
        from &libname..&tabel_navn
        where &tidsafgraensnings_kolonne=&udtraeksdato
      ;
    quit;
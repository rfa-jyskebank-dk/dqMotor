
%macro dan_korselsliste(afviklingsdato=, regel_id_liste=,debug=0);

%metalib(&inlibdqres);

/* sæt afviklingsdato til dd hvis ikke angivet */
%if %mf_isblank(&afviklingsdato) %then
  %do;
    %let afviklingsdato = %sysfunc(today());
  %end;

%put &=afviklingsdato;

/* finder jn_kolonner for korselsdato
og transponere dem så du kan merges på afviklingsfrekvens*/
proc sql noprint;
  select jn_kolonne into :jn_kolonne separated by ' '
    from  &inlibdqres..frekvens_opslag_dato_mapping fdm
  ;
quit;


proc transpose data=&inlibdqres..kalender 
out=korselsfrekvens(rename=(_name_=jn_kolonne JN1=JN) 
drop=_label_) prefix=JN;
  var &jn_kolonne;
  where dato=dhms(&afviklingsdato,0,0,0);
run;

/* finder den gennemsnitlige kørselstid for de sidste 10 korselser
bruges til at fordele i spor*/
proc sql;
  %odbc_connect(&inlibdqres.);
  create table avg_runtimes
    as select regel_id,
            avg_runtime
  from connection to odbc
    (
    WITH ranked_runs (regel_id, run_rank, run_duration)
AS (SELECT rk.regel_id,
           RANK() OVER (PARTITION BY rk.regel_id ORDER BY rk.start_datetime DESC) AS run_rank,
           DATEDIFF(MILLISECOND, rk.start_datetime, rk.slut_datetime) AS run_duration
    FROM Datakvalitet.DQRestricted.regel_korselsliste AS rk)
    SELECT ranked_runs.regel_id,
          AVG(ranked_runs.run_duration) AS avg_runtime
    FROM ranked_runs
    WHERE run_rank < 11
    GROUP BY ranked_runs.regel_id
    ORDER BY avg_runtime;

    );
  disconnect from odbc;
quit;


/* æaver udtræk af de regler der skal lægges på korselslisten*/
proc sql;
  create table korselsliste as
    select
      rb.regel_id format=11.,
      dhms(&afviklingsdato,0,0,0) format=datetime25.6 as afviklingsdato,
      coalesce(ar.avg_runtime, 1) as avg_runtime
    from &inlibdqres..regel_beskrivelse rb
/* left joiner korselslisten så vi ikke lægger de samme regler på 2 gange */
      left join &inlibdqres..regel_korselsliste rkl
        on rb.regel_id = rkl.regel_id
        and rkl.afviklingsdato = dhms(&afviklingsdato,0,0,0)
/*		left joiner frekvens mapping tabeller så 
		vi kan tjekke om der skal køres for dagen*/
      left join &inlibdqres..frekvens_opslag_dato_mapping fodm
        on fodm.frekvens=rb.afviklingsfrekvens
      left join work.korselsfrekvens k
        on k.jn_kolonne=fodm.jn_kolonne
      left join work.avg_runtimes ar
        on rb.regel_id = ar.regel_id
      where rb.status_id in (1,2) /*1=aktiv, 2=under udvikling*/
        and rkl.afviklingsdato is null
        and rkl.regel_id is null
        and (k.JN='J' or rb.afviklingsfrekvens = 'alledage')
		%if %mf_isblank(&regel_id_liste)=0 %then %do;
/*			hvis regel_id_liste ikke er tom udtrækkes kun disse id*/
			and regel_id in(&regel_id_liste)
		%end;
        order by regel_id

  ;
quit;

/* fordeler i spor */
data korselsliste_spor;
    set korselsliste ;
    retain spor1-spor5 0; /* initialer samlet kørselstid for hvert spor */

    /* Find sport med min samlet kørselstid */
    array runs[5] spor1-spor5;
    min_spor = whichn(min(of spor1-spor5), of spor1-spor5);

    /* tildet job til det spor med lavest samlet kørselstid */
    runs[min_spor] + avg_runtime;
    spor = min_spor;

run;

/* inserter i tabellen*/
data insert_data;
  set work.korselsliste_spor;
  length update con cmd $512;
  update="insert into DQRestricted.regel_korselsliste(regel_id, afviklingsdato, spor) values("||strip(regel_id)||","||strip(sasToSqlDatetime(afviklingsdato))||","||strip(spor)||")";
  con='READBUFF=32767  INSERTBUFF=32767  Datasrc=JK_T_DQ AUTHDOMAIN="JBMAIN00_AUTH"';
  cmd="proc sql;connect to ODBC ("||strip(con)||");reset noprint;execute ("||strip(update)||") by ODBC;disconnect from ODBC;quit;";
run;

data _NULL_;
  set work.insert_data;
  call execute(cmd);
run;
%mend dan_korselsliste

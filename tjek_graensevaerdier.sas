%macro tjek_graensevaerdier(regel_id=, opslagsdato=);

  data regel_graensevaerdi;
    set &inlibdqres..regel_graensevaerdi;
    call symputx('sammenlign_jn', sammenlign_jn);
    call symputx('sammenlign_med_maaling', sammenlign_med_maaling);
    call symputx('enhed', enhed);
    where regel_id = &regel_id;
  run;

  %if &sammenlign_jn = 'J' %then %do;
    proc sql;
      create table maaling as
      select &sammendlign_med_maaling
      from &inlibdqres..kalender
      where dato=&opslagsdato
      ;
      select
      %if &enhed=procent %then %do;
      (rm1.maaling-rm2.maaling)/rm2.maaling into :maaling
      %end;
      %else %if &enhed=antal %then %do;
      (rm1.maaling-rm2.maaling) into :maaling
      %end;
      from &inlibdqres..regel_maaling rm1
      inner join &&inlibdqres..regel_maaling rm2
        on rm1.regel_id=rm2.regel_id
        and rm2.koersel_dt = &sammenlignsdato
      where rm1.regel_id = &regel_id
      and rm1.koersel_dt = &opslagsdato
      ;
      quit;
  %end;
  %else %do;
    proc sql;
       create table maaling as
      select maaling_id, maaling into
      from &inlibdqres..regel_maaling
      where regel_id = &regel_id
      and koersel_dt = &opslagsdato
      ;
    quit;
  %end;

  data regel_graensevaerdi_interval;
    set &inlibdqres..regel_graensevaerdi_interval;
      call symputx(cats('interval_start',_N_),interval_start);
      call symputx(cats('interval_slut',_N_),interval_slut);
      call symputx('nobs',_n_);
    where regel_id = &regel_id;
  run;


    data udfald;
      attrib flag length=$8;
      set work.maaling;
      %do i=1 %to &nobs;
      %if %length(&&interval_start&i)=0 %then %do;
        if udfald &&interval_slut&i and not(missing(udfald)) then
      %end;
      %else %if %length(&&interval_slut&i)=0 %then %do;
        if udfald &&interval_start&i and not(missing(udfald)) then
      %end;
      %else %do;
        if udfald &&interval_start&i and udfald &&interval_slut&i and not(missing(udfald)) then
      %end;
        do;
          flag=interval_farve;
          output;
        end;
     %end;
    run;

  proc sql;
    insert into &inlibdqres..regel_evaluering(
       regel_id
      ,maaling_id
      ,graensevaerdi_id
      ,delgraense_id,
      udfald,
      evaluering_vaerdi,
      koersel_dt
      )
/* TODO: find værdier  */
quit;
%mend tjek_graensevaerdier;

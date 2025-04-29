%macro tjek_graensevaerdier(regel_id=, opslagsdato=, maaling_id=);

  data regel_graensevaerdi;
    set &inlibdqres..regel_graensevaerdi;
    call symputx('sammenlign_jn', sammenlign_jn);
    call symputx('sammenlign_med_maaling', sammenlign_med_maaling);
    call symputx('enhed', enhed);
    call symputx('graensevaerdi_id', graensevaerdi_id);
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
      select maaling
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
      call symputx(cats('interval_farve',_n_),interval_farve);
      call symputx(cats('delgraense_id', _N_), delgraense_id);
      call symputx('nobs',_n_);
    where regel_id = &regel_id;
  run;


  data udfald;
    attrib flag length=$8;
    set work.maaling;
    /* Loop through intervals */
    %do i = 1 %to &nobs;
      /* Handle cases where interval_start or interval_slut is missing */
      %if %length(&&interval_start&i) = 0 %then %do;
        if maaling &&interval_slut&i then do;
          udfald = "&&interval_farve&i";
          delgraense_id = "&&delgraense_id&i";
        end;
      %end;
      %else %if %length(&&interval_slut&i) = 0 %then %do;
        if maaling &&interval_start&i  then do;
          udfald = "&&interval_farve&i";
          delgraense_id = "&&delgraense_id&i";
          output;
        end;
      %end;
      %else %do;
        if maaling &&interval_start&i and maaling &&interval_slut&i then do;
          udfald = "&&interval_farve&i";
          delgraense_id = "&&delgraense_id&i";
          output;
        end;
      %end;
    %end;
    call symputx('udfald', udfald);
    call symputx('maaling', maaling);
    call symputx('delgraense_id', delgraense_id);
  run;

/* TODO: indsæt en test for der kun er 1 og kun 1 resultat fra udfalds tabellen*/


/* indsæt resultaterne i tabellen (skal måske laves om til en upsert) */
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
      values (
        &regel_id,
        &maaling_id,
        &graensevaerdi_id,
        &delgraense_id,
        &udfald,
        &maaling,
        &opslagsdato
      )
quit;



%mend tjek_graensevaerdier;

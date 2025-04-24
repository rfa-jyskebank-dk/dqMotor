%macro check_data(inputdata=, debug=0);
%global exitcode;
%local inputobs nrows i udtraeksdato;

%let exitcode=0;

%let inputobs=%di_nobs(data=&inputdata.);
%if &inputobs=0 %then %do;
  %put WARNING: No observations found in input data set &inputdata.;
  %put WARNING- setting exit code to 1;
  %let exitcode=1;
  %return;
%end;

%do i=1 %to &inputobs;

  data _null_;
    row=&i;
    set &inputdata. point=row;
    call symputx('tabel_navn',tabel_navn);
    call symputx('kolonne_navn',kolonne_navn);
    call symputx('tidsafgraensnings_kolonne',tidsafgraensnings_kolonne);
    call symputx('libname',libname);
    call symputx('opslagsdato',opslagsdato);
    stop;
  run;

  proc sql noprint;
  select catt('"',put(&opslagsdato,datetime25.6),'"dt')  into :udtraeksdato trimmed
    from &inlibdqres..kalender
      where dato=&afviklingsdato
  ;
quit;

%if &debug=1 %then %do;
  %put NOTE: Debug mode is ON;
  %put NOTE: Checking data for table: &libname..&tabel_navn;
  %put NOTE: Column name: &kolonne_navn;
  %put NOTE: Time constraint column: &tidsafgraensnings_kolonne;
  %put NOTE: Extraction date: &udtraeksdato;
%end;

  %metalib(&libname.);
  proc sql noprint;
      select count(&kolonne_navn) into :nrows trimmed
      from &libname..&tabel_navn
      where &tidsafgraensnings_kolonne = &udtraeksdato
      ;
  quit;

  %if &nrows=0 %then %do;
    %put WARNING: No rows found in &libname..&tabel_navn for date &udtraeksdato.;
    %put WARNING- setting exit code to 1;
    %let exitcode=1;
    %return; /* Exit the macro if no rows are found */
  %end;
%end;

%mend check_data;
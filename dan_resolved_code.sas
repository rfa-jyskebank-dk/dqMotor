%metalib(&inlibdqres);
/*sammensætter det data der skal bruges for en given regel*/
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

/* sætter en kørselsdato */
%let optaellingsdato=&datokortdt.;

/*danner macro variavle*/
data _null_;
  set test;
  call symputx('oplsaagsdato',oplsaagsdato);
  call symputx('kolonne_navn', kolonne_navn);
  call symputx('tabel_navn',tabel_navn);
  call symputx('tidsafgraensnings_kolonne',tidsafgraensnings_kolonne);
  call symputx('libname',libname);
run;

/*find udtræksdato*/
proc sql noprint;
  select &oplsaagsdato format=best32. into :udtraeksdato trimmed
    from &inlibdqres..kalender
      where dato=&optaellingsdato
  ;
quit;

/*resolver den kode der skal køres*/
%put &udtraeksdato;

%macro resolve_code(regelnr=);
filename myfile "/home/JB4555/dqMotor/regel&regelnr..sas";

data regel_data;
  length kode $32767 resolved_line $32767;
  retain kode '';
  infile myfile lrecl=32767 termstr=LF truncover end=eof;
  input line $char1000.;
/* erstatter macrovarialbe med den resolved værdi */
  udtraeksdato = symget('udtraeksdato');
  kolonne_navn = symget('kolonne_navn');
  tabel_navn = symget('tabel_navn');
  tidsafgraensnings_kolonne = symget('tidsafgraensnings_kolonne');
  libname = symget('libname');
  resolved_line = prxchange(cats('s/&udtraeksdato\.?/',udtraeksdato,'/i'), -1, line);
  resolved_line = prxchange(cats('s/&kolonne_navn\.?/',kolonne_navn,'/i'), -1, resolved_line);
  resolved_line = prxchange(cats('s/&tabel_navn\.?/',tabel_navn,'/i'), -1, resolved_line);
  resolved_line = prxchange(cats('s/&tidsafgraensnings_kolonne\.?/',tidsafgraensnings_kolonne,'/i'), -1, resolved_line);
  resolved_line = prxchange(cats('s/&libname\.?/',libname,'/i'), -1, resolved_line);

  if _N_ = 1 then
    kode = resolved_line;
  else kode = catt(kode, '0A'x, resolved_line);
  put _N_= resolved_line=; /* Debugging output */

  if eof then
    output;
run;

/* hent den resolved kode*/
data _null_;
set regel_data;
call symput('regel_kode',kode);
run;
%mend resolve_code;
/*kør koden*/
&regel_kode;

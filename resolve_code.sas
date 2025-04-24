%macro resolve_code(regelnr=,debug=0);
%global regel_kode;
filename myfile "/home/JB4555/dqMotor/regel&regelnr..sas";

data _null_;
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
  %if &debug=1 %then %do;
    put resolved_line; /* Debugging output */
  %end;
  if eof then
    call symput('regel_kode',kode);
run;


%mend resolve_code;
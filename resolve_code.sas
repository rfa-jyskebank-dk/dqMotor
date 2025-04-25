%macro resolve_code(regelnr=,debug=0);
%global regel_kode;

data _null;

  set work.regel_data point=1;

  length regel_kode $32767 resolved_line $32767;

  resolved_line = prxchange(cats('s/&udtraeksdato\.?/',udtraeksdato,'/i'), -1, regel_kode);
  if regel_type_id<100 then do;
    resolved_line = prxchange(cats('s/&kolonne_navn\.?/',kolonne_navn,'/i'), -1, resolved_line);
    resolved_line = prxchange(cats('s/&tabel_navn\.?/',tabel_navn,'/i'), -1, resolved_line);
    resolved_line = prxchange(cats('s/&tidsafgraensnings_kolonne\.?/',tidsafgraensnings_kolonne,'/i'), -1, resolved_line);
    resolved_line = prxchange(cats('s/&libname\.?/',libname,'/i'), -1, resolved_line);
  end;
  call symput('regel_kode',resolved_line);
  stop;
run;


%mend resolve_code;
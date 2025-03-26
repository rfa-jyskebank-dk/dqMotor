filename auth '~/api_keys/jira';

data _null_;
  infile auth truncover;
  input key $100.;
  call symputx('api_key', key);
run;


data tabeller;
  infile datalines truncover;
  input tabel $100.;
  datalines;
regel_kritisk_data_element_map
daekning_anden
daekning_anden_type
daekning_kode
data_ejer
data_omraade
data_omraade_detail
dimension
domaene
grundata_kolonne
grundata_tabel
kommentar
kritisk_anv
kritisk_anv_ejer
kritisk_anv_regel_fravalgt
kritisk_data_element
kritisk_data_element_afdeakning
ks_beskrivelse
ks_kontrol
ks_maalling
regel_global_id
regel_avanceret
regel_beskrivelse
regel_evaluering
regel_graense_vaerdi
regel_graense_vaerdi_suppl
regel_koersel_liste
regel_maaling
rolle_id_kobling
rolle_suppl
rolle_suppl_type
stikproeve_maaling
stikproeve_evaluering
stikproeve_graenser
;
run;
options set=SSLREQCERT="never";
%macro createJiraIssues();
  %do i=1 %to %di_nobs(data=tabeller);

    data _null_;
      obs=&i;
      set tabeller point=obs;
      call symputx('tabelNavn', tabel);
      stop;
    run;



  /*Create json object*/
  proc json out="~/jiraIssue.json" pretty noscan;
    write open object;
    write values "fields";
    write open object;
    write values "project";
    write open object;
    write values "id" "26450";
    write close;
    write values "summary" "Oprettelse af &tabelNavn";
    write values "description" "*Userstory*: Som udvikler vil jeg oprette tabellen &INLIBDQres..&tabelNavn. i test\n\n
      *Refinement*: Rud + Henriette \n\n
      *Afhængigheder*: Tabeller som foreign keys peger på er oprettet\n\n
      *Usikkerhed i opgaveløsning*: Nej\n\n
      *Acceptkriterier*: Tabellen er oprettet i udviklingsmiljøet\n
      Der er gemt et tabel-oprettelses-script i tabel prod hist \n\n
      *Hvad går opgaven ud på*:\n\n
      &tabelNavn skal oprettes. Se https://confluence.corp.jyskebank.net/confluence/spaces/datakvalitet/pages/168104576/Datamodel+for+datakvalitetsmotoren for mere information.\n\n
      \n\n
      *Risikovurdering:* Lav
      \n\n
      *Risikovurdering beskrivelse:* Ingen";
    write values "issuetype";
    write open object;
    write values "id" "21";
    write close;
    write values "customfield_10233" 1;
    write values "customfield_10861" "T242-52";
    write close;
    write close;
  run;

  filename issue '~/jiraIssue.json';

  /* Create issue*/
  proc http
    url='https://app-jira.corp.jyskebank.net/jira/rest/api/2/issue/'
    in=issue
    method='POST'
    ct="application/JSON"
  ;
    headers "Accept"="application/json" "Authorization"="Bearer &api_key"
    ;
  run;

  %prochttp_check_return(code=201);
    %end;
%mend createJiraIssues;

%createJiraIssues();

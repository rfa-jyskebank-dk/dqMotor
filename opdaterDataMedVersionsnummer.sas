/* Create test data for regelGraenseVaerdi */
data regelGraenseVaerdi;
    input graenseVaerdiId graenseVersionsnummer delgraenseId intervalFarve $ intervalStart $ intervalSlut $ GraenseVaerdiKommentar $;
    datalines;
    1 1 1 'grøn' '>=0' '<10' 'Oprettet'
    1 1 2 'gul' '<0' '>-10' 'Oprettet'
    1 1 3 'Rød' '>=10' '' 'Oprettet'
    ;
run;


%metalib(&inlibdqres);

proc append base=&inlibdqres..regelGraenseVaerdi data=regelGraenseVaerdi;
run;

/* Create test data for regelGraenseVaerdiSuppl */
data regelGraenseVaerdiSuppl;
    input GraenseVaerdiSupplId GraenseVaerdiSupplVersionsnr GraenseVaerdiSupplKommentar $ graenseVaerdiId regelId beskrivelseVersionsnummer graenseVersionsnummer  $ enhed $ sammenlignJn $ sammenlignMedMaaling $;
    datalines;
    1 1 'Oprettet' 1 1 1 1  'antal' 'N' ''
    ;
run;

%metalib(&inlibdqres);

proc append base=&inlibdqres..regelGraenseVaerdiSuppl data=regelGraenseVaerdiSuppl;
run;


/* Create test data for regelAvanceret */
data regelAvanceret;
    input avanceretRegelId kodeVersionsnummer regelId beskrivelseVersionsnummer regelTypeId regelkode $ versionsnummerKommentar $;
    datalines;
    1 1 1 1 101 'proc sql;quit;' 'Oprettet'
    ;
run;

%metalib(&inlibdqres);

proc append base=&inlibdqres..regelAvanceret data=regelAvanceret;
run;

/* Create test data for regelBeskrivelse */
data regelBeskrivelse;
    input regelId beskrivelseVersionsnummer regelBeskrivelse $ status afviklingsfrekvens $ oplsaagsDato $ versionnummerKommentar $ regelTypeId;
    datalines;
    1 1 'oprettet' 1 'bankage' 'bankDagForrigeDag' 'oprettet' 101
    ;
run;

%metalib(&inlibdqres);

proc append base=&inlibdqres..regelBeskrivelse data=regelBeskrivelse;
run;

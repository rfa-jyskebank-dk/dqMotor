options locale=da_DK;

data dato_Tabel;
    length
        dato 8
        iDag $1
        dagNr 3
        ugedagNavn $7
        ugeNr 3
        maanedNavn $9
        maanedNr 3
        kvartalNr 3
        aar 3
        danskBankdagJn $1
        primoDanskBankdagJn $1
        ultimoDanskBankdagJn $1
        primoJn $1
        ultimoJn $1
        ultimoMdr 8
        primoMdr 8
        ultimoForrigeMdr 8
        primoForrigeMdr 8
        aarMnd 6
        aarMndForrigeMdr 6
        bankdagForrigeDag 8
        primoDanskBankdagForrigeMdr 8
        primoDanskBankdag 8
        ultimoDanskBankdagForrigeMdr 8
        ultimoDanskBankdag 8
        primoUgeDanskBankdagJn $1
        ultimoUgeDanskBankdagJn $1
        primoDanskBankdagKvartalJn $1
        ultimoDanskBankdagKvartalJn $1
        ultimoDanskBankdagKvartal 8
        primoDanskBankdagKvartal 8
        ultimoDkBdagKvtForrigeKvt 8
        primoDkBdagKvtForrigeKvt 8
        ultimoDanskBankdagAar 8
        primoDanskBankdagAar 8
        ultimoDanskBankdagAarJn  $1
        primoDanskBankdagAarJn $1
        irbOutputJn $1
        irbOutputDato 8
        forsteBdEfter20KldagJn $1
        forsteBdEfter20KldagDato 8
        tyskBankdagJn $1
        primoTyskBankdagJn $1
        ultimoTyskBankdagJn $1
        primoTyskBankdag 8
        ultimoTyskBankdag 8
    ;
;
    startDato=intnx('day',today(),-365*1,'s');
    slutDato=intnx('day',today(),365*1,'s');

    do _dato=startDato to slutDato;
        * Calculate basic date components;
        dato=dhms(_dato,0,0,0);
        if _dato=today() then iDag='J';
        else iDag='N';

        dagNr = day(_dato);
        ugedagNavn = Propcase(NLDATE(_dato,'%A'));
        ugeNr = week(_dato,'v');
        maanedNavn = propcase(NLDATE(_dato,'%B'));
        maanedNr = month(_dato);
        aar = year(_dato);
        aarMnd = cats(aar, put(maanedNr, z2.));
        aarMndForrigeMdr = cats(year(intnx('month', _dato, -1, 'e')), put(month(intnx('month', _dato, -1, 'e')), z2.));
        kvartalNr = qtr(_dato);

        * Determine bank days;
        if erBankdag(_dato) then danskBankdagJn = 'J';
        else danskBankdagJn = 'N';

        if erTyskBankdag(_dato) then tyskBankdagJn = 'J';
        else tyskBankdagJn = 'N';

        * Determine month boundaries;
        if _dato = intnx('month', _dato, 0, 'b') then primoJn = 'J';
        else primoJn = 'N';
        primoMdr = dhms(intnx('month', _dato, 0, 'b'), 0, 0, 0);
        primoForrigeMdr = dhms(intnx('month', _dato, -1, 'b'), 0, 0, 0);

        if _dato = intnx('month', _dato, 0, 'e') then ultimoJn = 'J';
        else ultimoJn = 'N';
        ultimoMdr = dhms(intnx('month', _dato, 0, 'e'), 0, 0, 0);
        ultimoForrigeMdr = dhms(intnx('month', _dato, -1, 'e'), 0, 0, 0);

        * Determine Danish bank days;
        primoDanskBankdag = dhms(BankdagEfter(intnx('month', _dato, -1, 'e')), 0, 0, 0);
        if _dato = datepart(primoDanskBankdag) then primoDanskBankdagJn = 'J';
        else primoDanskBankdagJn = 'N';

        ultimoDanskBankdag = dhms(BankdagFor(intnx('month', _dato, 1, 'b')), 0, 0, 0);
        if _dato = datepart(ultimoDanskBankdag) then ultimoDanskBankdagJn = 'J';
        else ultimoDanskBankdagJn = 'N';

        * Determine German bank days;
        primoTyskBankdag = dhms(tyskBankdagEfter(intnx('month', _dato, -1, 'e')), 0, 0, 0);
        if _dato = datepart(primoTyskBankdag) then primoTyskBankdagJn = 'J';
        else primoTyskBankdagJn = 'N';

        ultimoTyskBankdag = dhms(tyskBankdagFor(intnx('month', _dato, 1, 'b')), 0, 0, 0);
        if _dato = datepart(ultimoTyskBankdag) then ultimoTyskBankdagJn = 'J';
        else ultimoTyskBankdagJn = 'N';

        * Determine week boundaries;
        if _dato = bankdagefter(intnx('weekv', _dato, -1, 'e')) then primoUgeDanskBankdagJn = 'J';
        else primoUgeDanskBankdagJn = 'N';

        if _dato = bankdagFor(intnx('weekv', _dato, 1, 'b')) then ultimoUgeDanskBankdagJn = 'J';
        else ultimoUgeDanskBankdagJn = 'N';

        * Determine quarter boundaries;
        primoDanskBankdagKvartal = dhms(BankdagEfter(intnx('qtr', _dato, -1, 'e')), 0, 0, 0);
        if _dato = datepart(primoDanskBankdagKvartal) then primoDanskBankdagKvartalJn = 'J';
        else primoDanskBankdagKvartalJn = 'N';

        ultimoDanskBankdagKvartal = dhms(BankdagFor(intnx('qtr', _dato, 1, 'b')), 0, 0, 0);
        if _dato = datepart(ultimoDanskBankdagKvartal) then ultimoDanskBankdagKvartalJn = 'J';
        else ultimoDanskBankdagKvartalJn = 'N';

        primoDkBdagKvtForrigeKvt = dhms(BankdagEfter(intnx('qtr', _dato, -2, 'e')), 0, 0, 0);
        ultimoDkBdagKvtForrigeKvt = dhms(BankdagFor(intnx('qtr', _dato, 0, 'b')), 0, 0, 0);

        * Determine year boundaries;
        primoDanskBankdagAar = dhms(BankdagEfter(intnx('year', _dato, -1, 'e')), 0, 0, 0);
        if _dato = datepart(primoDanskBankdagAar) then primoDanskBankdagAarJn = 'J';
        else primoDanskBankdagAarJn = 'N';

        ultimoDanskBankdagAar = dhms(BankdagFor(intnx('year', _dato, 1, 'b')), 0, 0, 0);
        if _dato = datepart(ultimoDanskBankdagAar) then ultimoDanskBankdagAarJn = 'J';
        else ultimoDanskBankdagAarJn = 'N';

        * Calculate additional fields;
        bankdagForrigeDag = dhms(BankdagFor(_dato), 0, 0, 0);
        primoDanskBankdagForrigeMdr = dhms(BankdagEfter(intnx('month', _dato, -2, 'e')), 0, 0, 0);
        ultimoDanskBankdagForrigeMdr = dhms(BankdagFor(intnx('month', _dato, 0, 'b')), 0, 0, 0);

        if dagNr = 20 then forsteBdEfter20KldagDato = dhms(bankdagefter(datepart(_dato)), 0, 0, 0);

        if _dato = forsteBdEfter20KldagDato then forsteBdEfter20KldagJn = 'J';
        else forsteBdEfter20KldagJn = 'N';

        if primoDanskBankdagKvartalJn = 'J' then antalBankdageEfterPrimoKvt = 1;
        else if erBankdag(_dato) then antalBankdageEfterPrimoKvt + 1;

        if antalBankdageEfterPrimoKvt = 6 then do;
            irbOutputJn = 'J';
            irbOutputDato = dhms(_dato, 0, 0, 0);
        end;
        else irbOutputJn = 'N';

        output;
    end;

    format ultimoMdr
    primoMdr
    primoForrigeMdr
    ultimoForrigeMdr
    primoDkBdagKvtForrigeKvt
    ultimoDkBdagKvtForrigeKvt
    ultimoDanskBankdagKvartal
    primoDanskBankdagKvartal
    primoDanskBankdag
    ultimoDanskBankdag
    bankdagForrigeDag
    primoDanskBankdagForrigeMdr
    ultimoDanskBankdagForrigeMdr
    ultimoTyskBankdag
    primoTyskBankdag
    primoDanskBankdagAar
    ultimoDanskBankdagAar
    irbOutputDato
    forsteBdEfter20KldagDato
    dato
    datetime25.6
    ;

    drop
    startDato
    slutDato
    _dato
    antalBankdageEfterPrimoKvt
    ;
run;

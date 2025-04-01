options locale=da_DK;

data dato_tabel;
    length
        dato 8
        i_dag $1
        dag_nr 3
        ugedag_navn $7
        uge_nr 3
        maaned_navn $9
        maaned_nr 3
        kvartal_nr 3
        aar 3
        dansk_bankdag_jn $1
        primo_dansk_bankdag_jn $1
        ultimo_dansk_bankdag_jn $1
        primo_jn $1
        ultimo_jn $1
        ultimo_mdr 8
        primo_mdr 8
        ultimo_forrige_mdr 8
        primo_forrige_mdr 8
        aar_mnd 6
        aar_mnd_forrige_mdr 6
        bankdag_forrige_dag 8
        primo_dansk_bankdag_forrige_mdr 8
        primo_dansk_bankdag 8
        ultimo_dansk_bankdag_forrige_mdr 8
        ultimo_dansk_bankdag 8
        primo_uge_dansk_bankdag_jn $1
        ultimo_uge_dansk_bankdag_jn $1
        primo_dansk_bankdag_kvartal_jn $1
        ultimo_dansk_bankdag_kvartal_jn $1
        ultimo_dansk_bankdag_kvartal 8
        primo_dansk_bankdag_kvartal 8
        ultimo_dk_bdag_kvt_forrige_kvt 8
        primo_dk_bdag_kvt_forrige_kvt 8
        ultimo_dansk_bankdag_aar 8
        primo_dansk_bankdag_aar 8
        ultimo_dansk_bankdag_aar_jn $1
        primo_dansk_bankdag_aar_jn $1
        irb_output_jn $1
        irb_output_dato 8
        forste_bd_efter_20_kldag_jn $1
        forste_bd_efter_20_kldag_dato 8
        tysk_bankdag_jn $1
        primo_tysk_bankdag_jn $1
        ultimo_tysk_bankdag_jn $1
        primo_tysk_bankdag 8
        ultimo_tysk_bankdag 8
    ;
;
    start_dato = intnx('day', today(), -365*1, 's');
    slut_dato = intnx('day', today(), 365*1, 's');

    do _dato = start_dato to slut_dato;
        * Calculate basic date components;
        dato = dhms(_dato, 0, 0, 0);
        if _dato = today() then i_dag = 'J';
        else i_dag = 'N';

        dag_nr = day(_dato);
        ugedag_navn = Propcase(NLDATE(_dato, '%A'));
        uge_nr = week(_dato, 'v');
        maaned_navn = propcase(NLDATE(_dato, '%B'));
        maaned_nr = month(_dato);
        aar = year(_dato);
        aar_mnd = cats(aar, put(maaned_nr, z2.));
        aar_mnd_forrige_mdr = cats(year(intnx('month', _dato, -1, 'e')), put(month(intnx('month', _dato, -1, 'e')), z2.));
        kvartal_nr = qtr(_dato);

        * Determine bank days;
        if erbankdag(_dato) then dansk_bankdag_jn = 'J';
        else dansk_bankdag_jn = 'N';

        if ertyskbankdag(_dato) then tysk_bankdag_jn = 'J';
        else tysk_bankdag_jn = 'N';

        * Determine month boundaries;
        if _dato = intnx('month', _dato, 0, 'b') then primo_jn = 'J';
        else primo_jn = 'N';
        primo_mdr = dhms(intnx('month', _dato, 0, 'b'), 0, 0, 0);
        primo_forrige_mdr = dhms(intnx('month', _dato, -1, 'b'), 0, 0, 0);

        if _dato = intnx('month', _dato, 0, 'e') then ultimo_jn = 'J';
        else ultimo_jn = 'N';
        ultimo_mdr = dhms(intnx('month', _dato, 0, 'e'), 0, 0, 0);
        ultimo_forrige_mdr = dhms(intnx('month', _dato, -1, 'e'), 0, 0, 0);

        * Determine Danish bank days;
        primo_dansk_bankdag = dhms(BankdagEfter(intnx('month', _dato, -1, 'e')), 0, 0, 0);
        if _dato = datepart(primo_dansk_bankdag) then primo_dansk_bankdag_jn = 'J';
        else primo_dansk_bankdag_jn = 'N';

        ultimo_dansk_bankdag = dhms(bankdagFor(intnx('month', _dato, 1, 'b')), 0, 0, 0);
        if _dato = datepart(ultimo_dansk_bankdag) then ultimo_dansk_bankdag_jn = 'J';
        else ultimo_dansk_bankdag_jn = 'N';

        * Determine German bank days;
        primo_tysk_bankdag = dhms(tyskBankdagFor(intnx('month', _dato, -1, 'e')), 0, 0, 0);
        if _dato = datepart(primo_tysk_bankdag) then primo_tysk_bankdag_jn = 'J';
        else primo_tysk_bankdag_jn = 'N';

        ultimo_tysk_bankdag = dhms(bankdagFor(intnx('month', _dato, 1, 'b')), 0, 0, 0);
        if _dato = datepart(ultimo_tysk_bankdag) then ultimo_tysk_bankdag_jn = 'J';
        else ultimo_tysk_bankdag_jn = 'N';

        * Determine week boundaries;
        if _dato = bankdagEfter(intnx('weekv', _dato, -1, 'e')) then primo_uge_dansk_bankdag_jn = 'J';
        else primo_uge_dansk_bankdag_jn = 'N';

        if _dato = bankdagFor(intnx('weekv', _dato, 1, 'b')) then ultimo_uge_dansk_bankdag_jn = 'J';
        else ultimo_uge_dansk_bankdag_jn = 'N';

        * Determine quarter boundaries;
        primo_dansk_bankdag_kvartal = dhms(BankdagEfter(intnx('qtr', _dato, -1, 'e')), 0, 0, 0);
        if _dato = datepart(primo_dansk_bankdag_kvartal) then primo_dansk_bankdag_kvartal_jn = 'J';
        else primo_dansk_bankdag_kvartal_jn = 'N';

        ultimo_dansk_bankdag_kvartal = dhms(bankdagFor(intnx('qtr', _dato, 1, 'b')), 0, 0, 0);
        if _dato = datepart(ultimo_dansk_bankdag_kvartal) then ultimo_dansk_bankdag_kvartal_jn = 'J';
        else ultimo_dansk_bankdag_kvartal_jn = 'N';

        primo_dk_bdag_kvt_forrige_kvt = dhms(BankdagEfter(intnx('qtr', _dato, -2, 'e')), 0, 0, 0);
        ultimo_dk_bdag_kvt_forrige_kvt = dhms(bankdagFor(intnx('qtr', _dato, 0, 'b')), 0, 0, 0);

        * Determine year boundaries;
        primo_dansk_bankdag_aar = dhms(BankdagEfter(intnx('year', _dato, -1, 'e')), 0, 0, 0);
        if _dato = datepart(primo_dansk_bankdag_aar) then primo_dansk_bankdag_aar_jn = 'J';
        else primo_dansk_bankdag_aar_jn = 'N';

        ultimo_dansk_bankdag_aar = dhms(bankdagFor(intnx('year', _dato, 1, 'b')), 0, 0, 0);
        if _dato = datepart(ultimo_dansk_bankdag_aar) then ultimo_dansk_bankdag_aar_jn = 'J';
        else ultimo_dansk_bankdag_aar_jn = 'N';

        * Calculate additional fields;
        bankdag_forrige_dag = dhms(bankdagFor(_dato), 0, 0, 0);
        primo_dansk_bankdag_forrige_mdr = dhms(BankdagEfter(intnx('month', _dato, -2, 'e')), 0, 0, 0);
        ultimo_dansk_bankdag_forrige_mdr = dhms(bankdagFor(intnx('month', _dato, 0, 'b')), 0, 0, 0);

        if dag_nr = 20 then forste_bd_efter_20_kldag_dato = dhms(BankdagEfter(datepart(_dato)), 0, 0, 0);

        if _dato = forste_bd_efter_20_kldag_dato then forste_bd_efter_20_kldag_jn = 'J';
        else forste_bd_efter_20_kldag_jn = 'N';

        if primo_dansk_bankdag_kvartal_jn = 'J' then antal_bankdage_efter_primo_kvt = 1;
        else if erbankdag(_dato) then antal_bankdage_efter_primo_kvt + 1;

        if antal_bankdage_efter_primo_kvt = 6 then do;
            irb_output_jn = 'J';
            irb_output_dato = dhms(_dato, 0, 0, 0);
        end;
        else irb_output_jn = 'N';

        output;
    end;

    format ultimo_mdr
    primo_mdr
    primo_forrige_mdr
    ultimo_forrige_mdr
    primo_dk_bdag_kvt_forrige_kvt
    ultimo_dk_bdag_kvt_forrige_kvt
    ultimo_dansk_bankdag_kvartal
    primo_dansk_bankdag_kvartal
    primo_dansk_bankdag
    ultimo_dansk_bankdag
    bankdag_forrige_dag
    primo_dansk_bankdag_forrige_mdr
    ultimo_dansk_bankdag_forrige_mdr
    ultimo_tysk_bankdag
    primo_tysk_bankdag
    primo_dansk_bankdag_aar
    ultimo_dansk_bankdag_aar
    irb_output_dato
    forste_bd_efter_20_kldag_dato
    dato
    datetime25.6
    ;

    drop
    start_dato
    slut_dato
    _dato
    antal_bankdage_efter_primo_kvt
    ;
run;

%metalib(dqres)
proc append base=&inlibdqres..kalender data=work.dato_tabel;
run;
data _null_;
  dato=date();
  PRIMO_DANSK_BANKDAG=BankdagEfterAntalDage(intnx('month',dato,-1,'e'),1);
  ULTIMO_DANSK_BANKDAG=BankdagForAntalDage(intnx('month',dato,-1,'e'),1);
  ULTIMO_DATO=intnx('month', dato, 0, 'end');
  PRIMO_DATO=intnx('month', dato, 0, 'begin');
  put dato=;
  put PRIMO_DATO=;
  put ULTIMO_DATO=;
  put PRIMO_DANSK_BANKDAG=;
  put ULTIMO_DANSK_BANKDAG=;
  format dato PRIMO_DANSK_BANKDAG ULTIMO_DANSK_BANKDAG ULTIMO_DATO PRIMO_DATO
    date9.;
run;

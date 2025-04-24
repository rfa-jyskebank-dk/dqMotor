%metalib(&dqres);

proc sql;
	create table regler_i_spor
		as select regel_id
			from &inlibdqres..regel_korselsliste
				where spor=1;
quit;


proc sql;
  %odbc_connect(&inlibjb_dw. /* jbdw */);
  create table tabel
    as select columns
  from connection to odbc
    (
    sql-statement
    );
  disconnect from odbc;
quit;

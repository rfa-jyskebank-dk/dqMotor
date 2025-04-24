%metalib(dqres,data);
%metareg(dqres);

data _null_;
	length uri $256;
	call missing(uri, nobj);

	* Get URI for table I want to delete;
	nobj=metadata_getnobj("omsobj:DataTable?@Name='regel_beskrivelse'",1,uri);

	* Delete table;
	rc = METADATA_DELOBJ(uri);

	* Output for debug purposes;
	put nobj= rc=;
run;

proc sql;
	%odbc_connect(dqres);
select  catt('"',name,'"') length=100  format=$100. into :temporal separated by ' ' 
			from connection to odbc
				(
			select name
				from sys.tables
				where name like 'temporal_%'
				);
	disconnect from odbc;
quit;
%put &=temporal;
proc metalib;
	omr (liburi="SASLibrary?@libref='dqres'");
	update_rule=(delete);
	exclude ("temporal_kritisk_anv");
	report(type=detail);
run;

proc sql;
	create table meta
		as select memname as name
			from sashelp.vtable
				where libname='DQRES';
run;

proc sql;
	%odbc_connect(dqres);
	create table tabel
		as select name
			from connection to odbc
				(
			select name
				from sys.tables
				);
	disconnect from odbc;
quit;

proc sql;
	select t1.name as metaname, t2.name as sqlname
		from meta t1
			full join tabel t2
				on t1.name=t2.name;
quit;


proc metalib;
   omr (liburi="SASLibrary?@libref='DQ'");
   select("dim_status");
   update_rule=(delete);
   report(type=detail);
run;

data _null_;
   length uri $256;
   rc = metadata_getnobj("omsobj:DataTable?@Name='regel_beskrivelse'",1,uri);
   if rc > 0 then do;
      rc = metadata_delobj(uri);
      put "Metadata object deleted: " rc=;
   end;
   else put "Table not found in metadata.";
run;



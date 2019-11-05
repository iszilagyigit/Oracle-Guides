set serveroutput on
declare
	v_maximum_line_length constant number(2) := 80;
	v_separator constant varchar2(2) := ', ';
	v_line_length number(2);
	v_object_count number;
	v_object_type varchar2(100);
	v_object_summary_line varchar2(30000);
	v_object_summary_item varchar2(100);
	v_iteration number := 0;
begin

	select count(*) into v_object_count from user_objects where generated='N';
	v_object_summary_line := 'Schema contains ' || v_object_count || ' objects';

	if v_object_count > 0 then
		v_object_summary_line := v_object_summary_line || ' (';
	end if;

	v_line_length := length(v_object_summary_line);
	for o in (select object_type,count(*) as object_count from user_objects where generated='N' group by object_type order by object_type) loop
		
		if v_iteration != 0 then
			v_object_summary_line := v_object_summary_line || v_separator;
			v_line_length := v_line_length + length(v_separator);
		end if;
        v_object_type := lower(o.object_type);
		v_object_summary_item := o.object_count || ' ' || v_object_type || '(s)';
		
		-- Neue Output Zeile falls notwendig
		if v_line_length + length(v_object_summary_item) > v_maximum_line_length then
			dbms_output.put_line(v_object_summary_line);
			v_object_summary_line := null;
			v_line_length := 0;
		end if;
		
		v_object_summary_line := v_object_summary_line || v_object_summary_item;
		v_line_length := v_line_length + length(v_object_summary_item);
		
		v_iteration := v_iteration + 1;		
	end loop;
	if v_object_count > 0 then
		v_object_summary_line := v_object_summary_line || ')';
	end if;
	if v_object_summary_line is not null then
		dbms_output.put_line(v_object_summary_line);
	end if;
	
end;
/
set serveroutput off

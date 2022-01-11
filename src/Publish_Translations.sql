FUNCTION Publish_Translations (
    p_Application_ID NUMBER,
    p_Exec_Asynchronous VARCHAR2 DEFAULT 'Y',
    p_Seed_Translations VARCHAR2 DEFAULT 'Y'
)
RETURN BOOLEAN
IS
	job_exist EXCEPTION;
	PRAGMA EXCEPTION_INIT (job_exist, -27477); -- ORA-27477: job already exists
    v_Owner APEX_APPLICATIONS.OWNER%TYPE;
    v_Pref_Name VARCHAR2(64) := 'PUBLISH_TRANSLATIONS'||p_Application_ID;
    v_Last_Updated VARCHAR2(64);
    v_sql USER_SCHEDULER_JOBS.JOB_ACTION%TYPE;
BEGIN 
    select OWNER, TO_CHAR(LAST_UPDATED_ON, 'YYYY/MM/DD HH24:MI:SS')
    into v_Owner, v_Last_Updated
    from APEX_APPLICATIONS
    where APPLICATION_ID = p_Application_ID;
    if v_Last_Updated = apex_util.get_preference(v_Pref_Name, v_Owner) then 
        return true;
    end if;
    apex_util.set_preference(
        p_preference => v_Pref_Name, 
        p_value => v_Last_Updated,
        p_user => v_Owner
    );
    commit;
    v_sql := apex_string.format(p_message => 
        'begin 
        !   apex_session.attach (%s, %s, %s);
        !   for cur in (
        !       select PRIMARY_APPLICATION_ID app_id, TRANSLATED_APP_LANGUAGE lang
        !       from APEX_APPLICATION_TRANS_MAP
        !       where PRIMARY_APPLICATION_ID = %s
        !   ) loop
        !      %s apex_lang.seed_translations(cur.app_id, cur.lang);
        !       apex_lang.publish_application(cur.app_id, cur.lang);
        !   end loop;
        !   apex_session.detach;
        !end;', 
        p0 => p_Application_ID, 
        p1 => V('APP_PAGE_ID'),
        p2 => V('APP_SESSION'),
        p3 => p_Application_ID, 
        p4 => case when p_seed_translations = 'N' then '-- ' end,
        p_prefix => '!'
    );
    if apex_application.g_debug then
        apex_debug.message('exec_asynchronous: %s', p_exec_asynchronous);
        apex_debug.message('seed_translations: %s', p_seed_translations);
        apex_debug.message('job_action: %s', v_sql);
    end if;
    if p_exec_asynchronous = 'Y' then 
        dbms_scheduler.create_job(
            job_name => v_Pref_Name,
            start_date => SYSDATE,
            job_type => 'PLSQL_BLOCK',
            job_action => v_sql,
            enabled => true 
        );
    else 
        EXECUTE IMMEDIATE v_sql;
    end if;
    return false;
EXCEPTION WHEN job_exist THEN
	return true;
END Publish_Translations;

FUNCTION plugin_publish_translations (
    p_process in apex_plugin.t_process,
    p_plugin  in apex_plugin.t_plugin )
RETURN apex_plugin.t_process_exec_result
IS
    v_exec_result apex_plugin.t_process_exec_result;
    v_exec_asynchronous VARCHAR2(30);
    v_seed_translations VARCHAR2(30);
BEGIN
    if apex_application.g_debug then
        apex_plugin_util.debug_process (
            p_plugin => p_plugin,
            p_process => p_process
        );
    end if;
    v_exec_asynchronous := p_process.attribute_01;
    v_seed_translations  := p_process.attribute_02;
    v_exec_result.execution_skipped := Publish_Translations(
        p_Application_ID => apex_application.g_flow_id, 
        p_Exec_Asynchronous => v_exec_asynchronous,
        p_Seed_Translations => v_seed_translations
    );
    RETURN v_exec_result;
END plugin_publish_translations;

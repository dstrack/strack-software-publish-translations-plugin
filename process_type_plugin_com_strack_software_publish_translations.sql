prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_190100 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2019.03.31'
,p_release=>'19.1.0.00.15'
,p_default_workspace_id=>1293931922049787
,p_default_application_id=>530
,p_default_owner=>'HR_DATA'
);
end;
/
prompt --application/shared_components/plugins/process_type/com_strack_software_publish_translations
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(545080404462086996)
,p_plugin_type=>'PROCESS TYPE'
,p_name=>'COM.STRACK_SOFTWARE.PUBLISH_TRANSLATIONS'
,p_display_name=>'Seed and Publish Translations'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'FUNCTION Publish_Translations (',
'	p_Application_ID NUMBER,',
'	p_Exec_Asynchronous VARCHAR2 DEFAULT ''Y'',',
'	p_Seed_Translations VARCHAR2 DEFAULT ''Y''',
')',
'RETURN BOOLEAN',
'IS',
'	v_Owner APEX_APPLICATIONS.OWNER%TYPE;',
'	v_Pref_Name VARCHAR2(64) := ''PUBLISH_TRANSLATIONS''||p_Application_ID;',
'	v_Last_Updated VARCHAR2(64);',
'	v_sql USER_SCHEDULER_JOBS.JOB_ACTION%TYPE;',
'BEGIN ',
'	select OWNER, TO_CHAR(LAST_UPDATED_ON, ''YYYY/MM/DD HH24:MI:SS'')',
'	into v_Owner, v_Last_Updated',
'	from APEX_APPLICATIONS',
'	where APPLICATION_ID = p_Application_ID;',
'	if v_Last_Updated = apex_util.get_preference(v_Pref_Name, v_Owner) then ',
'		return true;',
'	end if;',
'	apex_util.set_preference(',
'		p_preference => v_Pref_Name, ',
'		p_value => v_Last_Updated,',
'		p_user => v_Owner',
'	);',
'	v_sql := apex_string.format(p_message => ',
'		''begin ',
'		!	apex_session.attach (%s, %s, %s);',
'		!	for cur in (',
'		!		select PRIMARY_APPLICATION_ID app_id, TRANSLATED_APP_LANGUAGE lang',
'		!		from APEX_APPLICATION_TRANS_MAP',
'		!		where PRIMARY_APPLICATION_ID = %s',
'		!	) loop',
'		!       %s',
'		!		apex_lang.publish_application(cur.app_id, cur.lang);',
'		!	end loop;',
'		!	apex_session.detach;',
'		!end;'', ',
'		p0 => p_Application_ID, ',
'		p1 => V(''APP_PAGE_ID''),',
'		p2 => V(''APP_SESSION''),',
'		p3 => p_Application_ID, ',
'		p4 => case when p_seed_translations = ''Y'' then ',
'			''apex_lang.seed_translations(cur.app_id, cur.lang);''',
'		end,',
'		p_prefix => ''!''',
'	);',
'	if apex_application.g_debug then',
'		apex_debug.message(''exec_async: %s'', p_exec_asynchronous);',
'		apex_debug.message(''job_action: %s'', v_sql);',
'	end if;',
'	if p_exec_asynchronous = ''Y'' then ',
'		dbms_scheduler.create_job(',
'			job_name => v_Pref_Name,',
'			start_date => SYSDATE,',
'			job_type => ''PLSQL_BLOCK'',',
'			job_action => v_sql,',
'			enabled => true ',
'		);',
'	else ',
'		EXECUTE IMMEDIATE v_sql;',
'	end if;',
'	return false;',
'END Publish_Translations;',
'',
'FUNCTION plugin_publish_translations (',
'	p_process in apex_plugin.t_process,',
'	p_plugin  in apex_plugin.t_plugin )',
'RETURN apex_plugin.t_process_exec_result',
'IS',
'	v_exec_result apex_plugin.t_process_exec_result;',
'	v_exec_asynchronous VARCHAR2(30);',
'	v_seed_translations VARCHAR2(30);',
'BEGIN',
'	if apex_application.g_debug then',
'		apex_plugin_util.debug_process (',
'			p_plugin => p_plugin,',
'			p_process => p_process',
'		);',
'	end if;',
'	v_exec_asynchronous := p_process.attribute_01;',
'	v_seed_translations  := p_process.attribute_02;',
'	v_exec_result.execution_skipped := Publish_Translations(',
'		p_Application_ID => apex_application.g_flow_id, ',
'		p_Exec_Asynchronous => v_exec_asynchronous,',
'		p_Seed_Translations => v_seed_translations',
'	);',
'	RETURN v_exec_result;',
'END plugin_publish_translations;',
''))
,p_api_version=>2
,p_execution_function=>'plugin_publish_translations'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>'Automatic seed and publish translated APEX application with an asynchronous backgound job.'
,p_version_identifier=>'2.0.1'
,p_about_url=>'https://github.com/dstrack/strack-software-publish-translations-plugin.git'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(545080605220094927)
,p_plugin_id=>wwv_flow_api.id(545080404462086996)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Execute Asynchronous'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'When this option is set to Yes, then the seed and publish of the translated apps is executed asynchronous by an scheduler job.',
'Otherwise, the application user has to wait until the seed and publish process is completed.'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(545120887193060741)
,p_plugin_id=>wwv_flow_api.id(545080404462086996)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Seed Translations'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Seeding the translation copies all translatable text into the translation text repository. ',
'When this option is set to Yes, then seeding of the translated text is executed.',
'Otherwise, the seeding of translatable text is skipped.'))
);
end;
/
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false), p_is_component_import => true);
commit;
end;
/
set verify on feedback on define on
prompt  ...done

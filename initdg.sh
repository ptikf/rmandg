rm -rf /opt/oracle/oradata/ORCLCDB/*.dbf
rm -rf /opt/oracle/oradata/ORCLCDB/*.log
rm -rf /opt/oracle/oradata/ORCLCDBDG/*.dbf
rm -rf /opt/oracle/oradata/ORCLCDBDG/*.log
rm -rf /opt/oracle/diag/rdbms/cdb_stby/ORCLCDB/trace/*


rm -rf /opt/oracle/fast_recovery_area/CDB_STBY/*

sqlplus / as sysdba <<EOF
STARTUP NOMOUNT PFILE='/tmp/initorclcdb_stdby.ora';
exit
EOF

rman TARGET sys/Fuguer1#@CDB_PRIM AUXILIARY sys/Fuguer1#@CDB_STBY <<EOF
run {
allocate channel C1 type disk ;
allocate channel C2 type disk ;
allocate channel C3 type disk ;
allocate channel C4 type disk ;
allocate auxiliary channel stby type disk ;
DUPLICATE TARGET DATABASE
  FOR STANDBY
  FROM ACTIVE DATABASE
  SPFILE
    set db_unique_name='CDB_STBY'
        set db_file_name_convert='/opt/oracle/oradata/ORCLCDB/','/opt/oracle/oradata/ORCLCDBDG/'
        set log_file_name_convert='/opt/oracle/oradata/ORCLCDB/','/opt/oracle/oradata/ORCLCDBDG/'
        set db_recovery_FILE_DEST_SIZE='2G'
        set db_recovery_file_dest='/opt/oracle/fast_recovery_area/'
        set control_files='/opt/oracle/product/19c/dbhome_1/dbs/control01.ctl','/opt/oracle/product/19c/dbhome_1/dbs/control02.ctl'
        set fal_client='CDB_CTBY'
        set fal_server='CDB_PRIM'
        set standby_file_management='AUTO'
        set log_archive_config='dg_config=(CDB_PRIM,CDB_STBY)'
        set log_archive_dest_1='location=use_db_recovery_file_dest valid_for=(all_logfiles,all_roles) db_unique_name=CDB_STBY'
#        set log_archive_dest_2='SERVICE=CDB_PRIM ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=CDB_PRIM'
  NOFILENAMECHECK;
  }
EOF
exit

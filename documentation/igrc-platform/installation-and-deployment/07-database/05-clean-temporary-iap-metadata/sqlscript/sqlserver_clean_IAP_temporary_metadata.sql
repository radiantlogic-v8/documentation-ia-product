-- ------------------------------------------------------------------------
-- Filename:   sqlserver_clean_IAS_temporary_metadata.sql
-- Purpose :   Clean temporary metadata after migration to CurieR2
-- COMPANY : Identity Analytics
--  Date : February 2022
-- To execute in Microsoft SQL Server Management Studio
-- ------------------------------------------------------------------------

select current_timestamp as START_TIME;

delete from tmetadata where ckey = 'bwa_accountmetrics_nbbusinessactivity';
delete from tmetadata where ckey = 'bwa_accountmetrics_nbfsrights';
delete from tmetadata where ckey = 'bwa_accountmetrics_nbgroup';
delete from tmetadata where ckey = 'bwa_accountmetrics_nbperimeter';
delete from tmetadata where ckey = 'bwa_accountmetrics_nbrights';
delete from tmetadata where ckey = 'bwa_accountmetrics_nbrisks';
delete from tmetadata where ckey = 'bwa_accountmetrics_nbtheoretical';
delete from tmetadata where ckey = 'bwa_accountmetrics_nbusage';
delete from tmetadata where ckey = 'bwa_accountmetrics_riskrank';
delete from tmetadata where ckey = 'bwa_accountmetrics_score';
delete from tmetadata where ckey = 'bwa_accountrepositorymetrics_nbgroup';
delete from tmetadata where ckey = 'bwa_applicationmetrics_nbbusinessactivity';
delete from tmetadata where ckey = 'bwa_applicationmetrics_nbtheoretical';
delete from tmetadata where ckey = 'bwa_applicationmetrics_nbusage';
delete from tmetadata where ckey = 'bwa_appmetrics_nb';
delete from tmetadata where ckey = 'bwa_appmetrics_nbperimeter';
delete from tmetadata where ckey = 'bwa_applicationmetrics_nbperm';
delete from tmetadata where ckey = 'bwa_applicationmetrics_nbright';
delete from tmetadata where ckey = 'bwa_ba_root';

delete from tmetadata where ckey = 'bwa_foldermetrics_nbfull';
delete from tmetadata where ckey = 'foldermetrics_nbrw';
delete from tmetadata where ckey = 'bwa_groupmetrics_nb';
delete from tmetadata where ckey = 'bwa_groupmetrics_nbappshare';
delete from tmetadata where ckey = 'bwa_groupmetrics_nbdirect';
delete from tmetadata where ckey = 'bwa_identitymetrics_aggnbrisks';
delete from tmetadata where ckey = 'bwa_identitymetrics_aggscore';
delete from tmetadata where ckey = 'bwa_identitymetrics_nbaccount';
delete from tmetadata where ckey = 'bwa_identitymetrics_nbappshare';
delete from tmetadata where ckey = 'bwa_identitymetrics_nbbusinessactivity';
delete from tmetadata where ckey = 'bwa_identitymetrics_nbperimeter';
delete from tmetadata where ckey = 'bwa_identitymetrics_nbrisks';
delete from tmetadata where ckey = 'bwa_identitymetrics_nbtheoretical';
delete from tmetadata where ckey = 'bwa_identitymetrics_nbusage';
delete from tmetadata where ckey = 'bwa_identitymetrics_orgsjobs';
delete from tmetadata where ckey = 'bwa_identitymetrics_riskrank';
delete from tmetadata where ckey = 'bwa_identitymetrics_score';
delete from tmetadata where ckey = 'bwa_orgmetrics_aggscore';
delete from tmetadata where ckey = 'bwa_orgmetrics_depth';
delete from tmetadata where ckey = 'bwa_orgmetrics_nbappshare';
delete from tmetadata where ckey = 'bwa_orgmetrics_nbbusinessactivity';
delete from tmetadata where ckey = 'bwa_orgmetrics_nbmembers';
delete from tmetadata where ckey = 'bwa_orgmetrics_nbperimeter';
delete from tmetadata where ckey = 'bwa_orgmetrics_nbproblems';
delete from tmetadata where ckey = 'bwa_orgmetrics_nbsuborgs';
delete from tmetadata where ckey = 'bwa_orgmetrics_nbtheoretical';
delete from tmetadata where ckey = 'bwa_orgmetrics_nbusages';
delete from tmetadata where ckey = 'bwa_orgmetrics_riskrank';
delete from tmetadata where ckey = 'bwa_orgmetrics_score';
delete from tmetadata where ckey = 'bwa_permissionmetrics_nbsubpermission';
delete from tmetadata where ckey = 'bwa_permissionmetrics_nbtheoretical';
delete from tmetadata where ckey = 'bwa_permissionmetrics_nbusage';
delete from tmetadata where ckey = 'bwa_permmetrics_nb';
delete from tmetadata where ckey = 'bwa_repositorymetrics_nb';
delete from tmetadata where ckey = 'bwf_repositorymetrics_nbappshare';
delete from tmetadata where ckey = 'bwa_repositorymetrics_nbgroup';
delete from tmetadata where ckey = 'bwa_repositorymetrics_nbright';
delete from tmetadata where ckey = 'bwa_repositorymetrics_nbusage';
delete from tmetadata where ckey = 'bwa_sharemetrics_nbfolders';
delete from tmetadata where ckey = 'sharemetrics_nbfull';
delete from tmetadata where ckey = 'bwa_sharemetrics_nbrw';

delete from tportalmetadata where ckey = 'bwa_accountmetrics_nbbusinessactivity';
delete from tportalmetadata where ckey = 'bwa_accountmetrics_nbfsrights';
delete from tportalmetadata where ckey = 'bwa_accountmetrics_nbgroup';
delete from tportalmetadata where ckey = 'bwa_accountmetrics_nbperimeter';
delete from tportalmetadata where ckey = 'bwa_accountmetrics_nbrights';
delete from tportalmetadata where ckey = 'bwa_accountmetrics_nbrisks';
delete from tportalmetadata where ckey = 'bwa_accountmetrics_nbtheoretical';
delete from tportalmetadata where ckey = 'bwa_accountmetrics_nbusage';
delete from tportalmetadata where ckey = 'bwa_accountmetrics_riskrank';
delete from tportalmetadata where ckey = 'bwa_accountmetrics_score';
delete from tportalmetadata where ckey = 'bwa_accountrepositorymetrics_nbgroup';
delete from tportalmetadata where ckey = 'bwa_applicationmetrics_nbbusinessactivity';
delete from tportalmetadata where ckey = 'bwa_applicationmetrics_nbtheoretical';
delete from tportalmetadata where ckey = 'bwa_applicationmetrics_nbusage';
delete from tportalmetadata where ckey = 'bwa_appmetrics_nb';
delete from tportalmetadata where ckey = 'bwa_appmetrics_nbperimeter';
delete from tportalmetadata where ckey = 'bwa_applicationmetrics_nbperm';
delete from tportalmetadata where ckey = 'bwa_applicationmetrics_nbright';

delete from tportalmetadata where ckey = 'bwa_ba_root';
delete from tportalmetadata where ckey = 'bwa_foldermetrics_nbfull';
delete from tportalmetadata where ckey = 'foldermetrics_nbrw';
delete from tportalmetadata where ckey = 'bwa_groupmetrics_nb';
delete from tportalmetadata where ckey = 'bwa_groupmetrics_nbappshare';
delete from tportalmetadata where ckey = 'bwa_groupmetrics_nbdirect';
delete from tportalmetadata where ckey = 'bwa_identitymetrics_aggnbrisks';
delete from tportalmetadata where ckey = 'bwa_identitymetrics_aggscore';
delete from tportalmetadata where ckey = 'bwa_identitymetrics_nbaccount';
delete from tportalmetadata where ckey = 'bwa_identitymetrics_nbappshare';
delete from tportalmetadata where ckey = 'bwa_identitymetrics_nbbusinessactivity';
delete from tportalmetadata where ckey = 'bwa_identitymetrics_nbperimeter';
delete from tportalmetadata where ckey = 'bwa_identitymetrics_nbrisks';
delete from tportalmetadata where ckey = 'bwa_identitymetrics_nbtheoretical';
delete from tportalmetadata where ckey = 'bwa_identitymetrics_nbusage';
delete from tportalmetadata where ckey = 'bwa_identitymetrics_orgsjobs';
delete from tportalmetadata where ckey = 'bwa_identitymetrics_riskrank';
delete from tportalmetadata where ckey = 'bwa_identitymetrics_score';
delete from tportalmetadata where ckey = 'bwa_orgmetrics_aggscore';
delete from tportalmetadata where ckey = 'bwa_orgmetrics_depth';
delete from tportalmetadata where ckey = 'bwa_orgmetrics_nbappshare';
delete from tportalmetadata where ckey = 'bwa_orgmetrics_nbbusinessactivity';
delete from tportalmetadata where ckey = 'bwa_orgmetrics_nbmembers';
delete from tportalmetadata where ckey = 'bwa_orgmetrics_nbperimeter';
delete from tportalmetadata where ckey = 'bwa_orgmetrics_nbproblems';
delete from tportalmetadata where ckey = 'bwa_orgmetrics_nbsuborgs';
delete from tportalmetadata where ckey = 'bwa_orgmetrics_nbtheoretical';
delete from tportalmetadata where ckey = 'bwa_orgmetrics_nbusages';
delete from tportalmetadata where ckey = 'bwa_orgmetrics_riskrank';
delete from tportalmetadata where ckey = 'bwa_orgmetrics_score';
delete from tportalmetadata where ckey = 'bwa_permissionmetrics_nbsubpermission';
delete from tportalmetadata where ckey = 'bwa_permissionmetrics_nbtheoretical';
delete from tportalmetadata where ckey = 'bwa_permissionmetrics_nbusage';
delete from tportalmetadata where ckey = 'bwa_permmetrics_nb';
delete from tportalmetadata where ckey = 'bwa_repositorymetrics_nb';
delete from tportalmetadata where ckey = 'bwf_repositorymetrics_nbappshare';
delete from tportalmetadata where ckey = 'bwa_repositorymetrics_nbgroup';
delete from tportalmetadata where ckey = 'bwa_repositorymetrics_nbright';
delete from tportalmetadata where ckey = 'bwa_repositorymetrics_nbusage';
delete from tportalmetadata where ckey = 'bwa_sharemetrics_nbfolders';
delete from tportalmetadata where ckey = 'sharemetrics_nbfull';
delete from tportalmetadata where ckey = 'bwa_sharemetrics_nbrw';

delete from tmetadatavalue where not exists (select 1 from tmetadata m where m.crecorduid = cmetadatafk);
delete from tportalmetadatavalue where not exists (select 1 from tmetadata m where m.crecorduid = cmetadatafk);

select current_timestamp as END_TIME;


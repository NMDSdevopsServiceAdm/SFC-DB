-- this is a set of functions/stored procedures for migrating a single establishment
DROP FUNCTION IF EXISTS migration.establishment_other_services;
CREATE OR REPLACE FUNCTION migration.establishment_other_services(_tribalId INTEGER, _sfcid INTEGER)
  RETURNS void AS $$
DECLARE
  MyOtherServices REFCURSOR;
  CurrrentOtherService RECORD;
  TotalOtherServices INTEGER;
BEGIN
  RAISE NOTICE '... mapping other services';

  -- now add any "other services"
  OPEN MyOtherServices FOR SELECT ms.sfcid
    FROM establishment e
      INNER JOIN provision p
        INNER JOIN provision_servicetype pst INNER JOIN migration.services ms ON pst.servicetype_id = ms.tribalid
          ON pst.provision_id = p.id and pst.ismainservice = 0
        ON p.establishment_id = e.id
    WHERE e.id=_tribalId;

  -- first delete any existing "other services"
  DELETE FROM cqc."EstablishmentServices" WHERE "EstablishmentID" = _sfcid;

  LOOP
    BEGIN
      FETCH MyOtherServices INTO CurrrentOtherService;
      EXIT WHEN NOT FOUND;

      INSERT INTO cqc."EstablishmentServices" ("EstablishmentID", "ServiceID")
        VALUES (_sfcid, CurrrentOtherService.sfcid)
        ON CONFLICT DO NOTHING;

      --EXCEPTION WHEN OTHERS THEN RAISE WARNING 'Failed to process other services: % (%)', _tribalId, _sfcid;
    END;
  END LOOP;

  -- update the Establishment's OtherServices change property
  SELECT count(0) FROM cqc."EstablishmentServices" WHERE "EstablishmentID" = _sfcid INTO TotalOtherServices;
  IF (TotalOtherServices > 0) THEN
    UPDATE
      cqc."Establishment"
    SET
      "OtherServicesSavedAt" = now(),
      "OtherServicesSavedBy" = 'migration'
    WHERE
      "EstablishmentID" = _sfcid;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- intentionally not sharing anything recordset between "other services" and "capacities"
DROP FUNCTION IF EXISTS migration.establishment_capacities;
CREATE OR REPLACE FUNCTION migration.establishment_capacities(_tribalId INTEGER, _sfcid INTEGER)
  RETURNS void AS $$
DECLARE
  MyCapacities REFCURSOR;
  CurrrentCapacityService RECORD;
  TargetCapacities REFCURSOR;
  TargetTotalCapacityRecord RECORD;
  TargetUtilisationRecord RECORD;
  TotalCapacities INTEGER;
BEGIN
  RAISE NOTICE '... mapping capacities';

  -- first delete any existing "capacities"
  DELETE FROM cqc."EstablishmentCapacity" WHERE "EstablishmentID" = _sfcid;

  -- capacities in tribal are recorded in the same table as "main/other services"
  OPEN MyCapacities FOR SELECT ms.sfcid, pst.totalcapacity, pst.currentutilisation
    FROM establishment e
      INNER JOIN provision p
        INNER JOIN provision_servicetype pst INNER JOIN migration.services ms ON pst.servicetype_id = ms.tribalid
          ON pst.provision_id = p.id
        ON p.establishment_id = e.id
    WHERE e.id=_tribalId;

  LOOP
    BEGIN
      FETCH MyCapacities INTO CurrrentCapacityService;
      EXIT WHEN NOT FOUND;
	  
	    RAISE NOTICE 'CurrrentCapacityService: %', CurrrentCapacityService;
      OPEN TargetCapacities FOR SELECT
          "ServiceCapacityID" servicecapacityid,
          "ServiceID" AS serviceid,
          "Question" as question,
          "Sequence" as questionsequence
        FROM cqc."ServicesCapacity"
        WHERE "ServiceID" = CurrrentCapacityService.sfcid
        ORDER BY questionsequence ASC;

      -- we're expecting up to two target capacities for the given source (ref) service
      FETCH TargetCapacities INTO TargetTotalCapacityRecord;
      FETCH TargetCapacities INTO TargetUtilisationRecord;
	  
      --RAISE NOTICE 'TargetTotalCapacityRecord: %', TargetTotalCapacityRecord;
      --RAISE NOTICE 'TargetUtilisationRecord: %', TargetUtilisationRecord;
      
      IF (TargetTotalCapacityRecord.servicecapacityid IS NOT NULL AND TargetUtilisationRecord.servicecapacityid IS NOT NULL) THEN
        -- expecting two capacities
		    IF (CurrrentCapacityService.totalcapacity IS NOT NULL) THEN
        	INSERT INTO cqc."EstablishmentCapacity" ("EstablishmentID", "ServiceCapacityID","Answer")
          		VALUES (_sfcid, TargetTotalCapacityRecord.servicecapacityid, CurrrentCapacityService.totalcapacity)
              ON CONFLICT DO NOTHING;
		    END IF;
		
		    IF (CurrrentCapacityService.currentutilisation IS NOT NULL) THEN
	        INSERT INTO cqc."EstablishmentCapacity" ("EstablishmentID", "ServiceCapacityID","Answer")
    	      VALUES (_sfcid, TargetUtilisationRecord.servicecapacityid, CurrrentCapacityService.currentutilisation)
            ON CONFLICT DO NOTHING;
		    END IF;
      ELSIF (TargetTotalCapacityRecord.servicecapacityid IS NOT NULL AND TargetUtilisationRecord.servicecapacityid IS NULL) THEN
        -- expecting just one capacity
        -- special case mapping for Domicilliary Care Services (sfcid=20) - take the currentutilisation
		    IF (CurrrentCapacityService.totalcapacity IS NOT NULL AND CurrrentCapacityService.sfcid <> 20) THEN
	        INSERT INTO cqc."EstablishmentCapacity" ("EstablishmentID", "ServiceCapacityID","Answer")
    	      VALUES (_sfcid, TargetTotalCapacityRecord.servicecapacityid, CurrrentCapacityService.totalcapacity)
            ON CONFLICT DO NOTHING;
        elsIF (CurrrentCapacityService.totalcapacity IS NOT NULL AND (CurrrentCapacityService.sfcid = 20 OR CurrrentCapacityService.sfcid = 11)  THEN
	        INSERT INTO cqc."EstablishmentCapacity" ("EstablishmentID", "ServiceCapacityID","Answer")
    	      VALUES (_sfcid, TargetTotalCapacityRecord.servicecapacityid, CurrrentCapacityService.currentutilisation)
            ON CONFLICT DO NOTHING;
		    END IF;
      ELSE
        -- do nothing - skip over this source service as target has no capacities
      END IF;

      --EXCEPTION WHEN OTHERS THEN RAISE WARNING 'Failed to process capacities: % (%)', _tribalId, _sfcid;

      CLOSE TargetCapacities;
    END;
  END LOOP;

  -- update the Establishment's OtherServices change property
  SELECT count(0) FROM cqc."EstablishmentCapacity" WHERE "EstablishmentID" = _sfcid INTO TotalCapacities;
  IF (TotalCapacities > 0) THEN
    UPDATE
      cqc."Establishment"
    SET
      "CapacityServicesSavedAt" = now(),
      "CapacityServicesSavedBy" = 'migration'
    WHERE
      "EstablishmentID" = _sfcid;
  END IF;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS migration.establishment_service_users;
CREATE OR REPLACE FUNCTION migration.establishment_service_users(_tribalId INTEGER, _sfcid INTEGER)
  RETURNS void AS $$
DECLARE
  MyServiceUsers REFCURSOR;
  CurrrentServiceUser RECORD;
  TotalServiceUsers INTEGER;
BEGIN
  RAISE NOTICE '... mapping service users';

  -- now add any "other services"
  OPEN MyServiceUsers FOR SELECT ms.sfcid
    FROM establishment e
      INNER JOIN provision p
        inner join provision_usertype
          inner join usertype
            inner join migration.serviceusers ms on ms.tribalid = usertype.id
            on usertype.id = provision_usertype.usertype_id
          on provision_usertype.provision_id = p.id
        ON p.establishment_id = e.id
    WHERE e.id=_tribalId;

  -- first delete any existing "service users"
  DELETE FROM cqc."EstablishmentServiceUsers" WHERE "EstablishmentID" = _sfcid;

  LOOP
    BEGIN
      FETCH MyServiceUsers INTO CurrrentServiceUser;
      EXIT WHEN NOT FOUND;

      INSERT INTO cqc."EstablishmentServiceUsers" ("EstablishmentID", "ServiceUserID")
        VALUES (_sfcid, CurrrentServiceUser.sfcid)
        ON CONFLICT DO NOTHING;

      --EXCEPTION WHEN OTHERS THEN RAISE WARNING 'Failed to process service users: % (%)', _tribalId, _sfcid;
    END;
  END LOOP;

  -- update the Establishment's ServiceUsers change property
  SELECT count(0) FROM cqc."EstablishmentServiceUsers" WHERE "EstablishmentID" = _sfcid INTO TotalServiceUsers;
  IF (TotalServiceUsers > 0) THEN
    UPDATE
      cqc."Establishment"
    SET
      "ServiceUsersSavedAt" = now(),
      "ServiceUsersSavedBy" = 'migration'
    WHERE
      "EstablishmentID" = _sfcid;
  END IF;
END;
$$ LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS migration.establishment_local_authorities;
CREATE OR REPLACE FUNCTION migration.establishment_local_authorities(_tribalId INTEGER, _sfcid INTEGER, _visiblecsci INTEGER)
  RETURNS void AS $$
DECLARE
  MyLocalAuthorities REFCURSOR;
  CurrrentLocalAuthority RECORD;
  TotalLocalAuthorities INTEGER;
  TargetCssrID INTEGER;
  TargetCssrName VARCHAR(200);
  ShareWithCQC BOOLEAN;
BEGIN
  RAISE NOTICE '... mapping Local Authorities (CSSRs)';

  -- note - there are four source CSSRs that map different to the target CSSRs
  --        therefore it is necessary to do a left join from cssr to cqc."Cssr"
  OPEN MyLocalAuthorities FOR SELECT
      cssr.code::INTEGER AS sourcecssrid,
      cssr.name AS sourcecssr,
      DistinctTargetCssrs."CssrID" AS targetcssrid,
      DistinctTargetCssrs."CssR" AS targetcssr
    FROM establishment
      INNER JOIN establishment_cssr
        INNER JOIN cssr
          LEFT JOIN (SELECT DISTINCT "CssrID", "CssR" FROM cqc."Cssr") DistinctTargetCssrs ON cssr.code::INTEGER = DistinctTargetCssrs."CssrID"
          ON cssr.id = establishment_cssr.cssr_id
      ON establishment.id = establishment_cssr.establishment_id
    WHERE establishment.id=_tribalId;

  -- first delete any existing "local authorities"
  DELETE FROM cqc."EstablishmentLocalAuthority" WHERE "EstablishmentID" = _sfcid;

  LOOP
    BEGIN
      FETCH MyLocalAuthorities INTO CurrrentLocalAuthority;
      EXIT WHEN NOT FOUND;

      CASE CurrrentLocalAuthority.sourcecssrid
        WHEN 625 THEN
          TargetCssrID = 996;
          TargetCssrName = CurrrentLocalAuthority.sourcecssr;
        WHEN 626 THEN
          TargetCssrID = 997;
          TargetCssrName = CurrrentLocalAuthority.sourcecssr;
        WHEN 326 THEN
          TargetCssrID = 998;
          TargetCssrName = CurrrentLocalAuthority.sourcecssr;
        WHEN 327 THEN
          TargetCssrID = 999;
          TargetCssrName = CurrrentLocalAuthority.sourcecssr;
        ELSE
          TargetCssrID = CurrrentLocalAuthority.targetcssrid;
          TargetCssrName = CurrrentLocalAuthority.targetcssr;
      END CASE;

      INSERT INTO cqc."EstablishmentLocalAuthority" ("EstablishmentID", "CssrID", "CssR")
        VALUES (_sfcid, TargetCssrID, TargetCssrName)
        ON CONFLICT DO NOTHING;

      --EXCEPTION WHEN OTHERS THEN RAISE WARNING 'Failed to process Local Authority: % (%) - %', _tribalId, _sfcid, CurrrentLocalAuthority.sourcecssr;
    END;
  END LOOP;

  -- share with CQC is taken from the source "visiblecsci" (null, 0 or 1)
  ShareWithCQC = NULL;
  IF (_visiblecsci) THEN
    IF (_visiblecsci = 1) THEN
      ShareWithCQC = true;
    ELSE
      ShareWithCQC = false;
    END IF;
  END IF;

  -- update the Establishment's ShareWithLA change property
  SELECT count(0) FROM cqc."EstablishmentLocalAuthority" WHERE "EstablishmentID" = _sfcid INTO TotalLocalAuthorities;
  IF (TotalLocalAuthorities > 0 OR ShareWithCQC IS NOT NULL) THEN
    RAISE NOTICE '...... sharing with LA and sharing to true';
    UPDATE
      cqc."Establishment"
    SET
      "ShareWithLASavedAt" = now(),
      "ShareDataSavedAt" = now(),
      "ShareWithLASavedBy" = 'migration',
      "ShareDataSavedBy" = 'migration',
      "ShareDataValue" = true,
      "ShareDataWithLA" = CASE WHEN TotalLocalAuthorities > 0 THEN true ELSE false END,
      "ShareDataWithCQC" = CASE WHEN ShareWithCQC IS NOT NULL THEN ShareWithCQC ELSE false END
    WHERE
      "EstablishmentID" = _sfcid;
  ELSE
    RAISE NOTICE '...... sharing with LA and sharing to false';
    UPDATE
      cqc."Establishment"
    SET
      "ShareWithLASavedAt" = now(),
      "ShareWithLASavedBy" = 'migration',
      "ShareDataValue" = false,
      "ShareDataWithLA" = false
    WHERE
      "EstablishmentID" = _sfcid;
  END IF;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS migration.establishment_jobs;
CREATE OR REPLACE FUNCTION migration.establishment_jobs(_tribalId INTEGER, _sfcid INTEGER)
  RETURNS void AS $$
DECLARE
  MyJobs REFCURSOR;
  CurrrentJob RECORD;
  TotalVacancies INTEGER;
  TotalStarters INTEGER;
  TotalLeavers INTEGER;
  TotalStaff INTEGER;
BEGIN
  RAISE NOTICE '... mapping jobs (vacancies, starters and leavers)';

  OPEN MyJobs FOR SELECT
        provision.totalvacancies,
        provision.totalstarters,
        provision.totalleavers,
        "Job"."JobID" AS jobid,
		sum(pjr.permanentstaffcount) AS permanentstaffcount,
		sum(pjr.temporarystaffcount) AS temporarystaffcount,
        sum(pjr.poolstaffcount) AS poolstaffcount,
        sum(pjr.agencystaffcount) AS agencystaffcount,
        sum(pjr.studentstaffcount) AS studentstaffcount,
        sum(pjr.voluntarystaffcount) AS voluntarystaffcount,
        sum(pjr.otherstaffcount) AS otherstaffcount,
        sum(pjr.startedcount) AS startedcount,
        sum(pjr.stoppedcount) AS stoppedcount,
        sum(pjr.vacanciescount) AS vacanciescount,
        sum(pjr.startedcount) AS starters,
        sum(pjr.stoppedcount) AS leavers,
        sum(pjr.vacanciescount) AS vacancies
      FROM establishment
        INNER JOIN provision ON provision.establishment_id = establishment.id
          LEFT JOIN provision_jobrole pjr
            INNER JOIN migration.jobs ms
              INNER JOIN cqc."Job" ON ms.sfcid = "Job"."JobID"
              ON pjr.jobrole = ms.tribalid
            ON pjr.provision_id = provision.id
      WHERE establishment.id =_tribalId
      GROUP BY establishment.id, provision.totalvacancies, provision.totalstarters, provision.totalleavers, "Job"."JobID";

  -- first delete any existing "jobs"
  DELETE FROM cqc."EstablishmentJobs" WHERE "EstablishmentID" = _sfcid;

  -- reset the establishment's sum of total staff
  TotalStaff = 0;

  LOOP
    BEGIN
      FETCH MyJobs INTO CurrrentJob;
      EXIT WHEN NOT FOUND;

      -- the totals will be the same for every job type record
      TotalVacancies = 0;
      TotalStarters = 0;
      TotalLeavers = 0;
	
      TotalStaff = TotalStaff +
        CurrrentJob.permanentstaffcount +
        CurrrentJob.temporarystaffcount +
        CurrrentJob.poolstaffcount +
        CurrrentJob.agencystaffcount +
        CurrrentJob.studentstaffcount +
        CurrrentJob.voluntarystaffcount +
        CurrrentJob.otherstaffcount;

      -- note - CurrrentJob.vacanciescount, CurrrentJob.startedcount and CurrrentJob.stoppedcount are never null
      --        and the same CurrentJob could have none, one, two or all three of vacancies, started and stopped counts
      IF (CurrrentJob.vacancies > 0) THEN
        INSERT INTO cqc."EstablishmentJobs" ("EstablishmentID", "JobID", "JobType", "Total")
          VALUES (_sfcid, CurrrentJob.jobid, 'Vacancies', CurrrentJob.vacancies)
          ON CONFLICT DO NOTHING;

        TotalVacancies = TotalVacancies + CurrrentJob.vacancies;
      END IF;

      IF (CurrrentJob.starters > 0) THEN
        INSERT INTO cqc."EstablishmentJobs" ("EstablishmentID", "JobID", "JobType", "Total")
          VALUES (_sfcid, CurrrentJob.jobid, 'Starters', CurrrentJob.starters)
          ON CONFLICT DO NOTHING;

        TotalStarters = TotalStarters + CurrrentJob.starters;
      END IF;
         
      IF (CurrrentJob.leavers > 0) THEN
        INSERT INTO cqc."EstablishmentJobs" ("EstablishmentID", "JobID", "JobType", "Total")
          VALUES (_sfcid, CurrrentJob.jobid, 'Leavers', CurrrentJob.leavers)
          ON CONFLICT DO NOTHING;

        TotalLeavers = TotalLeavers + CurrrentJob.leavers;
      END IF;

      --EXCEPTION WHEN OTHERS THEN RAISE WARNING 'Failed to process Job with target role: % (%) - %', _tribalId, _sfcid, CurrrentJob.jobid;
    END;
  END LOOP;

  -- update the Establishment's Vacancies, Starters and Leavers change properties
  -- if there are no records, then all Vacancies, Starters and Leavers are "Don't know"

  IF (TotalStaff = 0) THEN
    RAISE NOTICE '...... don''t know vacancies, starters and leavers';
    UPDATE
      cqc."Establishment"
    SET
      "VacanciesSavedAt" = now(),
      "VacanciesSavedBy" = 'migration',
      "VacanciesValue" = 'Don''t know',
      "StartersSavedAt" = now(),
      "StartersSavedBy" = 'migration',
      "StartersValue" = 'Don''t know',
      "LeaversSavedAt" = now(),
      "LeaversSavedBy" = 'migration',
      "LeaversValue" = 'Don''t know'
    WHERE
      "EstablishmentID" = _sfcid;
  ELSE
    IF (TotalVacancies = 0) THEN
      RAISE NOTICE '...... have no vacancies';
      UPDATE
        cqc."Establishment"
      SET
        "VacanciesSavedAt" = now(),
        "VacanciesSavedBy" = 'migration',
        "VacanciesValue" = 'None'
      WHERE
        "EstablishmentID" = _sfcid;
    ELSE
      RAISE NOTICE '...... have vacancies';
      UPDATE
        cqc."Establishment"
      SET
        "VacanciesSavedAt" = now(),
        "VacanciesSavedBy" = 'migration',
        "VacanciesValue" = 'With Jobs'
      WHERE
        "EstablishmentID" = _sfcid;
    END IF;

    IF (TotalStarters = 0) THEN
      RAISE NOTICE '...... have no starters';
      UPDATE
        cqc."Establishment"
      SET
        "StartersSavedAt" = now(),
        "StartersSavedBy" = 'migration',
        "StartersValue" = 'None'
      WHERE
        "EstablishmentID" = _sfcid;
    ELSE
      RAISE NOTICE '...... have starters';
      UPDATE
        cqc."Establishment"
      SET
        "StartersSavedAt" = now(),
        "StartersSavedBy" = 'migration',
        "StartersValue" = 'With Jobs'
      WHERE
        "EstablishmentID" = _sfcid;
    END IF;

    IF (TotalLeavers = 0) THEN
      RAISE NOTICE '...... have no leavers';
      UPDATE
        cqc."Establishment"
      SET
        "LeaversSavedAt" = now(),
        "LeaversSavedBy" = 'migration',
        "LeaversValue" = 'None'
      WHERE
        "EstablishmentID" = _sfcid;
    ELSE
      RAISE NOTICE '...... have leavers';
      UPDATE
        cqc."Establishment"
      SET
        "LeaversSavedAt" = now(),
        "LeaversSavedBy" = 'migration',
        "LeaversValue" = 'With Jobs'
      WHERE
        "EstablishmentID" = _sfcid;
    END IF;
  END IF;

  -- update the establishments total number of staff
  UPDATE
    cqc."Establishment"
  SET
    "NumberOfStaffSavedAt" = now(),
    "NumberOfStaffSavedBy" = 'migration',
    "NumberOfStaffValue" = TotalStaff
  WHERE
    "EstablishmentID" = _sfcid;

END;
$$ LANGUAGE plpgsql;
StartersValue-- FUNCTION: migration.establishment_local_authorities(integer, integer, integer)

-- DROP FUNCTION migration.establishment_local_authorities(integer, integer, integer);

CREATE OR REPLACE FUNCTION migration.establishment_local_authorities(
	_tribalid integer,
	_sfcid integer,
	_visiblecsci integer,
	_isregulated boolean)
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
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
  
  IF(_isregulated = false) THEN
      ShareWithCQC = false;
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
$BODY$;

ALTER FUNCTION migration.establishment_local_authorities(integer, integer, integer,boolean)
    OWNER TO postgres;

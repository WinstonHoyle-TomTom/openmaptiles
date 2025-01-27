-- Checks to ensure that test data was imported correctly
DO $$

DECLARE
  cnt integer;

BEGIN

  -- Clear prior results
  DELETE FROM omt_test_failures WHERE test_type='update';

  -- Test 100: Verify re-tag of national_park to protected_area worked
  SELECT COUNT(*) INTO cnt FROM osm_park_polygon_gen_z5 WHERE boundary='national_park';
  IF cnt <> 0 THEN
    INSERT INTO omt_test_failures VALUES(100, 'update', 'osm_park_polygon_gen_z5 national_park expected 0, got ' || cnt);
  END IF;

  SELECT COUNT(*) INTO cnt FROM osm_park_polygon_gen_z5 WHERE boundary='protected_area';
  IF cnt <> 2 THEN
    INSERT INTO omt_test_failures VALUES(100, 'update', 'osm_park_polygon_gen_z5 protected_area expected 2, got ' || cnt);
  END IF;

  -- Test 200: Verify aerodrome deleted and modified
  SELECT COUNT(*) INTO cnt FROM osm_aerodrome_label_point;
  IF cnt <> 2 THEN
    INSERT INTO omt_test_failures VALUES(200, 'update', 'osm_aerodrome_label_point expected 2, got ' || cnt);
  END IF;

  SELECT COUNT(*) INTO cnt FROM osm_aerodrome_label_point WHERE icao='KOMT' AND ele='124' AND name='OpenMapTiles International Airport';
  IF cnt <> 1 THEN
    INSERT INTO omt_test_failures VALUES(200, 'update', 'osm_aerodrome_label_point failed to update attributes');
  END IF;

 -- Test 300: Verify landuse modified
  SELECT COUNT(*) INTO cnt FROM osm_landcover_polygon WHERE mapping_key='natural' AND subclass='scrub';
  IF cnt <> 1 THEN
    INSERT INTO omt_test_failures VALUES(300, 'import', 'osm_landcover_polygon natural=scrub expected 1, got ' || cnt);
  END IF;

  SELECT COUNT(*) INTO cnt FROM osm_landcover_polygon WHERE mapping_key='natural' AND subclass='wood';
  IF cnt <> 0 THEN
    INSERT INTO omt_test_failures VALUES(300, 'import', 'osm_landcover_polygon natural=wood expected 0, got ' || cnt);
  END IF;

  -- Test 400: Verify new city added
  SELECT COUNT(DISTINCT relation_id) INTO cnt FROM osm_border_linestring WHERE admin_level=8;
  IF cnt <> 2 THEN
    INSERT INTO omt_test_failures VALUES(400, 'update', 'osm_border_linestring city count expected 2, got ' || cnt);
  END IF;

END;

$$;


DO $$

DECLARE
  cnt integer;
BEGIN
  SELECT COUNT(*) INTO cnt FROM omt_test_failures;
  IF cnt > 0 THEN
    RAISE '% unit test(s) failed on updates.  Details can be found in table omt_test_failures.', cnt USING ERRCODE = '0Z000';
  END IF;
END;

$$;

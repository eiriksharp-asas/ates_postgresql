CREATE OR REPLACE FUNCTION create_views(sch text)
RETURNS void AS $$
BEGIN

    EXECUTE 'CREATE MATERIALIZED VIEW IF NOT EXISTS ' || sch || '."MV_decision_point_warnings"
        TABLESPACE pg_default
        AS
        SELECT dp.id,
            dp.guid,
            dp.geom,
            dp.assessment_area_guid,
            dp.feature_name,
            concerns.warnings_text AS concerns,
            mitigations.warnings_text AS mitigations
        FROM ' || sch || '.decision_points dp
            JOIN (
                SELECT dpw.decision_points_guid AS dp_guid,
                    w.warning_type,
                    array_agg(w.warning_text) AS warnings_text
                FROM ' || sch || '.decision_points_warnings dpw
                    JOIN ' || sch || '.lu_warnings w ON dpw.warnings_guid = w.guid
                WHERE w.warning_type::text = ''Concern''::text
                GROUP BY dpw.decision_points_guid, w.warning_type
            ) concerns ON concerns.dp_guid = dp.guid
            JOIN (
                SELECT dpw.decision_points_guid AS dp_guid,
                    w.warning_type,
                    array_agg(w.warning_text) AS warnings_text
                FROM ' || sch || '.decision_points_warnings dpw
                    JOIN ' || sch || '.lu_warnings w ON dpw.warnings_guid = w.guid
                WHERE w.warning_type::text = ''Managing risk''::text
                GROUP BY dpw.decision_points_guid, w.warning_type
            ) mitigations ON mitigations.dp_guid = dp.guid
        ORDER BY dp.guid
        WITH DATA;
		
		CREATE UNIQUE INDEX IF NOT EXISTS mv_ates_decision_point_warnings_id
            ON ' || sch || '."MV_decision_point_warnings" USING btree
            (id, concerns COLLATE pg_catalog."default", mitigations COLLATE pg_catalog."default")
            TABLESPACE pg_default;';
		
    EXECUTE 'CREATE MATERIALIZED VIEW IF NOT EXISTS ' || sch || '."MV_ates20_routes"
        TABLESPACE pg_default
        AS
        SELECT feature.id,
            feature.geom,
            feature.guid,
            assessment_area.text assessment_area,
            feature.class_code AS ates_class,
            slope_angle.text as slope_angle,
            slope_shape.text as slope_shape,
            terrain_traps.text as terrain_traps,
            freq_mag.text as freq_mag,
            startzone_density.text as startzone_density,
            path_exposure.text as path_exposure,
            route_options.text as route_options,
            exposure_time.text as exposure_time
        FROM ' || sch || '.ates20_ln feature
            LEFT JOIN (
                SELECT assessment_areas.guid,
                    assessment_areas.feature_name as text	
                FROM ' || sch || '.assessment_areas assessment_areas
            ) assessment_area on assessment_area.guid = feature.assessment_area_guid
            INNER JOIN (
                SELECT ratings.class_code,
                    ratings.slope_angle as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) slope_angle on slope_angle.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.slope_shape as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) slope_shape on slope_shape.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.terrain_traps as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) terrain_traps on terrain_traps.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.freq_mag as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) freq_mag on freq_mag.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.startzone_density as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) startzone_density on startzone_density.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.path_exposure as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) path_exposure on path_exposure.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.route_options as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) route_options on route_options.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.exposure_time as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) exposure_time on exposure_time.class_code = feature.slope_angle
        WHERE feature.feature_type = ''Route''::bpchar
        ORDER BY assessment_area.text
        WITH DATA;        
        CREATE UNIQUE INDEX IF NOT EXISTS mv_ates20_routes_id
            ON ' || sch || '."MV_ates20_routes" USING btree
            (id, ates_class)
            TABLESPACE pg_default;';

    EXECUTE 'CREATE MATERIALIZED VIEW IF NOT EXISTS ' || sch || '."MV_ates20_corridor_buffered"
        TABLESPACE pg_default
        AS
        SELECT feature.id,
            st_transform(st_buffer(st_transform(feature.geom, 3857), feature.precision_m::double precision), 4326) AS geom,
            feature.guid,
            assessment_area.text assessment_area,
            feature.class_code AS ates_class,
            slope_angle.text as slope_angle,
            slope_shape.text as slope_shape,
            terrain_traps.text as terrain_traps,
            freq_mag.text as freq_mag,
            startzone_density.text as startzone_density,
            path_exposure.text as path_exposure,
            route_options.text as route_options,
            exposure_time.text as exposure_time
        FROM ' || sch || '.ates20_ln feature
            LEFT JOIN (
                SELECT assessment_areas.guid,
                    assessment_areas.feature_name as text	
                FROM ' || sch || '.assessment_areas assessment_areas
            ) assessment_area on assessment_area.guid = feature.assessment_area_guid
            INNER JOIN (
                SELECT ratings.class_code,
                    ratings.slope_angle as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) slope_angle on slope_angle.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.slope_shape as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) slope_shape on slope_shape.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.terrain_traps as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) terrain_traps on terrain_traps.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.freq_mag as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) freq_mag on freq_mag.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.startzone_density as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) startzone_density on startzone_density.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.path_exposure as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) path_exposure on path_exposure.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.route_options as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) route_options on route_options.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.exposure_time as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) exposure_time on exposure_time.class_code = feature.slope_angle
        WHERE feature.feature_type = ''Corridor''::bpchar
        ORDER BY assessment_area.text
        WITH DATA;

        CREATE UNIQUE INDEX IF NOT EXISTS mv_ates20_corridor_buffered_id
            ON ' || sch || '."MV_ates20_corridor_buffered" USING btree
            (id, ates_class)
            TABLESPACE pg_default;';
			
    EXECUTE 'CREATE MATERIALIZED VIEW IF NOT EXISTS ' || sch || '."MV_ates20_zones_buffered"
        TABLESPACE pg_default
        AS
        SELECT feature.id,
            st_transform(st_buffer(st_transform(feature.geom, 3857), feature.precision_m::double precision), 4326) AS geom,
            feature.guid,
            assessment_area.text assessment_area,
            feature.class_code AS ates_class,
            slope_angle.text as slope_angle,
            slope_shape.text as slope_shape,
            terrain_traps.text as terrain_traps,
            freq_mag.text as freq_mag,
            startzone_density.text as startzone_density,
            path_exposure.text as path_exposure,
            route_options.text as route_options,
            exposure_time.text as exposure_time
        FROM ' || sch || '.ates20_poly feature
            LEFT JOIN (
                SELECT assessment_areas.guid,
                    assessment_areas.feature_name as text	
                FROM ' || sch || '.assessment_areas assessment_areas
            ) assessment_area on assessment_area.guid = feature.assessment_area_guid
            INNER JOIN (
                SELECT ratings.class_code,
                    ratings.slope_angle as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) slope_angle on slope_angle.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.slope_shape as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) slope_shape on slope_shape.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.terrain_traps as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) terrain_traps on terrain_traps.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.freq_mag as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) freq_mag on freq_mag.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.startzone_density as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) startzone_density on startzone_density.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.path_exposure as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) path_exposure on path_exposure.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.route_options as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) route_options on route_options.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.exposure_time as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) exposure_time on exposure_time.class_code = feature.slope_angle
        WHERE feature.feature_type = ''Zone''::bpchar
        ORDER BY assessment_area.text
        WITH DATA;
        
        CREATE UNIQUE INDEX IF NOT EXISTS mv_ates20_zones_buffered_id
            ON ' || sch || '."MV_ates20_zones_buffered" USING btree
            (id, ates_class)
            TABLESPACE pg_default;';

    EXECUTE 'CREATE MATERIALIZED VIEW IF NOT EXISTS ' || sch || '."MV_ates20_areas_buffered"
        TABLESPACE pg_default
        AS
        SELECT feature.id,
            st_transform(st_buffer(st_transform(feature.geom, 3857), feature.precision_m::double precision), 4326) AS geom,
            feature.guid,
            assessment_area.text assessment_area,
            feature.class_code AS ates_class,
            slope_angle.text as slope_angle,
            slope_shape.text as slope_shape,
            terrain_traps.text as terrain_traps,
            freq_mag.text as freq_mag,
            startzone_density.text as startzone_density,
            path_exposure.text as path_exposure,
            route_options.text as route_options,
            exposure_time.text as exposure_time
        FROM ' || sch || '.ates20_poly feature
            LEFT JOIN (
                SELECT assessment_areas.guid,
                    assessment_areas.feature_name as text	
                FROM ' || sch || '.assessment_areas assessment_areas
            ) assessment_area on assessment_area.guid = feature.assessment_area_guid
            INNER JOIN (
                SELECT ratings.class_code,
                    ratings.slope_angle as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) slope_angle on slope_angle.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.slope_shape as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) slope_shape on slope_shape.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.terrain_traps as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) terrain_traps on terrain_traps.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.freq_mag as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) freq_mag on freq_mag.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.startzone_density as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) startzone_density on startzone_density.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.path_exposure as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) path_exposure on path_exposure.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.route_options as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) route_options on route_options.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.exposure_time as text 	
                FROM ' || sch || '.lu_ates20_ratings ratings
            ) exposure_time on exposure_time.class_code = feature.slope_angle
        WHERE feature.feature_type = ''Area''::bpchar
        ORDER BY assessment_area.text
        WITH DATA;
        
        CREATE UNIQUE INDEX IF NOT EXISTS mv_ates20_areas_buffered_id
            ON ' || sch || '."MV_ates20_areas_buffered" USING btree
            (id, ates_class)
            TABLESPACE pg_default;';

END;
$$ LANGUAGE plpgsql;

SELECT create_views('ates_dev');
CREATE OR REPLACE FUNCTION create_views(sch text)
RETURNS void AS $$
BEGIN

    EXECUTE 'CREATE MATERIALIZED VIEW IF NOT EXISTS ' || sch || '."MV_decision_point_warnings"
        TABLESPACE pg_default
        AS
        SELECT dp.id,
            dp.guid,
            dp.geom,
            dp.area_guid,
            dp.feature_name,
            dp.feature_description,
            dp.created_by,
            dp.created_on,
            dp.feature_comments,
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
        SELECT ates20_ln.id,
            ates20_ln.geom,
            ates20_ln.class_code AS ates_class
        FROM ' || sch || '.ates20_ln
        WHERE ates20_ln.feature_type = ''Route''::bpchar
        ORDER BY ates20_ln.id
        WITH DATA;
        
        CREATE UNIQUE INDEX IF NOT EXISTS mv_ates20_routes_id
            ON ' || sch || '."MV_ates20_routes" USING btree
            (id, ates_class)
            TABLESPACE pg_default;';

    EXECUTE 'CREATE MATERIALIZED VIEW IF NOT EXISTS ' || sch || '."MV_ates20_corridor_buffered"
        TABLESPACE pg_default
        AS
        SELECT ates20_ln.id,
            st_transform(st_buffer(st_transform(ates20_ln.geom, 3857), ates20_ln.precision_m::double precision), 4326) AS geom,
            ates20_ln.class_code AS ates_class
        FROM ' || sch || '.ates20_ln
        WHERE ates20_ln.feature_type = ''Coridor''::bpchar
        ORDER BY ates20_ln.id
        WITH DATA;

        CREATE UNIQUE INDEX IF NOT EXISTS mv_ates20_corridor_buffered_id
            ON ' || sch || '."MV_ates20_corridor_buffered" USING btree
            (id, ates_class)
            TABLESPACE pg_default;';
			
    EXECUTE 'CREATE MATERIALIZED VIEW IF NOT EXISTS ' || sch || '."MV_ates20_zones_buffered"
        TABLESPACE pg_default
        AS
        SELECT ates20_poly.id,
            st_transform(st_buffer(st_transform(ates20_poly.geom, 3857), ates20_poly.precision_m::double precision), 4326) AS geom,
            ates20_poly.class_code AS ates_class
        FROM ' || sch || '.ates20_poly
        WHERE ates20_poly.feature_type = ''Zone''::bpchar
        ORDER BY ates20_poly.id
        WITH DATA;
        
        CREATE UNIQUE INDEX IF NOT EXISTS mv_ates20_zones_buffered_id
            ON ates_dev."MV_ates20_zones_buffered" USING btree
            (id, ates_class)
            TABLESPACE pg_default;';

    EXECUTE 'CREATE MATERIALIZED VIEW IF NOT EXISTS ' || sch || '."MV_ates20_areas_buffered"
        TABLESPACE pg_default
        AS
        SELECT ates20_poly.id,
            st_transform(st_buffer(st_transform(ates20_poly.geom, 3857), ates20_poly.precision_m::double precision), 4326) AS geom,
            ates20_poly.class_code AS ates_class
        FROM ' || sch || '.ates20_poly
        WHERE ates20_poly.feature_type = ''Area''::bpchar
        ORDER BY ates20_poly.id
        WITH DATA;
        
        CREATE UNIQUE INDEX IF NOT EXISTS mv_ates20_areas_buffered_id
            ON ates_dev."MV_ates20_areas_buffered" USING btree
            (id, ates_class)
            TABLESPACE pg_default;';

END;
$$ LANGUAGE plpgsql;

SELECT create_views('ates_dev');
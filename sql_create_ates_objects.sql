-- Function to create ATES tables
CREATE OR REPLACE FUNCTION create_ates_tables(schema_name text)
    RETURNS void AS $$
    BEGIN

    -- Create table lu_ates10_ln_ratings
    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || schema_name || '.lu_ates10_ln_ratings
    (
        id SERIAL PRIMARY KEY,
        class_code integer NOT NULL UNIQUE,
        slope_angle character varying(256) COLLATE pg_catalog."default" UNIQUE,
        slope_shape character varying(256) COLLATE pg_catalog."default" UNIQUE,
        forest_density character varying(256) COLLATE pg_catalog."default" UNIQUE,
        terrain_traps character varying(256) COLLATE pg_catalog."default" UNIQUE,
        avalanche_frequency character varying(256) COLLATE pg_catalog."default" UNIQUE,
        startzone_density character varying(256) COLLATE pg_catalog."default" UNIQUE,
        runout_character character varying(256) COLLATE pg_catalog."default" UNIQUE,
        path_exposure character varying(256) COLLATE pg_catalog."default" UNIQUE,
        route_options character varying(256) COLLATE pg_catalog."default" UNIQUE,
        exposure_time character varying(256) COLLATE pg_catalog."default" UNIQUE,
        glaciation character varying(256) COLLATE pg_catalog."default" UNIQUE
    )';

    -- Create table lu_ates10_poly_ratings
    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || schema_name || '."lu_ates10_poly_ratings"
    (
        id SERIAL PRIMARY KEY,
        class_code integer NOT NULL UNIQUE,
        slope_character character varying(256) COLLATE pg_catalog."default" NOT NULL,
        startzone_density character varying(256) COLLATE pg_catalog."default" NOT NULL,
        path_exposure character varying(256) COLLATE pg_catalog."default" NOT NULL,
        terrain_traps character varying(256) COLLATE pg_catalog."default" NOT NULL,
        slope_shape character varying(256) COLLATE pg_catalog."default" NOT NULL
    )';

    -- Create table lu_ates20_ratings
    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || schema_name || '.lu_ates20_ratings
    (
        id SERIAL PRIMARY KEY,
        class_code integer NOT NULL UNIQUE,
        slope_angle character(250) COLLATE pg_catalog."default" UNIQUE,
        slope_shape character(250) COLLATE pg_catalog."default" UNIQUE,
        terrain_traps character(250) COLLATE pg_catalog."default" UNIQUE,
        freq_mag character(250) COLLATE pg_catalog."default" UNIQUE,
        startzone_density character(250) COLLATE pg_catalog."default" UNIQUE,
        path_exposure character(250) COLLATE pg_catalog."default" UNIQUE,
        route_options character(250) COLLATE pg_catalog."default" UNIQUE,
        exposure_time character(250) COLLATE pg_catalog."default" UNIQUE
    )';

    -- Create table assessment_areas
    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || schema_name || '.assessment_areas
    (
        id SERIAL PRIMARY KEY,
        guid UUID DEFAULT uuid_generate_v4() NOT NULL UNIQUE,
        geom geometry(MultiPolygon,4326),
        feature_name character varying(250) COLLATE pg_catalog."default" NOT NULL,
        feature_description character(250) COLLATE pg_catalog."default",
        feature_comments character varying(250) COLLATE pg_catalog."default",
        data_owner character(50) COLLATE pg_catalog."default"
    )';

    -- Create table access_roads
    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || schema_name || '.access_roads
    (
        id SERIAL PRIMARY KEY,
        geom geometry(LineString,4326),
        assessment_area_guid UUID,
        feature_name character varying(250) COLLATE pg_catalog."default",
        feature_description character varying(500) COLLATE pg_catalog."default",
        data_source character varying(250) COLLATE pg_catalog."default",
        created_by character varying(50) COLLATE pg_catalog."default",
        created_on timestamp without time zone,
        feature_comments character varying(250) COLLATE pg_catalog."default",
        CONSTRAINT fk_assessment_area_guid FOREIGN KEY (assessment_area_guid)
            REFERENCES ' || schema_name || '.assessment_areas (guid) MATCH SIMPLE
            ON UPDATE NO ACTION
            ON DELETE NO ACTION
    )';

    -- Create table avalanche_paths
    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || schema_name || '.avalanche_paths
    (
        id SERIAL PRIMARY KEY,
        geom geometry(LineString, 4326),
        assessment_area_guid UUID,
        feature_name character varying(250) COLLATE pg_catalog."default",
        feature_description character varying(500) COLLATE pg_catalog."default",
        data_source character varying(250) COLLATE pg_catalog."default",
        created_by character varying(50) COLLATE pg_catalog."default",
        created_on timestamp without time zone,
        xb10 double precision DEFAULT 0,
        p double precision DEFAULT 0.85,
        u_1 double precision DEFAULT 0.185,
        b_1 double precision DEFAULT 0.108,
        u_2 double precision DEFAULT 0.107,
        b_2 double precision DEFAULT 0.088,
        dx_1 double precision GENERATED ALWAYS AS ((xb10 * (u_1 - (b_1 * ln((- ln(p))))))) STORED,
        dx_2 double precision GENERATED ALWAYS AS ((xb10 * (u_2 - (b_2 * ln((- ln(p))))))) STORED,
        dx_average double precision GENERATED ALWAYS AS ((((xb10 * (u_1 - (b_1 * ln((- ln(p)))))) + (xb10 * (u_2 - (b_2 * ln((- ln(p))))))) / (2)::double precision)) STORED,
        feature_comments character(250) COLLATE pg_catalog."default",
        CONSTRAINT fk_assessment_area_guid FOREIGN KEY (assessment_area_guid)
            REFERENCES ' || schema_name || '.assessment_areas (guid) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION
    )';

    -- Create table decision_points
    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || schema_name || '.decision_points
    (
        id SERIAL PRIMARY KEY,
        guid UUID DEFAULT uuid_generate_v4() NOT NULL UNIQUE,
        geom geometry(Point, 4326),
        assessment_area_guid UUID,
        feature_name character varying(250) COLLATE pg_catalog."default",
        feature_description character varying(500) COLLATE pg_catalog."default",
        created_by character varying(50) COLLATE pg_catalog."default",
        created_on timestamp without time zone,
        feature_comments character varying(250) COLLATE pg_catalog."default",
        CONSTRAINT fk_assessment_area_guid FOREIGN KEY (assessment_area_guid)
            REFERENCES ' || schema_name || '.assessment_areas (guid) MATCH SIMPLE
            ON UPDATE NO ACTION
            ON DELETE NO ACTION
    )';

    -- Create table lu_warnings
    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || schema_name || '.lu_warnings
    (
        id SERIAL PRIMARY KEY,
        guid UUID DEFAULT uuid_generate_v4() NOT NULL UNIQUE,
        warning_type character varying(250) COLLATE pg_catalog."default" NOT NULL,
        warning_text character varying(250) COLLATE pg_catalog."default" NOT NULL UNIQUE
    )';

    -- Create table decision_points_warnings
    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || schema_name || '.decision_points_warnings
    (
        id SERIAL PRIMARY KEY,
        guid UUID DEFAULT uuid_generate_v4() NOT NULL UNIQUE,
        decision_points_guid UUID,
        warnings_guid UUID,
        CONSTRAINT fk_decisions_points_guid FOREIGN KEY (decision_points_guid)
            REFERENCES ' || schema_name || '.decision_points (guid) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_warnings_guid FOREIGN KEY (warnings_guid)
            REFERENCES ' || schema_name || '.lu_warnings (guid) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION
    )';

    -- Create table lu_points_of_interest
    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || schema_name || '.lu_points_of_interest
    (
        id serial PRIMARY KEY,
        poi_guid UUID,
        poi_type character varying(250) COLLATE pg_catalog."default" NOT NULL UNIQUE
    )';
    

    -- Create table points_of_interest
    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || schema_name || '.points_of_interest
        (
            id serial PRIMARY KEY,
            guid UUID DEFAULT uuid_generate_v4() NOT NULL UNIQUE,
            geom geometry(Point,4326),
            assessment_area_guid UUID,
            feature_name character varying(250) COLLATE pg_catalog."default",
            feature_description character varying(500) COLLATE pg_catalog."default",
            data_source character varying(250) COLLATE pg_catalog."default",
            created_by character varying(50) COLLATE pg_catalog."default",
            created_on timestamp without time zone,
            poi_type character(50) COLLATE pg_catalog."default",
            feature_comments character(250) COLLATE pg_catalog."default",
            CONSTRAINT fk_area_id FOREIGN KEY (assessment_area_guid)
                REFERENCES ' || schema_name || '.assessment_areas (guid) MATCH SIMPLE
                ON UPDATE CASCADE
                ON DELETE NO ACTION,
            CONSTRAINT fk_points_of_interst_guid FOREIGN KEY (poi_type)
                REFERENCES ' || schema_name || '.lu_points_of_interest (poi_type) MATCH SIMPLE
                ON UPDATE CASCADE
                ON DELETE NO ACTION
        )';


    -- Create table ates10_ln
    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || schema_name || '.ates10_ln
    (
        id serial PRIMARY KEY,
        geom geometry(LineString,4326),
        assessment_area_guid UUID,
        feature_name character varying(250) COLLATE pg_catalog."default",
        feature_description character varying(500) COLLATE pg_catalog."default",
        data_source character varying(250) COLLATE pg_catalog."default",
        created_by character varying(50) COLLATE pg_catalog."default",
        created_on timestamp without time zone,
        class_code integer,
        slope_angle integer,
        slope_shape integer,
        forest_density integer,
        terrain_traps integer,
        avalanche_frequency integer,
        startzone_density integer,
        runout_character integer,
        path_exposure integer,
        route_options integer,
        exposure_time integer,
        glaciation integer,
        CONSTRAINT fk_assessment_area_guid FOREIGN KEY (assessment_area_guid)
            REFERENCES ' || schema_name || '.assessment_areas (guid) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT ates_rating_class FOREIGN KEY (class_code)
            REFERENCES ' || schema_name || '.lu_ates10_ln_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT avalanche_frequency_class FOREIGN KEY (avalanche_frequency)
            REFERENCES ' || schema_name || '.lu_ates10_ln_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT exposure_time_class FOREIGN KEY (exposure_time)
            REFERENCES ' || schema_name || '.lu_ates10_ln_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT forest_density_class FOREIGN KEY (forest_density)
            REFERENCES ' || schema_name || '.lu_ates10_ln_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT glaciation_class FOREIGN KEY (glaciation)
            REFERENCES ' || schema_name || '.lu_ates10_ln_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT path_exposure_class FOREIGN KEY (path_exposure)
            REFERENCES ' || schema_name || '.lu_ates10_ln_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT route_options_class FOREIGN KEY (route_options)
            REFERENCES ' || schema_name || '.lu_ates10_ln_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT runnout_character_class FOREIGN KEY (runout_character)
            REFERENCES ' || schema_name || '.lu_ates10_ln_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT slope_angle_class FOREIGN KEY (slope_angle)
            REFERENCES ' || schema_name || '.lu_ates10_ln_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT slope_shape_class FOREIGN KEY (slope_shape)
            REFERENCES ' || schema_name || '.lu_ates10_ln_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT terrain_traps_class FOREIGN KEY (terrain_traps)
            REFERENCES ' || schema_name || '.lu_ates10_ln_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION
    )';

    -- Create table ates10_poly
    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || schema_name || '.ates10_poly
    (
        id serial PRIMARY KEY,
        geom geometry(Polygon,4326),
        assessment_area_guid UUID,
        feature_name character varying(250) COLLATE pg_catalog."default",
        feature_description character varying(500) COLLATE pg_catalog."default",
        data_source character varying(250) COLLATE pg_catalog."default",
        created_by character varying(50) COLLATE pg_catalog."default",
        created_on timestamp without time zone,
        class_code integer,
        slope_character integer,
        startzone_density integer,
        path_exposure integer,
        terrain_traps integer,
        slope_shape integer,
        CONSTRAINT fk_assessment_area_guid FOREIGN KEY (assessment_area_guid)
            REFERENCES ' || schema_name || '.assessment_areas (guid) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT ates_rating_class FOREIGN KEY (class_code)
            REFERENCES ' || schema_name || '.lu_ates10_poly_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT slope_character_class FOREIGN KEY (slope_character)
            REFERENCES ' || schema_name || '.lu_ates10_poly_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT startzone_density_class FOREIGN KEY (startzone_density)
            REFERENCES ' || schema_name || '.lu_ates10_poly_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT path_exposure_class FOREIGN KEY (path_exposure)
            REFERENCES ' || schema_name || '.lu_ates10_poly_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT terrain_traps_class FOREIGN KEY (terrain_traps)
            REFERENCES ' || schema_name || '.lu_ates10_poly_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT slope_shape_class FOREIGN KEY (slope_shape)
            REFERENCES ' || schema_name || '.lu_ates10_poly_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION
    )';



    -- Create table ates20_pt
    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || schema_name || '.ates20_pt
    (
        id SERIAL PRIMARY KEY,
        geom geometry(Point, 4326) NOT NULL,
        assessment_area_guid UUID,
        feature_name character varying(250) COLLATE pg_catalog."default",
        feature_description character varying(500) COLLATE pg_catalog."default",
        data_source character varying(250) COLLATE pg_catalog."default",
        created_by character varying(50) COLLATE pg_catalog."default",
        created_on timestamp without time zone,
        feature_type character(50) COLLATE pg_catalog."default",
        class_code integer,
        slope_angle integer,
        slope_shape integer,
        terrain_traps integer,
        freq_mag integer,
        startzone_density integer,
        path_exposure integer,
        route_options integer,
        exposure_time integer,
        feature_comments character varying(250) COLLATE pg_catalog."default",
        precision_m integer DEFAULT 0,
        CONSTRAINT fk_assessment_area_guid FOREIGN KEY (assessment_area_guid)
            REFERENCES ' || schema_name || '.assessment_areas (guid) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_class_code FOREIGN KEY (class_code)
            REFERENCES ' || schema_name || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_exposure_time_class FOREIGN KEY (exposure_time)
            REFERENCES ' || schema_name || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_freq_mag_class FOREIGN KEY (freq_mag)
            REFERENCES ' || schema_name || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_path_exposure_class FOREIGN KEY (path_exposure)
            REFERENCES ' || schema_name || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_route_options_class FOREIGN KEY (route_options)
            REFERENCES ' || schema_name || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_slope_angle_class FOREIGN KEY (slope_angle)
            REFERENCES ' || schema_name || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_slope_shape_class FOREIGN KEY (slope_shape)
            REFERENCES ' || schema_name || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_startzone_density_class FOREIGN KEY (startzone_density)
            REFERENCES ' || schema_name || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_terrain_traps_class FOREIGN KEY (terrain_traps)
            REFERENCES ' || schema_name || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT feature_type_check CHECK (feature_type in (''Area''))
    )';	

    -- Create table ates20_ln
    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || schema_name || '.ates20_ln
    (
        id SERIAL PRIMARY KEY,
        geom geometry(LineString, 4326) NOT NULL,
        assessment_area_guid UUID,
        feature_name character varying(250) COLLATE pg_catalog."default",
        feature_description character varying(500) COLLATE pg_catalog."default",
        data_source character varying(250) COLLATE pg_catalog."default",
        created_by character varying(50) COLLATE pg_catalog."default",
        created_on timestamp without time zone,
        feature_type character(50) COLLATE pg_catalog."default",
        class_code integer,
        slope_angle integer,
        slope_shape integer,
        terrain_traps integer,
        freq_mag integer,
        startzone_density integer,
        path_exposure integer,
        route_options integer,
        exposure_time integer,
        feature_comments character varying(250) COLLATE pg_catalog."default",
        precision_m integer DEFAULT 0,
        CONSTRAINT fk_assessment_area_guid FOREIGN KEY (assessment_area_guid)
            REFERENCES ' || schema_name || '.assessment_areas (guid) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_class_code FOREIGN KEY (class_code)
            REFERENCES ' || schema_name || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_exposure_time_class FOREIGN KEY (exposure_time)
            REFERENCES ' || schema_name || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_freq_mag_class FOREIGN KEY (freq_mag)
            REFERENCES ' || schema_name || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_path_exposure_class FOREIGN KEY (path_exposure)
            REFERENCES ' || schema_name || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_route_options_class FOREIGN KEY (route_options)
            REFERENCES ' || schema_name || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_slope_angle_class FOREIGN KEY (slope_angle)
            REFERENCES ' || schema_name || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_slope_shape_class FOREIGN KEY (slope_shape)
            REFERENCES ' || schema_name || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_startzone_density_class FOREIGN KEY (startzone_density)
            REFERENCES ' || schema_name || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_terrain_traps_class FOREIGN KEY (terrain_traps)
            REFERENCES ' || schema_name || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT feature_type_check CHECK (feature_type in (''Route'',''Corridor''))
    )';
       -- Create table ates20_poly
    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || schema_name || '.ates20_poly
    (
        id SERIAL PRIMARY KEY,
        geom geometry(LineString, 4326) NOT NULL,
        assessment_area_guid UUID,
        feature_name character varying(250) COLLATE pg_catalog."default",
        feature_description character varying(500) COLLATE pg_catalog."default",
        data_source character varying(250) COLLATE pg_catalog."default",
        created_by character varying(50) COLLATE pg_catalog."default",
        created_on timestamp without time zone,
        feature_type character(50) COLLATE pg_catalog."default",
        class_code integer,
        slope_angle integer,
        slope_shape integer,
        terrain_traps integer,
        freq_mag integer,
        startzone_density integer,
        path_exposure integer,
        route_options integer,
        exposure_time integer,
        feature_comments character varying(250) COLLATE pg_catalog."default",
        precision_m integer DEFAULT 0,
        CONSTRAINT fk_assessment_area_guid FOREIGN KEY (assessment_area_guid)
            REFERENCES ' || schema_name || '.assessment_areas (guid) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_class_code FOREIGN KEY (class_code)
            REFERENCES ' || schema_name || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_exposure_time_class FOREIGN KEY (exposure_time)
            REFERENCES ' || schema_name || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_freq_mag_class FOREIGN KEY (freq_mag)
            REFERENCES ' || schema_name || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_path_exposure_class FOREIGN KEY (path_exposure)
            REFERENCES ' || schema_name || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_route_options_class FOREIGN KEY (route_options)
            REFERENCES ' || schema_name || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_slope_angle_class FOREIGN KEY (slope_angle)
            REFERENCES ' || schema_name || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_slope_shape_class FOREIGN KEY (slope_shape)
            REFERENCES ' || schema_name || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_startzone_density_class FOREIGN KEY (startzone_density)
            REFERENCES ' || schema_name || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_terrain_traps_class FOREIGN KEY (terrain_traps)
            REFERENCES ' || schema_name || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT feature_type_check CHECK (feature_type in (''Zone'', ''Area''))
    )';
    
    RETURN;
    END;
    $$ LANGUAGE plpgsql;

-- Function to create ATES views
CREATE OR REPLACE FUNCTION create_ates_views(schema_name text)
    RETURNS void AS $$
    BEGIN
    
    -- Create materialized view for "MV_decision_point_warnings"
 /*   EXECUTE 'CREATE MATERIALIZED VIEW IF NOT EXISTS ' || schema_name || '."MV_decision_point_warnings" TABLESPACE pg_default AS
        SELECT
            uuid_generate_v4() AS id,
            dp.guid,
            dp.geom,
            dp.assessment_area_guid,
            dp.feature_name,
            concerns.warnings_text AS concerns,
            mitigations.warnings_text AS mitigations
        FROM ' || schema_name || '.decision_points dp
            JOIN (
                SELECT dpw.decision_points_guid AS dp_guid,
                    w.warning_type,
                    array_agg(w.warning_text) AS warnings_text
                FROM ' || schema_name || '.decision_points_warnings dpw
                    JOIN ' || schema_name || '.lu_warnings w ON dpw.warnings_guid = w.guid
                WHERE w.warning_type::text = ''Concern''::text
                GROUP BY dpw.decision_points_guid, w.warning_type
            ) concerns ON concerns.dp_guid = dp.guid
            JOIN (
                SELECT dpw.decision_points_guid AS dp_guid,
                    w.warning_type,
                    array_agg(w.warning_text) AS warnings_text
                FROM ' || schema_name || '.decision_points_warnings dpw
                    JOIN ' || schema_name || '.lu_warnings w ON dpw.warnings_guid = w.guid
                WHERE w.warning_type::text = ''Managing risk''::text
                GROUP BY dpw.decision_points_guid, w.warning_type
            ) mitigations ON mitigations.dp_guid = dp.guid
        ORDER BY dp.guid
        WITH DATA;
		
		CREATE UNIQUE INDEX IF NOT EXISTS mv_ates_decision_point_warnings_id
            ON ' || schema_name || '."MV_decision_point_warnings" USING btree
            (id)
            TABLESPACE pg_default;';*/

    EXECUTE 'CREATE MATERIALIZED VIEW IF NOT EXISTS ' || schema_name || '."MV_decision_point_warnings" TABLESPACE pg_default AS
        SELECT
            dp.guid,
            dp.geom,
            dp.assessment_area_guid,
            dp.feature_name,
            json_agg(json_build_object(''warning_type'', warnings.warning_type, ''warning_text'', warnings.warnings_text) order by warnings.warning_type) AS concerns_and_mitigations
        FROM ' || schema_name || '.decision_points dp
        JOIN (
            SELECT dpw.decision_points_guid AS dp_guid,
                w.warning_type,
                array_agg(DISTINCT w.warning_text) AS warnings_text
            FROM ' || schema_name || '.decision_points_warnings dpw
            JOIN ' || schema_name || '.lu_warnings w ON dpw.warnings_guid = w.guid
            WHERE w.warning_type::text IN (''Concern'', ''Managing risk'')
            GROUP BY dpw.decision_points_guid, w.warning_type
        ) warnings ON warnings.dp_guid = dp.guid
        GROUP BY dp.guid, dp.geom, dp.assessment_area_guid, dp.feature_name
        ORDER BY dp.guid;

    CREATE UNIQUE INDEX IF NOT EXISTS mv_ates_decision_point_warnings_id
        ON ' || schema_name || '.MV_decision_point_warnings USING btree
        (id)
        TABLESPACE pg_default;';

    -- Create materialized view for "MV_ates20_routes"	
    EXECUTE 'CREATE MATERIALIZED VIEW IF NOT EXISTS ' || schema_name || '."MV_ates20_routes" TABLESPACE pg_default AS
        SELECT
            uuid_generate_v4() AS id,
            feature.geom,
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
        FROM ' || schema_name || '.ates20_ln feature
            LEFT JOIN (
                SELECT assessment_areas.guid,
                    assessment_areas.feature_name as text	
                FROM ' || schema_name || '.assessment_areas assessment_areas
            ) assessment_area on assessment_area.guid = feature.assessment_area_guid
            INNER JOIN (
                SELECT ratings.class_code,
                    ratings.slope_angle as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) slope_angle on slope_angle.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.slope_shape as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) slope_shape on slope_shape.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.terrain_traps as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) terrain_traps on terrain_traps.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.freq_mag as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) freq_mag on freq_mag.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.startzone_density as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) startzone_density on startzone_density.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.path_exposure as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) path_exposure on path_exposure.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.route_options as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) route_options on route_options.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.exposure_time as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) exposure_time on exposure_time.class_code = feature.slope_angle
        WHERE feature.feature_type = ''Route''::bpchar
        ORDER BY assessment_area.text;

        CREATE UNIQUE INDEX IF NOT EXISTS mv_ates20_routes_id
            ON ' || schema_name || '."MV_ates20_routes" USING btree
            (id)
            TABLESPACE pg_default;';

    -- Create materialized view for "MV_ates20_corridor_buffered"	
    EXECUTE 'CREATE MATERIALIZED VIEW IF NOT EXISTS ' || schema_name || '."MV_ates20_corridor_buffered" TABLESPACE pg_default AS
        SELECT
            uuid_generate_v4() AS id,
            st_transform(st_buffer(st_transform(feature.geom, 3857), feature.precision_m::double precision), 4326) AS geom,
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
        FROM ' || schema_name || '.ates20_ln feature
            LEFT JOIN (
                SELECT assessment_areas.guid,
                    assessment_areas.feature_name as text	
                FROM ' || schema_name || '.assessment_areas assessment_areas
            ) assessment_area on assessment_area.guid = feature.assessment_area_guid
            INNER JOIN (
                SELECT ratings.class_code,
                    ratings.slope_angle as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) slope_angle on slope_angle.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.slope_shape as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) slope_shape on slope_shape.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.terrain_traps as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) terrain_traps on terrain_traps.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.freq_mag as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) freq_mag on freq_mag.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.startzone_density as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) startzone_density on startzone_density.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.path_exposure as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) path_exposure on path_exposure.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.route_options as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) route_options on route_options.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.exposure_time as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) exposure_time on exposure_time.class_code = feature.slope_angle
        WHERE feature.feature_type = ''Corridor''::bpchar
        ORDER BY assessment_area.text;

        CREATE UNIQUE INDEX IF NOT EXISTS mv_ates20_corridor_buffered_id
            ON ' || schema_name || '."MV_ates20_corridor_buffered" USING btree
            (id)
            TABLESPACE pg_default;';

    -- Create materialized view for "MV_ates20_corridor_fuzzy_buffer"	
    EXECUTE 'CREATE MATERIALIZED VIEW IF NOT EXISTS ' || schema_name || '."MV_ates20_corridor_fuzzy_buffer" TABLESPACE pg_default AS
        SELECT
			uuid_generate_v4() AS id,
			class_code as ates_class,
            ST_Transform(ST_Difference(ST_Buffer(ST_Transform(feature.geom, 3857), (feature.precision_m / 10 * d), ''quad_segs=90''), ST_Buffer(ST_Transform(feature.geom, 3857), (feature.precision_m / 10 * (d - 1)), ''quad_segs=90'')), 4326) AS geom,
            (100-(d)*10) AS transparency
        FROM
            ' || schema_name || '.ates20_poly feature,
        generate_series(1, 10) d(d)
        WHERE feature.feature_type = ''Corridor''::bpchar;  
        
        CREATE UNIQUE INDEX IF NOT EXISTS MV_ates20_corridor_fuzzy_buffer_id
            ON ' || schema_name || '."MV_ates20_corridor_fuzzy_buffer" USING btree
            (id)
            TABLESPACE pg_default;';    

    -- Create materialized view for "MV_ates20_zones_buffered"		
    EXECUTE 'CREATE MATERIALIZED VIEW IF NOT EXISTS ' || schema_name || '."MV_ates20_zones_buffered" TABLESPACE pg_default AS
        SELECT
            uuid_generate_v4() AS id,
            st_transform(st_buffer(st_transform(feature.geom, 3857), feature.precision_m::double precision), 4326) AS geom,
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
        FROM ' || schema_name || '.ates20_poly feature
            LEFT JOIN (
                SELECT assessment_areas.guid,
                    assessment_areas.feature_name as text	
                FROM ' || schema_name || '.assessment_areas assessment_areas
            ) assessment_area on assessment_area.guid = feature.assessment_area_guid
            INNER JOIN (
                SELECT ratings.class_code,
                    ratings.slope_angle as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) slope_angle on slope_angle.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.slope_shape as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) slope_shape on slope_shape.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.terrain_traps as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) terrain_traps on terrain_traps.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.freq_mag as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) freq_mag on freq_mag.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.startzone_density as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) startzone_density on startzone_density.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.path_exposure as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) path_exposure on path_exposure.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.route_options as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) route_options on route_options.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.exposure_time as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) exposure_time on exposure_time.class_code = feature.slope_angle
        WHERE feature.feature_type = ''Zone''::bpchar
        ORDER BY assessment_area.text;
        
        CREATE UNIQUE INDEX IF NOT EXISTS MV_ates20_zones_buffered_id
            ON ' || schema_name || '."MV_ates20_zones_buffered" USING btree
            (id)
            TABLESPACE pg_default;';

    -- Create materialized view for "MV_ates20_zones_fuzzy_buffer" 
    EXECUTE 'CREATE MATERIALIZED VIEW IF NOT EXISTS ' || schema_name || '."MV_ates20_zones_fuzzy_buffer" TABLESPACE pg_default AS
        SELECT
			uuid_generate_v4() AS id,
			class_code as ates_class,
            ST_Transform(ST_Difference(ST_Buffer(ST_Transform(feature.geom, 3857), (feature.precision_m / 10 * d), ''quad_segs=90''), ST_Buffer(ST_Transform(feature.geom, 3857), (feature.precision_m / 10 * (d - 1)), ''quad_segs=90'')), 4326) AS geom,
            (100-(d)*10) AS transparency
        FROM
            ' || schema_name || '.ates20_poly feature,
            generate_series(1, 10) d(d)
            WHERE feature.feature_type = ''Zone''::bpchar

        UNION 

        SELECT
			uuid_generate_v4() AS id,
			class_code as ates_class,
            feature.geom,
            100 AS transparency
        FROM
            ' || schema_name || '.ates20_poly feature
        WHERE feature.feature_type = ''Zone''::bpchar;

        CREATE UNIQUE INDEX IF NOT EXISTS MV_ates20_zones_fuzzy_buffer_id
            ON ' || schema_name || '."MV_ates20_zones_fuzzy_buffer" USING btree
            (id)
            TABLESPACE pg_default;';

    -- Create materialized view for "MV_ates20_areas_buffered"		
    EXECUTE 'CREATE MATERIALIZED VIEW IF NOT EXISTS ' || schema_name || '."MV_ates20_areas_buffered" TABLESPACE pg_default AS
        SELECT uuid_generate_v4() AS id,
            st_transform(st_buffer(st_transform(feature.geom, 3857), feature.precision_m::double precision), 4326) AS geom,
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
        FROM ' || schema_name || '.ates20_poly feature
            LEFT JOIN (
                SELECT assessment_areas.guid,
                    assessment_areas.feature_name as text	
                FROM ' || schema_name || '.assessment_areas assessment_areas
            ) assessment_area on assessment_area.guid = feature.assessment_area_guid
            INNER JOIN (
                SELECT ratings.class_code,
                    ratings.slope_angle as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) slope_angle on slope_angle.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.slope_shape as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) slope_shape on slope_shape.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.terrain_traps as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) terrain_traps on terrain_traps.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.freq_mag as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) freq_mag on freq_mag.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.startzone_density as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) startzone_density on startzone_density.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.path_exposure as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) path_exposure on path_exposure.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.route_options as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) route_options on route_options.class_code = feature.slope_angle
            INNER JOIN(
                SELECT ratings.class_code,
                    ratings.exposure_time as text 	
                FROM ' || schema_name || '.lu_ates20_ratings ratings
            ) exposure_time on exposure_time.class_code = feature.slope_angle
        WHERE feature.feature_type = ''Area''::bpchar
        ORDER BY assessment_area.text;
        
        CREATE UNIQUE INDEX IF NOT EXISTS MV_ates20_areas_buffered_id
            ON ' || schema_name || '."MV_ates20_areas_buffered" USING btree
            (id)
            TABLESPACE pg_default;';

    -- Create materialized view for "MV_ates20_areas_fuzzy_buuffer" 
    EXECUTE 'CREATE MATERIALIZED VIEW IF NOT EXISTS ' || schema_name || '."MV_ates20_areas_fuzzy_buffer" TABLESPACE pg_default AS
        WITH bufferedgeom AS
            ( SELECT feature.id AS feature_id,
                    st_buffer(st_transform(feature.geom, 3857), (- feature.precision_m)::double precision, 'join=mitre mitre_limit=5.0'::text) AS transformed_buffered_geom,
                    feature.class_code,
                    feature.precision_m
            FROM ates20_poly feature
            WHERE feature.feature_type = 'Zone'::bpchar )
        SELECT uuid_generate_v4() AS id,
            CASE
                WHEN d.d >= 1 THEN st_transform(st_difference(st_buffer(bg.transformed_buffered_geom, (2 * bg.precision_m / 20 * d.d)::double precision, 'join=mitre mitre_limit=5.0'::text), st_buffer(bg.transformed_buffered_geom, (2 * bg.precision_m / 20 * (d.d - 1))::double precision, 'join=mitre mitre_limit=5.0'::text)), 4326)
                ELSE st_transform(bg.transformed_buffered_geom, 4326)
            END AS geom,
            bg.class_code AS ates_class,
            CASE
                WHEN d.d >= 1 THEN 100 + 100 / (20 * 2) - d.d * (100 / 20)
                ELSE 100
            END AS transparency
        FROM bufferedgeom bg
        CROSS JOIN generate_series(0, 20) d(d) WITH DATA;      

        CREATE UNIQUE INDEX IF NOT EXISTS MV_ates20_areas_fuzzy_buffer_id
            ON ' || schema_name || '."MV_ates20_areas_fuzzy_buffer" USING btree
            (id)
            TABLESPACE pg_default;';

    END;
    $$ LANGUAGE plpgsql;



-- Function to create ATES objects in the current schema
CREATE OR REPLACE FUNCTION create_ates_objects()
    RETURNS VOID AS $$
    DECLARE
        schema_name TEXT;
    BEGIN
        -- Set the variable to the result of SELECT current_schema()
        SELECT current_schema() INTO schema_name;
        
        -- Call function create_ates_tables() with the schema_name variable
        PERFORM create_ates_tables(schema_name);
        
        -- Call function create_ates_views() with the schema_name variable
        PERFORM create_ates_views(schema_name);
    
        

        RETURN;
    END;
    $$ LANGUAGE plpgsql; 

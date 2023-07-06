CREATE OR REPLACE FUNCTION CREATE_tables(sch text)
RETURNS void AS $$
BEGIN

    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || sch || '.lu_ates10_ln_ratings
    (
        id SERIAL PRIMARY KEY,
		--guid UUID DEFAULT uuid_generate_v4() NOT NULL UNIQUE,
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

    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || sch || '."lu_ates10_poly_ratings"
    (
        id SERIAL PRIMARY KEY,
		--guid UUID DEFAULT uuid_generate_v4() NOT NULL UNIQUE,
        class_code integer NOT NULL UNIQUE,
        slope_character character varying(256) COLLATE pg_catalog."default" NOT NULL,
        startzone_density character varying(256) COLLATE pg_catalog."default" NOT NULL,
        path_exposure character varying(256) COLLATE pg_catalog."default" NOT NULL,
        terrain_traps character varying(256) COLLATE pg_catalog."default" NOT NULL,
        slope_shape character varying(256) COLLATE pg_catalog."default" NOT NULL
    )';

    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || sch || '.lu_ates20_ratings
    (
        id SERIAL PRIMARY KEY,
		--guid UUID DEFAULT uuid_generate_v4() NOT NULL UNIQUE,
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

	EXECUTE 'CREATE TABLE IF NOT EXISTS ' || sch || '.assessment_areas
    (
        id SERIAL PRIMARY KEY,
		guid UUID DEFAULT uuid_generate_v4() NOT NULL UNIQUE,
        geom geometry(MultiPolygon,4326),
        feature_name character varying(250) COLLATE pg_catalog."default" NOT NULL,
        feature_description character(250) COLLATE pg_catalog."default",
        feature_comments character varying(250) COLLATE pg_catalog."default",
		data_owner character(50) COLLATE pg_catalog."default"
    )';

    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || sch || '.access_roads
    (
        id SERIAL PRIMARY KEY,
        --guid UUID DEFAULT uuid_generate_v4() NOT NULL UNIQUE,
        geom geometry(MultiLineString,4326),
        assessment_area_guid UUID,
        feature_name character varying(250) COLLATE pg_catalog."default",
        feature_description character varying(500) COLLATE pg_catalog."default",
        data_source character varying(250) COLLATE pg_catalog."default",
        CREATEd_by character varying(50) COLLATE pg_catalog."default",
        CREATEd_on timestamp without time zone,
        feature_comments character varying(250) COLLATE pg_catalog."default",
        CONSTRAINT fk_assessment_area_guid FOREIGN KEY (assessment_area_guid)
            REFERENCES ' || sch || '.assessment_areas (guid) MATCH SIMPLE
            ON UPDATE NO ACTION
            ON DELETE NO ACTION
    )';

	EXECUTE 'CREATE TABLE IF NOT EXISTS ' || sch || '.avalanche_paths
    (
        id SERIAL PRIMARY KEY,
       --guid UUID DEFAULT uuid_generate_v4() NOT NULL UNIQUE,
        geom geometry(LineString, 4326),
        assessment_area_guid UUID,
        feature_name character varying(250) COLLATE pg_catalog."default",
        feature_description character varying(500) COLLATE pg_catalog."default",
        data_source character varying(250) COLLATE pg_catalog."default",
        CREATEd_by character varying(50) COLLATE pg_catalog."default",
        CREATEd_on timestamp without time zone,
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
            REFERENCES ' || sch || '.assessment_areas (guid) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION
    )';

	EXECUTE 'CREATE TABLE IF NOT EXISTS ' || sch || '.decision_points
    (
        id SERIAL PRIMARY KEY,
        guid UUID DEFAULT uuid_generate_v4() NOT NULL UNIQUE,
        geom geometry(Point, 4326),
        assessment_area_guid UUID,
        feature_name character varying(250) COLLATE pg_catalog."default",
        feature_description character varying(500) COLLATE pg_catalog."default",
        CREATEd_by character varying(50) COLLATE pg_catalog."default",
        CREATEd_on timestamp without time zone,
        feature_comments character varying(250) COLLATE pg_catalog."default",
        CONSTRAINT fk_assessment_area_guid FOREIGN KEY (assessment_area_guid)
            REFERENCES ' || sch || '.assessment_areas (guid) MATCH SIMPLE
            ON UPDATE NO ACTION
            ON DELETE NO ACTION
    )';

    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || sch || '.lu_warnings
    (
        id SERIAL PRIMARY KEY,
        guid UUID DEFAULT uuid_generate_v4() NOT NULL UNIQUE,
        warning_type character varying(250) COLLATE pg_catalog."default" NOT NULL,
        warning_text character varying(250) COLLATE pg_catalog."default" NOT NULL UNIQUE
    )';

    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || sch || '.decision_points_warnings
    (
        id SERIAL PRIMARY KEY,
        guid UUID DEFAULT uuid_generate_v4() NOT NULL UNIQUE,
        decision_points_guid UUID,
        warnings_guid UUID,
        CONSTRAINT fk_decisions_points_guid FOREIGN KEY (decision_points_guid)
            REFERENCES ' || sch || '.decision_points (guid) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_warnings_guid FOREIGN KEY (warnings_guid)
            REFERENCES ' || sch || '.lu_warnings (guid) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION
    )';

    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || sch || '.lu_points_of_interest
    (
        id serial PRIMARY KEY,
        --guid UUID DEFAULT uuid_generate_v4() NOT NULL UNIQUE,
        poi_guid UUID,
        poi_type character varying(250) COLLATE pg_catalog."default" NOT NULL UNIQUE
    )';
    

    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || sch || '.points_of_interest
        (
            id serial PRIMARY KEY,
            --guid UUID DEFAULT uuid_generate_v4() NOT NULL UNIQUE,
            geom geometry(Point,4326),
            assessment_area_guid UUID,
            feature_name character varying(250) COLLATE pg_catalog."default",
            feature_description character varying(500) COLLATE pg_catalog."default",
            data_source character varying(250) COLLATE pg_catalog."default",
            CREATEd_by character varying(50) COLLATE pg_catalog."default",
            CREATEd_on timestamp without time zone,
            poi_type character(50) COLLATE pg_catalog."default",
            feature_comments character(250) COLLATE pg_catalog."default",
            CONSTRAINT fk_area_id FOREIGN KEY (assessment_area_guid)
                REFERENCES ' || sch || '.assessment_areas (guid) MATCH SIMPLE
                ON UPDATE CASCADE
                ON DELETE NO ACTION,
            CONSTRAINT fk_points_of_interst_guid FOREIGN KEY (poi_type)
                REFERENCES ' || sch || '.lu_points_of_interest (poi_type) MATCH SIMPLE
                ON UPDATE CASCADE
                ON DELETE NO ACTION
        )';


    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || sch || 'ates10_ln
    (
        id serial PRIMARY KEY,
        --guid UUID DEFAULT uuid_generate_v4() NOT NULL UNIQUE,
        geom geometry(MultiLineString,4326),
        assessment_area_guid UUID,
        feature_name character varying(250) COLLATE pg_catalog."default",
        feature_description character varying(500) COLLATE pg_catalog."default",
        data_source character varying(250) COLLATE pg_catalog."default",
        CREATEd_by character varying(50) COLLATE pg_catalog."default",
        CREATEd_on timestamp without time zone,
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
            REFERENCES ' || sch || '.assessment_areas (guid) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT ates_rating_class FOREIGN KEY (class_code)
            REFERENCES ' || sch || '.lu_ates10_ln_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT avalanche_frequency_class FOREIGN KEY (avalanche_frequency)
            REFERENCES ' || sch || '.lu_ates10_ln_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT exposure_time_class FOREIGN KEY (exposure_time)
            REFERENCES ' || sch || '.lu_ates10_ln_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT forest_density_class FOREIGN KEY (forest_density)
            REFERENCES ' || sch || '.lu_ates10_ln_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT glaciation_class FOREIGN KEY (glaciation)
            REFERENCES ' || sch || '.lu_ates10_ln_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT path_exposure_class FOREIGN KEY (path_exposure)
            REFERENCES ' || sch || '.lu_ates10_ln_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT route_options_class FOREIGN KEY (route_options)
            REFERENCES ' || sch || '.lu_ates10_ln_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT runnout_character_class FOREIGN KEY (runout_character)
            REFERENCES ' || sch || '.lu_ates10_ln_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT slope_angle_class FOREIGN KEY (slope_angle)
            REFERENCES ' || sch || '.lu_ates10_ln_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT slope_shape_class FOREIGN KEY (slope_shape)
            REFERENCES ' || sch || '.lu_ates10_ln_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT terrain_traps_class FOREIGN KEY (terrain_traps)
            REFERENCES ' || sch || '.lu_ates10_ln_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION
    )';

    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || sch || '.ates10_poly
    (
        id serial PRIMARY KEY,
        --guid UUID DEFAULT uuid_generate_v4() NOT NULL UNIQUE,
        geom geometry(MultiPolygon,4326),
        assessment_area_guid UUID,
        feature_name character varying(250) COLLATE pg_catalog."default",
        feature_description character varying(500) COLLATE pg_catalog."default",
        data_source character varying(250) COLLATE pg_catalog."default",
        CREATEd_by character varying(50) COLLATE pg_catalog."default",
        CREATEd_on timestamp without time zone,
        class_code integer,
        slope_character integer,
        startzone_density integer,
        path_exposure integer,
        terrain_traps integer,
        slope_shape integer,
        CONSTRAINT fk_assessment_area_guid FOREIGN KEY (assessment_area_guid)
            REFERENCES ' || sch || '.assessment_areas (guid) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT ates_rating_class FOREIGN KEY (class_code)
            REFERENCES ' || sch || '.lu_ates10_poly_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT slope_character_class FOREIGN KEY (slope_character)
            REFERENCES ' || sch || '.lu_ates10_poly_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT startzone_density_class FOREIGN KEY (startzone_density)
            REFERENCES ' || sch || '.lu_ates10_poly_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT path_exposure_class FOREIGN KEY (path_exposure)
            REFERENCES ' || sch || '.lu_ates10_poly_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT terrain_traps_class FOREIGN KEY (terrain_traps)
            REFERENCES ' || sch || '.lu_ates10_poly_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT slope_shape_class FOREIGN KEY (slope_shape)
            REFERENCES ' || sch || '.lu_ates10_poly_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION
    )';



    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || sch || '.ates20_pt
    (
        id SERIAL PRIMARY KEY,
        --guid UUID DEFAULT uuid_generate_v4() NOT NULL UNIQUE,
        geom geometry(Point, 4326) NOT NULL,
        assessment_area_guid UUID,
        feature_name character varying(250) COLLATE pg_catalog."default",
        feature_description character varying(500) COLLATE pg_catalog."default",
        data_source character varying(250) COLLATE pg_catalog."default",
        CREATEd_by character varying(50) COLLATE pg_catalog."default",
        CREATEd_on timestamp without time zone,
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
            REFERENCES ' || sch || '.assessment_areas (guid) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_class_code FOREIGN KEY (class_code)
            REFERENCES ' || sch || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_exposure_time_class FOREIGN KEY (exposure_time)
            REFERENCES ' || sch || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_freq_mag_class FOREIGN KEY (freq_mag)
            REFERENCES ' || sch || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_path_exposure_class FOREIGN KEY (path_exposure)
            REFERENCES ' || sch || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_route_options_class FOREIGN KEY (route_options)
            REFERENCES ' || sch || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_slope_angle_class FOREIGN KEY (slope_angle)
            REFERENCES ' || sch || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_slope_shape_class FOREIGN KEY (slope_shape)
            REFERENCES ' || sch || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_startzone_density_class FOREIGN KEY (startzone_density)
            REFERENCES ' || sch || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_terrain_traps_class FOREIGN KEY (terrain_traps)
            REFERENCES ' || sch || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT feature_type_check CHECK (feature_type in (''Area''))
    )';	

    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || sch || '.ates20_ln
    (
        id SERIAL PRIMARY KEY,
        --guid UUID DEFAULT uuid_generate_v4() NOT NULL UNIQUE,
        geom geometry(MultiLineString, 4326) NOT NULL,
        assessment_area_guid UUID,
        feature_name character varying(250) COLLATE pg_catalog."default",
        feature_description character varying(500) COLLATE pg_catalog."default",
        data_source character varying(250) COLLATE pg_catalog."default",
        CREATEd_by character varying(50) COLLATE pg_catalog."default",
        CREATEd_on timestamp without time zone,
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
            REFERENCES ' || sch || '.assessment_areas (guid) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_class_code FOREIGN KEY (class_code)
            REFERENCES ' || sch || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_exposure_time_class FOREIGN KEY (exposure_time)
            REFERENCES ' || sch || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_freq_mag_class FOREIGN KEY (freq_mag)
            REFERENCES ' || sch || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_path_exposure_class FOREIGN KEY (path_exposure)
            REFERENCES ' || sch || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_route_options_class FOREIGN KEY (route_options)
            REFERENCES ' || sch || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_slope_angle_class FOREIGN KEY (slope_angle)
            REFERENCES ' || sch || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_slope_shape_class FOREIGN KEY (slope_shape)
            REFERENCES ' || sch || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_startzone_density_class FOREIGN KEY (startzone_density)
            REFERENCES ' || sch || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_terrain_traps_class FOREIGN KEY (terrain_traps)
            REFERENCES ' || sch || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT feature_type_check CHECK (feature_type in (''Route'', ''Corridor''))
    )';	
	
	EXECUTE 'CREATE TABLE IF NOT EXISTS ' || sch || '.ates20_poly
    (
        id SERIAL PRIMARY KEY,
        --guid UUID DEFAULT uuid_generate_v4() NOT NULL UNIQUE,
        geom geometry(MultiPolygon, 4326) NOT NULL,
        assessment_area_guid UUID,
        feature_name character varying(250) COLLATE pg_catalog."default",
        feature_description character varying(500) COLLATE pg_catalog."default",
        data_source character varying(250) COLLATE pg_catalog."default",
        CREATEd_by character varying(50) COLLATE pg_catalog."default",
        CREATEd_on timestamp without time zone,
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
            REFERENCES ' || sch || '.assessment_areas (guid) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_class_code FOREIGN KEY (class_code)
            REFERENCES ' || sch || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_exposure_time_class FOREIGN KEY (exposure_time)
            REFERENCES ' || sch || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_freq_mag_class FOREIGN KEY (freq_mag)
            REFERENCES ' || sch || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_path_exposure_class FOREIGN KEY (path_exposure)
            REFERENCES ' || sch || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_route_options_class FOREIGN KEY (route_options)
            REFERENCES ' || sch || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_slope_angle_class FOREIGN KEY (slope_angle)
            REFERENCES ' || sch || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_slope_shape_class FOREIGN KEY (slope_shape)
            REFERENCES ' || sch || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_startzone_density_class FOREIGN KEY (startzone_density)
            REFERENCES ' || sch || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT fk_terrain_traps_class FOREIGN KEY (terrain_traps)
            REFERENCES ' || sch || '.lu_ates20_ratings (class_code) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT feature_type_check CHECK (feature_type in (''Zone'', ''Area''))
    )';

END;
$$ LANGUAGE plpgsql;

SELECT CREATE_tables('ates_dev');
	


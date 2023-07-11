CREATE OR REPLACE FUNCTION refresh_materialized_views(schema_name text)
RETURNS void AS $$
BEGIN
    -- Trigger function for refreshing the materialized view MV_decision_point_warnings
    CREATE OR REPLACE FUNCTION refresh_mv_decision_point_warnings()
    RETURNS TRIGGER AS $$
    BEGIN
        REFRESH MATERIALIZED VIEW schema_name || '.MV_decision_point_warnings';
        RETURN NULL;
    END;
    $$ LANGUAGE plpgsql;

    -- Trigger for refreshing the materialized view MV_decision_point_warnings after insert, update, or delete on the decision_points_warnings table
    CREATE TRIGGER trg_refresh_mv_decision_point_warnings
    AFTER INSERT OR UPDATE OR DELETE ON schema_name || '.decision_points_warnings'
    FOR EACH STATEMENT
    EXECUTE FUNCTION refresh_mv_decision_point_warnings();

    -- Repeat the above steps for the other materialized views

    -- Trigger function for refreshing the materialized view MV_ates20_routes
    CREATE OR REPLACE FUNCTION refresh_mv_ates20_routes()
    RETURNS TRIGGER AS $$
    BEGIN
        REFRESH MATERIALIZED VIEW schema_name || '.MV_ates20_routes';
        RETURN NULL;
    END;
    $$ LANGUAGE plpgsql;

    -- Trigger for refreshing the materialized view MV_ates20_routes after insert, update, or delete on the ates20_ln table
    CREATE TRIGGER trg_refresh_mv_ates20_routes
    AFTER INSERT OR UPDATE OR DELETE ON schema_name || '.ates20_ln'
    FOR EACH STATEMENT
    EXECUTE FUNCTION refresh_mv_ates20_routes();

    -- Repeat the above steps for the other materialized views

    -- Trigger function for refreshing the materialized view MV_ates20_corridor_buffered
    CREATE OR REPLACE FUNCTION refresh_mv_ates20_corridor_buffered()
    RETURNS TRIGGER AS $$
    BEGIN
        REFRESH MATERIALIZED VIEW schema_name || '.MV_ates20_corridor_buffered';
        RETURN NULL;
    END;
    $$ LANGUAGE plpgsql;

    -- Trigger for refreshing the materialized view MV_ates20_corridor_buffered after insert, update, or delete on the ates20_ln table
    CREATE TRIGGER trg_refresh_mv_ates20_corridor_buffered
    AFTER INSERT OR UPDATE OR DELETE ON schema_name || '.ates20_ln'
    FOR EACH STATEMENT
    EXECUTE FUNCTION refresh_mv_ates20_corridor_buffered();

    -- Repeat the above steps for the other materialized views

    -- Trigger function for refreshing the materialized view MV_ates20_zones_buffered
    CREATE OR REPLACE FUNCTION refresh_mv_ates20_zones_buffered()
    RETURNS TRIGGER AS $$
    BEGIN
        REFRESH MATERIALIZED VIEW schema_name || '.MV_ates20_zones_buffered';
        RETURN NULL;
    END;
    $$ LANGUAGE plpgsql;

    -- Trigger for refreshing the materialized view MV_ates20_zones_buffered after insert, update, or delete on the ates20_poly table
    CREATE TRIGGER trg_refresh_mv_ates20_zones_buffered
    AFTER INSERT OR UPDATE OR DELETE ON schema_name || '.ates20_poly'
    FOR EACH STATEMENT
    EXECUTE FUNCTION refresh_mv_ates20_zones_buffered();

    -- Repeat the above steps for the other materialized views

    -- Trigger function for refreshing the materialized view MV_ates20_zones
    CREATE OR REPLACE FUNCTION refresh_mv_ates20_zones()
    RETURNS TRIGGER AS $$
    BEGIN
        REFRESH MATERIALIZED VIEW schema_name || '.MV_ates20_zones';
        RETURN NULL;
    END;
    $$ LANGUAGE plpgsql;

    -- Trigger for refreshing the materialized view MV_ates20_zones after insert, update, or delete on the ates20_poly table
    CREATE TRIGGER trg_refresh_mv_ates20_zones
    AFTER INSERT OR UPDATE OR DELETE ON schema_name || '.ates20_poly'
    FOR EACH STATEMENT
    EXECUTE FUNCTION refresh_mv_ates20_zones();

    -- Repeat the above steps for the other materialized views

    -- Trigger function for refreshing the materialized view MV_ates20_zones_fuzzy_buffer
    CREATE OR REPLACE FUNCTION refresh_mv_ates20_zones_fuzzy_buffer()
    RETURNS TRIGGER AS $$
    BEGIN
        REFRESH MATERIALIZED VIEW schema_name || '.MV_ates20_zones_fuzzy_buffer';
        RETURN NULL;
    END;
    $$ LANGUAGE plpgsql;

    -- Trigger for refreshing the materialized view MV_ates20_zones_fuzzy_buffer after insert, update, or delete on the ates20_poly table
    CREATE TRIGGER trg_refresh_mv_ates20_zones_fuzzy_buffer
    AFTER INSERT OR UPDATE OR DELETE ON schema_name || '.ates20_poly'
    FOR EACH STATEMENT
    EXECUTE FUNCTION refresh_mv_ates20_zones_fuzzy_buffer();

    -- Trigger function for refreshing the materialized view MV_ates20_areas_buffered
    CREATE OR REPLACE FUNCTION refresh_mv_ates20_areas_buffered()
    RETURNS TRIGGER AS $$
    BEGIN
        REFRESH MATERIALIZED VIEW schema_name || '.MV_ates20_areas_buffered';
        RETURN NULL;
    END;
    $$ LANGUAGE plpgsql;

    -- Trigger for refreshing the materialized view MV_ates20_areas_buffered after insert, update, or delete on the ates20_poly table
    CREATE TRIGGER trg_refresh_mv_ates20_areas_buffered
    AFTER INSERT OR UPDATE OR DELETE ON schema_name || '.ates20_poly'
    FOR EACH STATEMENT
    EXECUTE FUNCTION refresh_mv_ates20_areas_buffered();

END;
$$ LANGUAGE plpgsql;

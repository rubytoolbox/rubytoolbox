SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


--
-- Name: categories_update_description_tsvector_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.categories_update_description_tsvector_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    new.description_tsvector := to_tsvector('pg_catalog.simple', coalesce(new.description, ''));
    RETURN NEW;
END;
$$;


--
-- Name: categories_update_name_tsvector_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.categories_update_name_tsvector_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    new.name_tsvector := to_tsvector('pg_catalog.simple', coalesce(new.name, ''));
    RETURN NEW;
END;
$$;


--
-- Name: projects_update_description_tsvector_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.projects_update_description_tsvector_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    new.description_tsvector := to_tsvector('pg_catalog.simple', coalesce(new.description, ''));
    RETURN NEW;
END;
$$;


--
-- Name: projects_update_permalink_tsvector_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.projects_update_permalink_tsvector_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    new.permalink_tsvector := to_tsvector('pg_catalog.simple', coalesce(new.permalink, ''));
    RETURN NEW;
END;
$$;


--
-- Name: rubygem_stats_calculation_month(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.rubygem_stats_calculation_month() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    previous_downloads int;
    previous_relative_change decimal;
BEGIN
    SELECT total_downloads, relative_change_month INTO previous_downloads, previous_relative_change
      FROM rubygem_download_stats
      WHERE
        rubygem_name = NEW.rubygem_name AND date = NEW.date - 28;
    
    IF previous_downloads IS NOT NULL THEN
      NEW.absolute_change_month := NEW.total_downloads - previous_downloads;
      IF previous_downloads > 0 THEN
        NEW.relative_change_month := ROUND((NEW.absolute_change_month * 100.0) / previous_downloads, 2);
    
        IF previous_relative_change IS NOT NULL THEN
          NEW.growth_change_month := NEW.relative_change_month - previous_relative_change;
        END IF;
      END IF;
    END IF;
    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    service_name character varying NOT NULL,
    byte_size bigint NOT NULL,
    checksum character varying,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: active_storage_variant_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_variant_records (
    id bigint NOT NULL,
    blob_id bigint NOT NULL,
    variation_digest character varying NOT NULL
);


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_variant_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNED BY public.active_storage_variant_records.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    permalink public.citext NOT NULL,
    name character varying NOT NULL,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    category_group_permalink public.citext NOT NULL,
    name_tsvector tsvector,
    rank integer,
    description_tsvector tsvector
);


--
-- Name: categorizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categorizations (
    id bigint NOT NULL,
    category_permalink public.citext NOT NULL,
    project_permalink character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: categorizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categorizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categorizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categorizations_id_seq OWNED BY public.categorizations.id;


--
-- Name: category_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.category_groups (
    permalink public.citext NOT NULL,
    name character varying NOT NULL,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: database_exports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.database_exports (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: database_exports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.database_exports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: database_exports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.database_exports_id_seq OWNED BY public.database_exports.id;


--
-- Name: github_ignores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.github_ignores (
    path character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: github_readmes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.github_readmes (
    path character varying NOT NULL,
    html text NOT NULL,
    etag character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: github_repos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.github_repos (
    path public.citext NOT NULL,
    stargazers_count integer NOT NULL,
    forks_count integer NOT NULL,
    watchers_count integer NOT NULL,
    description character varying,
    homepage_url character varying,
    repo_created_at timestamp without time zone,
    repo_pushed_at timestamp without time zone,
    has_issues boolean,
    has_wiki boolean,
    archived boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    primary_language character varying,
    license character varying,
    default_branch character varying,
    is_fork boolean,
    is_mirror boolean,
    open_issues_count integer,
    closed_issues_count integer,
    open_pull_requests_count integer,
    merged_pull_requests_count integer,
    closed_pull_requests_count integer,
    average_recent_committed_at timestamp without time zone,
    code_of_conduct_url character varying,
    code_of_conduct_name character varying,
    topics character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    total_issues_count integer,
    total_pull_requests_count integer,
    issue_closure_rate numeric(5,2) DEFAULT NULL::numeric,
    pull_request_acceptance_rate numeric(5,2) DEFAULT NULL::numeric,
    fetched_at timestamp without time zone
);


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects (
    permalink character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    rubygem_name character varying,
    github_repo_path public.citext,
    score numeric(5,2),
    description text,
    permalink_tsvector tsvector,
    description_tsvector tsvector,
    bugfix_fork_of character varying,
    bugfix_fork_criteria character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    is_bugfix_fork boolean DEFAULT false NOT NULL,
    CONSTRAINT check_project_permalink_and_rubygem_name_parity CHECK (((rubygem_name IS NULL) OR ((rubygem_name)::text = (permalink)::text)))
);


--
-- Name: rubygem_code_statistics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rubygem_code_statistics (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    rubygem_name character varying NOT NULL,
    language character varying NOT NULL,
    code integer NOT NULL,
    blanks integer NOT NULL,
    comments integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: rubygem_dependencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rubygem_dependencies (
    id bigint NOT NULL,
    rubygem_name character varying NOT NULL,
    dependency_name character varying NOT NULL,
    type character varying NOT NULL,
    requirements character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: rubygem_dependencies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rubygem_dependencies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rubygem_dependencies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rubygem_dependencies_id_seq OWNED BY public.rubygem_dependencies.id;


--
-- Name: rubygem_download_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rubygem_download_stats (
    id bigint NOT NULL,
    rubygem_name character varying NOT NULL,
    date date NOT NULL,
    total_downloads integer NOT NULL,
    absolute_change_month integer,
    relative_change_month numeric,
    growth_change_month numeric
);


--
-- Name: rubygem_download_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rubygem_download_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rubygem_download_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rubygem_download_stats_id_seq OWNED BY public.rubygem_download_stats.id;


--
-- Name: rubygem_trends; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rubygem_trends (
    id bigint NOT NULL,
    date date NOT NULL,
    rubygem_name character varying NOT NULL,
    "position" integer NOT NULL,
    rubygem_download_stat_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: rubygem_trends_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rubygem_trends_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rubygem_trends_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rubygem_trends_id_seq OWNED BY public.rubygem_trends.id;


--
-- Name: rubygems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rubygems (
    name character varying NOT NULL,
    downloads integer NOT NULL,
    current_version character varying NOT NULL,
    authors character varying,
    description text,
    licenses character varying[] DEFAULT '{}'::character varying[],
    bug_tracker_url character varying,
    changelog_url character varying,
    documentation_url character varying,
    homepage_url character varying,
    mailing_list_url character varying,
    source_code_url character varying,
    wiki_url character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    first_release_on date,
    latest_release_on date,
    releases_count integer,
    reverse_dependencies_count integer,
    fetched_at timestamp without time zone,
    quarterly_release_counts jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: active_storage_variant_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('public.active_storage_variant_records_id_seq'::regclass);


--
-- Name: categorizations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categorizations ALTER COLUMN id SET DEFAULT nextval('public.categorizations_id_seq'::regclass);


--
-- Name: database_exports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_exports ALTER COLUMN id SET DEFAULT nextval('public.database_exports_id_seq'::regclass);


--
-- Name: rubygem_dependencies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rubygem_dependencies ALTER COLUMN id SET DEFAULT nextval('public.rubygem_dependencies_id_seq'::regclass);


--
-- Name: rubygem_download_stats id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rubygem_download_stats ALTER COLUMN id SET DEFAULT nextval('public.rubygem_download_stats_id_seq'::regclass);


--
-- Name: rubygem_trends id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rubygem_trends ALTER COLUMN id SET DEFAULT nextval('public.rubygem_trends_id_seq'::regclass);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_variant_records active_storage_variant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT active_storage_variant_records_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: categorizations categorizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categorizations
    ADD CONSTRAINT categorizations_pkey PRIMARY KEY (id);


--
-- Name: database_exports database_exports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.database_exports
    ADD CONSTRAINT database_exports_pkey PRIMARY KEY (id);


--
-- Name: rubygem_code_statistics rubygem_code_statistics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rubygem_code_statistics
    ADD CONSTRAINT rubygem_code_statistics_pkey PRIMARY KEY (id);


--
-- Name: rubygem_dependencies rubygem_dependencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rubygem_dependencies
    ADD CONSTRAINT rubygem_dependencies_pkey PRIMARY KEY (id);


--
-- Name: rubygem_download_stats rubygem_download_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rubygem_download_stats
    ADD CONSTRAINT rubygem_download_stats_pkey PRIMARY KEY (id);


--
-- Name: rubygem_trends rubygem_trends_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rubygem_trends
    ADD CONSTRAINT rubygem_trends_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: categorizations_unique_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX categorizations_unique_index ON public.categorizations USING btree (category_permalink, project_permalink);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_active_storage_variant_records_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_variant_records_uniqueness ON public.active_storage_variant_records USING btree (blob_id, variation_digest);


--
-- Name: index_categories_on_category_group_permalink; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_category_group_permalink ON public.categories USING btree (category_group_permalink);


--
-- Name: index_categories_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_created_at ON public.categories USING btree (created_at);


--
-- Name: index_categories_on_description_tsvector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_description_tsvector ON public.categories USING gin (description_tsvector);


--
-- Name: index_categories_on_name_tsvector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_name_tsvector ON public.categories USING gin (name_tsvector);


--
-- Name: index_categories_on_permalink; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_categories_on_permalink ON public.categories USING btree (permalink);


--
-- Name: index_categories_on_rank; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_rank ON public.categories USING btree (rank);


--
-- Name: index_categorizations_on_category_permalink; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categorizations_on_category_permalink ON public.categorizations USING btree (category_permalink);


--
-- Name: index_categorizations_on_project_permalink; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categorizations_on_project_permalink ON public.categorizations USING btree (project_permalink);


--
-- Name: index_category_groups_on_permalink; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_category_groups_on_permalink ON public.category_groups USING btree (permalink);


--
-- Name: index_github_ignores_on_path; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_github_ignores_on_path ON public.github_ignores USING btree (path);


--
-- Name: index_github_readmes_on_path; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_github_readmes_on_path ON public.github_readmes USING btree (path);


--
-- Name: index_github_repos_on_path; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_github_repos_on_path ON public.github_repos USING btree (path);


--
-- Name: index_projects_on_bugfix_fork_of; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_bugfix_fork_of ON public.projects USING btree (bugfix_fork_of);


--
-- Name: index_projects_on_description_tsvector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_description_tsvector ON public.projects USING gin (description_tsvector);


--
-- Name: index_projects_on_github_repo_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_github_repo_path ON public.projects USING btree (github_repo_path);


--
-- Name: index_projects_on_is_bugfix_fork; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_is_bugfix_fork ON public.projects USING btree (is_bugfix_fork);


--
-- Name: index_projects_on_permalink; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_projects_on_permalink ON public.projects USING btree (permalink);


--
-- Name: index_projects_on_permalink_tsvector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_permalink_tsvector ON public.projects USING gin (permalink_tsvector);


--
-- Name: index_projects_on_rubygem_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_projects_on_rubygem_name ON public.projects USING btree (rubygem_name);


--
-- Name: index_rubygem_code_statistics_on_rubygem_name_and_language; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_rubygem_code_statistics_on_rubygem_name_and_language ON public.rubygem_code_statistics USING btree (rubygem_name, language);


--
-- Name: index_rubygem_dependencies_on_dependency_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rubygem_dependencies_on_dependency_name ON public.rubygem_dependencies USING btree (dependency_name);


--
-- Name: index_rubygem_dependencies_on_rubygem_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rubygem_dependencies_on_rubygem_name ON public.rubygem_dependencies USING btree (rubygem_name);


--
-- Name: index_rubygem_download_stats_on_absolute_change_month; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rubygem_download_stats_on_absolute_change_month ON public.rubygem_download_stats USING btree (absolute_change_month DESC NULLS LAST);


--
-- Name: index_rubygem_download_stats_on_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rubygem_download_stats_on_date ON public.rubygem_download_stats USING btree (date);


--
-- Name: index_rubygem_download_stats_on_growth_change_month; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rubygem_download_stats_on_growth_change_month ON public.rubygem_download_stats USING btree (growth_change_month DESC NULLS LAST);


--
-- Name: index_rubygem_download_stats_on_relative_change_month; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rubygem_download_stats_on_relative_change_month ON public.rubygem_download_stats USING btree (relative_change_month DESC NULLS LAST);


--
-- Name: index_rubygem_download_stats_on_rubygem_name_and_date; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_rubygem_download_stats_on_rubygem_name_and_date ON public.rubygem_download_stats USING btree (rubygem_name, date);


--
-- Name: index_rubygem_download_stats_on_total_downloads; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rubygem_download_stats_on_total_downloads ON public.rubygem_download_stats USING btree (total_downloads DESC NULLS LAST);


--
-- Name: index_rubygem_trends_on_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rubygem_trends_on_date ON public.rubygem_trends USING btree (date);


--
-- Name: index_rubygem_trends_on_date_and_position; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_rubygem_trends_on_date_and_position ON public.rubygem_trends USING btree (date, "position");


--
-- Name: index_rubygem_trends_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rubygem_trends_on_position ON public.rubygem_trends USING btree ("position");


--
-- Name: index_rubygems_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_rubygems_on_name ON public.rubygems USING btree (name);


--
-- Name: categories categories_update_description_tsvector_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER categories_update_description_tsvector_trigger BEFORE INSERT OR UPDATE ON public.categories FOR EACH ROW EXECUTE FUNCTION public.categories_update_description_tsvector_trigger();


--
-- Name: categories categories_update_name_tsvector_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER categories_update_name_tsvector_trigger BEFORE INSERT OR UPDATE ON public.categories FOR EACH ROW EXECUTE FUNCTION public.categories_update_name_tsvector_trigger();


--
-- Name: projects projects_update_description_tsvector_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER projects_update_description_tsvector_trigger BEFORE INSERT OR UPDATE ON public.projects FOR EACH ROW EXECUTE FUNCTION public.projects_update_description_tsvector_trigger();


--
-- Name: projects projects_update_permalink_tsvector_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER projects_update_permalink_tsvector_trigger BEFORE INSERT OR UPDATE ON public.projects FOR EACH ROW EXECUTE FUNCTION public.projects_update_permalink_tsvector_trigger();


--
-- Name: rubygem_download_stats rubygem_stats_calculation_month; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER rubygem_stats_calculation_month BEFORE INSERT OR UPDATE ON public.rubygem_download_stats FOR EACH ROW EXECUTE FUNCTION public.rubygem_stats_calculation_month();


--
-- Name: categorizations fk_rails_1c87ed593b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categorizations
    ADD CONSTRAINT fk_rails_1c87ed593b FOREIGN KEY (category_permalink) REFERENCES public.categories(permalink);


--
-- Name: categorizations fk_rails_2f82cbb022; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categorizations
    ADD CONSTRAINT fk_rails_2f82cbb022 FOREIGN KEY (project_permalink) REFERENCES public.projects(permalink);


--
-- Name: categories fk_rails_4bd2d3273a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT fk_rails_4bd2d3273a FOREIGN KEY (category_group_permalink) REFERENCES public.category_groups(permalink);


--
-- Name: rubygem_dependencies fk_rails_7b157253c8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rubygem_dependencies
    ADD CONSTRAINT fk_rails_7b157253c8 FOREIGN KEY (rubygem_name) REFERENCES public.rubygems(name);


--
-- Name: rubygem_trends fk_rails_8a29c552ee; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rubygem_trends
    ADD CONSTRAINT fk_rails_8a29c552ee FOREIGN KEY (rubygem_name) REFERENCES public.rubygems(name);


--
-- Name: active_storage_variant_records fk_rails_993965df05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT fk_rails_993965df05 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: rubygem_trends fk_rails_ac818cf2a2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rubygem_trends
    ADD CONSTRAINT fk_rails_ac818cf2a2 FOREIGN KEY (rubygem_download_stat_id) REFERENCES public.rubygem_download_stats(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: rubygem_download_stats fk_rails_c4eb80d594; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rubygem_download_stats
    ADD CONSTRAINT fk_rails_c4eb80d594 FOREIGN KEY (rubygem_name) REFERENCES public.rubygems(name);


--
-- Name: rubygem_code_statistics fk_rails_d2e8b78455; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rubygem_code_statistics
    ADD CONSTRAINT fk_rails_d2e8b78455 FOREIGN KEY (rubygem_name) REFERENCES public.rubygems(name);


--
-- Name: projects fk_rails_ddb4eb0108; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT fk_rails_ddb4eb0108 FOREIGN KEY (rubygem_name) REFERENCES public.rubygems(name);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20240412142913'),
('20240412142709'),
('20211210110108'),
('20210531194507'),
('20210531193907'),
('20210228234343'),
('20200830205823'),
('20190730194020'),
('20190508190527'),
('20190228102103'),
('20190228101125'),
('20190226090403'),
('20190226090240'),
('20190220133053'),
('20190218131324'),
('20190211104231'),
('20190207133425'),
('20190204132920'),
('20190121165354'),
('20190117101723'),
('20190117100816'),
('20190110202221'),
('20181213102703'),
('20181210092238'),
('20181205134522'),
('20180718195202'),
('20180322231848'),
('20180322231205'),
('20180221214013'),
('20180127211755'),
('20180127203832'),
('20180126214714'),
('20180126213034'),
('20180118191419'),
('20180114223052'),
('20180105234511'),
('20180104223026'),
('20180103233845'),
('20180103194335'),
('20180103193038'),
('20171230223928'),
('20171028210534'),
('20171026221717'),
('20171026220117'),
('20171026202351'),
('20171026191745');


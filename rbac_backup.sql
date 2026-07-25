--
-- PostgreSQL database dump
--

\restrict Fy7sC9khtKJ3VcNgwurCTPPhgVeVfXBglh51R0qvRvf3111dAWAp1Wz9wTe8CWy

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: academic_periods; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.academic_periods (
    id bigint NOT NULL,
    name text NOT NULL,
    start_date timestamp with time zone NOT NULL,
    end_date timestamp with time zone NOT NULL,
    grading_open timestamp with time zone NOT NULL,
    grading_close timestamp with time zone NOT NULL,
    is_active boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.academic_periods OWNER TO postgres;

--
-- Name: academic_periods_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.academic_periods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.academic_periods_id_seq OWNER TO postgres;

--
-- Name: academic_periods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.academic_periods_id_seq OWNED BY public.academic_periods.id;


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_logs (
    id bigint NOT NULL,
    actor_user_id bigint,
    action text NOT NULL,
    resource_type text,
    resource_id text,
    outcome text NOT NULL,
    reason text,
    ip_address text,
    user_agent text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_id bigint,
    resource text,
    deny_reason text,
    request_path text,
    "timestamp" timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.audit_logs OWNER TO postgres;

--
-- Name: audit_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.audit_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.audit_logs_id_seq OWNER TO postgres;

--
-- Name: audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.audit_logs_id_seq OWNED BY public.audit_logs.id;


--
-- Name: context_policies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.context_policies (
    id bigint NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    resource text NOT NULL,
    action text NOT NULL,
    condition jsonb NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.context_policies OWNER TO postgres;

--
-- Name: context_policies_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.context_policies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.context_policies_id_seq OWNER TO postgres;

--
-- Name: context_policies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.context_policies_id_seq OWNED BY public.context_policies.id;


--
-- Name: courses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.courses (
    id bigint NOT NULL,
    code text NOT NULL,
    title text NOT NULL,
    lecturer_id bigint,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    credits integer DEFAULT 3 NOT NULL,
    department_id bigint,
    academic_period_id bigint,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.courses OWNER TO postgres;

--
-- Name: courses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.courses_id_seq OWNER TO postgres;

--
-- Name: courses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.courses_id_seq OWNED BY public.courses.id;


--
-- Name: departments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.departments (
    id bigint NOT NULL,
    name text NOT NULL,
    code text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.departments OWNER TO postgres;

--
-- Name: departments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.departments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.departments_id_seq OWNER TO postgres;

--
-- Name: departments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.departments_id_seq OWNED BY public.departments.id;


--
-- Name: enrollments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.enrollments (
    id bigint NOT NULL,
    student_id bigint NOT NULL,
    course_id bigint NOT NULL,
    enrolled_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.enrollments OWNER TO postgres;

--
-- Name: enrollments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.enrollments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.enrollments_id_seq OWNER TO postgres;

--
-- Name: enrollments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.enrollments_id_seq OWNED BY public.enrollments.id;


--
-- Name: grades; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.grades (
    id bigint NOT NULL,
    student_id bigint NOT NULL,
    course_id bigint NOT NULL,
    submitter_id bigint CONSTRAINT grades_submitted_by_not_null NOT NULL,
    score numeric(5,2) NOT NULL,
    grade text,
    remarks text,
    submitted_at timestamp with time zone DEFAULT now() NOT NULL,
    approver_id bigint,
    status text DEFAULT 'DRAFT'::text NOT NULL,
    approved_at timestamp with time zone,
    CONSTRAINT grades_score_check CHECK (((score >= (0)::numeric) AND (score <= (100)::numeric)))
);


ALTER TABLE public.grades OWNER TO postgres;

--
-- Name: grades_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.grades_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.grades_id_seq OWNER TO postgres;

--
-- Name: grades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.grades_id_seq OWNED BY public.grades.id;


--
-- Name: grading_periods; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.grading_periods (
    id bigint NOT NULL,
    course_id bigint NOT NULL,
    starts_at timestamp with time zone NOT NULL,
    ends_at timestamp with time zone NOT NULL,
    is_active boolean DEFAULT false NOT NULL,
    CONSTRAINT grading_periods_check CHECK ((ends_at > starts_at))
);


ALTER TABLE public.grading_periods OWNER TO postgres;

--
-- Name: grading_periods_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.grading_periods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.grading_periods_id_seq OWNER TO postgres;

--
-- Name: grading_periods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.grading_periods_id_seq OWNED BY public.grading_periods.id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.permissions (
    id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    resource text NOT NULL,
    action text NOT NULL,
    description text
);


ALTER TABLE public.permissions OWNER TO postgres;

--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.permissions_id_seq OWNER TO postgres;

--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.permissions_id_seq OWNED BY public.permissions.id;


--
-- Name: role_conflicts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role_conflicts (
    role_id bigint NOT NULL,
    conflicting_role_id bigint NOT NULL
);


ALTER TABLE public.role_conflicts OWNER TO postgres;

--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role_permissions (
    role_id bigint NOT NULL,
    permission_id bigint NOT NULL
);


ALTER TABLE public.role_permissions OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    description text
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_id_seq OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: separation_of_duty_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.separation_of_duty_logs (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    violation text NOT NULL,
    attempted text NOT NULL,
    blocked boolean DEFAULT true NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.separation_of_duty_logs OWNER TO postgres;

--
-- Name: separation_of_duty_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.separation_of_duty_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.separation_of_duty_logs_id_seq OWNER TO postgres;

--
-- Name: separation_of_duty_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.separation_of_duty_logs_id_seq OWNED BY public.separation_of_duty_logs.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sessions (
    id uuid NOT NULL,
    user_id bigint NOT NULL,
    refresh_token text NOT NULL,
    ip_address text,
    user_agent text,
    is_revoked boolean DEFAULT false NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.sessions OWNER TO postgres;

--
-- Name: system_state; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.system_state (
    id smallint DEFAULT 1 NOT NULL,
    emergency_lockout_active boolean DEFAULT false NOT NULL,
    policy_config jsonb NOT NULL
);


ALTER TABLE public.system_state OWNER TO postgres;

--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_roles (
    user_id bigint NOT NULL,
    role_id bigint NOT NULL,
    assigned_at timestamp with time zone DEFAULT now() NOT NULL,
    assigned_by bigint
);


ALTER TABLE public.user_roles OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email text NOT NULL,
    password_hash text NOT NULL,
    full_name text NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    role_id bigint NOT NULL,
    student_id text,
    staff_id text,
    department text,
    failed_logins integer DEFAULT 0 NOT NULL,
    locked_until timestamp with time zone,
    last_login timestamp with time zone,
    last_login_ip text,
    office_location text,
    consultation_hours text
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: academic_periods id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.academic_periods ALTER COLUMN id SET DEFAULT nextval('public.academic_periods_id_seq'::regclass);


--
-- Name: audit_logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs ALTER COLUMN id SET DEFAULT nextval('public.audit_logs_id_seq'::regclass);


--
-- Name: context_policies id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.context_policies ALTER COLUMN id SET DEFAULT nextval('public.context_policies_id_seq'::regclass);


--
-- Name: courses id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.courses ALTER COLUMN id SET DEFAULT nextval('public.courses_id_seq'::regclass);


--
-- Name: departments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments ALTER COLUMN id SET DEFAULT nextval('public.departments_id_seq'::regclass);


--
-- Name: enrollments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments ALTER COLUMN id SET DEFAULT nextval('public.enrollments_id_seq'::regclass);


--
-- Name: grades id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grades ALTER COLUMN id SET DEFAULT nextval('public.grades_id_seq'::regclass);


--
-- Name: grading_periods id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grading_periods ALTER COLUMN id SET DEFAULT nextval('public.grading_periods_id_seq'::regclass);


--
-- Name: permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions ALTER COLUMN id SET DEFAULT nextval('public.permissions_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: separation_of_duty_logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.separation_of_duty_logs ALTER COLUMN id SET DEFAULT nextval('public.separation_of_duty_logs_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: academic_periods; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.academic_periods (id, name, start_date, end_date, grading_open, grading_close, is_active, created_at) FROM stdin;
1	Semester 2, 2025/2026	2026-01-05 00:00:00+00	2026-06-30 23:59:59.999+00	2026-05-01 00:00:00+00	2026-06-30 23:59:59.999+00	t	2026-06-24 12:00:43.940183+00
2	Semester 1, 2025/2026	2025-08-25 00:00:00+00	2025-12-15 23:59:59.999+00	2025-12-01 00:00:00+00	2025-12-10 23:59:59.999+00	f	2026-06-24 12:00:43.940183+00
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit_logs (id, actor_user_id, action, resource_type, resource_id, outcome, reason, ip_address, user_agent, metadata, created_at, user_id, resource, deny_reason, request_path, "timestamp") FROM stdin;
1	\N	approve	\N	\N	DENIED_SOD	\N	::1	\N	{"layer": "SOD"}	2026-06-24 12:11:34.53183+00	1	grades	SEPARATION_OF_DUTY_VIOLATION	\N	2026-06-24 12:11:34.53183+00
2	\N	approve	\N	\N	DENIED_SOD	\N	::1	\N	{"layer": "SOD"}	2026-06-24 12:11:34.58329+00	1	grades	SEPARATION_OF_DUTY_VIOLATION	\N	2026-06-24 12:11:34.58329+00
3	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 12:11:34.679781+00	1	users	\N	\N	2026-06-24 12:11:34.679781+00
4	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 12:11:34.680785+00	1	audit	\N	\N	2026-06-24 12:11:34.680785+00
5	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 12:11:34.746205+00	1	audit	\N	\N	2026-06-24 12:11:34.746205+00
6	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 12:11:34.803543+00	1	users	\N	\N	2026-06-24 12:11:34.803543+00
7	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 12:12:03.371396+00	1	users	\N	\N	2026-06-24 12:12:03.371396+00
8	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 12:12:03.403612+00	1	users	\N	\N	2026-06-24 12:12:03.403612+00
9	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 12:12:15.822786+00	1	users	\N	\N	2026-06-24 12:12:15.822786+00
10	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:12:15.852286+00	1	sessions	SESSION_EXPIRED	/	2026-06-24 12:12:15.852286+00
11	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:12:17.987763+00	1	sessions	SESSION_EXPIRED	/access-matrix	2026-06-24 12:12:17.987763+00
12	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:12:18.001717+00	1	sessions	SESSION_EXPIRED	/access-matrix	2026-06-24 12:12:18.001717+00
13	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:12:23.195666+00	1	sessions	SESSION_EXPIRED	/	2026-06-24 12:12:23.195666+00
14	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:12:23.197705+00	1	sessions	SESSION_EXPIRED	/stats	2026-06-24 12:12:23.197705+00
15	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:12:23.383156+00	1	sessions	SESSION_EXPIRED	/	2026-06-24 12:12:23.383156+00
16	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:12:23.398998+00	1	sessions	SESSION_EXPIRED	/stats	2026-06-24 12:12:23.398998+00
17	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:12:29.818937+00	1	sessions	SESSION_EXPIRED	/access-matrix	2026-06-24 12:12:29.818937+00
18	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:12:29.81961+00	1	sessions	SESSION_EXPIRED	/stats	2026-06-24 12:12:29.81961+00
19	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:12:29.890679+00	1	sessions	SESSION_EXPIRED	/access-matrix	2026-06-24 12:12:29.890679+00
20	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:12:29.891848+00	1	sessions	SESSION_EXPIRED	/stats	2026-06-24 12:12:29.891848+00
21	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:12:33.299387+00	1	sessions	SESSION_EXPIRED	/access-matrix	2026-06-24 12:12:33.299387+00
22	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:12:33.300146+00	1	sessions	SESSION_EXPIRED	/stats	2026-06-24 12:12:33.300146+00
23	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:12:43.819808+00	1	sessions	SESSION_EXPIRED	/stats	2026-06-24 12:12:43.819808+00
24	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:12:43.853157+00	1	sessions	SESSION_EXPIRED	/security-events	2026-06-24 12:12:43.853157+00
25	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:12:43.894997+00	1	sessions	SESSION_EXPIRED	/grades/pending	2026-06-24 12:12:43.894997+00
26	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:12:43.898991+00	1	sessions	SESSION_EXPIRED	/security-events	2026-06-24 12:12:43.898991+00
27	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:12:43.939723+00	1	sessions	SESSION_EXPIRED	/grades/pending	2026-06-24 12:12:43.939723+00
28	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:12:43.994091+00	1	sessions	SESSION_EXPIRED	/stats	2026-06-24 12:12:43.994091+00
30	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:12:51.476955+00	1	sessions	SESSION_EXPIRED	/stats	2026-06-24 12:12:51.476955+00
31	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:12:51.47758+00	1	sessions	SESSION_EXPIRED	/security-events	2026-06-24 12:12:51.47758+00
29	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:12:51.476339+00	1	sessions	SESSION_EXPIRED	/grades/pending	2026-06-24 12:12:51.476339+00
32	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:12:51.513233+00	1	sessions	SESSION_EXPIRED	/stats	2026-06-24 12:12:51.513233+00
33	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:12:51.513817+00	1	sessions	SESSION_EXPIRED	/security-events	2026-06-24 12:12:51.513817+00
34	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:12:51.514449+00	1	sessions	SESSION_EXPIRED	/grades/pending	2026-06-24 12:12:51.514449+00
35	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:13:00.582981+00	1	sessions	SESSION_EXPIRED	/access-matrix	2026-06-24 12:13:00.582981+00
36	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:13:00.583648+00	1	sessions	SESSION_EXPIRED	/stats	2026-06-24 12:13:00.583648+00
37	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:13:00.648409+00	1	sessions	SESSION_EXPIRED	/access-matrix	2026-06-24 12:13:00.648409+00
38	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:13:00.649021+00	1	sessions	SESSION_EXPIRED	/stats	2026-06-24 12:13:00.649021+00
40	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:13:01.61918+00	1	sessions	SESSION_EXPIRED	/stats	2026-06-24 12:13:01.61918+00
55	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:13:08.394928+00	1	sessions	SESSION_EXPIRED	/security-events	2026-06-24 12:13:08.394928+00
39	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:13:01.618691+00	1	sessions	SESSION_EXPIRED	/	2026-06-24 12:13:01.618691+00
44	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:13:02.603242+00	1	sessions	SESSION_EXPIRED	/access-matrix	2026-06-24 12:13:02.603242+00
45	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:13:03.574227+00	1	sessions	SESSION_EXPIRED	/	2026-06-24 12:13:03.574227+00
41	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:13:01.653031+00	1	sessions	SESSION_EXPIRED	/stats	2026-06-24 12:13:01.653031+00
42	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:13:01.689186+00	1	sessions	SESSION_EXPIRED	/	2026-06-24 12:13:01.689186+00
43	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:13:02.562996+00	1	sessions	SESSION_EXPIRED	/access-matrix	2026-06-24 12:13:02.562996+00
46	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:13:03.576878+00	1	sessions	SESSION_EXPIRED	/stats	2026-06-24 12:13:03.576878+00
47	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:13:03.615002+00	1	sessions	SESSION_EXPIRED	/	2026-06-24 12:13:03.615002+00
49	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:13:05.292954+00	1	sessions	SESSION_EXPIRED	/access-matrix	2026-06-24 12:13:05.292954+00
52	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:13:06.175022+00	1	sessions	SESSION_EXPIRED	/	2026-06-24 12:13:06.175022+00
53	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:13:08.392622+00	1	sessions	SESSION_EXPIRED	/grades/pending	2026-06-24 12:13:08.392622+00
48	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:13:03.617783+00	1	sessions	SESSION_EXPIRED	/stats	2026-06-24 12:13:03.617783+00
50	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:13:05.319484+00	1	sessions	SESSION_EXPIRED	/access-matrix	2026-06-24 12:13:05.319484+00
51	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:13:06.139723+00	1	sessions	SESSION_EXPIRED	/	2026-06-24 12:13:06.139723+00
54	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 12:13:08.39358+00	1	sessions	SESSION_EXPIRED	/stats	2026-06-24 12:13:08.39358+00
56	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:23:36.116683+00	1	users	\N	\N	2026-06-24 13:23:36.116683+00
57	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:23:36.240282+00	1	users	\N	\N	2026-06-24 13:23:36.240282+00
58	\N	approve	\N	\N	DENIED_SOD	\N	::1	\N	{"layer": "SOD"}	2026-06-24 13:23:36.310955+00	1	grades	SEPARATION_OF_DUTY_VIOLATION	\N	2026-06-24 13:23:36.310955+00
60	\N	approve	\N	\N	DENIED_SOD	\N	::1	\N	{"layer": "SOD"}	2026-06-24 13:23:36.344032+00	1	grades	SEPARATION_OF_DUTY_VIOLATION	\N	2026-06-24 13:23:36.344032+00
59	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:23:36.343083+00	1	audit	\N	\N	2026-06-24 13:23:36.343083+00
61	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:23:36.384182+00	1	audit	\N	\N	2026-06-24 13:23:36.384182+00
62	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:23:41.636531+00	1	users	\N	\N	2026-06-24 13:23:41.636531+00
63	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:23:41.637285+00	1	audit	\N	\N	2026-06-24 13:23:41.637285+00
64	\N	approve	\N	\N	DENIED_SOD	\N	::1	\N	{"layer": "SOD"}	2026-06-24 13:23:41.646091+00	1	grades	SEPARATION_OF_DUTY_VIOLATION	\N	2026-06-24 13:23:41.646091+00
65	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:23:41.684757+00	1	audit	\N	\N	2026-06-24 13:23:41.684757+00
66	\N	approve	\N	\N	DENIED_SOD	\N	::1	\N	{"layer": "SOD"}	2026-06-24 13:23:41.699414+00	1	grades	SEPARATION_OF_DUTY_VIOLATION	\N	2026-06-24 13:23:41.699414+00
67	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:23:41.730411+00	1	users	\N	\N	2026-06-24 13:23:41.730411+00
68	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:24:05.129977+00	1	users	\N	\N	2026-06-24 13:24:05.129977+00
69	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:24:05.163596+00	1	users	\N	\N	2026-06-24 13:24:05.163596+00
70	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:24:06.383651+00	1	users	\N	\N	2026-06-24 13:24:06.383651+00
71	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:24:06.415308+00	1	users	\N	\N	2026-06-24 13:24:06.415308+00
72	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:24:07.558272+00	1	audit	\N	\N	2026-06-24 13:24:07.558272+00
73	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:24:07.626742+00	1	audit	\N	\N	2026-06-24 13:24:07.626742+00
74	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:24:07.682586+00	1	audit	\N	\N	2026-06-24 13:24:07.682586+00
75	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:24:07.719544+00	1	audit	\N	\N	2026-06-24 13:24:07.719544+00
76	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:24:08.437167+00	1	users	\N	\N	2026-06-24 13:24:08.437167+00
77	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:24:08.437869+00	1	users	\N	\N	2026-06-24 13:24:08.437869+00
78	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:24:08.507355+00	1	users	\N	\N	2026-06-24 13:24:08.507355+00
79	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:24:08.508085+00	1	users	\N	\N	2026-06-24 13:24:08.508085+00
80	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:24:11.65967+00	1	users	\N	\N	2026-06-24 13:24:11.65967+00
81	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:24:11.661069+00	1	audit	\N	\N	2026-06-24 13:24:11.661069+00
82	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:24:11.744097+00	1	audit	\N	\N	2026-06-24 13:24:11.744097+00
83	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:24:11.744789+00	1	users	\N	\N	2026-06-24 13:24:11.744789+00
84	\N	approve	\N	\N	DENIED_SOD	\N	::1	\N	{"layer": "SOD"}	2026-06-24 13:24:11.858007+00	1	grades	SEPARATION_OF_DUTY_VIOLATION	\N	2026-06-24 13:24:11.858007+00
85	\N	approve	\N	\N	DENIED_SOD	\N	::1	\N	{"layer": "SOD"}	2026-06-24 13:24:11.879662+00	1	grades	SEPARATION_OF_DUTY_VIOLATION	\N	2026-06-24 13:24:11.879662+00
86	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:24:43.966388+00	1	users	\N	\N	2026-06-24 13:24:43.966388+00
87	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:24:43.994643+00	1	users	\N	\N	2026-06-24 13:24:43.994643+00
88	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:24:45.990354+00	1	users	\N	\N	2026-06-24 13:24:45.990354+00
89	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:29:26.446062+00	1	users	\N	\N	2026-06-24 13:29:26.446062+00
90	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:29:26.57041+00	1	users	\N	\N	2026-06-24 13:29:26.57041+00
91	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:29:34.137309+00	1	users	\N	\N	2026-06-24 13:29:34.137309+00
92	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:29:40.043434+00	1	periods	\N	\N	2026-06-24 13:29:40.043434+00
93	\N	write	\N	policy-config	GRANTED	\N	::1	\N	{"layer": "ALL", "message": "Global Access Control policy redeployed"}	2026-06-24 13:29:40.047816+00	1	periods	\N	\N	2026-06-24 13:29:40.047816+00
94	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:29:40.071771+00	1	users	\N	\N	2026-06-24 13:29:40.071771+00
95	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:38:22.395919+00	1	users	\N	\N	2026-06-24 13:38:22.395919+00
96	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:38:22.430244+00	1	users	\N	\N	2026-06-24 13:38:22.430244+00
97	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:00.947041+00	1	users	\N	\N	2026-06-24 13:39:00.947041+00
98	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:01.934711+00	1	users	\N	\N	2026-06-24 13:39:01.934711+00
99	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:14.965436+00	1	users	\N	\N	2026-06-24 13:39:14.965436+00
100	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:15.024033+00	1	users	\N	\N	2026-06-24 13:39:15.024033+00
101	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:16.023579+00	1	users	\N	\N	2026-06-24 13:39:16.023579+00
102	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:16.060705+00	1	users	\N	\N	2026-06-24 13:39:16.060705+00
103	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:16.616249+00	1	users	\N	\N	2026-06-24 13:39:16.616249+00
104	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:16.636265+00	1	users	\N	\N	2026-06-24 13:39:16.636265+00
105	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:17.403856+00	1	users	\N	\N	2026-06-24 13:39:17.403856+00
106	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:17.430783+00	1	users	\N	\N	2026-06-24 13:39:17.430783+00
107	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:18.135496+00	1	users	\N	\N	2026-06-24 13:39:18.135496+00
108	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:18.173629+00	1	users	\N	\N	2026-06-24 13:39:18.173629+00
109	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:18.859065+00	1	users	\N	\N	2026-06-24 13:39:18.859065+00
110	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:18.89037+00	1	users	\N	\N	2026-06-24 13:39:18.89037+00
111	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:25.955421+00	1	users	\N	\N	2026-06-24 13:39:25.955421+00
112	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:25.983321+00	1	users	\N	\N	2026-06-24 13:39:25.983321+00
113	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:28.697901+00	1	users	\N	\N	2026-06-24 13:39:28.697901+00
114	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:28.72202+00	1	users	\N	\N	2026-06-24 13:39:28.72202+00
115	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:31.983702+00	1	users	\N	\N	2026-06-24 13:39:31.983702+00
116	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:32.020122+00	1	users	\N	\N	2026-06-24 13:39:32.020122+00
117	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:32.990909+00	1	users	\N	\N	2026-06-24 13:39:32.990909+00
118	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:33.023663+00	1	users	\N	\N	2026-06-24 13:39:33.023663+00
119	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:35.112736+00	1	users	\N	\N	2026-06-24 13:39:35.112736+00
120	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:35.138128+00	1	users	\N	\N	2026-06-24 13:39:35.138128+00
121	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:36.054552+00	1	users	\N	\N	2026-06-24 13:39:36.054552+00
122	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:36.080308+00	1	users	\N	\N	2026-06-24 13:39:36.080308+00
123	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:37.181727+00	1	users	\N	\N	2026-06-24 13:39:37.181727+00
124	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:37.227433+00	1	users	\N	\N	2026-06-24 13:39:37.227433+00
125	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:38.6849+00	1	users	\N	\N	2026-06-24 13:39:38.6849+00
126	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:38.71444+00	1	users	\N	\N	2026-06-24 13:39:38.71444+00
127	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:40.132317+00	1	users	\N	\N	2026-06-24 13:39:40.132317+00
128	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:40.155765+00	1	users	\N	\N	2026-06-24 13:39:40.155765+00
129	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:41.193429+00	1	users	\N	\N	2026-06-24 13:39:41.193429+00
130	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:41.214877+00	1	users	\N	\N	2026-06-24 13:39:41.214877+00
131	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:42.159923+00	1	users	\N	\N	2026-06-24 13:39:42.159923+00
132	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:42.180955+00	1	users	\N	\N	2026-06-24 13:39:42.180955+00
133	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:42.994153+00	1	users	\N	\N	2026-06-24 13:39:42.994153+00
134	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:43.032497+00	1	users	\N	\N	2026-06-24 13:39:43.032497+00
135	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:43.76358+00	1	users	\N	\N	2026-06-24 13:39:43.76358+00
136	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:43.781618+00	1	users	\N	\N	2026-06-24 13:39:43.781618+00
137	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:49.660751+00	1	users	\N	\N	2026-06-24 13:39:49.660751+00
138	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:39:50.559852+00	1	users	\N	\N	2026-06-24 13:39:50.559852+00
139	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:41:18.994698+00	1	users	\N	\N	2026-06-24 13:41:18.994698+00
140	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:46:41.494002+00	1	users	\N	\N	2026-06-24 13:46:41.494002+00
141	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:54:52.27388+00	1	users	\N	\N	2026-06-24 13:54:52.27388+00
142	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:54:55.835779+00	1	users	\N	\N	2026-06-24 13:54:55.835779+00
143	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 13:54:55.872224+00	1	sessions	SESSION_EXPIRED	/	2026-06-24 13:54:55.872224+00
144	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-24 13:54:56.76013+00	1	sessions	SESSION_EXPIRED	/1	2026-06-24 13:54:56.76013+00
145	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:58:46.875587+00	1	users	\N	\N	2026-06-24 13:58:46.875587+00
146	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:58:46.98811+00	1	users	\N	\N	2026-06-24 13:58:46.98811+00
147	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:58:47.042496+00	1	audit	\N	\N	2026-06-24 13:58:47.042496+00
148	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 13:58:47.077494+00	1	audit	\N	\N	2026-06-24 13:58:47.077494+00
149	\N	approve	\N	\N	DENIED_SOD	\N	::1	\N	{"layer": "SOD"}	2026-06-24 13:58:47.086463+00	1	grades	SEPARATION_OF_DUTY_VIOLATION	\N	2026-06-24 13:58:47.086463+00
150	\N	approve	\N	\N	DENIED_SOD	\N	::1	\N	{"layer": "SOD"}	2026-06-24 13:58:47.129801+00	1	grades	SEPARATION_OF_DUTY_VIOLATION	\N	2026-06-24 13:58:47.129801+00
151	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:25.366762+00	1	users	\N	\N	2026-06-24 15:36:25.366762+00
152	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:25.484952+00	1	users	\N	\N	2026-06-24 15:36:25.484952+00
153	\N	approve	\N	\N	DENIED_SOD	\N	::1	\N	{"layer": "SOD"}	2026-06-24 15:36:25.578846+00	1	grades	SEPARATION_OF_DUTY_VIOLATION	\N	2026-06-24 15:36:25.578846+00
154	\N	approve	\N	\N	DENIED_SOD	\N	::1	\N	{"layer": "SOD"}	2026-06-24 15:36:25.608898+00	1	grades	SEPARATION_OF_DUTY_VIOLATION	\N	2026-06-24 15:36:25.608898+00
155	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:25.636066+00	1	audit	\N	\N	2026-06-24 15:36:25.636066+00
156	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:25.678726+00	1	audit	\N	\N	2026-06-24 15:36:25.678726+00
157	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:30.487139+00	1	users	\N	\N	2026-06-24 15:36:30.487139+00
158	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:30.488931+00	1	users	\N	\N	2026-06-24 15:36:30.488931+00
159	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:30.542417+00	1	users	\N	\N	2026-06-24 15:36:30.542417+00
160	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:30.551188+00	1	users	\N	\N	2026-06-24 15:36:30.551188+00
161	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:32.711401+00	1	users	\N	\N	2026-06-24 15:36:32.711401+00
162	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:32.713232+00	1	audit	\N	\N	2026-06-24 15:36:32.713232+00
163	\N	approve	\N	\N	DENIED_SOD	\N	::1	\N	{"layer": "SOD"}	2026-06-24 15:36:32.732895+00	1	grades	SEPARATION_OF_DUTY_VIOLATION	\N	2026-06-24 15:36:32.732895+00
164	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:32.803766+00	1	audit	\N	\N	2026-06-24 15:36:32.803766+00
165	\N	approve	\N	\N	DENIED_SOD	\N	::1	\N	{"layer": "SOD"}	2026-06-24 15:36:32.822273+00	1	grades	SEPARATION_OF_DUTY_VIOLATION	\N	2026-06-24 15:36:32.822273+00
166	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:32.825867+00	1	users	\N	\N	2026-06-24 15:36:32.825867+00
167	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:35.525701+00	1	audit	\N	\N	2026-06-24 15:36:35.525701+00
168	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:35.526924+00	1	users	\N	\N	2026-06-24 15:36:35.526924+00
169	\N	approve	\N	\N	DENIED_SOD	\N	::1	\N	{"layer": "SOD"}	2026-06-24 15:36:35.565896+00	1	grades	SEPARATION_OF_DUTY_VIOLATION	\N	2026-06-24 15:36:35.565896+00
170	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:35.614491+00	1	audit	\N	\N	2026-06-24 15:36:35.614491+00
171	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:35.617551+00	1	users	\N	\N	2026-06-24 15:36:35.617551+00
172	\N	approve	\N	\N	DENIED_SOD	\N	::1	\N	{"layer": "SOD"}	2026-06-24 15:36:35.630746+00	1	grades	SEPARATION_OF_DUTY_VIOLATION	\N	2026-06-24 15:36:35.630746+00
173	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:45.399611+00	1	users	\N	\N	2026-06-24 15:36:45.399611+00
174	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:45.400165+00	1	users	\N	\N	2026-06-24 15:36:45.400165+00
175	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:45.457379+00	1	users	\N	\N	2026-06-24 15:36:45.457379+00
176	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:45.48486+00	1	users	\N	\N	2026-06-24 15:36:45.48486+00
177	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:47.79147+00	1	users	\N	\N	2026-06-24 15:36:47.79147+00
178	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:47.830027+00	1	audit	\N	\N	2026-06-24 15:36:47.830027+00
179	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:47.877692+00	1	users	\N	\N	2026-06-24 15:36:47.877692+00
180	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:47.910514+00	1	audit	\N	\N	2026-06-24 15:36:47.910514+00
181	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:48.616863+00	1	users	\N	\N	2026-06-24 15:36:48.616863+00
182	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:48.633988+00	1	users	\N	\N	2026-06-24 15:36:48.633988+00
183	\N	approve	\N	\N	DENIED_SOD	\N	::1	\N	{"layer": "SOD"}	2026-06-24 15:36:49.519356+00	1	grades	SEPARATION_OF_DUTY_VIOLATION	\N	2026-06-24 15:36:49.519356+00
184	\N	approve	\N	\N	DENIED_SOD	\N	::1	\N	{"layer": "SOD"}	2026-06-24 15:36:49.556094+00	1	grades	SEPARATION_OF_DUTY_VIOLATION	\N	2026-06-24 15:36:49.556094+00
185	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:49.68785+00	1	users	\N	\N	2026-06-24 15:36:49.68785+00
186	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:49.719572+00	1	users	\N	\N	2026-06-24 15:36:49.719572+00
187	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:50.704832+00	1	audit	\N	\N	2026-06-24 15:36:50.704832+00
188	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:50.733247+00	1	audit	\N	\N	2026-06-24 15:36:50.733247+00
189	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:50.74722+00	1	audit	\N	\N	2026-06-24 15:36:50.74722+00
190	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:50.785011+00	1	audit	\N	\N	2026-06-24 15:36:50.785011+00
191	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:51.676316+00	1	users	\N	\N	2026-06-24 15:36:51.676316+00
192	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:51.676872+00	1	users	\N	\N	2026-06-24 15:36:51.676872+00
193	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:51.724092+00	1	users	\N	\N	2026-06-24 15:36:51.724092+00
194	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:51.724647+00	1	users	\N	\N	2026-06-24 15:36:51.724647+00
195	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:52.733802+00	1	audit	\N	\N	2026-06-24 15:36:52.733802+00
196	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:52.732591+00	1	audit	\N	\N	2026-06-24 15:36:52.732591+00
197	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:52.772865+00	1	audit	\N	\N	2026-06-24 15:36:52.772865+00
198	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:36:52.794692+00	1	audit	\N	\N	2026-06-24 15:36:52.794692+00
199	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:37:37.143171+00	3	users	\N	\N	2026-06-24 15:37:37.143171+00
200	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:37:37.200549+00	3	users	\N	\N	2026-06-24 15:37:37.200549+00
201	\N	approve	\N	\N	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-06-24 15:37:37.300338+00	3	grades	NO_ACADEMIC_RELATIONSHIP	\N	2026-06-24 15:37:37.300338+00
202	\N	approve	\N	\N	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-06-24 15:37:37.31707+00	3	grades	NO_ACADEMIC_RELATIONSHIP	\N	2026-06-24 15:37:37.31707+00
203	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:37:37.318106+00	3	audit	\N	\N	2026-06-24 15:37:37.318106+00
204	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:37:37.354471+00	3	audit	\N	\N	2026-06-24 15:37:37.354471+00
205	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:37:54.975158+00	3	courses	\N	\N	2026-06-24 15:37:54.975158+00
206	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:37:55.001014+00	3	courses	\N	\N	2026-06-24 15:37:55.001014+00
207	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:38:04.104579+00	3	courses	\N	\N	2026-06-24 15:38:04.104579+00
208	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:38:04.128347+00	3	courses	\N	\N	2026-06-24 15:38:04.128347+00
209	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:38:05.258348+00	3	courses	\N	\N	2026-06-24 15:38:05.258348+00
210	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:38:05.283669+00	3	courses	\N	\N	2026-06-24 15:38:05.283669+00
211	\N	read	\N	3	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:38:05.38571+00	3	students	\N	\N	2026-06-24 15:38:05.38571+00
212	\N	read	\N	3	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:38:05.399877+00	3	grades	\N	\N	2026-06-24 15:38:05.399877+00
213	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:38:08.123817+00	3	courses	\N	\N	2026-06-24 15:38:08.123817+00
214	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:38:08.170675+00	3	courses	\N	\N	2026-06-24 15:38:08.170675+00
215	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:38:09.113237+00	3	courses	\N	\N	2026-06-24 15:38:09.113237+00
216	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:38:09.161911+00	3	courses	\N	\N	2026-06-24 15:38:09.161911+00
217	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:38:09.904225+00	3	courses	\N	\N	2026-06-24 15:38:09.904225+00
218	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:38:09.926559+00	3	courses	\N	\N	2026-06-24 15:38:09.926559+00
219	\N	read	\N	3	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:38:09.978511+00	3	students	\N	\N	2026-06-24 15:38:09.978511+00
220	\N	read	\N	3	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:38:09.98039+00	3	grades	\N	\N	2026-06-24 15:38:09.98039+00
221	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:38:14.036453+00	3	courses	\N	\N	2026-06-24 15:38:14.036453+00
222	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:38:14.088717+00	3	courses	\N	\N	2026-06-24 15:38:14.088717+00
223	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:40:45.622223+00	3	courses	\N	\N	2026-06-24 15:40:45.622223+00
224	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:40:45.700432+00	3	courses	\N	\N	2026-06-24 15:40:45.700432+00
225	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:43:51.613062+00	3	courses	\N	\N	2026-06-24 15:43:51.613062+00
226	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:43:51.697967+00	3	courses	\N	\N	2026-06-24 15:43:51.697967+00
227	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:43:53.168161+00	3	courses	\N	\N	2026-06-24 15:43:53.168161+00
228	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:43:53.211229+00	3	courses	\N	\N	2026-06-24 15:43:53.211229+00
229	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:43:56.669767+00	3	courses	\N	\N	2026-06-24 15:43:56.669767+00
230	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:43:56.692431+00	3	courses	\N	\N	2026-06-24 15:43:56.692431+00
231	\N	read	\N	3	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:43:56.760103+00	3	students	\N	\N	2026-06-24 15:43:56.760103+00
232	\N	read	\N	3	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:43:56.781433+00	3	grades	\N	\N	2026-06-24 15:43:56.781433+00
233	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:43:59.96221+00	3	courses	\N	\N	2026-06-24 15:43:59.96221+00
234	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:43:59.999097+00	3	courses	\N	\N	2026-06-24 15:43:59.999097+00
235	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:44:00.929208+00	3	courses	\N	\N	2026-06-24 15:44:00.929208+00
236	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 15:44:00.969732+00	3	courses	\N	\N	2026-06-24 15:44:00.969732+00
237	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:13:53.974044+00	7	grades	\N	\N	2026-06-24 16:13:53.974044+00
238	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:13:54.084206+00	7	grades	\N	\N	2026-06-24 16:13:54.084206+00
239	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:13:54.118701+00	7	enrollments	\N	\N	2026-06-24 16:13:54.118701+00
240	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:13:54.147235+00	7	enrollments	\N	\N	2026-06-24 16:13:54.147235+00
241	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:13:54.242076+00	7	grades	\N	\N	2026-06-24 16:13:54.242076+00
242	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:13:54.284028+00	7	grades	\N	\N	2026-06-24 16:13:54.284028+00
243	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:46:08.134036+00	3	courses	\N	\N	2026-06-24 16:46:08.134036+00
244	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:46:08.19315+00	3	courses	\N	\N	2026-06-24 16:46:08.19315+00
245	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:46:11.785421+00	3	courses	\N	\N	2026-06-24 16:46:11.785421+00
246	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:46:11.807119+00	3	courses	\N	\N	2026-06-24 16:46:11.807119+00
247	\N	read	\N	3	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:46:11.912965+00	3	students	\N	\N	2026-06-24 16:46:11.912965+00
248	\N	read	\N	3	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:46:11.918459+00	3	grades	\N	\N	2026-06-24 16:46:11.918459+00
249	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:46:14.529608+00	3	courses	\N	\N	2026-06-24 16:46:14.529608+00
254	\N	read	\N	3	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:46:17.597747+00	3	grades	\N	\N	2026-06-24 16:46:17.597747+00
255	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:46:19.221274+00	3	courses	\N	\N	2026-06-24 16:46:19.221274+00
258	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:46:21.470174+00	3	courses	\N	\N	2026-06-24 16:46:21.470174+00
262	\N	read	\N	3	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:46:22.571238+00	3	grades	\N	\N	2026-06-24 16:46:22.571238+00
264	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:46:26.437524+00	3	courses	\N	\N	2026-06-24 16:46:26.437524+00
265	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:46:27.414191+00	3	courses	\N	\N	2026-06-24 16:46:27.414191+00
266	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:46:27.438211+00	3	courses	\N	\N	2026-06-24 16:46:27.438211+00
267	\N	read	\N	3	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:46:27.481444+00	3	students	\N	\N	2026-06-24 16:46:27.481444+00
250	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:46:14.569367+00	3	courses	\N	\N	2026-06-24 16:46:14.569367+00
251	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:46:17.533903+00	3	courses	\N	\N	2026-06-24 16:46:17.533903+00
252	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:46:17.55703+00	3	courses	\N	\N	2026-06-24 16:46:17.55703+00
253	\N	read	\N	3	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:46:17.594909+00	3	students	\N	\N	2026-06-24 16:46:17.594909+00
256	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:46:19.279449+00	3	courses	\N	\N	2026-06-24 16:46:19.279449+00
257	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:46:21.430783+00	3	courses	\N	\N	2026-06-24 16:46:21.430783+00
259	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:46:22.494582+00	3	courses	\N	\N	2026-06-24 16:46:22.494582+00
260	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:46:22.523443+00	3	courses	\N	\N	2026-06-24 16:46:22.523443+00
261	\N	read	\N	3	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:46:22.56691+00	3	students	\N	\N	2026-06-24 16:46:22.56691+00
263	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:46:26.397527+00	3	courses	\N	\N	2026-06-24 16:46:26.397527+00
268	\N	read	\N	3	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:46:27.487469+00	3	grades	\N	\N	2026-06-24 16:46:27.487469+00
269	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:52:51.965617+00	3	courses	\N	\N	2026-06-24 16:52:51.965617+00
270	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:52:52.009778+00	3	courses	\N	\N	2026-06-24 16:52:52.009778+00
271	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:52:52.901841+00	3	courses	\N	\N	2026-06-24 16:52:52.901841+00
272	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:52:52.951555+00	3	courses	\N	\N	2026-06-24 16:52:52.951555+00
273	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:54:16.590838+00	2	courses	\N	\N	2026-06-24 16:54:16.590838+00
274	\N	write	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:55:34.857698+00	2	grades	\N	\N	2026-06-24 16:55:34.857698+00
275	\N	submit	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:55:34.882951+00	2	grades	\N	\N	2026-06-24 16:55:34.882951+00
276	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:55:34.902437+00	2	grades	\N	\N	2026-06-24 16:55:34.902437+00
277	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:58:27.209755+00	3	courses	\N	\N	2026-06-24 16:58:27.209755+00
278	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:58:27.264223+00	3	courses	\N	\N	2026-06-24 16:58:27.264223+00
279	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:58:28.979009+00	3	courses	\N	\N	2026-06-24 16:58:28.979009+00
280	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:58:29.040948+00	3	courses	\N	\N	2026-06-24 16:58:29.040948+00
281	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:58:42.152486+00	3	courses	\N	\N	2026-06-24 16:58:42.152486+00
282	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:58:42.178669+00	3	courses	\N	\N	2026-06-24 16:58:42.178669+00
283	\N	read	\N	3	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:58:42.229911+00	3	grades	\N	\N	2026-06-24 16:58:42.229911+00
284	\N	read	\N	3	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:58:42.292043+00	3	students	\N	\N	2026-06-24 16:58:42.292043+00
285	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:58:43.968239+00	3	courses	\N	\N	2026-06-24 16:58:43.968239+00
286	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:58:44.009509+00	3	courses	\N	\N	2026-06-24 16:58:44.009509+00
287	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:58:45.226911+00	3	courses	\N	\N	2026-06-24 16:58:45.226911+00
288	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:58:45.285899+00	3	courses	\N	\N	2026-06-24 16:58:45.285899+00
289	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:58:48.57795+00	3	courses	\N	\N	2026-06-24 16:58:48.57795+00
290	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 16:58:48.618653+00	3	courses	\N	\N	2026-06-24 16:58:48.618653+00
291	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 17:05:04.677644+00	3	courses	\N	\N	2026-06-24 17:05:04.677644+00
292	\N	read	\N	3	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 17:05:05.041794+00	3	students	\N	\N	2026-06-24 17:05:05.041794+00
293	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 17:11:33.985795+00	3	courses	\N	\N	2026-06-24 17:11:33.985795+00
294	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 17:11:34.049776+00	3	courses	\N	\N	2026-06-24 17:11:34.049776+00
295	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 17:11:34.911696+00	3	courses	\N	\N	2026-06-24 17:11:34.911696+00
296	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 17:11:34.931167+00	3	courses	\N	\N	2026-06-24 17:11:34.931167+00
297	\N	read	\N	3	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 17:11:35.003413+00	3	students	\N	\N	2026-06-24 17:11:35.003413+00
298	\N	read	\N	3	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 17:11:35.014041+00	3	grades	\N	\N	2026-06-24 17:11:35.014041+00
299	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 17:11:36.679947+00	3	courses	\N	\N	2026-06-24 17:11:36.679947+00
300	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 17:11:36.755243+00	3	courses	\N	\N	2026-06-24 17:11:36.755243+00
301	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 17:12:02.555952+00	3	courses	\N	\N	2026-06-24 17:12:02.555952+00
302	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 17:12:02.720451+00	3	courses	\N	\N	2026-06-24 17:12:02.720451+00
303	\N	read	\N	3	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 17:12:02.780431+00	3	students	\N	\N	2026-06-24 17:12:02.780431+00
304	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 17:14:14.724699+00	3	courses	\N	\N	2026-06-24 17:14:14.724699+00
305	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 17:33:32.121655+00	3	courses	\N	\N	2026-06-24 17:33:32.121655+00
306	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-24 17:33:32.17994+00	3	courses	\N	\N	2026-06-24 17:33:32.17994+00
307	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:26:07.133187+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:26:07.133187+00
308	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:26:07.200442+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:26:07.200442+00
309	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:26:21.021585+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:26:21.021585+00
310	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:26:21.052212+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:26:21.052212+00
311	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:26:44.082751+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:26:44.082751+00
312	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:26:44.121633+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:26:44.121633+00
313	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:26:45.218352+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:26:45.218352+00
314	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:26:45.235047+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:26:45.235047+00
315	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:27:34.00329+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:27:34.00329+00
316	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:27:34.022423+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:27:34.022423+00
317	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:27:49.780669+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:27:49.780669+00
318	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:27:49.802968+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:27:49.802968+00
319	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:27:51.266936+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:27:51.266936+00
320	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:27:51.347511+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:27:51.347511+00
321	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:27:54.474437+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:27:54.474437+00
322	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:27:54.521149+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:27:54.521149+00
323	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:27:55.602139+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:27:55.602139+00
324	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:27:55.621698+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:27:55.621698+00
325	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:27:58.224928+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:27:58.224928+00
326	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:27:58.27817+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:27:58.27817+00
327	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:40:24.073656+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:40:24.073656+00
328	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:40:24.115234+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:40:24.115234+00
329	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:51:11.471301+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:51:11.471301+00
330	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:51:17.415098+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:51:17.415098+00
331	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:51:17.484047+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:51:17.484047+00
332	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:51:24.034639+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:51:24.034639+00
333	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:51:24.109775+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:51:24.109775+00
334	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:51:25.134851+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:51:25.134851+00
335	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:51:25.148339+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:51:25.148339+00
336	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:51:26.371285+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:51:26.371285+00
337	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:51:26.423411+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:51:26.423411+00
338	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:52:14.920241+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:52:14.920241+00
339	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:52:14.947925+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:52:14.947925+00
340	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:52:21.728938+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:52:21.728938+00
341	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:52:21.764426+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:52:21.764426+00
342	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:52:29.649093+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:52:29.649093+00
343	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:52:29.674866+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:52:29.674866+00
344	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:56:29.574747+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:56:29.574747+00
345	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:56:29.609492+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:56:29.609492+00
346	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:56:32.256223+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:56:32.256223+00
347	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:56:32.284347+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:56:32.284347+00
348	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:56:34.266047+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:56:34.266047+00
349	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:56:34.332023+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:56:34.332023+00
350	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:56:36.097264+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:56:36.097264+00
351	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:56:36.143955+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:56:36.143955+00
352	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:58:53.227172+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:58:53.227172+00
353	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:58:53.266428+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:58:53.266428+00
354	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:58:54.63983+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:58:54.63983+00
355	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:58:54.682079+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:58:54.682079+00
356	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:58:55.417205+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:58:55.417205+00
357	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:58:55.465092+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:58:55.465092+00
358	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:58:56.431725+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:58:56.431725+00
359	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:58:56.47177+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:58:56.47177+00
360	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:58:57.583839+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:58:57.583839+00
361	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:58:57.639928+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:58:57.639928+00
362	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:58:58.627902+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:58:58.627902+00
363	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:58:58.693281+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:58:58.693281+00
364	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:58:59.860357+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:58:59.860357+00
365	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:58:59.907548+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:58:59.907548+00
366	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:59:00.811478+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:59:00.811478+00
367	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:59:00.86644+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:59:00.86644+00
368	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:59:01.805213+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:59:01.805213+00
369	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:59:01.848439+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:59:01.848439+00
370	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:59:03.859243+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:59:03.859243+00
371	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:59:03.907163+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:59:03.907163+00
372	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:59:05.163234+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:59:05.163234+00
373	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 22:59:05.207854+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 22:59:05.207854+00
374	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:02.989095+00	2	audit	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:02.989095+00
375	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:02.995131+00	2	audit	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:02.995131+00
376	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:03.01479+00	2	audit	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:03.01479+00
377	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:03.017669+00	2	audit	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:03.017669+00
378	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:07.027812+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:07.027812+00
379	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:07.047649+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:07.047649+00
381	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:08.347416+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:08.347416+00
383	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:09.519603+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:09.519603+00
386	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:11.111715+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:11.111715+00
388	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:11.912974+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:11.912974+00
389	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:11.944524+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:11.944524+00
390	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:14.512642+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:14.512642+00
392	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:20.298112+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:20.298112+00
394	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:21.16146+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:21.16146+00
395	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:21.207502+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:21.207502+00
397	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:22.485739+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:22.485739+00
380	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:08.297158+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:08.297158+00
385	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:10.535434+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:10.535434+00
387	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:11.150302+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:11.150302+00
393	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:20.345334+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:20.345334+00
396	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:22.444434+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:22.444434+00
398	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:23.58474+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:23.58474+00
399	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:23.641264+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:23.641264+00
400	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:26.015215+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:26.015215+00
401	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:26.048239+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:26.048239+00
382	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:09.498825+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:09.498825+00
384	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:10.490814+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:10.490814+00
391	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:14.546205+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:14.546205+00
402	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:40.662887+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:40.662887+00
403	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:40.680861+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:40.680861+00
404	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:43.055255+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:43.055255+00
405	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:43.095616+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:43.095616+00
406	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:44.37632+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:44.37632+00
407	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:44.39608+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:44.39608+00
408	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:45.585335+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:45.585335+00
409	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:00:45.627877+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:00:45.627877+00
410	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:01:04.177754+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:01:04.177754+00
411	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:01:04.212115+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:01:04.212115+00
412	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:01:04.798336+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:01:04.798336+00
413	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:01:04.829699+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:01:04.829699+00
414	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:01:05.64103+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:01:05.64103+00
415	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:01:05.684978+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:01:05.684978+00
416	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:01:06.54824+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:01:06.54824+00
417	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:01:06.589727+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:01:06.589727+00
418	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:01:07.318618+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:01:07.318618+00
419	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:01:07.363149+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:01:07.363149+00
420	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:01:09.687462+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:01:09.687462+00
421	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:01:09.704972+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:01:09.704972+00
422	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:01:10.52399+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:01:10.52399+00
423	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:01:10.570799+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:01:10.570799+00
424	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:01:32.472854+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:01:32.472854+00
425	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:01:32.506398+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:01:32.506398+00
426	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:03:45.455533+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:03:45.455533+00
427	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-25 23:03:45.478834+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-25 23:03:45.478834+00
428	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 11:20:18.329306+00	2	courses	\N	\N	2026-06-26 11:20:18.329306+00
429	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 11:20:18.461053+00	2	courses	\N	\N	2026-06-26 11:20:18.461053+00
430	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 11:20:21.74852+00	2	courses	\N	\N	2026-06-26 11:20:21.74852+00
431	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 11:20:21.81993+00	2	courses	\N	\N	2026-06-26 11:20:21.81993+00
432	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 11:20:21.871175+00	2	students	\N	\N	2026-06-26 11:20:21.871175+00
433	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 11:20:21.894584+00	2	grades	\N	\N	2026-06-26 11:20:21.894584+00
434	\N	approve	\N	1	DENIED_SOD	\N	::1	\N	{"layer": "SOD"}	2026-06-26 11:20:44.585562+00	2	grades	SEPARATION_OF_DUTY_VIOLATION	\N	2026-06-26 11:20:44.585562+00
435	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 11:20:50.279153+00	2	courses	\N	\N	2026-06-26 11:20:50.279153+00
436	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 11:20:50.409034+00	2	students	\N	\N	2026-06-26 11:20:50.409034+00
437	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 11:20:50.411863+00	2	grades	\N	\N	2026-06-26 11:20:50.411863+00
438	\N	write	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 11:21:03.141956+00	2	grades	\N	\N	2026-06-26 11:21:03.141956+00
439	\N	submit	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 11:21:03.169135+00	2	grades	\N	\N	2026-06-26 11:21:03.169135+00
440	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 11:21:03.196847+00	2	students	\N	\N	2026-06-26 11:21:03.196847+00
441	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 11:21:03.27172+00	2	grades	\N	\N	2026-06-26 11:21:03.27172+00
442	\N	approve	\N	1	DENIED_SOD	\N	::1	\N	{"layer": "SOD"}	2026-06-26 11:21:07.35278+00	2	grades	SEPARATION_OF_DUTY_VIOLATION	\N	2026-06-26 11:21:07.35278+00
443	\N	approve	\N	1	DENIED_SOD	\N	::1	\N	{"layer": "SOD"}	2026-06-26 11:21:08.286989+00	2	grades	SEPARATION_OF_DUTY_VIOLATION	\N	2026-06-26 11:21:08.286989+00
444	\N	approve	\N	1	DENIED_SOD	\N	::1	\N	{"layer": "SOD"}	2026-06-26 11:21:08.90402+00	2	grades	SEPARATION_OF_DUTY_VIOLATION	\N	2026-06-26 11:21:08.90402+00
445	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 11:21:10.49623+00	2	students	\N	\N	2026-06-26 11:21:10.49623+00
446	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 11:21:10.49721+00	2	grades	\N	\N	2026-06-26 11:21:10.49721+00
447	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 11:21:10.806188+00	2	students	\N	\N	2026-06-26 11:21:10.806188+00
448	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 11:21:10.807114+00	2	grades	\N	\N	2026-06-26 11:21:10.807114+00
449	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 11:21:11.33461+00	2	students	\N	\N	2026-06-26 11:21:11.33461+00
450	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 11:21:11.3359+00	2	grades	\N	\N	2026-06-26 11:21:11.3359+00
451	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 11:24:13.381957+00	2	audit	\N	\N	2026-06-26 11:24:13.381957+00
452	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 11:24:13.386796+00	2	audit	\N	\N	2026-06-26 11:24:13.386796+00
453	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 11:24:13.445196+00	2	audit	\N	\N	2026-06-26 11:24:13.445196+00
454	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 11:24:13.448688+00	2	audit	\N	\N	2026-06-26 11:24:13.448688+00
455	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 11:24:14.078354+00	2	users	\N	\N	2026-06-26 11:24:14.078354+00
456	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 11:24:14.079689+00	2	audit	\N	\N	2026-06-26 11:24:14.079689+00
457	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 11:24:14.16403+00	2	audit	\N	\N	2026-06-26 11:24:14.16403+00
458	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 11:24:14.210146+00	2	users	\N	\N	2026-06-26 11:24:14.210146+00
459	\N	approve	\N	\N	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-06-26 11:24:14.265321+00	2	grades	NO_ACADEMIC_RELATIONSHIP	\N	2026-06-26 11:24:14.265321+00
460	\N	approve	\N	\N	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-06-26 11:24:14.279097+00	2	grades	NO_ACADEMIC_RELATIONSHIP	\N	2026-06-26 11:24:14.279097+00
461	\N	approve	\N	\N	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-06-26 12:05:28.300865+00	2	grades	NO_ACADEMIC_RELATIONSHIP	\N	2026-06-26 12:05:28.300865+00
462	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:28.309235+00	2	audit	\N	\N	2026-06-26 12:05:28.309235+00
463	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:28.33121+00	2	users	\N	\N	2026-06-26 12:05:28.33121+00
464	\N	approve	\N	\N	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-06-26 12:05:28.384588+00	2	grades	NO_ACADEMIC_RELATIONSHIP	\N	2026-06-26 12:05:28.384588+00
465	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:28.402693+00	2	audit	\N	\N	2026-06-26 12:05:28.402693+00
466	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:28.451956+00	2	users	\N	\N	2026-06-26 12:05:28.451956+00
467	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:33.163969+00	2	users	\N	\N	2026-06-26 12:05:33.163969+00
468	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:33.195393+00	2	users	\N	\N	2026-06-26 12:05:33.195393+00
469	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:33.93756+00	2	users	\N	\N	2026-06-26 12:05:33.93756+00
470	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:33.965419+00	2	users	\N	\N	2026-06-26 12:05:33.965419+00
471	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:34.664166+00	2	audit	\N	\N	2026-06-26 12:05:34.664166+00
472	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:34.664934+00	2	audit	\N	\N	2026-06-26 12:05:34.664934+00
473	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:34.714867+00	2	audit	\N	\N	2026-06-26 12:05:34.714867+00
474	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:34.735723+00	2	audit	\N	\N	2026-06-26 12:05:34.735723+00
475	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:35.311815+00	2	users	\N	\N	2026-06-26 12:05:35.311815+00
476	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:35.312488+00	2	users	\N	\N	2026-06-26 12:05:35.312488+00
477	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:35.365474+00	2	users	\N	\N	2026-06-26 12:05:35.365474+00
478	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:35.366087+00	2	users	\N	\N	2026-06-26 12:05:35.366087+00
479	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:37.515142+00	2	audit	\N	\N	2026-06-26 12:05:37.515142+00
480	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:37.515884+00	2	audit	\N	\N	2026-06-26 12:05:37.515884+00
481	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:37.562783+00	2	audit	\N	\N	2026-06-26 12:05:37.562783+00
482	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:37.597767+00	2	audit	\N	\N	2026-06-26 12:05:37.597767+00
483	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:39.084008+00	2	users	\N	\N	2026-06-26 12:05:39.084008+00
484	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:39.102413+00	2	users	\N	\N	2026-06-26 12:05:39.102413+00
485	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:39.910628+00	2	users	\N	\N	2026-06-26 12:05:39.910628+00
486	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:39.954736+00	2	users	\N	\N	2026-06-26 12:05:39.954736+00
487	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:40.392648+00	2	users	\N	\N	2026-06-26 12:05:40.392648+00
488	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:40.393248+00	2	audit	\N	\N	2026-06-26 12:05:40.393248+00
489	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:40.452985+00	2	audit	\N	\N	2026-06-26 12:05:40.452985+00
490	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:40.47741+00	2	users	\N	\N	2026-06-26 12:05:40.47741+00
491	\N	approve	\N	\N	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-06-26 12:05:40.542517+00	2	grades	NO_ACADEMIC_RELATIONSHIP	\N	2026-06-26 12:05:40.542517+00
492	\N	approve	\N	\N	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-06-26 12:05:40.559066+00	2	grades	NO_ACADEMIC_RELATIONSHIP	\N	2026-06-26 12:05:40.559066+00
493	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:40.685851+00	2	audit	\N	\N	2026-06-26 12:05:40.685851+00
494	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:40.688452+00	2	audit	\N	\N	2026-06-26 12:05:40.688452+00
495	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:40.732672+00	2	audit	\N	\N	2026-06-26 12:05:40.732672+00
496	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:40.760232+00	2	audit	\N	\N	2026-06-26 12:05:40.760232+00
497	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:42.087574+00	2	courses	\N	\N	2026-06-26 12:05:42.087574+00
498	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:42.109708+00	2	courses	\N	\N	2026-06-26 12:05:42.109708+00
499	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:42.199672+00	2	students	\N	\N	2026-06-26 12:05:42.199672+00
500	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-26 12:05:42.201883+00	2	grades	\N	\N	2026-06-26 12:05:42.201883+00
501	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 15:52:55.893873+00	7	grades	\N	\N	2026-06-27 15:52:55.893873+00
502	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 15:52:55.961562+00	7	enrollments	\N	\N	2026-06-27 15:52:55.961562+00
503	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 15:52:55.993116+00	7	grades	\N	\N	2026-06-27 15:52:55.993116+00
504	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 15:52:56.161389+00	7	enrollments	\N	\N	2026-06-27 15:52:56.161389+00
505	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 15:52:56.162773+00	7	grades	\N	\N	2026-06-27 15:52:56.162773+00
506	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 15:52:56.171885+00	7	grades	\N	\N	2026-06-27 15:52:56.171885+00
507	\N	approve	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-06-27 17:19:05.461982+00	7	grades	INSUFFICIENT_ROLE	\N	2026-06-27 17:19:05.461982+00
508	\N	approve	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-06-27 17:19:05.550391+00	7	grades	INSUFFICIENT_ROLE	\N	2026-06-27 17:19:05.550391+00
509	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:19:05.640609+00	7	users	\N	\N	2026-06-27 17:19:05.640609+00
510	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:19:05.706915+00	7	audit	\N	\N	2026-06-27 17:19:05.706915+00
511	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:19:05.753449+00	7	users	\N	\N	2026-06-27 17:19:05.753449+00
512	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:19:05.787255+00	7	audit	\N	\N	2026-06-27 17:19:05.787255+00
513	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:19:24.873029+00	7	courses	\N	\N	2026-06-27 17:19:24.873029+00
514	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:19:24.910256+00	7	courses	\N	\N	2026-06-27 17:19:24.910256+00
515	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:19:27.800743+00	7	courses	\N	\N	2026-06-27 17:19:27.800743+00
516	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:19:27.840314+00	7	courses	\N	\N	2026-06-27 17:19:27.840314+00
517	\N	read	\N	1	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-06-27 17:19:27.938554+00	7	students	NO_ACADEMIC_RELATIONSHIP	\N	2026-06-27 17:19:27.938554+00
518	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:19:27.946265+00	7	grades	\N	\N	2026-06-27 17:19:27.946265+00
519	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:23:09.964827+00	7	courses	\N	\N	2026-06-27 17:23:09.964827+00
520	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:23:10.160637+00	7	courses	\N	\N	2026-06-27 17:23:10.160637+00
521	\N	read	\N	1	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-06-27 17:23:10.161928+00	7	students	NO_ACADEMIC_RELATIONSHIP	\N	2026-06-27 17:23:10.161928+00
522	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:23:10.170972+00	7	grades	\N	\N	2026-06-27 17:23:10.170972+00
523	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:27:34.159006+00	7	courses	\N	\N	2026-06-27 17:27:34.159006+00
524	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:27:34.222773+00	7	courses	\N	\N	2026-06-27 17:27:34.222773+00
525	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:28:23.579401+00	7	courses	\N	\N	2026-06-27 17:28:23.579401+00
526	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:28:23.649904+00	7	courses	\N	\N	2026-06-27 17:28:23.649904+00
527	\N	read	\N	1	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-06-27 17:28:23.874941+00	7	students	NO_ACADEMIC_RELATIONSHIP	\N	2026-06-27 17:28:23.874941+00
528	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:28:23.878896+00	7	courses	\N	\N	2026-06-27 17:28:23.878896+00
529	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:28:23.888703+00	7	grades	\N	\N	2026-06-27 17:28:23.888703+00
530	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:32:48.460885+00	7	courses	\N	\N	2026-06-27 17:32:48.460885+00
531	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:32:48.540588+00	7	courses	\N	\N	2026-06-27 17:32:48.540588+00
532	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:32:48.712088+00	7	courses	\N	\N	2026-06-27 17:32:48.712088+00
533	\N	read	\N	1	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-06-27 17:32:48.715083+00	7	students	NO_ACADEMIC_RELATIONSHIP	\N	2026-06-27 17:32:48.715083+00
534	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:32:48.720605+00	7	grades	\N	\N	2026-06-27 17:32:48.720605+00
535	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:34:39.060416+00	7	courses	\N	\N	2026-06-27 17:34:39.060416+00
536	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:34:39.376997+00	7	courses	\N	\N	2026-06-27 17:34:39.376997+00
538	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:34:39.58302+00	7	grades	\N	\N	2026-06-27 17:34:39.58302+00
537	\N	read	\N	1	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-06-27 17:34:39.582151+00	7	students	NO_ACADEMIC_RELATIONSHIP	\N	2026-06-27 17:34:39.582151+00
539	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:34:39.594219+00	7	courses	\N	\N	2026-06-27 17:34:39.594219+00
540	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:39:47.615959+00	7	grades	\N	\N	2026-06-27 17:39:47.615959+00
541	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:39:47.683835+00	7	grades	\N	\N	2026-06-27 17:39:47.683835+00
542	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:39:47.866214+00	7	grades	\N	\N	2026-06-27 17:39:47.866214+00
543	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:39:47.904012+00	7	enrollments	\N	\N	2026-06-27 17:39:47.904012+00
544	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:39:47.957178+00	7	grades	\N	\N	2026-06-27 17:39:47.957178+00
545	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:39:48.088275+00	7	enrollments	\N	\N	2026-06-27 17:39:48.088275+00
546	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:47:59.021986+00	7	grades	\N	\N	2026-06-27 17:47:59.021986+00
547	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:47:59.230583+00	7	grades	\N	\N	2026-06-27 17:47:59.230583+00
548	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:47:59.418138+00	7	grades	\N	\N	2026-06-27 17:47:59.418138+00
549	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:47:59.474557+00	7	grades	\N	\N	2026-06-27 17:47:59.474557+00
550	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:00.327913+00	7	courses	\N	\N	2026-06-27 17:48:00.327913+00
551	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:00.482218+00	7	courses	\N	\N	2026-06-27 17:48:00.482218+00
552	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:00.643218+00	7	enrollments	\N	\N	2026-06-27 17:48:00.643218+00
553	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:00.689817+00	7	enrollments	\N	\N	2026-06-27 17:48:00.689817+00
554	\N	read	\N	3	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:00.741425+00	7	courses	\N	\N	2026-06-27 17:48:00.741425+00
555	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:00.778074+00	7	courses	\N	\N	2026-06-27 17:48:00.778074+00
556	\N	read	\N	3	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:00.840331+00	7	courses	\N	\N	2026-06-27 17:48:00.840331+00
557	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:00.840756+00	7	courses	\N	\N	2026-06-27 17:48:00.840756+00
558	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:08.566332+00	7	grades	\N	\N	2026-06-27 17:48:08.566332+00
559	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:08.567095+00	7	grades	\N	\N	2026-06-27 17:48:08.567095+00
560	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:08.617923+00	7	grades	\N	\N	2026-06-27 17:48:08.617923+00
561	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:08.618383+00	7	grades	\N	\N	2026-06-27 17:48:08.618383+00
562	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:11.524775+00	7	enrollments	\N	\N	2026-06-27 17:48:11.524775+00
563	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:11.525269+00	7	courses	\N	\N	2026-06-27 17:48:11.525269+00
564	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:11.581052+00	7	enrollments	\N	\N	2026-06-27 17:48:11.581052+00
565	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:11.581617+00	7	courses	\N	\N	2026-06-27 17:48:11.581617+00
566	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:11.644624+00	7	courses	\N	\N	2026-06-27 17:48:11.644624+00
567	\N	read	\N	3	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:11.645362+00	7	courses	\N	\N	2026-06-27 17:48:11.645362+00
568	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:11.6904+00	7	courses	\N	\N	2026-06-27 17:48:11.6904+00
569	\N	read	\N	3	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:11.690796+00	7	courses	\N	\N	2026-06-27 17:48:11.690796+00
570	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:15.691256+00	7	grades	\N	\N	2026-06-27 17:48:15.691256+00
571	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:15.692207+00	7	grades	\N	\N	2026-06-27 17:48:15.692207+00
572	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:15.746283+00	7	grades	\N	\N	2026-06-27 17:48:15.746283+00
573	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:15.748229+00	7	grades	\N	\N	2026-06-27 17:48:15.748229+00
574	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:17.302302+00	7	grades	\N	\N	2026-06-27 17:48:17.302302+00
575	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:17.302823+00	7	grades	\N	\N	2026-06-27 17:48:17.302823+00
576	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:17.303586+00	7	enrollments	\N	\N	2026-06-27 17:48:17.303586+00
577	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:17.338657+00	7	grades	\N	\N	2026-06-27 17:48:17.338657+00
578	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:17.364512+00	7	enrollments	\N	\N	2026-06-27 17:48:17.364512+00
579	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:17.366266+00	7	grades	\N	\N	2026-06-27 17:48:17.366266+00
580	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:18.922098+00	7	enrollments	\N	\N	2026-06-27 17:48:18.922098+00
581	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:18.92352+00	7	courses	\N	\N	2026-06-27 17:48:18.92352+00
582	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:19.004929+00	7	enrollments	\N	\N	2026-06-27 17:48:19.004929+00
583	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:19.011632+00	7	courses	\N	\N	2026-06-27 17:48:19.011632+00
584	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:19.08593+00	7	courses	\N	\N	2026-06-27 17:48:19.08593+00
585	\N	read	\N	3	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:19.086412+00	7	courses	\N	\N	2026-06-27 17:48:19.086412+00
586	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:19.124523+00	7	courses	\N	\N	2026-06-27 17:48:19.124523+00
587	\N	read	\N	3	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:48:19.124954+00	7	courses	\N	\N	2026-06-27 17:48:19.124954+00
588	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:49:39.340423+00	7	grades	\N	\N	2026-06-27 17:49:39.340423+00
589	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:49:39.425411+00	7	grades	\N	\N	2026-06-27 17:49:39.425411+00
590	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:49:39.458703+00	7	enrollments	\N	\N	2026-06-27 17:49:39.458703+00
591	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:49:39.461935+00	7	grades	\N	\N	2026-06-27 17:49:39.461935+00
592	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:49:39.515246+00	7	grades	\N	\N	2026-06-27 17:49:39.515246+00
596	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:49:42.306464+00	7	enrollments	\N	\N	2026-06-27 17:49:42.306464+00
599	\N	read	\N	3	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:49:42.373319+00	7	courses	\N	\N	2026-06-27 17:49:42.373319+00
600	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:49:42.459117+00	7	courses	\N	\N	2026-06-27 17:49:42.459117+00
593	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:49:39.516037+00	7	enrollments	\N	\N	2026-06-27 17:49:39.516037+00
595	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:49:42.239658+00	7	enrollments	\N	\N	2026-06-27 17:49:42.239658+00
597	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:49:42.339868+00	7	courses	\N	\N	2026-06-27 17:49:42.339868+00
598	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:49:42.371445+00	7	courses	\N	\N	2026-06-27 17:49:42.371445+00
601	\N	read	\N	3	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:49:42.460192+00	7	courses	\N	\N	2026-06-27 17:49:42.460192+00
594	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:49:42.238887+00	7	courses	\N	\N	2026-06-27 17:49:42.238887+00
602	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:52:20.404995+00	7	grades	\N	\N	2026-06-27 17:52:20.404995+00
603	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:52:20.529068+00	7	grades	\N	\N	2026-06-27 17:52:20.529068+00
604	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:52:20.616137+00	7	enrollments	\N	\N	2026-06-27 17:52:20.616137+00
605	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:52:20.708736+00	7	grades	\N	\N	2026-06-27 17:52:20.708736+00
606	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:52:20.772325+00	7	enrollments	\N	\N	2026-06-27 17:52:20.772325+00
607	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:52:20.821561+00	7	grades	\N	\N	2026-06-27 17:52:20.821561+00
608	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:59:47.913596+00	7	courses	\N	\N	2026-06-27 17:59:47.913596+00
609	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:59:47.985296+00	7	courses	\N	\N	2026-06-27 17:59:47.985296+00
610	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:59:48.071986+00	7	enrollments	\N	\N	2026-06-27 17:59:48.071986+00
611	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:59:48.102443+00	7	enrollments	\N	\N	2026-06-27 17:59:48.102443+00
612	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:59:59.923899+00	7	grades	\N	\N	2026-06-27 17:59:59.923899+00
613	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:59:59.959448+00	7	grades	\N	\N	2026-06-27 17:59:59.959448+00
614	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 17:59:59.963372+00	7	grades	\N	\N	2026-06-27 17:59:59.963372+00
615	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-27 18:00:00.012092+00	7	grades	\N	\N	2026-06-27 18:00:00.012092+00
616	\N	approve	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 21:57:45.53699+00	1	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 21:57:45.53699+00
617	\N	approve	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 21:57:45.62911+00	1	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 21:57:45.62911+00
618	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 21:57:45.726457+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 21:57:45.726457+00
619	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 21:57:45.747386+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 21:57:45.747386+00
620	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 21:57:45.757177+00	1	audit	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 21:57:45.757177+00
621	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 21:57:45.775593+00	1	audit	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 21:57:45.775593+00
622	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:05:48.337522+00	8	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:05:48.337522+00
623	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:05:48.369216+00	8	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:05:48.369216+00
624	\N	approve	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-06-28 22:05:48.478926+00	8	grades	INSUFFICIENT_ROLE	\N	2026-06-28 22:05:48.478926+00
625	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:05:48.48057+00	8	audit	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:05:48.48057+00
626	\N	approve	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-06-28 22:05:48.501888+00	8	grades	INSUFFICIENT_ROLE	\N	2026-06-28 22:05:48.501888+00
627	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:05:48.503792+00	8	audit	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:05:48.503792+00
628	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:00.730664+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:00.730664+00
629	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:00.750929+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:00.750929+00
630	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:00.773585+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:00.773585+00
631	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:00.783536+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:00.783536+00
632	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:00.809473+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:00.809473+00
633	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:00.815486+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:00.815486+00
634	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:15.801619+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:15.801619+00
635	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:15.808623+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:15.808623+00
636	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:15.836695+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:15.836695+00
637	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:15.837472+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:15.837472+00
638	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:18.069811+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:18.069811+00
639	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:18.077385+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:18.077385+00
640	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:18.110776+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:18.110776+00
641	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:18.135574+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:18.135574+00
642	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:18.205564+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:18.205564+00
643	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:18.221948+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:18.221948+00
644	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:18.993633+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:18.993633+00
645	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:18.99643+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:18.99643+00
646	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:19.078932+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:19.078932+00
647	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:19.07966+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:19.07966+00
648	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:19.724865+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:19.724865+00
649	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:19.725998+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:19.725998+00
650	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:19.769891+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:19.769891+00
651	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:19.786849+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:19.786849+00
652	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:23.797586+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:23.797586+00
653	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:23.798984+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:23.798984+00
654	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:23.851424+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:23.851424+00
655	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:23.85243+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:23.85243+00
657	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:24.595895+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:24.595895+00
660	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:25.306712+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:25.306712+00
665	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:25.360393+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:25.360393+00
666	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:26.404256+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:26.404256+00
669	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:26.449618+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:26.449618+00
673	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:27.702111+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:27.702111+00
674	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:27.721389+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:27.721389+00
680	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:41.753426+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:41.753426+00
686	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:43.575857+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:43.575857+00
688	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:43.62817+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:43.62817+00
656	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:24.595312+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:24.595312+00
661	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:25.309292+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:25.309292+00
672	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:27.676522+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:27.676522+00
658	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:24.616688+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:24.616688+00
659	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:24.632081+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:24.632081+00
667	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:26.407528+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:26.407528+00
662	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:25.312076+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:25.312076+00
663	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:25.35227+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:25.35227+00
670	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:27.67455+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:27.67455+00
664	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:25.356747+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:25.356747+00
668	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:26.447417+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:26.447417+00
671	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:27.675553+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:27.675553+00
675	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:27.721763+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:27.721763+00
676	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:40.602906+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:40.602906+00
677	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:40.618303+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:40.618303+00
678	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:40.686705+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:40.686705+00
679	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:40.699035+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:40.699035+00
681	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:41.753899+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:41.753899+00
682	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:41.788914+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:41.788914+00
683	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:41.790951+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:41.790951+00
684	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:43.573868+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:43.573868+00
685	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:43.574951+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:43.574951+00
687	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:43.627772+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:43.627772+00
689	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:06:43.628675+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:06:43.628675+00
690	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:22.463832+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:22.463832+00
691	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:22.508417+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:22.508417+00
692	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:22.602239+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:22.602239+00
693	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:22.61933+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:22.61933+00
694	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:23.692795+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:23.692795+00
695	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:23.696469+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:23.696469+00
696	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:23.735539+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:23.735539+00
697	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:23.741753+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:23.741753+00
698	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:25.275384+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:25.275384+00
699	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:25.276195+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:25.276195+00
700	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:25.324306+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:25.324306+00
701	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:25.324799+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:25.324799+00
702	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:25.417389+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:25.417389+00
703	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:25.433498+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:25.433498+00
704	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:52.96763+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:52.96763+00
705	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:53.033268+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:53.033268+00
706	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:53.037691+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:53.037691+00
707	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:53.058678+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:53.058678+00
708	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:53.933322+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:53.933322+00
709	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:53.933889+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:53.933889+00
710	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:53.986085+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:53.986085+00
711	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:53.98677+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:53.98677+00
712	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:54.916054+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:54.916054+00
713	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:54.918357+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:54.918357+00
714	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:54.920085+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:54.920085+00
715	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:54.966899+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:54.966899+00
716	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:54.969357+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:54.969357+00
717	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:54.96984+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:54.96984+00
718	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:56.207613+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:56.207613+00
719	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:56.208057+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:56.208057+00
720	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:56.282767+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:56.282767+00
721	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:56.284014+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:56.284014+00
722	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:57.259406+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:57.259406+00
723	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:57.260008+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:57.260008+00
724	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:57.316119+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:57.316119+00
725	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:09:57.317306+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:09:57.317306+00
726	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:10:01.3088+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:10:01.3088+00
728	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:10:01.349828+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:10:01.349828+00
732	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:10:02.352651+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:10:02.352651+00
734	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:10:05.990631+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:10:05.990631+00
736	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:10:06.031994+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:10:06.031994+00
727	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:10:01.309255+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:10:01.309255+00
729	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:10:01.353271+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:10:01.353271+00
733	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:10:02.355098+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:10:02.355098+00
730	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:10:02.313281+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:10:02.313281+00
731	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:10:02.31354+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:10:02.31354+00
735	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:10:05.991006+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:10:05.991006+00
737	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:10:06.033018+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:10:06.033018+00
738	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:10:08.770277+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:10:08.770277+00
739	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:10:08.770931+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:10:08.770931+00
740	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:10:08.821305+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:10:08.821305+00
741	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:10:08.821625+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:10:08.821625+00
742	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:10:08.90336+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:10:08.90336+00
743	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:10:08.918064+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:10:08.918064+00
744	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:10:10.332269+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:10:10.332269+00
745	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:10:10.332607+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:10:10.332607+00
746	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:10:10.41358+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:10:10.41358+00
747	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:10:10.416167+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:10:10.416167+00
748	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:10:57.23228+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:10:57.23228+00
749	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:10:57.262739+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:10:57.262739+00
750	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:10:57.271051+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:10:57.271051+00
751	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:10:57.309601+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:10:57.309601+00
752	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:10:57.313731+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:10:57.313731+00
753	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:10:57.314104+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:10:57.314104+00
754	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:11:08.888279+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:11:08.888279+00
755	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:11:08.958471+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:11:08.958471+00
756	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:11:09.009656+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:11:09.009656+00
757	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:11:09.025199+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:11:09.025199+00
758	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:11:09.625792+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:11:09.625792+00
759	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:11:09.626748+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:11:09.626748+00
760	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:11:09.645529+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:11:09.645529+00
761	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:11:09.668124+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:11:09.668124+00
762	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:11:13.905485+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:11:13.905485+00
763	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:11:13.9077+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:11:13.9077+00
764	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:11:13.953979+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:11:13.953979+00
765	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:11:13.954792+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:11:13.954792+00
766	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:11:14.055424+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:11:14.055424+00
767	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:11:14.074946+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:11:14.074946+00
768	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:12:37.110376+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:12:37.110376+00
770	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:19:34.357713+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:19:34.357713+00
769	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:19:34.353388+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:19:34.353388+00
771	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:19:34.380067+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:19:34.380067+00
772	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:19:34.380314+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:19:34.380314+00
773	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:19:34.839041+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:19:34.839041+00
774	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:19:34.839454+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:19:34.839454+00
775	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:19:34.889194+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:19:34.889194+00
776	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:19:34.8895+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:19:34.8895+00
777	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:19:35.438243+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:19:35.438243+00
778	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:19:35.439137+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:19:35.439137+00
779	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:19:35.463544+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:19:35.463544+00
780	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:19:35.501056+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:19:35.501056+00
781	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:19:35.566921+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:19:35.566921+00
782	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:19:35.582653+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:19:35.582653+00
783	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:19:36.088204+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:19:36.088204+00
784	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:19:36.089051+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:19:36.089051+00
785	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:19:36.112128+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:19:36.112128+00
786	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:19:36.130776+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:19:36.130776+00
788	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:19:36.797904+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:19:36.797904+00
787	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:19:36.797386+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:19:36.797386+00
790	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:19:36.849556+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:19:36.849556+00
796	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:19:38.339433+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:19:38.339433+00
789	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:19:36.798655+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:19:36.798655+00
791	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:19:36.850539+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:19:36.850539+00
793	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:19:38.300249+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:19:38.300249+00
792	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:19:36.85216+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:19:36.85216+00
794	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:19:38.300034+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:19:38.300034+00
795	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:19:38.333+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:19:38.333+00
797	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:20:25.29064+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:20:25.29064+00
798	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:20:25.321289+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:20:25.321289+00
799	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:20:25.401937+00	1	audit	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:20:25.401937+00
800	\N	approve	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:20:25.415662+00	1	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:20:25.415662+00
801	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:20:25.418083+00	1	audit	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:20:25.418083+00
802	\N	approve	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:20:25.42937+00	1	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:20:25.42937+00
803	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:02.643751+00	3	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:02.643751+00
804	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:02.657227+00	3	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:02.657227+00
805	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:31.634265+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:31.634265+00
806	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:31.657682+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:31.657682+00
807	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:31.688434+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:31.688434+00
808	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:31.69147+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:31.69147+00
809	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:31.706417+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:31.706417+00
810	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:31.710323+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:31.710323+00
811	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:35.252266+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:35.252266+00
812	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:35.253012+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:35.253012+00
813	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:35.332468+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:35.332468+00
814	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:35.332859+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:35.332859+00
815	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:36.177423+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:36.177423+00
816	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:36.178302+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:36.178302+00
817	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:36.181953+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:36.181953+00
818	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:36.242249+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:36.242249+00
819	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:36.242815+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:36.242815+00
820	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:36.243299+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:36.243299+00
821	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:37.794996+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:37.794996+00
822	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:37.795422+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:37.795422+00
823	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:37.843377+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:37.843377+00
824	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:37.844535+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:37.844535+00
825	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:38.661737+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:38.661737+00
826	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:38.662135+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:38.662135+00
827	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:38.709494+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:38.709494+00
828	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:38.710934+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:38.710934+00
829	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:39.383658+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:39.383658+00
830	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:39.411212+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:39.411212+00
831	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:39.42819+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:39.42819+00
832	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:39.44797+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:39.44797+00
833	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:41.063145+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:41.063145+00
834	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:41.064699+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:41.064699+00
835	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:41.101535+00	8	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:41.101535+00
836	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:21:41.102342+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:21:41.102342+00
837	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:48:01.522378+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:48:01.522378+00
838	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:48:01.558861+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:48:01.558861+00
839	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:48:01.594762+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:48:01.594762+00
840	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:48:01.597179+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:48:01.597179+00
841	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:48:01.622878+00	8	enrollments	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:48:01.622878+00
842	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:48:01.631073+00	8	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:48:01.631073+00
843	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:49:09.720371+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:49:09.720371+00
844	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:49:09.744135+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:49:09.744135+00
845	\N	approve	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:49:09.839096+00	1	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:49:09.839096+00
846	\N	approve	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:49:09.858842+00	1	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:49:09.858842+00
847	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:49:09.86059+00	1	audit	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:49:09.86059+00
848	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:49:09.881061+00	1	audit	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:49:09.881061+00
849	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:49:14.831884+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:49:14.831884+00
850	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:49:14.83242+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:49:14.83242+00
851	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:49:14.848946+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:49:14.848946+00
852	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:49:14.850429+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:49:14.850429+00
853	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:49:21.84276+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:49:21.84276+00
854	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:49:21.844077+00	1	audit	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:49:21.844077+00
855	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:49:21.861678+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:49:21.861678+00
856	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:49:21.876874+00	1	audit	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:49:21.876874+00
857	\N	approve	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:49:21.945095+00	1	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:49:21.945095+00
858	\N	approve	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:49:21.95618+00	1	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:49:21.95618+00
859	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:49:34.858246+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:49:34.858246+00
860	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:49:34.874284+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:49:34.874284+00
861	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:49:36.419332+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:49:36.419332+00
862	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:49:36.434257+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:49:36.434257+00
863	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:49:37.42028+00	1	audit	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:49:37.42028+00
864	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:49:37.43463+00	1	audit	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:49:37.43463+00
865	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:49:37.515642+00	1	audit	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:49:37.515642+00
866	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:49:37.5281+00	1	audit	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:49:37.5281+00
867	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:49:38.170802+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:49:38.170802+00
868	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-28 22:49:38.187899+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-28 22:49:38.187899+00
869	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:19:35.537344+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:19:35.537344+00
870	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:19:35.633095+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:19:35.633095+00
871	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:19:35.669778+00	1	audit	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:19:35.669778+00
872	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:19:35.70003+00	1	audit	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:19:35.70003+00
873	\N	approve	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:19:35.752851+00	1	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:19:35.752851+00
874	\N	approve	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:19:35.77438+00	1	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:19:35.77438+00
876	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:19:37.25663+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:19:37.25663+00
875	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:19:37.255937+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:19:37.255937+00
877	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:19:37.283767+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:19:37.283767+00
878	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:19:37.28594+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:19:37.28594+00
879	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:19:38.806+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:19:38.806+00
880	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:19:38.806965+00	1	audit	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:19:38.806965+00
881	\N	approve	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:19:38.807976+00	1	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:19:38.807976+00
882	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:19:38.84378+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:19:38.84378+00
883	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:19:38.851892+00	1	audit	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:19:38.851892+00
884	\N	approve	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:19:38.852763+00	1	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:19:38.852763+00
885	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:19:42.468555+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:19:42.468555+00
886	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:19:42.469622+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:19:42.469622+00
887	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:19:42.496949+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:19:42.496949+00
888	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:19:42.498136+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:19:42.498136+00
889	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:19:46.486083+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:19:46.486083+00
890	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:19:46.486529+00	1	audit	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:19:46.486529+00
891	\N	approve	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:19:46.487321+00	1	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:19:46.487321+00
892	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:19:46.519384+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:19:46.519384+00
893	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:19:46.520761+00	1	audit	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:19:46.520761+00
894	\N	approve	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:19:46.52216+00	1	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:19:46.52216+00
895	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:21:17.702212+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:21:17.702212+00
896	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:21:17.723008+00	1	users	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:21:17.723008+00
897	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:21:57.825614+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:21:57.825614+00
898	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:21:57.845264+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:21:57.845264+00
899	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:22:00.441193+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:22:00.441193+00
900	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:22:00.472945+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:22:00.472945+00
901	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:22:02.314664+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:22:02.314664+00
902	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:22:02.368522+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:22:02.368522+00
903	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:22:03.116453+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:22:03.116453+00
904	\N	read	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:22:03.148+00	2	courses	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:22:03.148+00
905	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 21:39:01.42682+00	2	courses	\N	\N	2026-06-29 21:39:01.42682+00
906	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 21:39:01.52497+00	2	courses	\N	\N	2026-06-29 21:39:01.52497+00
907	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 21:39:01.689693+00	2	courses	\N	\N	2026-06-29 21:39:01.689693+00
908	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 21:39:01.698375+00	2	students	\N	\N	2026-06-29 21:39:01.698375+00
909	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 21:39:01.755757+00	2	grades	\N	\N	2026-06-29 21:39:01.755757+00
910	\N	write	\N	1	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:39:44.394863+00	2	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:39:44.394863+00
911	\N	write	\N	1	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:40:18.809079+00	2	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:40:18.809079+00
912	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 21:41:59.810911+00	2	courses	\N	\N	2026-06-29 21:41:59.810911+00
913	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 21:41:59.870234+00	2	courses	\N	\N	2026-06-29 21:41:59.870234+00
914	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 21:42:10.991768+00	2	courses	\N	\N	2026-06-29 21:42:10.991768+00
915	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 21:42:11.030835+00	2	courses	\N	\N	2026-06-29 21:42:11.030835+00
916	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 21:42:11.132535+00	2	courses	\N	\N	2026-06-29 21:42:11.132535+00
917	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 21:42:11.143537+00	2	grades	\N	\N	2026-06-29 21:42:11.143537+00
918	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 21:42:11.148962+00	2	students	\N	\N	2026-06-29 21:42:11.148962+00
919	\N	write	\N	1	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:42:19.387543+00	2	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:42:19.387543+00
920	\N	write	\N	1	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:42:32.753231+00	2	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:42:32.753231+00
921	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 21:47:36.004916+00	2	courses	\N	\N	2026-06-29 21:47:36.004916+00
922	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 21:47:36.053269+00	2	courses	\N	\N	2026-06-29 21:47:36.053269+00
923	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 21:47:38.34496+00	2	courses	\N	\N	2026-06-29 21:47:38.34496+00
924	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 21:47:38.389298+00	2	courses	\N	\N	2026-06-29 21:47:38.389298+00
925	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 21:47:38.498937+00	2	courses	\N	\N	2026-06-29 21:47:38.498937+00
926	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 21:47:38.505556+00	2	grades	\N	\N	2026-06-29 21:47:38.505556+00
927	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 21:47:38.506368+00	2	students	\N	\N	2026-06-29 21:47:38.506368+00
928	\N	write	\N	1	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:47:54.561394+00	2	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:47:54.561394+00
929	\N	write	\N	1	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:48:06.873067+00	2	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:48:06.873067+00
930	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 21:52:02.21714+00	1	users	\N	\N	2026-06-29 21:52:02.21714+00
931	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 21:52:02.345469+00	1	users	\N	\N	2026-06-29 21:52:02.345469+00
932	\N	approve	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:52:02.404746+00	1	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:52:02.404746+00
933	\N	approve	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 21:52:02.423202+00	1	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 21:52:02.423202+00
934	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 21:52:02.430598+00	1	audit	\N	\N	2026-06-29 21:52:02.430598+00
935	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 21:52:02.46946+00	1	audit	\N	\N	2026-06-29 21:52:02.46946+00
936	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:00:15.515802+00	1	users	\N	\N	2026-06-29 22:00:15.515802+00
937	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:00:15.719328+00	1	audit	\N	\N	2026-06-29 22:00:15.719328+00
938	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:00:15.798191+00	1	users	\N	\N	2026-06-29 22:00:15.798191+00
939	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:00:15.800543+00	1	audit	\N	\N	2026-06-29 22:00:15.800543+00
940	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:00:15.801151+00	1	grades	\N	\N	2026-06-29 22:00:15.801151+00
941	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:00:15.885852+00	1	grades	\N	\N	2026-06-29 22:00:15.885852+00
942	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:01:19.770444+00	2	courses	\N	\N	2026-06-29 22:01:19.770444+00
943	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:01:19.81973+00	2	courses	\N	\N	2026-06-29 22:01:19.81973+00
944	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:01:21.71826+00	2	courses	\N	\N	2026-06-29 22:01:21.71826+00
945	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:01:21.751125+00	2	courses	\N	\N	2026-06-29 22:01:21.751125+00
946	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:01:21.846897+00	2	courses	\N	\N	2026-06-29 22:01:21.846897+00
947	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:01:21.861297+00	2	grades	\N	\N	2026-06-29 22:01:21.861297+00
948	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:01:21.864822+00	2	students	\N	\N	2026-06-29 22:01:21.864822+00
949	\N	write	\N	1	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 22:01:27.460247+00	2	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 22:01:27.460247+00
950	\N	write	\N	1	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-06-29 22:01:43.129909+00	2	grades	OUTSIDE_GRADING_PERIOD	\N	2026-06-29 22:01:43.129909+00
951	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:08:14.633225+00	2	courses	\N	\N	2026-06-29 22:08:14.633225+00
952	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:08:14.709948+00	2	courses	\N	\N	2026-06-29 22:08:14.709948+00
953	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:08:15.283854+00	2	courses	\N	\N	2026-06-29 22:08:15.283854+00
954	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:08:15.297676+00	2	grades	\N	\N	2026-06-29 22:08:15.297676+00
955	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:08:15.393515+00	2	students	\N	\N	2026-06-29 22:08:15.393515+00
956	\N	write	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:08:45.238894+00	2	grades	\N	\N	2026-06-29 22:08:45.238894+00
957	\N	submit	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:08:45.265514+00	2	grades	\N	\N	2026-06-29 22:08:45.265514+00
958	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:08:45.300934+00	2	courses	\N	\N	2026-06-29 22:08:45.300934+00
959	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:08:45.402358+00	2	students	\N	\N	2026-06-29 22:08:45.402358+00
960	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:08:45.410568+00	2	grades	\N	\N	2026-06-29 22:08:45.410568+00
961	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:10:08.665771+00	4	grades	\N	\N	2026-06-29 22:10:08.665771+00
962	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:10:08.836138+00	4	grades	\N	\N	2026-06-29 22:10:08.836138+00
963	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:10:08.857168+00	4	enrollments	\N	\N	2026-06-29 22:10:08.857168+00
964	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:10:08.891925+00	4	grades	\N	\N	2026-06-29 22:10:08.891925+00
965	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:10:08.917793+00	4	enrollments	\N	\N	2026-06-29 22:10:08.917793+00
966	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:10:08.965282+00	4	grades	\N	\N	2026-06-29 22:10:08.965282+00
967	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:10:43.03036+00	4	grades	\N	\N	2026-06-29 22:10:43.03036+00
968	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:10:43.073493+00	4	grades	\N	\N	2026-06-29 22:10:43.073493+00
969	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:10:43.078581+00	4	grades	\N	\N	2026-06-29 22:10:43.078581+00
970	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:10:43.109008+00	4	grades	\N	\N	2026-06-29 22:10:43.109008+00
971	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:12:00.691122+00	1	users	\N	\N	2026-06-29 22:12:00.691122+00
972	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:12:00.785584+00	1	users	\N	\N	2026-06-29 22:12:00.785584+00
973	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:12:00.862373+00	1	audit	\N	\N	2026-06-29 22:12:00.862373+00
974	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:12:00.871304+00	1	grades	\N	\N	2026-06-29 22:12:00.871304+00
975	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:12:00.917457+00	1	audit	\N	\N	2026-06-29 22:12:00.917457+00
976	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:12:00.967848+00	1	grades	\N	\N	2026-06-29 22:12:00.967848+00
977	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:12:16.670072+00	1	users	\N	\N	2026-06-29 22:12:16.670072+00
978	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:12:16.690815+00	1	users	\N	\N	2026-06-29 22:12:16.690815+00
979	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:12:19.530206+00	1	users	\N	\N	2026-06-29 22:12:19.530206+00
980	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:12:19.556949+00	1	users	\N	\N	2026-06-29 22:12:19.556949+00
981	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:12:48.537412+00	1	users	\N	\N	2026-06-29 22:12:48.537412+00
982	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:12:48.586169+00	1	grades	\N	\N	2026-06-29 22:12:48.586169+00
983	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:12:48.597985+00	1	audit	\N	\N	2026-06-29 22:12:48.597985+00
984	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:12:48.666837+00	1	users	\N	\N	2026-06-29 22:12:48.666837+00
985	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:12:48.670413+00	1	grades	\N	\N	2026-06-29 22:12:48.670413+00
986	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:12:48.673924+00	1	audit	\N	\N	2026-06-29 22:12:48.673924+00
987	\N	approve	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:13:01.188016+00	1	grades	\N	\N	2026-06-29 22:13:01.188016+00
988	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:13:01.224664+00	1	users	\N	\N	2026-06-29 22:13:01.224664+00
989	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:13:01.322232+00	1	audit	\N	\N	2026-06-29 22:13:01.322232+00
990	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:13:01.34689+00	1	grades	\N	\N	2026-06-29 22:13:01.34689+00
991	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:13:19.298089+00	4	grades	\N	\N	2026-06-29 22:13:19.298089+00
992	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:13:19.38623+00	4	grades	\N	\N	2026-06-29 22:13:19.38623+00
993	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:13:19.391083+00	4	enrollments	\N	\N	2026-06-29 22:13:19.391083+00
994	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:13:19.473892+00	4	enrollments	\N	\N	2026-06-29 22:13:19.473892+00
995	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:13:19.552859+00	4	grades	\N	\N	2026-06-29 22:13:19.552859+00
996	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:13:19.593855+00	4	grades	\N	\N	2026-06-29 22:13:19.593855+00
997	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:19:32.984112+00	4	courses	\N	\N	2026-06-29 22:19:32.984112+00
998	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:19:33.533394+00	4	grades	\N	\N	2026-06-29 22:19:33.533394+00
999	\N	read	\N	1	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-06-29 22:19:33.751164+00	4	students	NO_ACADEMIC_RELATIONSHIP	\N	2026-06-29 22:19:33.751164+00
1000	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:56:14.808263+00	4	enrollments	\N	\N	2026-06-29 22:56:14.808263+00
1001	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:56:14.888121+00	4	courses	\N	\N	2026-06-29 22:56:14.888121+00
1002	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:56:14.896335+00	4	enrollments	\N	\N	2026-06-29 22:56:14.896335+00
1003	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:56:14.92537+00	4	courses	\N	\N	2026-06-29 22:56:14.92537+00
1004	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:57:59.168467+00	2	courses	\N	\N	2026-06-29 22:57:59.168467+00
1005	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:57:59.216163+00	2	courses	\N	\N	2026-06-29 22:57:59.216163+00
1006	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:58:06.946557+00	2	courses	\N	\N	2026-06-29 22:58:06.946557+00
1007	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:58:06.989173+00	2	courses	\N	\N	2026-06-29 22:58:06.989173+00
1008	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:58:07.081169+00	2	courses	\N	\N	2026-06-29 22:58:07.081169+00
1009	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:58:07.081761+00	2	students	\N	\N	2026-06-29 22:58:07.081761+00
1010	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 22:58:07.089411+00	2	grades	\N	\N	2026-06-29 22:58:07.089411+00
1011	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:07:00.536547+00	2	courses	\N	\N	2026-06-29 23:07:00.536547+00
1012	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:07:00.597115+00	2	courses	\N	\N	2026-06-29 23:07:00.597115+00
1013	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:07:01.290763+00	2	students	\N	\N	2026-06-29 23:07:01.290763+00
1014	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:07:01.291822+00	2	courses	\N	\N	2026-06-29 23:07:01.291822+00
1015	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:07:01.32217+00	2	grades	\N	\N	2026-06-29 23:07:01.32217+00
1016	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:11:07.325058+00	2	courses	\N	\N	2026-06-29 23:11:07.325058+00
1017	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:11:07.41827+00	2	courses	\N	\N	2026-06-29 23:11:07.41827+00
1018	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:11:07.607592+00	2	students	\N	\N	2026-06-29 23:11:07.607592+00
1019	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:11:07.620652+00	2	courses	\N	\N	2026-06-29 23:11:07.620652+00
1020	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:11:07.633619+00	2	grades	\N	\N	2026-06-29 23:11:07.633619+00
1021	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:30:39.772576+00	2	courses	\N	\N	2026-06-29 23:30:39.772576+00
1022	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:30:39.815359+00	2	courses	\N	\N	2026-06-29 23:30:39.815359+00
1023	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:30:40.359271+00	2	courses	\N	\N	2026-06-29 23:30:40.359271+00
1024	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:30:40.368492+00	2	students	\N	\N	2026-06-29 23:30:40.368492+00
1025	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:30:40.377643+00	2	grades	\N	\N	2026-06-29 23:30:40.377643+00
1026	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:38:24.562163+00	2	courses	\N	\N	2026-06-29 23:38:24.562163+00
1027	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:38:24.620114+00	2	courses	\N	\N	2026-06-29 23:38:24.620114+00
1028	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:38:25.20313+00	2	courses	\N	\N	2026-06-29 23:38:25.20313+00
1029	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:38:25.25007+00	2	courses	\N	\N	2026-06-29 23:38:25.25007+00
1030	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:38:25.321655+00	2	courses	\N	\N	2026-06-29 23:38:25.321655+00
1035	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:38:27.743979+00	2	courses	\N	\N	2026-06-29 23:38:27.743979+00
1039	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:38:27.844238+00	2	grades	\N	\N	2026-06-29 23:38:27.844238+00
1031	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:38:25.325683+00	2	grades	\N	\N	2026-06-29 23:38:25.325683+00
1032	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:38:25.330202+00	2	students	\N	\N	2026-06-29 23:38:25.330202+00
1033	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:38:26.654674+00	2	courses	\N	\N	2026-06-29 23:38:26.654674+00
1034	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:38:26.705456+00	2	courses	\N	\N	2026-06-29 23:38:26.705456+00
1036	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:38:27.77883+00	2	courses	\N	\N	2026-06-29 23:38:27.77883+00
1037	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:38:27.839081+00	2	courses	\N	\N	2026-06-29 23:38:27.839081+00
1038	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:38:27.839472+00	2	students	\N	\N	2026-06-29 23:38:27.839472+00
1040	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:40:41.185683+00	2	courses	\N	\N	2026-06-29 23:40:41.185683+00
1041	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:40:41.209022+00	2	courses	\N	\N	2026-06-29 23:40:41.209022+00
1042	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:40:41.544313+00	2	courses	\N	\N	2026-06-29 23:40:41.544313+00
1043	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:40:41.569277+00	2	grades	\N	\N	2026-06-29 23:40:41.569277+00
1044	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-29 23:40:41.608238+00	2	students	\N	\N	2026-06-29 23:40:41.608238+00
1045	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:08:18.083605+00	1	users	\N	\N	2026-06-30 10:08:18.083605+00
1046	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:08:18.254044+00	1	grades	\N	\N	2026-06-30 10:08:18.254044+00
1047	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:08:18.274862+00	1	users	\N	\N	2026-06-30 10:08:18.274862+00
1048	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:08:18.32906+00	1	grades	\N	\N	2026-06-30 10:08:18.32906+00
1049	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:08:18.35477+00	1	audit	\N	\N	2026-06-30 10:08:18.35477+00
1050	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:08:18.402916+00	1	audit	\N	\N	2026-06-30 10:08:18.402916+00
1051	\N	approve	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:08:26.569717+00	1	grades	\N	\N	2026-06-30 10:08:26.569717+00
1052	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:08:26.614952+00	1	users	\N	\N	2026-06-30 10:08:26.614952+00
1053	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:08:26.615675+00	1	audit	\N	\N	2026-06-30 10:08:26.615675+00
1054	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:08:26.616598+00	1	grades	\N	\N	2026-06-30 10:08:26.616598+00
1055	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:13:08.576052+00	2	courses	\N	\N	2026-06-30 10:13:08.576052+00
1056	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:13:08.626996+00	2	courses	\N	\N	2026-06-30 10:13:08.626996+00
1057	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:13:14.125187+00	8	grades	\N	\N	2026-06-30 10:13:14.125187+00
1058	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:13:14.241233+00	8	grades	\N	\N	2026-06-30 10:13:14.241233+00
1059	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:13:14.355768+00	8	grades	\N	\N	2026-06-30 10:13:14.355768+00
1060	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:13:14.368667+00	8	enrollments	\N	\N	2026-06-30 10:13:14.368667+00
1061	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:13:14.394088+00	8	grades	\N	\N	2026-06-30 10:13:14.394088+00
1062	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:13:14.399603+00	8	enrollments	\N	\N	2026-06-30 10:13:14.399603+00
1063	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:13:23.781915+00	2	courses	\N	\N	2026-06-30 10:13:23.781915+00
1064	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:13:23.813949+00	2	courses	\N	\N	2026-06-30 10:13:23.813949+00
1065	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:13:23.911529+00	2	courses	\N	\N	2026-06-30 10:13:23.911529+00
1066	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:13:23.912442+00	2	students	\N	\N	2026-06-30 10:13:23.912442+00
1067	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:13:23.914953+00	2	grades	\N	\N	2026-06-30 10:13:23.914953+00
1068	\N	submit	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:13:39.237349+00	2	grades	\N	\N	2026-06-30 10:13:39.237349+00
1069	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:13:39.273008+00	2	courses	\N	\N	2026-06-30 10:13:39.273008+00
1070	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:13:39.364107+00	2	students	\N	\N	2026-06-30 10:13:39.364107+00
1071	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:13:39.368417+00	2	grades	\N	\N	2026-06-30 10:13:39.368417+00
1072	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:13:46.039128+00	8	audit	\N	\N	2026-06-30 10:13:46.039128+00
1073	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:13:46.040091+00	8	users	\N	\N	2026-06-30 10:13:46.040091+00
1074	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:13:46.04111+00	8	grades	\N	\N	2026-06-30 10:13:46.04111+00
1075	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:13:46.162218+00	8	audit	\N	\N	2026-06-30 10:13:46.162218+00
1076	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:13:46.165274+00	8	grades	\N	\N	2026-06-30 10:13:46.165274+00
1077	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:13:46.177585+00	8	users	\N	\N	2026-06-30 10:13:46.177585+00
1078	\N	approve	\N	1	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-06-30 10:14:02.146527+00	8	grades	INSUFFICIENT_ROLE	\N	2026-06-30 10:14:02.146527+00
1079	\N	approve	\N	1	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-06-30 10:14:08.744015+00	8	grades	INSUFFICIENT_ROLE	\N	2026-06-30 10:14:08.744015+00
1080	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:14:40.896235+00	2	courses	\N	\N	2026-06-30 10:14:40.896235+00
1081	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:14:40.906016+00	2	students	\N	\N	2026-06-30 10:14:40.906016+00
1082	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:14:40.912631+00	2	grades	\N	\N	2026-06-30 10:14:40.912631+00
1083	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:14:41.754878+00	2	courses	\N	\N	2026-06-30 10:14:41.754878+00
1084	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:14:41.755472+00	2	students	\N	\N	2026-06-30 10:14:41.755472+00
1085	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:14:41.761284+00	2	grades	\N	\N	2026-06-30 10:14:41.761284+00
1086	\N	approve	\N	1	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-06-30 10:16:20.301779+00	8	grades	INSUFFICIENT_ROLE	\N	2026-06-30 10:16:20.301779+00
1087	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:29:16.508327+00	8	courses	\N	\N	2026-06-30 10:29:16.508327+00
1088	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:29:16.549547+00	8	courses	\N	\N	2026-06-30 10:29:16.549547+00
1089	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:29:17.008241+00	8	courses	\N	\N	2026-06-30 10:29:17.008241+00
1090	\N	read	\N	1	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-06-30 10:29:17.028149+00	8	students	NO_ACADEMIC_RELATIONSHIP	\N	2026-06-30 10:29:17.028149+00
1091	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:29:17.042493+00	8	grades	\N	\N	2026-06-30 10:29:17.042493+00
1092	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:29:17.294508+00	8	users	\N	\N	2026-06-30 10:29:17.294508+00
1093	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:29:17.298843+00	8	grades	\N	\N	2026-06-30 10:29:17.298843+00
1094	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:29:17.303587+00	8	audit	\N	\N	2026-06-30 10:29:17.303587+00
1095	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:29:17.693717+00	8	audit	\N	\N	2026-06-30 10:29:17.693717+00
1096	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:29:17.801285+00	8	grades	\N	\N	2026-06-30 10:29:17.801285+00
1097	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:29:17.802221+00	8	users	\N	\N	2026-06-30 10:29:17.802221+00
1098	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:29:18.051312+00	8	grades	\N	\N	2026-06-30 10:29:18.051312+00
1099	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:29:18.052491+00	8	grades	\N	\N	2026-06-30 10:29:18.052491+00
1100	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:29:18.053103+00	8	enrollments	\N	\N	2026-06-30 10:29:18.053103+00
1101	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:29:18.081283+00	8	enrollments	\N	\N	2026-06-30 10:29:18.081283+00
1102	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:29:18.083982+00	8	grades	\N	\N	2026-06-30 10:29:18.083982+00
1103	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:29:18.123571+00	8	grades	\N	\N	2026-06-30 10:29:18.123571+00
1104	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:30:13.784303+00	1	users	\N	\N	2026-06-30 10:30:13.784303+00
1105	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:30:13.902961+00	1	users	\N	\N	2026-06-30 10:30:13.902961+00
1106	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:30:13.977832+00	1	grades	\N	\N	2026-06-30 10:30:13.977832+00
1107	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:30:13.978365+00	1	audit	\N	\N	2026-06-30 10:30:13.978365+00
1108	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:30:14.038175+00	1	audit	\N	\N	2026-06-30 10:30:14.038175+00
1109	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:30:14.038921+00	1	grades	\N	\N	2026-06-30 10:30:14.038921+00
1110	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:30:30.30897+00	2	courses	\N	\N	2026-06-30 10:30:30.30897+00
1111	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:30:30.351995+00	2	courses	\N	\N	2026-06-30 10:30:30.351995+00
1112	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:30:51.369656+00	8	grades	\N	\N	2026-06-30 10:30:51.369656+00
1113	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:30:51.428392+00	8	enrollments	\N	\N	2026-06-30 10:30:51.428392+00
1114	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:30:51.435843+00	8	grades	\N	\N	2026-06-30 10:30:51.435843+00
1115	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:30:51.468958+00	8	grades	\N	\N	2026-06-30 10:30:51.468958+00
1116	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:30:51.528479+00	8	enrollments	\N	\N	2026-06-30 10:30:51.528479+00
1117	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:30:51.529007+00	8	grades	\N	\N	2026-06-30 10:30:51.529007+00
1118	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:30:56.899823+00	2	courses	\N	\N	2026-06-30 10:30:56.899823+00
1119	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:30:56.934982+00	2	courses	\N	\N	2026-06-30 10:30:56.934982+00
1120	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:30:57.007893+00	2	courses	\N	\N	2026-06-30 10:30:57.007893+00
1121	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:30:57.010401+00	2	grades	\N	\N	2026-06-30 10:30:57.010401+00
1122	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:30:57.01667+00	2	students	\N	\N	2026-06-30 10:30:57.01667+00
1123	\N	approve	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:12.03501+00	1	grades	\N	\N	2026-06-30 10:31:12.03501+00
1124	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:12.070178+00	1	users	\N	\N	2026-06-30 10:31:12.070178+00
1125	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:12.195976+00	1	grades	\N	\N	2026-06-30 10:31:12.195976+00
1126	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:12.205357+00	1	audit	\N	\N	2026-06-30 10:31:12.205357+00
1127	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:20.815195+00	2	students	\N	\N	2026-06-30 10:31:20.815195+00
1128	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:20.816593+00	2	grades	\N	\N	2026-06-30 10:31:20.816593+00
1129	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:20.818653+00	2	courses	\N	\N	2026-06-30 10:31:20.818653+00
1130	\N	submit	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:24.100477+00	2	grades	\N	\N	2026-06-30 10:31:24.100477+00
1131	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:24.128213+00	2	courses	\N	\N	2026-06-30 10:31:24.128213+00
1132	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:24.128987+00	2	students	\N	\N	2026-06-30 10:31:24.128987+00
1133	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:24.132541+00	2	grades	\N	\N	2026-06-30 10:31:24.132541+00
1134	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:29.839724+00	1	users	\N	\N	2026-06-30 10:31:29.839724+00
1135	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:29.840181+00	1	audit	\N	\N	2026-06-30 10:31:29.840181+00
1136	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:29.840687+00	1	grades	\N	\N	2026-06-30 10:31:29.840687+00
1137	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:30.658214+00	1	users	\N	\N	2026-06-30 10:31:30.658214+00
1138	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:30.65893+00	1	audit	\N	\N	2026-06-30 10:31:30.65893+00
1139	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:30.659336+00	1	grades	\N	\N	2026-06-30 10:31:30.659336+00
1140	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:30.761475+00	1	audit	\N	\N	2026-06-30 10:31:30.761475+00
1141	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:30.763111+00	1	grades	\N	\N	2026-06-30 10:31:30.763111+00
1142	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:30.798276+00	1	users	\N	\N	2026-06-30 10:31:30.798276+00
1143	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:31.034054+00	1	users	\N	\N	2026-06-30 10:31:31.034054+00
1144	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:31.034669+00	1	audit	\N	\N	2026-06-30 10:31:31.034669+00
1145	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:31.035218+00	1	grades	\N	\N	2026-06-30 10:31:31.035218+00
1146	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:31.096322+00	1	audit	\N	\N	2026-06-30 10:31:31.096322+00
1147	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:31.100321+00	1	grades	\N	\N	2026-06-30 10:31:31.100321+00
1148	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:31.127196+00	1	users	\N	\N	2026-06-30 10:31:31.127196+00
1149	\N	approve	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:35.316598+00	1	grades	\N	\N	2026-06-30 10:31:35.316598+00
1150	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:35.34806+00	1	users	\N	\N	2026-06-30 10:31:35.34806+00
1151	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:35.348827+00	1	audit	\N	\N	2026-06-30 10:31:35.348827+00
1152	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:35.349282+00	1	grades	\N	\N	2026-06-30 10:31:35.349282+00
1153	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:43.667116+00	2	courses	\N	\N	2026-06-30 10:31:43.667116+00
1154	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:43.667513+00	2	students	\N	\N	2026-06-30 10:31:43.667513+00
1155	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:43.670012+00	2	grades	\N	\N	2026-06-30 10:31:43.670012+00
1156	\N	submit	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:44.867448+00	2	grades	\N	\N	2026-06-30 10:31:44.867448+00
1157	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:44.894288+00	2	courses	\N	\N	2026-06-30 10:31:44.894288+00
1158	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:44.894828+00	2	students	\N	\N	2026-06-30 10:31:44.894828+00
1159	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:44.897862+00	2	grades	\N	\N	2026-06-30 10:31:44.897862+00
1160	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:49.538302+00	1	users	\N	\N	2026-06-30 10:31:49.538302+00
1161	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:49.53875+00	1	audit	\N	\N	2026-06-30 10:31:49.53875+00
1162	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:49.539266+00	1	grades	\N	\N	2026-06-30 10:31:49.539266+00
1163	\N	approve	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:51.941934+00	1	grades	\N	\N	2026-06-30 10:31:51.941934+00
1164	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:51.966241+00	1	users	\N	\N	2026-06-30 10:31:51.966241+00
1165	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:51.967105+00	1	audit	\N	\N	2026-06-30 10:31:51.967105+00
1166	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:51.967954+00	1	grades	\N	\N	2026-06-30 10:31:51.967954+00
1167	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:58.337488+00	2	courses	\N	\N	2026-06-30 10:31:58.337488+00
1168	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:58.337959+00	2	students	\N	\N	2026-06-30 10:31:58.337959+00
1169	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:31:58.339432+00	2	grades	\N	\N	2026-06-30 10:31:58.339432+00
1170	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:32:10.897507+00	8	enrollments	\N	\N	2026-06-30 10:32:10.897507+00
1171	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:32:10.948932+00	8	grades	\N	\N	2026-06-30 10:32:10.948932+00
1172	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:32:11.014685+00	8	grades	\N	\N	2026-06-30 10:32:11.014685+00
1173	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:32:11.062405+00	8	grades	\N	\N	2026-06-30 10:32:11.062405+00
1174	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:32:11.064844+00	8	enrollments	\N	\N	2026-06-30 10:32:11.064844+00
1175	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:32:11.094455+00	8	grades	\N	\N	2026-06-30 10:32:11.094455+00
1176	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:41:46.259049+00	1	users	\N	\N	2026-06-30 10:41:46.259049+00
1177	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:41:46.289505+00	1	users	\N	\N	2026-06-30 10:41:46.289505+00
1178	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:43:37.296531+00	1	users	\N	\N	2026-06-30 10:43:37.296531+00
1179	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:43:46.549204+00	1	users	\N	\N	2026-06-30 10:43:46.549204+00
1180	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:43:54.01351+00	1	periods	\N	\N	2026-06-30 10:43:54.01351+00
1181	\N	write	\N	policy-config	GRANTED	\N	::1	\N	{"layer": "ALL", "message": "Global Access Control policy redeployed"}	2026-06-30 10:43:54.020011+00	1	periods	\N	\N	2026-06-30 10:43:54.020011+00
1182	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:43:54.031549+00	1	users	\N	\N	2026-06-30 10:43:54.031549+00
1183	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:43:59.64057+00	1	users	\N	\N	2026-06-30 10:43:59.64057+00
1184	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:44:29.202958+00	1	users	\N	\N	2026-06-30 10:44:29.202958+00
1185	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:44:45.269679+00	1	users	\N	\N	2026-06-30 10:44:45.269679+00
1186	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:47:22.150115+00	8	users	\N	\N	2026-06-30 10:47:22.150115+00
1187	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:47:22.185852+00	8	users	\N	\N	2026-06-30 10:47:22.185852+00
1188	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:48:32.607552+00	8	users	\N	\N	2026-06-30 10:48:32.607552+00
1189	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:48:32.6559+00	8	users	\N	\N	2026-06-30 10:48:32.6559+00
1190	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:48:36.503549+00	8	users	\N	\N	2026-06-30 10:48:36.503549+00
1191	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:48:36.540674+00	8	users	\N	\N	2026-06-30 10:48:36.540674+00
1192	\N	write	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-06-30 10:50:17.013441+00	8	periods	INSUFFICIENT_ROLE	\N	2026-06-30 10:50:17.013441+00
1193	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:55:24.335221+00	1	users	\N	\N	2026-06-30 10:55:24.335221+00
1194	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:55:24.470507+00	1	users	\N	\N	2026-06-30 10:55:24.470507+00
1195	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:55:24.51887+00	1	grades	\N	\N	2026-06-30 10:55:24.51887+00
1196	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:55:24.547737+00	1	audit	\N	\N	2026-06-30 10:55:24.547737+00
1197	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:55:24.584157+00	1	grades	\N	\N	2026-06-30 10:55:24.584157+00
1198	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:55:24.61472+00	1	audit	\N	\N	2026-06-30 10:55:24.61472+00
1199	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:55:31.177549+00	1	users	\N	\N	2026-06-30 10:55:31.177549+00
1200	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:55:31.204723+00	1	users	\N	\N	2026-06-30 10:55:31.204723+00
1201	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:55:52.828161+00	1	periods	\N	\N	2026-06-30 10:55:52.828161+00
1202	\N	write	\N	policy-config	GRANTED	\N	::1	\N	{"layer": "ALL", "message": "Global Access Control policy redeployed"}	2026-06-30 10:55:52.831796+00	1	periods	\N	\N	2026-06-30 10:55:52.831796+00
1203	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:55:52.844373+00	1	users	\N	\N	2026-06-30 10:55:52.844373+00
1204	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:56:16.843738+00	1	users	\N	\N	2026-06-30 10:56:16.843738+00
1205	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:56:16.897402+00	1	users	\N	\N	2026-06-30 10:56:16.897402+00
1206	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:56:28.265881+00	1	periods	\N	\N	2026-06-30 10:56:28.265881+00
1207	\N	write	\N	policy-config	GRANTED	\N	::1	\N	{"layer": "ALL", "message": "Global Access Control policy redeployed"}	2026-06-30 10:56:28.269942+00	1	periods	\N	\N	2026-06-30 10:56:28.269942+00
1208	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:56:28.282455+00	1	users	\N	\N	2026-06-30 10:56:28.282455+00
1209	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:57:28.360682+00	1	periods	\N	\N	2026-06-30 10:57:28.360682+00
1210	\N	write	\N	policy-config	GRANTED	\N	::1	\N	{"layer": "ALL", "message": "Global Access Control policy redeployed"}	2026-06-30 10:57:28.366028+00	1	periods	\N	\N	2026-06-30 10:57:28.366028+00
1211	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:57:28.380528+00	1	users	\N	\N	2026-06-30 10:57:28.380528+00
1212	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:57:56.532625+00	4	grades	\N	\N	2026-06-30 10:57:56.532625+00
1213	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:57:56.544266+00	4	grades	\N	\N	2026-06-30 10:57:56.544266+00
1214	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:57:56.610668+00	4	grades	\N	\N	2026-06-30 10:57:56.610668+00
1215	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:57:56.619707+00	4	grades	\N	\N	2026-06-30 10:57:56.619707+00
1216	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:57:56.625474+00	4	enrollments	\N	\N	2026-06-30 10:57:56.625474+00
1217	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:57:56.671233+00	4	enrollments	\N	\N	2026-06-30 10:57:56.671233+00
1218	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:58:14.252581+00	4	courses	\N	\N	2026-06-30 10:58:14.252581+00
1219	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:58:14.287914+00	4	courses	\N	\N	2026-06-30 10:58:14.287914+00
1220	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:58:14.317213+00	4	enrollments	\N	\N	2026-06-30 10:58:14.317213+00
1221	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:58:14.338464+00	4	enrollments	\N	\N	2026-06-30 10:58:14.338464+00
1222	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:58:18.99775+00	4	grades	\N	\N	2026-06-30 10:58:18.99775+00
1223	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:58:18.998109+00	4	grades	\N	\N	2026-06-30 10:58:18.998109+00
1224	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:58:19.042892+00	4	grades	\N	\N	2026-06-30 10:58:19.042892+00
1225	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:58:19.056892+00	4	grades	\N	\N	2026-06-30 10:58:19.056892+00
1226	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:58:23.977985+00	4	courses	\N	\N	2026-06-30 10:58:23.977985+00
1227	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:58:23.984516+00	4	enrollments	\N	\N	2026-06-30 10:58:23.984516+00
1228	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:58:24.023674+00	4	courses	\N	\N	2026-06-30 10:58:24.023674+00
1229	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 10:58:24.040767+00	4	enrollments	\N	\N	2026-06-30 10:58:24.040767+00
1230	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 11:00:09.552315+00	1	users	\N	\N	2026-06-30 11:00:09.552315+00
1231	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 11:00:09.644098+00	1	users	\N	\N	2026-06-30 11:00:09.644098+00
1232	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 11:00:09.733622+00	1	audit	\N	\N	2026-06-30 11:00:09.733622+00
1233	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 11:00:09.736292+00	1	grades	\N	\N	2026-06-30 11:00:09.736292+00
1234	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 11:00:09.791768+00	1	audit	\N	\N	2026-06-30 11:00:09.791768+00
1235	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 11:00:09.792109+00	1	grades	\N	\N	2026-06-30 11:00:09.792109+00
1236	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 11:00:14.431683+00	1	users	\N	\N	2026-06-30 11:00:14.431683+00
1237	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 11:00:14.462236+00	1	users	\N	\N	2026-06-30 11:00:14.462236+00
1238	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 11:00:18.252845+00	1	periods	\N	\N	2026-06-30 11:00:18.252845+00
1239	\N	write	\N	policy-config	GRANTED	\N	::1	\N	{"layer": "ALL", "message": "Global Access Control policy redeployed"}	2026-06-30 11:00:18.25663+00	1	periods	\N	\N	2026-06-30 11:00:18.25663+00
1240	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 11:00:18.273782+00	1	users	\N	\N	2026-06-30 11:00:18.273782+00
1241	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-06-30 11:00:46.255815+00	4	enrollments	INSUFFICIENT_ROLE	\N	2026-06-30 11:00:46.255815+00
1242	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-06-30 11:00:46.278252+00	4	grades	INSUFFICIENT_ROLE	\N	2026-06-30 11:00:46.278252+00
1243	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-06-30 11:00:46.326963+00	4	grades	INSUFFICIENT_ROLE	\N	2026-06-30 11:00:46.326963+00
1244	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-06-30 11:00:46.327575+00	4	grades	INSUFFICIENT_ROLE	\N	2026-06-30 11:00:46.327575+00
1245	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-06-30 11:00:46.360779+00	4	enrollments	INSUFFICIENT_ROLE	\N	2026-06-30 11:00:46.360779+00
1246	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-06-30 11:00:46.38969+00	4	grades	INSUFFICIENT_ROLE	\N	2026-06-30 11:00:46.38969+00
1247	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-06-30 11:01:15.90717+00	4	grades	INSUFFICIENT_ROLE	\N	2026-06-30 11:01:15.90717+00
1248	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-06-30 11:01:15.930147+00	4	grades	INSUFFICIENT_ROLE	\N	2026-06-30 11:01:15.930147+00
1249	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-06-30 11:01:16.001992+00	4	grades	INSUFFICIENT_ROLE	\N	2026-06-30 11:01:16.001992+00
1250	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-06-30 11:01:16.003735+00	4	grades	INSUFFICIENT_ROLE	\N	2026-06-30 11:01:16.003735+00
1251	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-06-30 11:01:20.372909+00	4	courses	INSUFFICIENT_ROLE	\N	2026-06-30 11:01:20.372909+00
1252	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-06-30 11:01:20.382528+00	4	enrollments	INSUFFICIENT_ROLE	\N	2026-06-30 11:01:20.382528+00
1253	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-06-30 11:01:20.415075+00	4	courses	INSUFFICIENT_ROLE	\N	2026-06-30 11:01:20.415075+00
1254	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-06-30 11:01:20.421997+00	4	enrollments	INSUFFICIENT_ROLE	\N	2026-06-30 11:01:20.421997+00
1255	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-06-30 11:01:21.184756+00	4	grades	INSUFFICIENT_ROLE	\N	2026-06-30 11:01:21.184756+00
1256	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-06-30 11:01:21.185653+00	4	enrollments	INSUFFICIENT_ROLE	\N	2026-06-30 11:01:21.185653+00
1257	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-06-30 11:01:21.227218+00	4	grades	INSUFFICIENT_ROLE	\N	2026-06-30 11:01:21.227218+00
1258	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-06-30 11:01:21.228486+00	4	enrollments	INSUFFICIENT_ROLE	\N	2026-06-30 11:01:21.228486+00
1259	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-06-30 11:01:21.318176+00	4	grades	INSUFFICIENT_ROLE	\N	2026-06-30 11:01:21.318176+00
1260	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-06-30 11:01:21.333292+00	4	grades	INSUFFICIENT_ROLE	\N	2026-06-30 11:01:21.333292+00
1261	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 11:15:05.339444+00	1	users	\N	\N	2026-06-30 11:15:05.339444+00
1262	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 11:15:05.446344+00	1	users	\N	\N	2026-06-30 11:15:05.446344+00
1263	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 11:15:05.534724+00	1	grades	\N	\N	2026-06-30 11:15:05.534724+00
1264	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 11:15:05.535037+00	1	audit	\N	\N	2026-06-30 11:15:05.535037+00
1265	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 11:15:05.575788+00	1	audit	\N	\N	2026-06-30 11:15:05.575788+00
1266	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 11:15:05.576113+00	1	grades	\N	\N	2026-06-30 11:15:05.576113+00
1267	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 11:15:10.783209+00	1	users	\N	\N	2026-06-30 11:15:10.783209+00
1268	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 11:15:10.812109+00	1	users	\N	\N	2026-06-30 11:15:10.812109+00
1269	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 11:15:14.836711+00	1	periods	\N	\N	2026-06-30 11:15:14.836711+00
1270	\N	write	\N	policy-config	GRANTED	\N	::1	\N	{"layer": "ALL", "message": "Global Access Control policy redeployed"}	2026-06-30 11:15:14.839556+00	1	periods	\N	\N	2026-06-30 11:15:14.839556+00
1271	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 11:15:14.858147+00	1	users	\N	\N	2026-06-30 11:15:14.858147+00
1272	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 11:15:18.557878+00	1	users	\N	\N	2026-06-30 11:15:18.557878+00
1273	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 11:15:18.583095+00	1	users	\N	\N	2026-06-30 11:15:18.583095+00
1274	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 20:58:46.202966+00	1	users	\N	\N	2026-06-30 20:58:46.202966+00
1275	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 20:58:46.434644+00	1	audit	\N	\N	2026-06-30 20:58:46.434644+00
1276	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 20:58:46.525278+00	1	grades	\N	\N	2026-06-30 20:58:46.525278+00
1277	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 20:58:46.537331+00	1	users	\N	\N	2026-06-30 20:58:46.537331+00
1278	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 20:58:46.542938+00	1	audit	\N	\N	2026-06-30 20:58:46.542938+00
1279	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 20:58:46.672011+00	1	grades	\N	\N	2026-06-30 20:58:46.672011+00
1280	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 20:58:49.191667+00	1	users	\N	\N	2026-06-30 20:58:49.191667+00
1281	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 20:58:49.235558+00	1	users	\N	\N	2026-06-30 20:58:49.235558+00
1282	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 20:58:49.86029+00	1	users	\N	\N	2026-06-30 20:58:49.86029+00
1283	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 20:58:49.904495+00	1	users	\N	\N	2026-06-30 20:58:49.904495+00
1284	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 20:58:52.030931+00	1	users	\N	\N	2026-06-30 20:58:52.030931+00
1285	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 20:58:52.067086+00	1	users	\N	\N	2026-06-30 20:58:52.067086+00
1286	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 20:59:55.56901+00	1	users	\N	\N	2026-06-30 20:59:55.56901+00
1287	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 21:00:44.163138+00	1	users	\N	\N	2026-06-30 21:00:44.163138+00
1288	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 21:01:35.394351+00	1	users	\N	\N	2026-06-30 21:01:35.394351+00
1289	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 21:01:46.776831+00	1	users	\N	\N	2026-06-30 21:01:46.776831+00
1290	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 21:06:03.279093+00	1	users	\N	\N	2026-06-30 21:06:03.279093+00
1291	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 21:06:07.186621+00	1	users	\N	\N	2026-06-30 21:06:07.186621+00
1292	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 21:06:51.3932+00	1	users	\N	\N	2026-06-30 21:06:51.3932+00
1293	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 21:06:51.444542+00	1	users	\N	\N	2026-06-30 21:06:51.444542+00
1294	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 21:09:31.348366+00	1	users	\N	\N	2026-06-30 21:09:31.348366+00
1295	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 21:09:31.396751+00	1	users	\N	\N	2026-06-30 21:09:31.396751+00
1296	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 21:09:31.421971+00	1	users	\N	\N	2026-06-30 21:09:31.421971+00
1297	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 21:09:31.464802+00	1	users	\N	\N	2026-06-30 21:09:31.464802+00
1298	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 21:14:32.795961+00	1	users	\N	\N	2026-06-30 21:14:32.795961+00
1299	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-30 21:14:32.820912+00	1	sessions	SESSION_EXPIRED	/	2026-06-30 21:14:32.820912+00
1413	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 17:56:11.716543+00	1	grades	\N	\N	2026-07-03 17:56:11.716543+00
1300	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-30 21:14:33.784278+00	1	sessions	SESSION_EXPIRED	/1	2026-06-30 21:14:33.784278+00
1301	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-30 21:14:35.395781+00	1	sessions	SESSION_EXPIRED	/1	2026-06-30 21:14:35.395781+00
1302	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-30 21:14:36.252991+00	1	sessions	SESSION_EXPIRED	/1	2026-06-30 21:14:36.252991+00
1303	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-30 21:14:40.908154+00	1	sessions	SESSION_EXPIRED	/1	2026-06-30 21:14:40.908154+00
1304	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-30 21:14:47.313479+00	1	sessions	SESSION_EXPIRED	/1	2026-06-30 21:14:47.313479+00
1305	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-30 21:14:48.19021+00	1	sessions	SESSION_EXPIRED	/1	2026-06-30 21:14:48.19021+00
1306	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-30 21:14:48.687549+00	1	sessions	SESSION_EXPIRED	/1	2026-06-30 21:14:48.687549+00
1307	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-30 21:27:54.361068+00	1	sessions	SESSION_EXPIRED	/	2026-06-30 21:27:54.361068+00
1308	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-30 21:27:54.359388+00	1	sessions	SESSION_EXPIRED	/access-matrix	2026-06-30 21:27:54.359388+00
1309	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-30 21:27:54.443997+00	1	sessions	SESSION_EXPIRED	/me	2026-06-30 21:27:54.443997+00
1310	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-30 21:29:29.535091+00	1	sessions	SESSION_EXPIRED	/me	2026-06-30 21:29:29.535091+00
1311	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-30 21:29:29.539891+00	1	sessions	SESSION_EXPIRED	/access-matrix	2026-06-30 21:29:29.539891+00
1312	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-30 21:29:29.68519+00	1	sessions	SESSION_EXPIRED	/me	2026-06-30 21:29:29.68519+00
1313	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-30 21:29:29.700117+00	1	sessions	SESSION_EXPIRED	/access-matrix	2026-06-30 21:29:29.700117+00
1314	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-30 21:29:30.329587+00	1	sessions	SESSION_EXPIRED	/me	2026-06-30 21:29:30.329587+00
1315	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-30 21:29:30.330539+00	1	sessions	SESSION_EXPIRED	/access-matrix	2026-06-30 21:29:30.330539+00
1316	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-30 21:29:30.379727+00	1	sessions	SESSION_EXPIRED	/me	2026-06-30 21:29:30.379727+00
1317	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-30 21:29:30.382996+00	1	sessions	SESSION_EXPIRED	/access-matrix	2026-06-30 21:29:30.382996+00
1318	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-30 21:29:30.50818+00	1	sessions	SESSION_EXPIRED	/	2026-06-30 21:29:30.50818+00
1319	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-30 21:29:30.521216+00	1	sessions	SESSION_EXPIRED	/	2026-06-30 21:29:30.521216+00
1320	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 21:35:44.825878+00	1	users	\N	\N	2026-06-30 21:35:44.825878+00
1321	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 21:35:44.968975+00	1	users	\N	\N	2026-06-30 21:35:44.968975+00
1322	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 21:35:45.04792+00	1	grades	\N	\N	2026-06-30 21:35:45.04792+00
1323	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 21:35:45.063894+00	1	audit	\N	\N	2026-06-30 21:35:45.063894+00
1324	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 21:35:45.128341+00	1	grades	\N	\N	2026-06-30 21:35:45.128341+00
1325	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 21:35:45.128692+00	1	audit	\N	\N	2026-06-30 21:35:45.128692+00
1326	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 21:35:58.920713+00	1	users	\N	\N	2026-06-30 21:35:58.920713+00
1327	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 21:35:58.953249+00	1	users	\N	\N	2026-06-30 21:35:58.953249+00
1328	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 21:35:58.986968+00	1	users	\N	\N	2026-06-30 21:35:58.986968+00
1329	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 21:35:59.031309+00	1	users	\N	\N	2026-06-30 21:35:59.031309+00
1330	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 21:36:06.860191+00	1	users	\N	\N	2026-06-30 21:36:06.860191+00
1331	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-30 21:36:06.878237+00	1	sessions	SESSION_EXPIRED	/	2026-06-30 21:36:06.878237+00
1332	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-30 21:36:08.360232+00	1	sessions	SESSION_EXPIRED	/1	2026-06-30 21:36:08.360232+00
1333	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:10:32.490212+00	1	users	\N	\N	2026-06-30 22:10:32.490212+00
1334	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:10:32.639708+00	1	users	\N	\N	2026-06-30 22:10:32.639708+00
1335	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:10:32.704345+00	1	audit	\N	\N	2026-06-30 22:10:32.704345+00
1336	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:10:32.764837+00	1	grades	\N	\N	2026-06-30 22:10:32.764837+00
1337	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:10:32.776377+00	1	audit	\N	\N	2026-06-30 22:10:32.776377+00
1338	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:10:32.841369+00	1	grades	\N	\N	2026-06-30 22:10:32.841369+00
1339	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:10:36.611538+00	1	users	\N	\N	2026-06-30 22:10:36.611538+00
1340	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:10:36.612318+00	1	users	\N	\N	2026-06-30 22:10:36.612318+00
1341	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:10:36.66476+00	1	users	\N	\N	2026-06-30 22:10:36.66476+00
1342	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:10:36.665248+00	1	users	\N	\N	2026-06-30 22:10:36.665248+00
1343	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:10:39.648252+00	1	users	\N	\N	2026-06-30 22:10:39.648252+00
1414	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 17:56:11.805354+00	1	audit	\N	\N	2026-07-03 17:56:11.805354+00
1344	\N	AUTH_CHECK	\N	\N	DENIED_ROLE	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	{}	2026-06-30 22:10:39.665085+00	1	sessions	SESSION_EXPIRED	/	2026-06-30 22:10:39.665085+00
1345	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:24:25.537198+00	1	users	\N	\N	2026-06-30 22:24:25.537198+00
1346	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:24:25.693748+00	1	users	\N	\N	2026-06-30 22:24:25.693748+00
1347	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:24:25.784733+00	1	users	\N	\N	2026-06-30 22:24:25.784733+00
1348	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:24:25.883034+00	1	users	\N	\N	2026-06-30 22:24:25.883034+00
1349	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:24:54.079858+00	1	users	\N	\N	2026-06-30 22:24:54.079858+00
1350	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:24:54.115424+00	1	users	\N	\N	2026-06-30 22:24:54.115424+00
1351	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:24:54.278108+00	1	users	\N	\N	2026-06-30 22:24:54.278108+00
1352	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:24:54.305151+00	1	users	\N	\N	2026-06-30 22:24:54.305151+00
1353	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:25:07.392167+00	1	users	\N	\N	2026-06-30 22:25:07.392167+00
1354	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:25:07.425246+00	1	users	\N	\N	2026-06-30 22:25:07.425246+00
1355	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:25:14.648702+00	1	users	\N	\N	2026-06-30 22:25:14.648702+00
1356	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:25:14.680452+00	1	users	\N	\N	2026-06-30 22:25:14.680452+00
1357	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:26:02.883944+00	1	users	\N	\N	2026-06-30 22:26:02.883944+00
1358	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:26:02.935469+00	1	users	\N	\N	2026-06-30 22:26:02.935469+00
1359	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:26:02.967999+00	1	users	\N	\N	2026-06-30 22:26:02.967999+00
1360	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:26:03.03271+00	1	users	\N	\N	2026-06-30 22:26:03.03271+00
1361	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:29:12.515451+00	1	users	\N	\N	2026-06-30 22:29:12.515451+00
1362	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:29:12.658861+00	1	users	\N	\N	2026-06-30 22:29:12.658861+00
1363	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:29:12.780744+00	1	grades	\N	\N	2026-06-30 22:29:12.780744+00
1364	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:29:12.800699+00	1	audit	\N	\N	2026-06-30 22:29:12.800699+00
1365	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:29:12.866299+00	1	grades	\N	\N	2026-06-30 22:29:12.866299+00
1366	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:29:12.894359+00	1	audit	\N	\N	2026-06-30 22:29:12.894359+00
1367	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:29:17.579203+00	1	users	\N	\N	2026-06-30 22:29:17.579203+00
1368	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:29:17.579728+00	1	users	\N	\N	2026-06-30 22:29:17.579728+00
1369	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:29:17.632399+00	1	users	\N	\N	2026-06-30 22:29:17.632399+00
1370	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:29:17.644188+00	1	users	\N	\N	2026-06-30 22:29:17.644188+00
1371	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:29:25.351989+00	1	users	\N	\N	2026-06-30 22:29:25.351989+00
1372	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:29:25.377615+00	1	users	\N	\N	2026-06-30 22:29:25.377615+00
1373	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:30:22.932915+00	1	users	\N	\N	2026-06-30 22:30:22.932915+00
1374	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:30:22.959168+00	1	users	\N	\N	2026-06-30 22:30:22.959168+00
1375	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:30:25.938137+00	1	users	\N	\N	2026-06-30 22:30:25.938137+00
1376	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:30:25.958436+00	1	users	\N	\N	2026-06-30 22:30:25.958436+00
1377	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:30:32.170815+00	1	users	\N	\N	2026-06-30 22:30:32.170815+00
1378	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:30:32.209735+00	1	users	\N	\N	2026-06-30 22:30:32.209735+00
1379	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:56:30.041815+00	1	users	\N	\N	2026-06-30 22:56:30.041815+00
1380	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:56:30.2167+00	1	users	\N	\N	2026-06-30 22:56:30.2167+00
1381	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:56:30.326335+00	1	audit	\N	\N	2026-06-30 22:56:30.326335+00
1382	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:56:30.410477+00	1	audit	\N	\N	2026-06-30 22:56:30.410477+00
1383	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:56:30.458677+00	1	grades	\N	\N	2026-06-30 22:56:30.458677+00
1384	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:56:30.500916+00	1	grades	\N	\N	2026-06-30 22:56:30.500916+00
1385	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:58:00.244754+00	2	courses	\N	\N	2026-06-30 22:58:00.244754+00
1386	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:58:00.338305+00	2	courses	\N	\N	2026-06-30 22:58:00.338305+00
1387	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:58:27.021758+00	8	grades	\N	\N	2026-06-30 22:58:27.021758+00
1388	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:58:27.120545+00	8	grades	\N	\N	2026-06-30 22:58:27.120545+00
1389	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:58:27.358585+00	8	enrollments	\N	\N	2026-06-30 22:58:27.358585+00
1390	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:58:27.398799+00	8	grades	\N	\N	2026-06-30 22:58:27.398799+00
1391	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:58:27.430951+00	8	enrollments	\N	\N	2026-06-30 22:58:27.430951+00
1392	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 22:58:27.470518+00	8	grades	\N	\N	2026-06-30 22:58:27.470518+00
1393	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 23:06:02.250605+00	1	users	\N	\N	2026-06-30 23:06:02.250605+00
1394	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 23:06:02.485818+00	1	grades	\N	\N	2026-06-30 23:06:02.485818+00
1395	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 23:06:02.551979+00	1	audit	\N	\N	2026-06-30 23:06:02.551979+00
1396	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 23:06:02.658434+00	1	users	\N	\N	2026-06-30 23:06:02.658434+00
1397	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 23:06:02.660283+00	1	grades	\N	\N	2026-06-30 23:06:02.660283+00
1398	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 23:06:02.669354+00	1	audit	\N	\N	2026-06-30 23:06:02.669354+00
1399	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 23:06:05.037005+00	1	users	\N	\N	2026-06-30 23:06:05.037005+00
1400	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 23:06:05.03763+00	1	users	\N	\N	2026-06-30 23:06:05.03763+00
1401	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 23:06:05.067585+00	1	users	\N	\N	2026-06-30 23:06:05.067585+00
1402	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 23:06:05.083395+00	1	users	\N	\N	2026-06-30 23:06:05.083395+00
1403	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 23:12:37.623386+00	1	users	\N	\N	2026-06-30 23:12:37.623386+00
1404	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 23:12:38.482304+00	1	users	\N	\N	2026-06-30 23:12:38.482304+00
1405	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 23:13:13.751183+00	10	grades	\N	\N	2026-06-30 23:13:13.751183+00
1406	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 23:13:13.808544+00	10	grades	\N	\N	2026-06-30 23:13:13.808544+00
1407	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 23:13:13.834115+00	10	enrollments	\N	\N	2026-06-30 23:13:13.834115+00
1408	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 23:13:13.851474+00	10	grades	\N	\N	2026-06-30 23:13:13.851474+00
1409	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 23:13:13.896181+00	10	grades	\N	\N	2026-06-30 23:13:13.896181+00
1410	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-06-30 23:13:13.916779+00	10	enrollments	\N	\N	2026-06-30 23:13:13.916779+00
1411	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 17:56:11.398734+00	1	users	\N	\N	2026-07-03 17:56:11.398734+00
1412	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 17:56:11.613138+00	1	users	\N	\N	2026-07-03 17:56:11.613138+00
1415	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 17:56:11.882055+00	1	grades	\N	\N	2026-07-03 17:56:11.882055+00
1416	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 17:56:11.908268+00	1	audit	\N	\N	2026-07-03 17:56:11.908268+00
1417	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 17:56:21.563843+00	1	users	\N	\N	2026-07-03 17:56:21.563843+00
1420	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 17:56:21.751703+00	1	audit	\N	\N	2026-07-03 17:56:21.751703+00
1418	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 17:56:21.573918+00	1	audit	\N	\N	2026-07-03 17:56:21.573918+00
1422	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 17:56:21.754464+00	1	users	\N	\N	2026-07-03 17:56:21.754464+00
1419	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 17:56:21.713209+00	1	grades	\N	\N	2026-07-03 17:56:21.713209+00
1421	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 17:56:21.752502+00	1	grades	\N	\N	2026-07-03 17:56:21.752502+00
1424	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:03:58.54086+00	1	users	\N	\N	2026-07-03 18:03:58.54086+00
1423	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:03:58.526101+00	1	users	\N	\N	2026-07-03 18:03:58.526101+00
1425	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:03:58.604189+00	1	users	\N	\N	2026-07-03 18:03:58.604189+00
1426	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:03:58.622208+00	1	users	\N	\N	2026-07-03 18:03:58.622208+00
1427	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:04:03.01864+00	1	users	\N	\N	2026-07-03 18:04:03.01864+00
1428	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:04:03.073784+00	1	users	\N	\N	2026-07-03 18:04:03.073784+00
1429	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:04:30.593741+00	1	users	\N	\N	2026-07-03 18:04:30.593741+00
1430	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:04:30.680427+00	1	users	\N	\N	2026-07-03 18:04:30.680427+00
1431	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:04:30.781023+00	1	users	\N	\N	2026-07-03 18:04:30.781023+00
1432	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:04:30.814876+00	1	users	\N	\N	2026-07-03 18:04:30.814876+00
1433	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:39:07.212503+00	1	grades	\N	\N	2026-07-03 18:39:07.212503+00
1435	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:39:07.258729+00	1	users	\N	\N	2026-07-03 18:39:07.258729+00
1434	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:39:07.211915+00	1	audit	\N	\N	2026-07-03 18:39:07.211915+00
1436	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:39:07.410371+00	1	grades	\N	\N	2026-07-03 18:39:07.410371+00
1437	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:39:07.457641+00	1	audit	\N	\N	2026-07-03 18:39:07.457641+00
1438	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:39:07.56879+00	1	users	\N	\N	2026-07-03 18:39:07.56879+00
1439	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:40:15.652417+00	2	courses	\N	\N	2026-07-03 18:40:15.652417+00
1440	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:40:15.731293+00	2	courses	\N	\N	2026-07-03 18:40:15.731293+00
1441	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:40:33.352185+00	1	users	\N	\N	2026-07-03 18:40:33.352185+00
1442	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:40:33.392405+00	1	users	\N	\N	2026-07-03 18:40:33.392405+00
1443	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:51:59.946656+00	2	courses	\N	\N	2026-07-03 18:51:59.946656+00
1444	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:52:00.001647+00	2	courses	\N	\N	2026-07-03 18:52:00.001647+00
1445	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:52:35.751788+00	2	courses	\N	\N	2026-07-03 18:52:35.751788+00
1446	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:52:35.811133+00	2	courses	\N	\N	2026-07-03 18:52:35.811133+00
1447	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:52:35.942851+00	2	courses	\N	\N	2026-07-03 18:52:35.942851+00
1448	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:52:35.943369+00	2	students	\N	\N	2026-07-03 18:52:35.943369+00
1449	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:52:35.957912+00	2	grades	\N	\N	2026-07-03 18:52:35.957912+00
1450	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:57:06.233594+00	2	users	\N	\N	2026-07-03 18:57:06.233594+00
1451	\N	read	\N	\N	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-07-03 18:57:06.314636+00	2	grades	NO_ACADEMIC_RELATIONSHIP	\N	2026-07-03 18:57:06.314636+00
1452	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:57:06.328672+00	2	audit	\N	\N	2026-07-03 18:57:06.328672+00
1453	\N	read	\N	\N	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-07-03 18:57:06.412663+00	2	grades	NO_ACADEMIC_RELATIONSHIP	\N	2026-07-03 18:57:06.412663+00
1454	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:57:06.416694+00	2	users	\N	\N	2026-07-03 18:57:06.416694+00
1455	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:57:06.472567+00	2	audit	\N	\N	2026-07-03 18:57:06.472567+00
1456	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:57:10.162276+00	2	users	\N	\N	2026-07-03 18:57:10.162276+00
1457	\N	read	\N	\N	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-07-03 18:57:10.246572+00	2	grades	NO_ACADEMIC_RELATIONSHIP	\N	2026-07-03 18:57:10.246572+00
1458	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:57:10.24764+00	2	audit	\N	\N	2026-07-03 18:57:10.24764+00
1459	\N	read	\N	\N	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-07-03 18:57:10.41079+00	2	grades	NO_ACADEMIC_RELATIONSHIP	\N	2026-07-03 18:57:10.41079+00
1460	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:57:10.412228+00	2	users	\N	\N	2026-07-03 18:57:10.412228+00
1461	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:57:10.47971+00	2	audit	\N	\N	2026-07-03 18:57:10.47971+00
1462	\N	read	\N	\N	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-07-03 18:57:19.253155+00	2	grades	NO_ACADEMIC_RELATIONSHIP	\N	2026-07-03 18:57:19.253155+00
1463	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:57:19.255859+00	2	users	\N	\N	2026-07-03 18:57:19.255859+00
1464	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:57:19.258158+00	2	audit	\N	\N	2026-07-03 18:57:19.258158+00
1465	\N	read	\N	\N	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-07-03 18:57:19.405939+00	2	grades	NO_ACADEMIC_RELATIONSHIP	\N	2026-07-03 18:57:19.405939+00
1466	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:57:19.439051+00	2	audit	\N	\N	2026-07-03 18:57:19.439051+00
1467	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:57:19.43961+00	2	users	\N	\N	2026-07-03 18:57:19.43961+00
1468	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:57:21.37814+00	2	users	\N	\N	2026-07-03 18:57:21.37814+00
1469	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:57:21.41305+00	2	users	\N	\N	2026-07-03 18:57:21.41305+00
1470	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:57:23.16855+00	2	users	\N	\N	2026-07-03 18:57:23.16855+00
1471	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:57:23.1692+00	2	users	\N	\N	2026-07-03 18:57:23.1692+00
1472	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:57:23.224665+00	2	users	\N	\N	2026-07-03 18:57:23.224665+00
1473	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:57:23.253454+00	2	users	\N	\N	2026-07-03 18:57:23.253454+00
1474	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:59:58.653153+00	2	audit	\N	\N	2026-07-03 18:59:58.653153+00
1475	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:59:58.844403+00	2	audit	\N	\N	2026-07-03 18:59:58.844403+00
1476	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:59:59.100651+00	2	audit	\N	\N	2026-07-03 18:59:59.100651+00
1477	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 18:59:59.209913+00	2	audit	\N	\N	2026-07-03 18:59:59.209913+00
1478	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 19:11:13.054041+00	2	users	\N	\N	2026-07-03 19:11:13.054041+00
1479	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 19:11:13.102246+00	2	users	\N	\N	2026-07-03 19:11:13.102246+00
1480	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 19:11:18.279916+00	2	users	\N	\N	2026-07-03 19:11:18.279916+00
1481	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 19:11:18.307347+00	2	users	\N	\N	2026-07-03 19:11:18.307347+00
1482	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 19:11:18.337355+00	2	users	\N	\N	2026-07-03 19:11:18.337355+00
1483	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 19:11:18.366331+00	2	users	\N	\N	2026-07-03 19:11:18.366331+00
1484	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 19:14:45.893881+00	2	courses	\N	\N	2026-07-03 19:14:45.893881+00
1485	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 19:14:45.964105+00	2	courses	\N	\N	2026-07-03 19:14:45.964105+00
1486	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 19:14:49.174406+00	2	courses	\N	\N	2026-07-03 19:14:49.174406+00
1487	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 19:14:49.224297+00	2	courses	\N	\N	2026-07-03 19:14:49.224297+00
1488	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 19:14:49.340002+00	2	courses	\N	\N	2026-07-03 19:14:49.340002+00
1491	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 19:14:56.71719+00	2	courses	\N	\N	2026-07-03 19:14:56.71719+00
1496	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 19:14:59.955242+00	2	students	\N	\N	2026-07-03 19:14:59.955242+00
1498	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 19:15:01.271381+00	2	courses	\N	\N	2026-07-03 19:15:01.271381+00
1489	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 19:14:49.340569+00	2	students	\N	\N	2026-07-03 19:14:49.340569+00
1497	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 19:14:59.960121+00	2	grades	\N	\N	2026-07-03 19:14:59.960121+00
1490	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 19:14:49.354388+00	2	grades	\N	\N	2026-07-03 19:14:49.354388+00
1492	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 19:14:56.793582+00	2	courses	\N	\N	2026-07-03 19:14:56.793582+00
1493	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 19:14:59.806669+00	2	courses	\N	\N	2026-07-03 19:14:59.806669+00
1494	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 19:14:59.851911+00	2	courses	\N	\N	2026-07-03 19:14:59.851911+00
1495	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 19:14:59.947872+00	2	courses	\N	\N	2026-07-03 19:14:59.947872+00
1499	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 19:15:01.313735+00	2	courses	\N	\N	2026-07-03 19:15:01.313735+00
1502	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 20:13:34.444435+00	2	audit	\N	\N	2026-07-03 20:13:34.444435+00
1501	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 20:13:34.434557+00	2	users	\N	\N	2026-07-03 20:13:34.434557+00
1500	\N	read	\N	\N	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-07-03 20:13:34.428917+00	2	grades	NO_ACADEMIC_RELATIONSHIP	\N	2026-07-03 20:13:34.428917+00
1504	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 20:13:34.657581+00	2	users	\N	\N	2026-07-03 20:13:34.657581+00
1503	\N	read	\N	\N	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-07-03 20:13:34.656468+00	2	grades	NO_ACADEMIC_RELATIONSHIP	\N	2026-07-03 20:13:34.656468+00
1505	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 20:13:34.661945+00	2	audit	\N	\N	2026-07-03 20:13:34.661945+00
1506	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 20:14:02.027768+00	2	users	\N	\N	2026-07-03 20:14:02.027768+00
1507	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 20:14:02.028147+00	2	users	\N	\N	2026-07-03 20:14:02.028147+00
1508	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 20:14:02.072462+00	2	users	\N	\N	2026-07-03 20:14:02.072462+00
1509	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 20:14:02.079689+00	2	users	\N	\N	2026-07-03 20:14:02.079689+00
1510	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 20:14:13.99891+00	2	users	\N	\N	2026-07-03 20:14:13.99891+00
1511	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 20:14:14.088552+00	2	users	\N	\N	2026-07-03 20:14:14.088552+00
1512	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:00:00.201263+00	2	audit	\N	\N	2026-07-03 21:00:00.201263+00
1513	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:00:00.253697+00	2	audit	\N	\N	2026-07-03 21:00:00.253697+00
1514	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:00:00.35663+00	2	audit	\N	\N	2026-07-03 21:00:00.35663+00
1515	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:00:00.401671+00	2	audit	\N	\N	2026-07-03 21:00:00.401671+00
1516	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:03:06.907948+00	1	audit	\N	\N	2026-07-03 21:03:06.907948+00
1517	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:07:13.769829+00	2	audit	\N	\N	2026-07-03 21:07:13.769829+00
1518	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:07:13.879328+00	2	audit	\N	\N	2026-07-03 21:07:13.879328+00
1519	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:07:13.96239+00	2	audit	\N	\N	2026-07-03 21:07:13.96239+00
1520	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:07:14.052762+00	2	audit	\N	\N	2026-07-03 21:07:14.052762+00
1521	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:16:57.964046+00	2	audit	\N	\N	2026-07-03 21:16:57.964046+00
1522	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:16:58.040175+00	2	courses	\N	\N	2026-07-03 21:16:58.040175+00
1523	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:17:07.087571+00	2	students	\N	\N	2026-07-03 21:17:07.087571+00
1524	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:17:07.089888+00	2	grades	\N	\N	2026-07-03 21:17:07.089888+00
1525	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:17:07.092299+00	2	courses	\N	\N	2026-07-03 21:17:07.092299+00
1526	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:17:14.836426+00	2	audit	\N	\N	2026-07-03 21:17:14.836426+00
1527	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:17:14.836744+00	2	audit	\N	\N	2026-07-03 21:17:14.836744+00
1528	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:17:15.040767+00	2	audit	\N	\N	2026-07-03 21:17:15.040767+00
1529	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:17:15.041516+00	2	audit	\N	\N	2026-07-03 21:17:15.041516+00
1530	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:17:18.59627+00	2	audit	\N	\N	2026-07-03 21:17:18.59627+00
1531	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:17:18.597321+00	2	courses	\N	\N	2026-07-03 21:17:18.597321+00
1532	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:17:18.705413+00	2	audit	\N	\N	2026-07-03 21:17:18.705413+00
1533	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:17:18.705787+00	2	courses	\N	\N	2026-07-03 21:17:18.705787+00
1534	\N	read	\N	2	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:17:22.673255+00	2	courses	\N	\N	2026-07-03 21:17:22.673255+00
1535	\N	read	\N	2	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:17:22.673981+00	2	students	\N	\N	2026-07-03 21:17:22.673981+00
1536	\N	read	\N	2	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:17:22.703171+00	2	grades	\N	\N	2026-07-03 21:17:22.703171+00
1537	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:30:02.651408+00	2	audit	\N	\N	2026-07-03 21:30:02.651408+00
1538	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:30:02.715789+00	2	users	\N	\N	2026-07-03 21:30:02.715789+00
1539	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:30:02.810116+00	2	audit	\N	\N	2026-07-03 21:30:02.810116+00
1540	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:30:02.886239+00	2	users	\N	\N	2026-07-03 21:30:02.886239+00
1541	\N	read	\N	\N	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-07-03 21:30:02.888682+00	2	grades	NO_ACADEMIC_RELATIONSHIP	\N	2026-07-03 21:30:02.888682+00
1542	\N	read	\N	\N	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-07-03 21:30:02.949044+00	2	grades	NO_ACADEMIC_RELATIONSHIP	\N	2026-07-03 21:30:02.949044+00
1543	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:31:36.805429+00	2	users	\N	\N	2026-07-03 21:31:36.805429+00
1544	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:31:36.983368+00	2	audit	\N	\N	2026-07-03 21:31:36.983368+00
1545	\N	read	\N	\N	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-07-03 21:31:37.067346+00	2	grades	NO_ACADEMIC_RELATIONSHIP	\N	2026-07-03 21:31:37.067346+00
1546	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:31:37.183806+00	2	users	\N	\N	2026-07-03 21:31:37.183806+00
1547	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-03 21:31:37.333508+00	2	audit	\N	\N	2026-07-03 21:31:37.333508+00
1548	\N	read	\N	\N	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-07-03 21:31:37.484975+00	2	grades	NO_ACADEMIC_RELATIONSHIP	\N	2026-07-03 21:31:37.484975+00
1549	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 16:56:09.081039+00	1	users	\N	\N	2026-07-04 16:56:09.081039+00
1550	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 16:56:09.427322+00	1	users	\N	\N	2026-07-04 16:56:09.427322+00
1552	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 16:56:09.432158+00	1	grades	\N	\N	2026-07-04 16:56:09.432158+00
1551	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 16:56:09.431282+00	1	audit	\N	\N	2026-07-04 16:56:09.431282+00
1553	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 16:56:09.651489+00	1	audit	\N	\N	2026-07-04 16:56:09.651489+00
1554	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 16:56:09.662975+00	1	grades	\N	\N	2026-07-04 16:56:09.662975+00
1555	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:05:58.175148+00	1	users	\N	\N	2026-07-04 17:05:58.175148+00
1556	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:05:58.297844+00	1	users	\N	\N	2026-07-04 17:05:58.297844+00
1557	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:05:58.346432+00	1	users	\N	\N	2026-07-04 17:05:58.346432+00
1558	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:05:58.518589+00	1	users	\N	\N	2026-07-04 17:05:58.518589+00
1559	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:06:03.002436+00	1	users	\N	\N	2026-07-04 17:06:03.002436+00
1560	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:06:03.006182+00	1	audit	\N	\N	2026-07-04 17:06:03.006182+00
1561	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:06:03.213609+00	1	grades	\N	\N	2026-07-04 17:06:03.213609+00
1563	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:06:03.436008+00	1	grades	\N	\N	2026-07-04 17:06:03.436008+00
1562	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:06:03.239719+00	1	users	\N	\N	2026-07-04 17:06:03.239719+00
1564	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:06:03.521708+00	1	audit	\N	\N	2026-07-04 17:06:03.521708+00
1565	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:16:04.907721+00	1	audit	\N	\N	2026-07-04 17:16:04.907721+00
1566	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:16:04.908741+00	1	courses	\N	\N	2026-07-04 17:16:04.908741+00
1567	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:16:05.060394+00	1	audit	\N	\N	2026-07-04 17:16:05.060394+00
1568	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:16:05.066528+00	1	courses	\N	\N	2026-07-04 17:16:05.066528+00
1569	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:16:05.699071+00	1	users	\N	\N	2026-07-04 17:16:05.699071+00
1570	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:16:05.712133+00	1	users	\N	\N	2026-07-04 17:16:05.712133+00
1571	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:16:05.803234+00	1	users	\N	\N	2026-07-04 17:16:05.803234+00
1572	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:16:05.804338+00	1	users	\N	\N	2026-07-04 17:16:05.804338+00
1573	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:16:06.523039+00	1	users	\N	\N	2026-07-04 17:16:06.523039+00
1574	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:16:06.641563+00	1	users	\N	\N	2026-07-04 17:16:06.641563+00
1575	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:16:07.459917+00	1	audit	\N	\N	2026-07-04 17:16:07.459917+00
1576	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:16:07.4609+00	1	audit	\N	\N	2026-07-04 17:16:07.4609+00
1577	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:16:07.612229+00	1	audit	\N	\N	2026-07-04 17:16:07.612229+00
1578	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:16:07.756973+00	1	audit	\N	\N	2026-07-04 17:16:07.756973+00
1579	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:16:10.74755+00	1	users	\N	\N	2026-07-04 17:16:10.74755+00
1580	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:16:10.749378+00	1	users	\N	\N	2026-07-04 17:16:10.749378+00
1581	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:16:10.857378+00	1	users	\N	\N	2026-07-04 17:16:10.857378+00
1582	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:16:10.872603+00	1	users	\N	\N	2026-07-04 17:16:10.872603+00
1583	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:32:28.219362+00	1	users	\N	\N	2026-07-04 17:32:28.219362+00
1584	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:32:28.412826+00	1	audit	\N	\N	2026-07-04 17:32:28.412826+00
1585	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:32:28.42259+00	1	grades	\N	\N	2026-07-04 17:32:28.42259+00
1586	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:32:28.735832+00	1	grades	\N	\N	2026-07-04 17:32:28.735832+00
1587	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:32:28.736946+00	1	audit	\N	\N	2026-07-04 17:32:28.736946+00
1588	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:32:28.860059+00	1	users	\N	\N	2026-07-04 17:32:28.860059+00
1589	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:34:40.906917+00	1	grades	\N	\N	2026-07-04 17:34:40.906917+00
1590	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:34:40.983975+00	1	audit	\N	\N	2026-07-04 17:34:40.983975+00
1591	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:34:41.198215+00	1	users	\N	\N	2026-07-04 17:34:41.198215+00
1592	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:39:10.108924+00	1	users	\N	\N	2026-07-04 17:39:10.108924+00
1593	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:39:10.343484+00	1	users	\N	\N	2026-07-04 17:39:10.343484+00
1594	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:39:10.528882+00	1	grades	\N	\N	2026-07-04 17:39:10.528882+00
1595	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:39:10.541897+00	1	audit	\N	\N	2026-07-04 17:39:10.541897+00
1596	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:39:10.764845+00	1	audit	\N	\N	2026-07-04 17:39:10.764845+00
1597	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:39:11.031679+00	1	grades	\N	\N	2026-07-04 17:39:11.031679+00
1598	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:55:37.225147+00	6	grades	\N	\N	2026-07-04 17:55:37.225147+00
1599	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:55:37.41676+00	6	grades	\N	\N	2026-07-04 17:55:37.41676+00
1600	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:55:37.675277+00	6	grades	\N	\N	2026-07-04 17:55:37.675277+00
1601	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:55:37.808278+00	6	grades	\N	\N	2026-07-04 17:55:37.808278+00
1602	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:55:37.994667+00	6	enrollments	\N	\N	2026-07-04 17:55:37.994667+00
1603	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:55:38.048861+00	6	enrollments	\N	\N	2026-07-04 17:55:38.048861+00
1604	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:58:11.151696+00	6	grades	\N	\N	2026-07-04 17:58:11.151696+00
1605	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:58:13.380299+00	6	enrollments	\N	\N	2026-07-04 17:58:13.380299+00
1606	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 17:58:13.483942+00	6	grades	\N	\N	2026-07-04 17:58:13.483942+00
1607	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 18:00:00.585547+00	6	grades	\N	\N	2026-07-04 18:00:00.585547+00
1608	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 18:00:00.717961+00	6	grades	\N	\N	2026-07-04 18:00:00.717961+00
1609	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 18:00:00.737925+00	6	enrollments	\N	\N	2026-07-04 18:00:00.737925+00
1610	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 18:00:00.923348+00	6	enrollments	\N	\N	2026-07-04 18:00:00.923348+00
1611	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 18:00:00.932834+00	6	grades	\N	\N	2026-07-04 18:00:00.932834+00
1612	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 18:00:01.021264+00	6	grades	\N	\N	2026-07-04 18:00:01.021264+00
1613	\N	read	\N	999	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 18:02:59.00151+00	6	grades	\N	\N	2026-07-04 18:02:59.00151+00
1614	\N	read	\N	999	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 18:03:28.257877+00	6	grades	\N	\N	2026-07-04 18:03:28.257877+00
1615	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 18:03:42.038737+00	6	grades	\N	\N	2026-07-04 18:03:42.038737+00
1616	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 18:04:17.180409+00	6	enrollments	\N	\N	2026-07-04 18:04:17.180409+00
1617	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 18:04:17.233251+00	6	grades	\N	\N	2026-07-04 18:04:17.233251+00
1618	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 18:04:17.354697+00	6	enrollments	\N	\N	2026-07-04 18:04:17.354697+00
1619	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 18:04:17.357078+00	6	grades	\N	\N	2026-07-04 18:04:17.357078+00
1620	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 18:04:17.443477+00	6	grades	\N	\N	2026-07-04 18:04:17.443477+00
1621	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 18:04:17.505363+00	6	grades	\N	\N	2026-07-04 18:04:17.505363+00
1622	\N	read	\N	999	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 18:04:22.789029+00	6	grades	\N	\N	2026-07-04 18:04:22.789029+00
1623	\N	read	\N	999	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 18:07:33.364674+00	6	grades	\N	\N	2026-07-04 18:07:33.364674+00
1624	\N	read	\N	999	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 18:09:23.754856+00	6	grades	\N	\N	2026-07-04 18:09:23.754856+00
1625	\N	read	\N	999	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 18:38:13.326144+00	6	grades	\N	\N	2026-07-04 18:38:13.326144+00
1626	\N	read	\N	999	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 18:55:03.460591+00	6	grades	\N	\N	2026-07-04 18:55:03.460591+00
1627	\N	read	\N	999	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 18:55:05.708115+00	6	grades	\N	\N	2026-07-04 18:55:05.708115+00
1628	\N	read	\N	999	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 18:55:09.721069+00	6	grades	\N	\N	2026-07-04 18:55:09.721069+00
1629	\N	read	\N	999	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 18:55:14.873732+00	6	grades	\N	\N	2026-07-04 18:55:14.873732+00
1630	\N	read	\N	999	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 19:19:34.304269+00	6	grades	\N	\N	2026-07-04 19:19:34.304269+00
1697	\N	read	\N	999	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:20:35.876799+00	6	grades	\N	\N	2026-07-05 19:20:35.876799+00
1631	\N	read	\N	999	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-07-04 19:19:45.394044+00	6	courses	NO_ACADEMIC_RELATIONSHIP	\N	2026-07-04 19:19:45.394044+00
1632	\N	read	\N	999	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 19:20:02.809986+00	6	grades	\N	\N	2026-07-04 19:20:02.809986+00
1633	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 19:20:07.573086+00	6	grades	\N	\N	2026-07-04 19:20:07.573086+00
1634	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 19:20:48.551649+00	6	grades	\N	\N	2026-07-04 19:20:48.551649+00
1635	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 19:20:48.601087+00	6	enrollments	\N	\N	2026-07-04 19:20:48.601087+00
1636	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 19:20:48.748445+00	6	grades	\N	\N	2026-07-04 19:20:48.748445+00
1637	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 19:23:22.644987+00	6	grades	\N	\N	2026-07-04 19:23:22.644987+00
1638	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 19:23:22.882054+00	6	enrollments	\N	\N	2026-07-04 19:23:22.882054+00
1639	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 19:23:23.052915+00	6	grades	\N	\N	2026-07-04 19:23:23.052915+00
1640	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 19:23:23.27914+00	6	grades	\N	\N	2026-07-04 19:23:23.27914+00
1641	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 19:23:23.345189+00	6	enrollments	\N	\N	2026-07-04 19:23:23.345189+00
1642	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 19:23:23.392869+00	6	grades	\N	\N	2026-07-04 19:23:23.392869+00
1643	\N	read	\N	999	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 19:43:55.433479+00	6	grades	\N	\N	2026-07-04 19:43:55.433479+00
1644	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 19:44:03.195271+00	6	grades	\N	\N	2026-07-04 19:44:03.195271+00
1645	\N	read	\N	999	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-07-04 19:44:09.168548+00	6	courses	NO_ACADEMIC_RELATIONSHIP	\N	2026-07-04 19:44:09.168548+00
1646	\N	read	\N	999	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-07-04 19:44:37.697528+00	6	courses	NO_ACADEMIC_RELATIONSHIP	\N	2026-07-04 19:44:37.697528+00
1647	\N	read	\N	999	DENIED_RELATIONSHIP	\N	::1	\N	{"layer": "RELATIONSHIP"}	2026-07-04 19:52:03.60155+00	6	courses	NO_ACADEMIC_RELATIONSHIP	\N	2026-07-04 19:52:03.60155+00
1648	\N	read	\N	999	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 19:52:09.59273+00	6	grades	\N	\N	2026-07-04 19:52:09.59273+00
1649	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 22:10:39.061779+00	6	grades	\N	\N	2026-07-04 22:10:39.061779+00
1650	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 22:10:39.136859+00	6	grades	\N	\N	2026-07-04 22:10:39.136859+00
1651	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 22:10:39.213098+00	6	enrollments	\N	\N	2026-07-04 22:10:39.213098+00
1652	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 22:10:39.22105+00	6	grades	\N	\N	2026-07-04 22:10:39.22105+00
1653	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 22:10:39.222797+00	6	grades	\N	\N	2026-07-04 22:10:39.222797+00
1654	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 22:10:39.323366+00	6	enrollments	\N	\N	2026-07-04 22:10:39.323366+00
1655	\N	read	\N	999	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 22:15:35.647378+00	6	grades	\N	\N	2026-07-04 22:15:35.647378+00
1656	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 22:26:44.662254+00	6	grades	\N	\N	2026-07-04 22:26:44.662254+00
1657	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 22:26:44.693961+00	6	enrollments	\N	\N	2026-07-04 22:26:44.693961+00
1658	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 22:26:44.709354+00	6	grades	\N	\N	2026-07-04 22:26:44.709354+00
1659	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 22:26:45.002327+00	6	grades	\N	\N	2026-07-04 22:26:45.002327+00
1660	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 22:26:45.017466+00	6	grades	\N	\N	2026-07-04 22:26:45.017466+00
1661	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 22:26:45.020832+00	6	enrollments	\N	\N	2026-07-04 22:26:45.020832+00
1662	\N	read	\N	999	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 22:26:48.514959+00	6	grades	\N	\N	2026-07-04 22:26:48.514959+00
1663	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 22:28:18.913981+00	6	grades	\N	\N	2026-07-04 22:28:18.913981+00
1664	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 22:28:19.027802+00	6	grades	\N	\N	2026-07-04 22:28:19.027802+00
1665	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 22:28:19.112886+00	6	enrollments	\N	\N	2026-07-04 22:28:19.112886+00
1666	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 22:28:19.31373+00	6	grades	\N	\N	2026-07-04 22:28:19.31373+00
1667	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 22:28:19.443407+00	6	enrollments	\N	\N	2026-07-04 22:28:19.443407+00
1668	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 22:28:19.574026+00	6	grades	\N	\N	2026-07-04 22:28:19.574026+00
1669	\N	read	\N	999	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 22:28:21.135681+00	6	grades	\N	\N	2026-07-04 22:28:21.135681+00
1670	\N	read	\N	999	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 22:28:29.858958+00	6	grades	\N	\N	2026-07-04 22:28:29.858958+00
1671	\N	read	\N	999	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 22:37:12.269961+00	6	grades	\N	\N	2026-07-04 22:37:12.269961+00
1672	\N	read	\N	999	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 22:37:16.180695+00	6	grades	\N	\N	2026-07-04 22:37:16.180695+00
1673	\N	read	\N	999	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-04 22:42:27.169965+00	6	grades	\N	\N	2026-07-04 22:42:27.169965+00
1674	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 18:35:03.508918+00	1	users	\N	\N	2026-07-05 18:35:03.508918+00
1675	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 18:35:03.795146+00	1	users	\N	\N	2026-07-05 18:35:03.795146+00
1676	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 18:35:03.800853+00	1	grades	\N	\N	2026-07-05 18:35:03.800853+00
1677	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 18:35:03.970217+00	1	grades	\N	\N	2026-07-05 18:35:03.970217+00
1678	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 18:35:04.009765+00	1	audit	\N	\N	2026-07-05 18:35:04.009765+00
1679	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 18:35:04.143725+00	1	audit	\N	\N	2026-07-05 18:35:04.143725+00
1680	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:14:37.874419+00	6	enrollments	\N	\N	2026-07-05 19:14:37.874419+00
1681	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:14:37.95663+00	6	grades	\N	\N	2026-07-05 19:14:37.95663+00
1682	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:14:38.008377+00	6	grades	\N	\N	2026-07-05 19:14:38.008377+00
1683	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:14:38.092266+00	6	enrollments	\N	\N	2026-07-05 19:14:38.092266+00
1684	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:14:38.169249+00	6	grades	\N	\N	2026-07-05 19:14:38.169249+00
1685	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:14:38.170484+00	6	grades	\N	\N	2026-07-05 19:14:38.170484+00
1686	\N	read	\N	999	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:15:11.291372+00	6	grades	\N	\N	2026-07-05 19:15:11.291372+00
1687	\N	read	\N	999	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:16:25.329121+00	6	grades	\N	\N	2026-07-05 19:16:25.329121+00
1688	\N	read	\N	999	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:16:30.410779+00	6	grades	\N	\N	2026-07-05 19:16:30.410779+00
1689	\N	read	\N	999	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:16:33.255132+00	6	grades	\N	\N	2026-07-05 19:16:33.255132+00
1690	\N	read	\N	999	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:16:48.795126+00	6	grades	\N	\N	2026-07-05 19:16:48.795126+00
1691	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:20:31.547179+00	6	grades	\N	\N	2026-07-05 19:20:31.547179+00
1692	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:20:31.579636+00	6	enrollments	\N	\N	2026-07-05 19:20:31.579636+00
1693	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:20:31.771868+00	6	grades	\N	\N	2026-07-05 19:20:31.771868+00
1694	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:20:31.950613+00	6	enrollments	\N	\N	2026-07-05 19:20:31.950613+00
1695	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:20:31.951432+00	6	grades	\N	\N	2026-07-05 19:20:31.951432+00
1696	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:20:31.959279+00	6	grades	\N	\N	2026-07-05 19:20:31.959279+00
1698	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:20:42.459629+00	6	grades	\N	\N	2026-07-05 19:20:42.459629+00
1699	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:03.695352+00	1	users	\N	\N	2026-07-05 19:32:03.695352+00
1700	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:03.927797+00	1	users	\N	\N	2026-07-05 19:32:03.927797+00
1701	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:04.098819+00	1	audit	\N	\N	2026-07-05 19:32:04.098819+00
1702	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:04.100776+00	1	grades	\N	\N	2026-07-05 19:32:04.100776+00
1703	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:04.268811+00	1	audit	\N	\N	2026-07-05 19:32:04.268811+00
1704	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:04.489018+00	1	grades	\N	\N	2026-07-05 19:32:04.489018+00
1705	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:12.949767+00	1	courses	\N	\N	2026-07-05 19:32:12.949767+00
1706	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:12.95417+00	1	audit	\N	\N	2026-07-05 19:32:12.95417+00
1707	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:13.141051+00	1	courses	\N	\N	2026-07-05 19:32:13.141051+00
1708	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:13.185597+00	1	audit	\N	\N	2026-07-05 19:32:13.185597+00
1709	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:18.199554+00	1	users	\N	\N	2026-07-05 19:32:18.199554+00
1710	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:18.201209+00	1	audit	\N	\N	2026-07-05 19:32:18.201209+00
1711	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:18.203272+00	1	grades	\N	\N	2026-07-05 19:32:18.203272+00
1712	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:18.509047+00	1	grades	\N	\N	2026-07-05 19:32:18.509047+00
1713	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:18.512558+00	1	audit	\N	\N	2026-07-05 19:32:18.512558+00
1714	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:18.671431+00	1	users	\N	\N	2026-07-05 19:32:18.671431+00
1715	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:20.36113+00	1	users	\N	\N	2026-07-05 19:32:20.36113+00
1716	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:20.363017+00	1	users	\N	\N	2026-07-05 19:32:20.363017+00
1717	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:20.429259+00	1	users	\N	\N	2026-07-05 19:32:20.429259+00
1718	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:20.443939+00	1	users	\N	\N	2026-07-05 19:32:20.443939+00
1719	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:25.033402+00	1	users	\N	\N	2026-07-05 19:32:25.033402+00
1720	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:25.07152+00	1	users	\N	\N	2026-07-05 19:32:25.07152+00
1721	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:36.084563+00	1	periods	\N	\N	2026-07-05 19:32:36.084563+00
1722	\N	write	\N	policy-config	GRANTED	\N	::1	\N	{"layer": "ALL", "message": "Global Access Control policy redeployed"}	2026-07-05 19:32:36.096643+00	1	periods	\N	\N	2026-07-05 19:32:36.096643+00
1723	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:36.123662+00	1	users	\N	\N	2026-07-05 19:32:36.123662+00
1724	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:42.547213+00	1	grades	\N	\N	2026-07-05 19:32:42.547213+00
1725	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:42.621602+00	1	grades	\N	\N	2026-07-05 19:32:42.621602+00
1726	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:42.713714+00	1	enrollments	\N	\N	2026-07-05 19:32:42.713714+00
1727	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:42.799818+00	1	enrollments	\N	\N	2026-07-05 19:32:42.799818+00
1728	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:42.97244+00	1	grades	\N	\N	2026-07-05 19:32:42.97244+00
1729	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:43.034821+00	1	grades	\N	\N	2026-07-05 19:32:43.034821+00
1730	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:47.429777+00	1	grades	\N	\N	2026-07-05 19:32:47.429777+00
1731	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:55.681028+00	1	grades	\N	\N	2026-07-05 19:32:55.681028+00
1732	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:55.748233+00	1	enrollments	\N	\N	2026-07-05 19:32:55.748233+00
1733	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:55.834652+00	1	grades	\N	\N	2026-07-05 19:32:55.834652+00
1734	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:55.885645+00	1	grades	\N	\N	2026-07-05 19:32:55.885645+00
1735	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:55.914769+00	1	enrollments	\N	\N	2026-07-05 19:32:55.914769+00
1736	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 19:32:56.028423+00	1	grades	\N	\N	2026-07-05 19:32:56.028423+00
1737	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-07-05 19:33:25.841806+00	6	enrollments	INSUFFICIENT_ROLE	\N	2026-07-05 19:33:25.841806+00
1738	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-07-05 19:33:25.872709+00	6	grades	INSUFFICIENT_ROLE	\N	2026-07-05 19:33:25.872709+00
1739	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-07-05 19:33:25.994592+00	6	grades	INSUFFICIENT_ROLE	\N	2026-07-05 19:33:25.994592+00
1740	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-07-05 19:33:25.996271+00	6	enrollments	INSUFFICIENT_ROLE	\N	2026-07-05 19:33:25.996271+00
1741	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-07-05 19:33:26.051174+00	6	grades	INSUFFICIENT_ROLE	\N	2026-07-05 19:33:26.051174+00
1742	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-07-05 19:33:26.115368+00	6	grades	INSUFFICIENT_ROLE	\N	2026-07-05 19:33:26.115368+00
1743	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-07-05 19:33:28.938676+00	6	grades	INSUFFICIENT_ROLE	\N	2026-07-05 19:33:28.938676+00
1744	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-07-05 19:33:39.296057+00	6	grades	INSUFFICIENT_ROLE	\N	2026-07-05 19:33:39.296057+00
1745	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-07-05 19:34:03.230792+00	6	grades	INSUFFICIENT_ROLE	\N	2026-07-05 19:34:03.230792+00
1746	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-07-05 19:45:51.634867+00	6	grades	INSUFFICIENT_ROLE	\N	2026-07-05 19:45:51.634867+00
1747	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:27:40.988295+00	2	courses	\N	\N	2026-07-05 20:27:40.988295+00
1748	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:27:41.084577+00	2	courses	\N	\N	2026-07-05 20:27:41.084577+00
1749	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:27:48.726173+00	2	courses	\N	\N	2026-07-05 20:27:48.726173+00
1750	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:27:48.795891+00	2	courses	\N	\N	2026-07-05 20:27:48.795891+00
1751	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:27:48.990212+00	2	courses	\N	\N	2026-07-05 20:27:48.990212+00
1752	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:27:48.991531+00	2	students	\N	\N	2026-07-05 20:27:48.991531+00
1753	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:27:49.060646+00	2	grades	\N	\N	2026-07-05 20:27:49.060646+00
1754	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:39:06.221744+00	2	courses	\N	\N	2026-07-05 20:39:06.221744+00
1755	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:39:06.410715+00	2	courses	\N	\N	2026-07-05 20:39:06.410715+00
1756	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:39:07.697658+00	2	courses	\N	\N	2026-07-05 20:39:07.697658+00
1757	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:39:07.719574+00	2	students	\N	\N	2026-07-05 20:39:07.719574+00
1758	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:39:07.731698+00	2	grades	\N	\N	2026-07-05 20:39:07.731698+00
1759	\N	read	\N	2	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:39:26.210774+00	2	students	\N	\N	2026-07-05 20:39:26.210774+00
1760	\N	read	\N	2	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:39:26.249196+00	2	grades	\N	\N	2026-07-05 20:39:26.249196+00
1761	\N	read	\N	2	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:39:26.307817+00	2	courses	\N	\N	2026-07-05 20:39:26.307817+00
1762	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:48:20.999109+00	2	courses	\N	\N	2026-07-05 20:48:20.999109+00
1763	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:48:21.34645+00	2	courses	\N	\N	2026-07-05 20:48:21.34645+00
1764	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:48:21.355439+00	2	students	\N	\N	2026-07-05 20:48:21.355439+00
1765	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:48:21.36509+00	2	grades	\N	\N	2026-07-05 20:48:21.36509+00
1766	\N	submit	\N	1	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-07-05 20:48:35.205028+00	2	grades	OUTSIDE_GRADING_PERIOD	\N	2026-07-05 20:48:35.205028+00
1767	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:52:29.675058+00	2	courses	\N	\N	2026-07-05 20:52:29.675058+00
1768	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:52:29.813351+00	2	courses	\N	\N	2026-07-05 20:52:29.813351+00
1769	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:52:30.802566+00	2	students	\N	\N	2026-07-05 20:52:30.802566+00
1770	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:52:30.803404+00	2	courses	\N	\N	2026-07-05 20:52:30.803404+00
1771	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:52:30.823827+00	2	grades	\N	\N	2026-07-05 20:52:30.823827+00
1772	\N	write	\N	1	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-07-05 20:52:33.582194+00	2	grades	OUTSIDE_GRADING_PERIOD	\N	2026-07-05 20:52:33.582194+00
1773	\N	write	\N	1	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-07-05 20:53:17.569036+00	2	grades	OUTSIDE_GRADING_PERIOD	\N	2026-07-05 20:53:17.569036+00
1774	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:54:00.367869+00	1	users	\N	\N	2026-07-05 20:54:00.367869+00
1775	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:54:00.714775+00	1	audit	\N	\N	2026-07-05 20:54:00.714775+00
1776	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:54:01.009611+00	1	grades	\N	\N	2026-07-05 20:54:01.009611+00
1777	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:54:01.040781+00	1	users	\N	\N	2026-07-05 20:54:01.040781+00
1778	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:54:01.200389+00	1	audit	\N	\N	2026-07-05 20:54:01.200389+00
1779	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:54:01.364708+00	1	grades	\N	\N	2026-07-05 20:54:01.364708+00
1780	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:54:43.082125+00	1	users	\N	\N	2026-07-05 20:54:43.082125+00
1781	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:54:43.144367+00	1	users	\N	\N	2026-07-05 20:54:43.144367+00
1782	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:54:50.445222+00	1	periods	\N	\N	2026-07-05 20:54:50.445222+00
1783	\N	write	\N	policy-config	GRANTED	\N	::1	\N	{"layer": "ALL", "message": "Global Access Control policy redeployed"}	2026-07-05 20:54:50.455426+00	1	periods	\N	\N	2026-07-05 20:54:50.455426+00
1784	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:54:50.483893+00	1	users	\N	\N	2026-07-05 20:54:50.483893+00
1785	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:55:10.458643+00	2	courses	\N	\N	2026-07-05 20:55:10.458643+00
1786	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:55:10.579266+00	2	courses	\N	\N	2026-07-05 20:55:10.579266+00
1787	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:55:13.459425+00	2	courses	\N	\N	2026-07-05 20:55:13.459425+00
1788	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:55:13.528055+00	2	courses	\N	\N	2026-07-05 20:55:13.528055+00
1789	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:55:13.677972+00	2	courses	\N	\N	2026-07-05 20:55:13.677972+00
1790	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:55:13.678899+00	2	students	\N	\N	2026-07-05 20:55:13.678899+00
1791	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:55:13.698274+00	2	grades	\N	\N	2026-07-05 20:55:13.698274+00
1792	\N	write	\N	1	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-07-05 20:55:16.47932+00	2	grades	OUTSIDE_GRADING_PERIOD	\N	2026-07-05 20:55:16.47932+00
1793	\N	write	\N	1	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-07-05 20:55:19.94585+00	2	grades	OUTSIDE_GRADING_PERIOD	\N	2026-07-05 20:55:19.94585+00
1794	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:55:56.329029+00	2	courses	\N	\N	2026-07-05 20:55:56.329029+00
1795	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:55:56.53845+00	2	courses	\N	\N	2026-07-05 20:55:56.53845+00
1796	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:55:57.499204+00	2	courses	\N	\N	2026-07-05 20:55:57.499204+00
1797	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:55:57.508016+00	2	grades	\N	\N	2026-07-05 20:55:57.508016+00
1798	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:55:57.514408+00	2	students	\N	\N	2026-07-05 20:55:57.514408+00
1799	\N	write	\N	1	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-07-05 20:55:59.979612+00	2	grades	OUTSIDE_GRADING_PERIOD	\N	2026-07-05 20:55:59.979612+00
1800	\N	write	\N	1	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-07-05 20:58:43.005892+00	2	grades	OUTSIDE_GRADING_PERIOD	\N	2026-07-05 20:58:43.005892+00
1801	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:58:47.537203+00	2	courses	\N	\N	2026-07-05 20:58:47.537203+00
1802	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:58:47.633892+00	2	courses	\N	\N	2026-07-05 20:58:47.633892+00
1803	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:58:48.493567+00	2	courses	\N	\N	2026-07-05 20:58:48.493567+00
1804	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:58:48.510847+00	2	students	\N	\N	2026-07-05 20:58:48.510847+00
1805	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:58:48.528433+00	2	grades	\N	\N	2026-07-05 20:58:48.528433+00
1806	\N	write	\N	1	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-07-05 20:58:53.141886+00	2	grades	OUTSIDE_GRADING_PERIOD	\N	2026-07-05 20:58:53.141886+00
1807	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:59:30.930996+00	2	courses	\N	\N	2026-07-05 20:59:30.930996+00
1808	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:59:31.023283+00	2	courses	\N	\N	2026-07-05 20:59:31.023283+00
1809	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:59:37.595897+00	2	courses	\N	\N	2026-07-05 20:59:37.595897+00
1810	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:59:37.717781+00	2	courses	\N	\N	2026-07-05 20:59:37.717781+00
1811	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:59:38.004841+00	2	courses	\N	\N	2026-07-05 20:59:38.004841+00
1812	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:59:38.03441+00	2	students	\N	\N	2026-07-05 20:59:38.03441+00
1813	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 20:59:38.041627+00	2	grades	\N	\N	2026-07-05 20:59:38.041627+00
1814	\N	write	\N	1	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-07-05 20:59:41.731006+00	2	grades	OUTSIDE_GRADING_PERIOD	\N	2026-07-05 20:59:41.731006+00
1815	\N	write	\N	1	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-07-05 21:11:31.294689+00	2	grades	OUTSIDE_GRADING_PERIOD	\N	2026-07-05 21:11:31.294689+00
1816	\N	write	\N	1	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-07-05 21:11:50.614441+00	2	grades	OUTSIDE_GRADING_PERIOD	\N	2026-07-05 21:11:50.614441+00
1817	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 21:23:06.773485+00	2	courses	\N	\N	2026-07-05 21:23:06.773485+00
1818	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 21:23:06.85593+00	2	courses	\N	\N	2026-07-05 21:23:06.85593+00
1819	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 21:23:07.171682+00	2	courses	\N	\N	2026-07-05 21:23:07.171682+00
1820	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 21:23:07.184468+00	2	students	\N	\N	2026-07-05 21:23:07.184468+00
1821	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-05 21:23:07.192962+00	2	grades	\N	\N	2026-07-05 21:23:07.192962+00
1822	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:24:26.545676+00	1	users	\N	\N	2026-07-06 20:24:26.545676+00
1823	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:24:26.772479+00	1	audit	\N	\N	2026-07-06 20:24:26.772479+00
1824	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:24:26.774089+00	1	grades	\N	\N	2026-07-06 20:24:26.774089+00
1825	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:24:26.898002+00	1	audit	\N	\N	2026-07-06 20:24:26.898002+00
1826	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:24:27.007975+00	1	grades	\N	\N	2026-07-06 20:24:27.007975+00
1827	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:24:27.030864+00	1	users	\N	\N	2026-07-06 20:24:27.030864+00
1828	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:24:29.677243+00	1	courses	\N	\N	2026-07-06 20:24:29.677243+00
1829	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:24:29.678978+00	1	audit	\N	\N	2026-07-06 20:24:29.678978+00
1834	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:24:38.338223+00	1	grades	\N	\N	2026-07-06 20:24:38.338223+00
1830	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:24:29.794936+00	1	courses	\N	\N	2026-07-06 20:24:29.794936+00
1832	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:24:38.330143+00	1	courses	\N	\N	2026-07-06 20:24:38.330143+00
1831	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:24:29.796926+00	1	audit	\N	\N	2026-07-06 20:24:29.796926+00
1833	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:24:38.33126+00	1	students	\N	\N	2026-07-06 20:24:38.33126+00
1835	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:31:49.731615+00	1	audit	\N	\N	2026-07-06 20:31:49.731615+00
1836	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:31:49.856841+00	1	audit	\N	\N	2026-07-06 20:31:49.856841+00
1837	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:31:49.961237+00	1	courses	\N	\N	2026-07-06 20:31:49.961237+00
1838	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:31:50.054907+00	1	courses	\N	\N	2026-07-06 20:31:50.054907+00
1839	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:31:55.083705+00	1	courses	\N	\N	2026-07-06 20:31:55.083705+00
1840	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:31:55.084469+00	1	students	\N	\N	2026-07-06 20:31:55.084469+00
1841	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:31:55.135786+00	1	grades	\N	\N	2026-07-06 20:31:55.135786+00
1842	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:44:38.259721+00	1	courses	\N	\N	2026-07-06 20:44:38.259721+00
1843	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:44:38.260222+00	1	audit	\N	\N	2026-07-06 20:44:38.260222+00
1844	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:44:38.383371+00	1	courses	\N	\N	2026-07-06 20:44:38.383371+00
1845	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:44:38.399559+00	1	audit	\N	\N	2026-07-06 20:44:38.399559+00
1846	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:44:40.769485+00	1	students	\N	\N	2026-07-06 20:44:40.769485+00
1847	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:44:40.775686+00	1	courses	\N	\N	2026-07-06 20:44:40.775686+00
1848	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:44:40.785994+00	1	grades	\N	\N	2026-07-06 20:44:40.785994+00
1849	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:47:11.238001+00	1	audit	\N	\N	2026-07-06 20:47:11.238001+00
1850	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:47:11.253453+00	1	courses	\N	\N	2026-07-06 20:47:11.253453+00
1851	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:47:11.41771+00	1	courses	\N	\N	2026-07-06 20:47:11.41771+00
1852	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 20:47:11.423011+00	1	audit	\N	\N	2026-07-06 20:47:11.423011+00
1853	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 21:19:17.625836+00	1	grades	\N	\N	2026-07-06 21:19:17.625836+00
1854	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 21:19:17.634224+00	1	students	\N	\N	2026-07-06 21:19:17.634224+00
1855	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 21:19:17.64514+00	1	courses	\N	\N	2026-07-06 21:19:17.64514+00
1856	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 22:24:44.831645+00	1	users	\N	\N	2026-07-06 22:24:44.831645+00
1857	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 22:24:45.065147+00	1	grades	\N	\N	2026-07-06 22:24:45.065147+00
1858	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 22:24:45.091954+00	1	audit	\N	\N	2026-07-06 22:24:45.091954+00
1859	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 22:24:45.22052+00	1	users	\N	\N	2026-07-06 22:24:45.22052+00
1860	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 22:24:45.230418+00	1	grades	\N	\N	2026-07-06 22:24:45.230418+00
1861	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 22:24:45.233524+00	1	audit	\N	\N	2026-07-06 22:24:45.233524+00
1862	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 22:29:36.159581+00	1	audit	\N	\N	2026-07-06 22:29:36.159581+00
1863	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 22:29:36.16454+00	1	grades	\N	\N	2026-07-06 22:29:36.16454+00
1864	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 22:29:36.160442+00	1	users	\N	\N	2026-07-06 22:29:36.160442+00
1865	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 22:29:37.109759+00	1	users	\N	\N	2026-07-06 22:29:37.109759+00
1866	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 22:29:37.110468+00	1	audit	\N	\N	2026-07-06 22:29:37.110468+00
1867	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 22:29:37.111124+00	1	grades	\N	\N	2026-07-06 22:29:37.111124+00
1868	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 22:55:13.531518+00	1	users	\N	\N	2026-07-06 22:55:13.531518+00
1869	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 22:55:13.532089+00	1	users	\N	\N	2026-07-06 22:55:13.532089+00
1870	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 22:55:13.624221+00	1	users	\N	\N	2026-07-06 22:55:13.624221+00
1871	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 22:55:13.629531+00	1	users	\N	\N	2026-07-06 22:55:13.629531+00
1872	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 22:55:14.764855+00	1	users	\N	\N	2026-07-06 22:55:14.764855+00
1873	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 22:55:14.767375+00	1	users	\N	\N	2026-07-06 22:55:14.767375+00
1874	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 22:55:14.823616+00	1	users	\N	\N	2026-07-06 22:55:14.823616+00
1875	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 22:55:14.825569+00	1	users	\N	\N	2026-07-06 22:55:14.825569+00
1876	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 22:55:15.732018+00	1	users	\N	\N	2026-07-06 22:55:15.732018+00
1877	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 22:55:15.733033+00	1	users	\N	\N	2026-07-06 22:55:15.733033+00
1878	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 22:55:15.838174+00	1	users	\N	\N	2026-07-06 22:55:15.838174+00
1879	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-06 22:55:15.850271+00	1	users	\N	\N	2026-07-06 22:55:15.850271+00
1880	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:37:38.4882+00	1	users	\N	\N	2026-07-07 23:37:38.4882+00
1881	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:37:38.757272+00	1	users	\N	\N	2026-07-07 23:37:38.757272+00
1882	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:37:38.760053+00	1	grades	\N	\N	2026-07-07 23:37:38.760053+00
1883	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:37:38.901396+00	1	audit	\N	\N	2026-07-07 23:37:38.901396+00
1884	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:37:38.910413+00	1	grades	\N	\N	2026-07-07 23:37:38.910413+00
1885	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:37:39.010144+00	1	audit	\N	\N	2026-07-07 23:37:39.010144+00
1886	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:37:43.555441+00	1	users	\N	\N	2026-07-07 23:37:43.555441+00
1887	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:37:43.613563+00	1	users	\N	\N	2026-07-07 23:37:43.613563+00
1888	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:37:47.953805+00	1	audit	\N	\N	2026-07-07 23:37:47.953805+00
1889	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:37:47.954458+00	1	audit	\N	\N	2026-07-07 23:37:47.954458+00
1890	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:37:48.081509+00	1	audit	\N	\N	2026-07-07 23:37:48.081509+00
1891	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:37:48.160982+00	1	audit	\N	\N	2026-07-07 23:37:48.160982+00
1892	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:39:49.832653+00	1	users	\N	\N	2026-07-07 23:39:49.832653+00
1893	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:39:49.836855+00	1	users	\N	\N	2026-07-07 23:39:49.836855+00
1894	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:39:49.89011+00	1	users	\N	\N	2026-07-07 23:39:49.89011+00
1895	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:39:49.912653+00	1	users	\N	\N	2026-07-07 23:39:49.912653+00
1896	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:39:54.012919+00	1	courses	\N	\N	2026-07-07 23:39:54.012919+00
1897	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:39:54.033336+00	1	audit	\N	\N	2026-07-07 23:39:54.033336+00
1898	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:39:54.158619+00	1	courses	\N	\N	2026-07-07 23:39:54.158619+00
1899	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:39:54.178714+00	1	audit	\N	\N	2026-07-07 23:39:54.178714+00
1901	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:39:56.288145+00	1	students	\N	\N	2026-07-07 23:39:56.288145+00
1900	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:39:56.28781+00	1	courses	\N	\N	2026-07-07 23:39:56.28781+00
1902	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:39:56.300186+00	1	grades	\N	\N	2026-07-07 23:39:56.300186+00
1903	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:49:50.166492+00	1	audit	\N	\N	2026-07-07 23:49:50.166492+00
1904	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:49:50.188355+00	1	audit	\N	\N	2026-07-07 23:49:50.188355+00
1905	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:49:50.296123+00	1	audit	\N	\N	2026-07-07 23:49:50.296123+00
1906	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:49:50.296594+00	1	audit	\N	\N	2026-07-07 23:49:50.296594+00
1907	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:55:13.68967+00	1	audit	\N	\N	2026-07-07 23:55:13.68967+00
1908	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:55:13.806081+00	1	audit	\N	\N	2026-07-07 23:55:13.806081+00
1909	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:55:13.948743+00	1	courses	\N	\N	2026-07-07 23:55:13.948743+00
1910	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:55:13.971713+00	1	courses	\N	\N	2026-07-07 23:55:13.971713+00
1911	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:55:16.191637+00	1	courses	\N	\N	2026-07-07 23:55:16.191637+00
1912	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:55:16.196788+00	1	students	\N	\N	2026-07-07 23:55:16.196788+00
1913	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:55:16.206631+00	1	grades	\N	\N	2026-07-07 23:55:16.206631+00
1914	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:58:02.168069+00	1	courses	\N	\N	2026-07-07 23:58:02.168069+00
1915	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:58:02.214333+00	1	audit	\N	\N	2026-07-07 23:58:02.214333+00
1916	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:58:02.496841+00	1	courses	\N	\N	2026-07-07 23:58:02.496841+00
1917	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:58:02.502826+00	1	audit	\N	\N	2026-07-07 23:58:02.502826+00
1918	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:58:11.382326+00	1	courses	\N	\N	2026-07-07 23:58:11.382326+00
1919	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:58:11.383031+00	1	students	\N	\N	2026-07-07 23:58:11.383031+00
1920	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:58:11.390316+00	1	grades	\N	\N	2026-07-07 23:58:11.390316+00
1921	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:58:17.103289+00	1	courses	\N	\N	2026-07-07 23:58:17.103289+00
1922	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:58:17.104006+00	1	audit	\N	\N	2026-07-07 23:58:17.104006+00
1923	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:58:17.299246+00	1	courses	\N	\N	2026-07-07 23:58:17.299246+00
1924	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:58:17.331828+00	1	audit	\N	\N	2026-07-07 23:58:17.331828+00
1925	\N	read	\N	2	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:58:19.832142+00	1	courses	\N	\N	2026-07-07 23:58:19.832142+00
1926	\N	read	\N	2	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:58:19.83334+00	1	students	\N	\N	2026-07-07 23:58:19.83334+00
1927	\N	read	\N	2	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-07 23:58:19.839286+00	1	grades	\N	\N	2026-07-07 23:58:19.839286+00
1928	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 11:48:40.723489+00	1	users	\N	\N	2026-07-08 11:48:40.723489+00
1929	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 11:48:40.975061+00	1	audit	\N	\N	2026-07-08 11:48:40.975061+00
1930	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 11:48:40.982323+00	1	grades	\N	\N	2026-07-08 11:48:40.982323+00
1931	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 11:48:41.126503+00	1	audit	\N	\N	2026-07-08 11:48:41.126503+00
1932	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 11:48:41.129795+00	1	users	\N	\N	2026-07-08 11:48:41.129795+00
1933	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 11:48:41.305824+00	1	grades	\N	\N	2026-07-08 11:48:41.305824+00
1934	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 11:48:47.478392+00	1	users	\N	\N	2026-07-08 11:48:47.478392+00
1935	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 11:48:47.479101+00	1	users	\N	\N	2026-07-08 11:48:47.479101+00
1936	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 11:48:47.559528+00	1	users	\N	\N	2026-07-08 11:48:47.559528+00
1937	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 11:48:47.560468+00	1	users	\N	\N	2026-07-08 11:48:47.560468+00
1938	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 11:48:48.96361+00	1	users	\N	\N	2026-07-08 11:48:48.96361+00
1939	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 11:48:49.011672+00	1	users	\N	\N	2026-07-08 11:48:49.011672+00
1940	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 11:48:49.84099+00	1	audit	\N	\N	2026-07-08 11:48:49.84099+00
1941	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 11:48:49.84193+00	1	audit	\N	\N	2026-07-08 11:48:49.84193+00
1942	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 11:48:50.006616+00	1	audit	\N	\N	2026-07-08 11:48:50.006616+00
1943	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 11:48:50.094411+00	1	audit	\N	\N	2026-07-08 11:48:50.094411+00
1944	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 11:48:52.126399+00	1	audit	\N	\N	2026-07-08 11:48:52.126399+00
1945	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 11:48:52.127212+00	1	courses	\N	\N	2026-07-08 11:48:52.127212+00
1946	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 11:48:52.262524+00	1	audit	\N	\N	2026-07-08 11:48:52.262524+00
1947	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 11:48:52.290133+00	1	courses	\N	\N	2026-07-08 11:48:52.290133+00
1948	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 11:48:53.368156+00	1	courses	\N	\N	2026-07-08 11:48:53.368156+00
1949	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 11:48:53.374955+00	1	students	\N	\N	2026-07-08 11:48:53.374955+00
1950	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 11:48:53.386275+00	1	grades	\N	\N	2026-07-08 11:48:53.386275+00
1951	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:10:52.393303+00	6	grades	\N	\N	2026-07-08 12:10:52.393303+00
1952	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:10:52.483303+00	6	grades	\N	\N	2026-07-08 12:10:52.483303+00
1953	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:10:52.607423+00	6	enrollments	\N	\N	2026-07-08 12:10:52.607423+00
1954	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:10:52.65096+00	6	grades	\N	\N	2026-07-08 12:10:52.65096+00
1955	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:10:52.685809+00	6	enrollments	\N	\N	2026-07-08 12:10:52.685809+00
1956	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:10:52.721899+00	6	grades	\N	\N	2026-07-08 12:10:52.721899+00
1957	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:10:58.601925+00	6	grades	\N	\N	2026-07-08 12:10:58.601925+00
1958	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:10:58.605348+00	6	grades	\N	\N	2026-07-08 12:10:58.605348+00
1959	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:10:58.685694+00	6	grades	\N	\N	2026-07-08 12:10:58.685694+00
1960	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:10:58.695197+00	6	grades	\N	\N	2026-07-08 12:10:58.695197+00
1961	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:11:33.913693+00	2	courses	\N	\N	2026-07-08 12:11:33.913693+00
1962	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:11:33.949172+00	2	courses	\N	\N	2026-07-08 12:11:33.949172+00
1963	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:11:36.824259+00	2	courses	\N	\N	2026-07-08 12:11:36.824259+00
1964	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:11:36.891285+00	2	courses	\N	\N	2026-07-08 12:11:36.891285+00
1965	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:11:36.952212+00	2	courses	\N	\N	2026-07-08 12:11:36.952212+00
1966	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:11:36.963517+00	2	students	\N	\N	2026-07-08 12:11:36.963517+00
1967	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:11:36.970742+00	2	grades	\N	\N	2026-07-08 12:11:36.970742+00
1968	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:13:47.341943+00	2	courses	\N	\N	2026-07-08 12:13:47.341943+00
1969	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:13:47.441334+00	2	grades	\N	\N	2026-07-08 12:13:47.441334+00
1970	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:13:47.444144+00	2	courses	\N	\N	2026-07-08 12:13:47.444144+00
1971	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:13:47.446037+00	2	students	\N	\N	2026-07-08 12:13:47.446037+00
1972	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:18:21.489244+00	2	courses	\N	\N	2026-07-08 12:18:21.489244+00
1973	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:18:21.529431+00	2	courses	\N	\N	2026-07-08 12:18:21.529431+00
1974	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:18:22.762855+00	2	courses	\N	\N	2026-07-08 12:18:22.762855+00
1975	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:18:22.786249+00	2	grades	\N	\N	2026-07-08 12:18:22.786249+00
1976	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:18:22.791597+00	2	students	\N	\N	2026-07-08 12:18:22.791597+00
1977	\N	submit	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-07-08 12:20:01.767878+00	2	grades	OUTSIDE_GRADING_PERIOD	\N	2026-07-08 12:20:01.767878+00
1978	\N	submit	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-07-08 12:20:26.248185+00	2	grades	OUTSIDE_GRADING_PERIOD	\N	2026-07-08 12:20:26.248185+00
1979	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:36:43.659966+00	1	users	\N	\N	2026-07-08 12:36:43.659966+00
1980	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:36:43.876653+00	1	audit	\N	\N	2026-07-08 12:36:43.876653+00
1981	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:36:44.025162+00	1	grades	\N	\N	2026-07-08 12:36:44.025162+00
1983	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:36:44.07984+00	1	audit	\N	\N	2026-07-08 12:36:44.07984+00
1982	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:36:44.079323+00	1	users	\N	\N	2026-07-08 12:36:44.079323+00
1984	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:36:44.565543+00	1	grades	\N	\N	2026-07-08 12:36:44.565543+00
1985	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:36:45.557872+00	1	audit	\N	\N	2026-07-08 12:36:45.557872+00
1986	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:36:45.558447+00	1	audit	\N	\N	2026-07-08 12:36:45.558447+00
1987	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:36:45.717234+00	1	audit	\N	\N	2026-07-08 12:36:45.717234+00
1988	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:36:45.718584+00	1	audit	\N	\N	2026-07-08 12:36:45.718584+00
1989	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:36:48.522217+00	1	users	\N	\N	2026-07-08 12:36:48.522217+00
1990	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-08 12:36:48.554783+00	1	users	\N	\N	2026-07-08 12:36:48.554783+00
1991	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:07:52.168968+00	1	audit	\N	\N	2026-07-09 09:07:52.168968+00
1992	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:07:52.436271+00	1	audit	\N	\N	2026-07-09 09:07:52.436271+00
1993	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:07:52.51917+00	1	users	\N	\N	2026-07-09 09:07:52.51917+00
1994	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:07:52.526156+00	1	grades	\N	\N	2026-07-09 09:07:52.526156+00
1995	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:07:52.622642+00	1	grades	\N	\N	2026-07-09 09:07:52.622642+00
1996	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:07:52.642257+00	1	users	\N	\N	2026-07-09 09:07:52.642257+00
1997	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:07:54.29265+00	1	audit	\N	\N	2026-07-09 09:07:54.29265+00
1998	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:07:54.293294+00	1	audit	\N	\N	2026-07-09 09:07:54.293294+00
1999	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:07:54.517073+00	1	audit	\N	\N	2026-07-09 09:07:54.517073+00
2000	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:07:54.611314+00	1	audit	\N	\N	2026-07-09 09:07:54.611314+00
2001	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:07:55.959976+00	1	users	\N	\N	2026-07-09 09:07:55.959976+00
2002	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:07:55.993876+00	1	users	\N	\N	2026-07-09 09:07:55.993876+00
2003	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:08:15.835023+00	1	users	\N	\N	2026-07-09 09:08:15.835023+00
2004	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:08:15.872741+00	1	users	\N	\N	2026-07-09 09:08:15.872741+00
2005	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:00.780903+00	1	audit	\N	\N	2026-07-09 09:14:00.780903+00
2006	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:00.836009+00	1	audit	\N	\N	2026-07-09 09:14:00.836009+00
2007	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:00.841013+00	1	audit	\N	\N	2026-07-09 09:14:00.841013+00
2008	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:00.967092+00	1	audit	\N	\N	2026-07-09 09:14:00.967092+00
2009	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:09.5668+00	1	audit	\N	\N	2026-07-09 09:14:09.5668+00
2010	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:09.567465+00	1	audit	\N	\N	2026-07-09 09:14:09.567465+00
2011	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:10.563827+00	1	audit	\N	\N	2026-07-09 09:14:10.563827+00
2012	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:10.565659+00	1	audit	\N	\N	2026-07-09 09:14:10.565659+00
2013	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:11.363471+00	1	audit	\N	\N	2026-07-09 09:14:11.363471+00
2014	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:11.365204+00	1	audit	\N	\N	2026-07-09 09:14:11.365204+00
2015	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:12.119931+00	1	audit	\N	\N	2026-07-09 09:14:12.119931+00
2016	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:12.120665+00	1	audit	\N	\N	2026-07-09 09:14:12.120665+00
2017	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:12.607685+00	1	audit	\N	\N	2026-07-09 09:14:12.607685+00
2018	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:12.608374+00	1	audit	\N	\N	2026-07-09 09:14:12.608374+00
2019	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:13.381203+00	1	audit	\N	\N	2026-07-09 09:14:13.381203+00
2020	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:13.382594+00	1	audit	\N	\N	2026-07-09 09:14:13.382594+00
2021	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:15.199778+00	1	audit	\N	\N	2026-07-09 09:14:15.199778+00
2022	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:15.200455+00	1	audit	\N	\N	2026-07-09 09:14:15.200455+00
2023	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:19.294388+00	1	users	\N	\N	2026-07-09 09:14:19.294388+00
2024	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:19.294936+00	1	audit	\N	\N	2026-07-09 09:14:19.294936+00
2025	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:19.457182+00	1	audit	\N	\N	2026-07-09 09:14:19.457182+00
2026	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:19.530993+00	1	users	\N	\N	2026-07-09 09:14:19.530993+00
2027	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:19.586842+00	1	grades	\N	\N	2026-07-09 09:14:19.586842+00
2028	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:19.618493+00	1	grades	\N	\N	2026-07-09 09:14:19.618493+00
2030	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:22.498349+00	1	audit	\N	\N	2026-07-09 09:14:22.498349+00
2029	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:22.497838+00	1	users	\N	\N	2026-07-09 09:14:22.497838+00
2031	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:22.498915+00	1	grades	\N	\N	2026-07-09 09:14:22.498915+00
2032	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:24.185954+00	1	users	\N	\N	2026-07-09 09:14:24.185954+00
2033	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:24.186938+00	1	audit	\N	\N	2026-07-09 09:14:24.186938+00
2034	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:24.187573+00	1	grades	\N	\N	2026-07-09 09:14:24.187573+00
2035	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:24.766663+00	1	users	\N	\N	2026-07-09 09:14:24.766663+00
2036	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:24.768393+00	1	audit	\N	\N	2026-07-09 09:14:24.768393+00
2037	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:24.768909+00	1	grades	\N	\N	2026-07-09 09:14:24.768909+00
2038	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:26.23692+00	1	users	\N	\N	2026-07-09 09:14:26.23692+00
2039	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:26.264504+00	1	users	\N	\N	2026-07-09 09:14:26.264504+00
2040	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:26.287945+00	1	users	\N	\N	2026-07-09 09:14:26.287945+00
2041	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:26.336697+00	1	users	\N	\N	2026-07-09 09:14:26.336697+00
2043	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:28.086937+00	1	users	\N	\N	2026-07-09 09:14:28.086937+00
2046	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:29.366977+00	1	audit	\N	\N	2026-07-09 09:14:29.366977+00
2048	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:36.831581+00	1	users	\N	\N	2026-07-09 09:14:36.831581+00
2049	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:36.876692+00	1	users	\N	\N	2026-07-09 09:14:36.876692+00
2050	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:39.280675+00	1	users	\N	\N	2026-07-09 09:14:39.280675+00
2052	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:39.369048+00	1	users	\N	\N	2026-07-09 09:14:39.369048+00
2055	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:42.565004+00	1	audit	\N	\N	2026-07-09 09:14:42.565004+00
2056	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:42.735406+00	1	audit	\N	\N	2026-07-09 09:14:42.735406+00
2042	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:28.01718+00	1	users	\N	\N	2026-07-09 09:14:28.01718+00
2044	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:29.233286+00	1	audit	\N	\N	2026-07-09 09:14:29.233286+00
2047	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:29.370899+00	1	audit	\N	\N	2026-07-09 09:14:29.370899+00
2051	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:39.281213+00	1	users	\N	\N	2026-07-09 09:14:39.281213+00
2053	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:39.372504+00	1	users	\N	\N	2026-07-09 09:14:39.372504+00
2054	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:42.564398+00	1	users	\N	\N	2026-07-09 09:14:42.564398+00
2057	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:42.790026+00	1	users	\N	\N	2026-07-09 09:14:42.790026+00
2045	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:29.2335+00	1	audit	\N	\N	2026-07-09 09:14:29.2335+00
2058	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:42.849204+00	1	grades	\N	\N	2026-07-09 09:14:42.849204+00
2059	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 09:14:42.879106+00	1	grades	\N	\N	2026-07-09 09:14:42.879106+00
2060	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 10:03:38.533974+00	1	users	\N	\N	2026-07-09 10:03:38.533974+00
2061	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 10:03:38.606953+00	1	users	\N	\N	2026-07-09 10:03:38.606953+00
2062	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 10:03:44.65661+00	1	periods	\N	\N	2026-07-09 10:03:44.65661+00
2063	\N	write	\N	policy-config	GRANTED	\N	::1	\N	{"layer": "ALL", "message": "Global Access Control policy redeployed"}	2026-07-09 10:03:44.663078+00	1	periods	\N	\N	2026-07-09 10:03:44.663078+00
2064	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 10:03:44.686462+00	1	users	\N	\N	2026-07-09 10:03:44.686462+00
2065	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-07-09 10:04:09.577074+00	6	enrollments	INSUFFICIENT_ROLE	\N	2026-07-09 10:04:09.577074+00
2066	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-07-09 10:04:09.693844+00	6	enrollments	INSUFFICIENT_ROLE	\N	2026-07-09 10:04:09.693844+00
2067	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-07-09 10:04:09.835141+00	6	grades	INSUFFICIENT_ROLE	\N	2026-07-09 10:04:09.835141+00
2068	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-07-09 10:04:09.89008+00	6	grades	INSUFFICIENT_ROLE	\N	2026-07-09 10:04:09.89008+00
2069	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-07-09 10:04:09.941909+00	6	grades	INSUFFICIENT_ROLE	\N	2026-07-09 10:04:09.941909+00
2070	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-07-09 10:04:09.999381+00	6	grades	INSUFFICIENT_ROLE	\N	2026-07-09 10:04:09.999381+00
2071	\N	read	\N	\N	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-07-09 10:04:14.394307+00	6	grades	INSUFFICIENT_ROLE	\N	2026-07-09 10:04:14.394307+00
2072	\N	read	\N	999	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-07-09 10:04:21.738406+00	6	grades	INSUFFICIENT_ROLE	\N	2026-07-09 10:04:21.738406+00
2073	\N	read	\N	999	DENIED_ROLE	\N	::1	\N	{"layer": "ROLE"}	2026-07-09 10:04:28.037143+00	6	courses	INSUFFICIENT_ROLE	\N	2026-07-09 10:04:28.037143+00
2074	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 10:16:03.937449+00	1	audit	\N	\N	2026-07-09 10:16:03.937449+00
2075	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 10:16:04.128889+00	1	audit	\N	\N	2026-07-09 10:16:04.128889+00
2076	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 10:16:04.132686+00	1	users	\N	\N	2026-07-09 10:16:04.132686+00
2077	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 10:16:04.209692+00	1	grades	\N	\N	2026-07-09 10:16:04.209692+00
2078	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 10:16:04.284274+00	1	grades	\N	\N	2026-07-09 10:16:04.284274+00
2079	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 10:16:04.309517+00	1	users	\N	\N	2026-07-09 10:16:04.309517+00
2080	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 10:16:07.670752+00	1	users	\N	\N	2026-07-09 10:16:07.670752+00
2081	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 10:16:07.70963+00	1	users	\N	\N	2026-07-09 10:16:07.70963+00
2082	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 10:16:13.402405+00	1	periods	\N	\N	2026-07-09 10:16:13.402405+00
2083	\N	write	\N	policy-config	GRANTED	\N	::1	\N	{"layer": "ALL", "message": "Global Access Control policy redeployed"}	2026-07-09 10:16:13.406291+00	1	periods	\N	\N	2026-07-09 10:16:13.406291+00
2084	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 10:16:13.426503+00	1	users	\N	\N	2026-07-09 10:16:13.426503+00
2085	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 10:16:33.444767+00	1	users	\N	\N	2026-07-09 10:16:33.444767+00
2086	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 10:16:33.51895+00	1	users	\N	\N	2026-07-09 10:16:33.51895+00
2087	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 10:16:39.213732+00	1	periods	\N	\N	2026-07-09 10:16:39.213732+00
2088	\N	write	\N	policy-config	GRANTED	\N	::1	\N	{"layer": "ALL", "message": "Global Access Control policy redeployed"}	2026-07-09 10:16:39.217943+00	1	periods	\N	\N	2026-07-09 10:16:39.217943+00
2089	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 10:16:39.242498+00	1	users	\N	\N	2026-07-09 10:16:39.242498+00
2090	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 10:16:43.301103+00	1	users	\N	\N	2026-07-09 10:16:43.301103+00
2091	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 10:16:43.347363+00	1	users	\N	\N	2026-07-09 10:16:43.347363+00
2092	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 10:17:09.721437+00	2	courses	\N	\N	2026-07-09 10:17:09.721437+00
2093	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 10:17:09.774811+00	2	courses	\N	\N	2026-07-09 10:17:09.774811+00
2094	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 10:17:12.35211+00	2	courses	\N	\N	2026-07-09 10:17:12.35211+00
2095	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 10:17:12.409342+00	2	courses	\N	\N	2026-07-09 10:17:12.409342+00
2096	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 10:17:12.541777+00	2	courses	\N	\N	2026-07-09 10:17:12.541777+00
2097	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 10:17:12.567593+00	2	students	\N	\N	2026-07-09 10:17:12.567593+00
2098	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 10:17:12.575868+00	2	grades	\N	\N	2026-07-09 10:17:12.575868+00
2099	\N	submit	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-07-09 10:17:17.177577+00	2	grades	OUTSIDE_GRADING_PERIOD	\N	2026-07-09 10:17:17.177577+00
2100	\N	submit	\N	\N	DENIED_CONTEXT	\N	::1	\N	{"layer": "CONTEXT"}	2026-07-09 10:17:33.142943+00	2	grades	OUTSIDE_GRADING_PERIOD	\N	2026-07-09 10:17:33.142943+00
2101	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 12:49:33.916305+00	1	users	\N	\N	2026-07-09 12:49:33.916305+00
2102	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 12:49:34.371327+00	1	users	\N	\N	2026-07-09 12:49:34.371327+00
2103	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 12:49:34.580373+00	1	grades	\N	\N	2026-07-09 12:49:34.580373+00
2104	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 12:49:34.630302+00	1	audit	\N	\N	2026-07-09 12:49:34.630302+00
2105	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 12:49:34.633781+00	1	grades	\N	\N	2026-07-09 12:49:34.633781+00
2106	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-09 12:49:34.771782+00	1	audit	\N	\N	2026-07-09 12:49:34.771782+00
2107	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-13 22:12:11.961524+00	1	users	\N	\N	2026-07-13 22:12:11.961524+00
2108	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-13 22:12:12.21952+00	1	audit	\N	\N	2026-07-13 22:12:12.21952+00
2110	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-13 22:12:12.22293+00	1	users	\N	\N	2026-07-13 22:12:12.22293+00
2109	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-13 22:12:12.221153+00	1	grades	\N	\N	2026-07-13 22:12:12.221153+00
2111	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-13 22:12:12.37462+00	1	audit	\N	\N	2026-07-13 22:12:12.37462+00
2112	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-13 22:12:12.460894+00	1	grades	\N	\N	2026-07-13 22:12:12.460894+00
2113	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-13 23:39:51.347066+00	1	users	\N	\N	2026-07-13 23:39:51.347066+00
2114	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-13 23:39:51.575474+00	1	users	\N	\N	2026-07-13 23:39:51.575474+00
2115	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-13 23:39:51.576392+00	1	audit	\N	\N	2026-07-13 23:39:51.576392+00
2116	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-13 23:39:51.577926+00	1	grades	\N	\N	2026-07-13 23:39:51.577926+00
2117	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-13 23:39:51.698138+00	1	audit	\N	\N	2026-07-13 23:39:51.698138+00
2118	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-13 23:39:51.70175+00	1	grades	\N	\N	2026-07-13 23:39:51.70175+00
2119	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-13 23:45:45.548858+00	1	users	\N	\N	2026-07-13 23:45:45.548858+00
2120	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-13 23:45:45.786804+00	1	users	\N	\N	2026-07-13 23:45:45.786804+00
2121	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-13 23:45:45.788208+00	1	grades	\N	\N	2026-07-13 23:45:45.788208+00
2122	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-13 23:45:45.864096+00	1	audit	\N	\N	2026-07-13 23:45:45.864096+00
2124	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-13 23:45:46.00387+00	1	audit	\N	\N	2026-07-13 23:45:46.00387+00
2123	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-13 23:45:45.893319+00	1	grades	\N	\N	2026-07-13 23:45:45.893319+00
2125	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 00:00:36.293852+00	1	users	\N	\N	2026-07-14 00:00:36.293852+00
2126	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 00:00:36.436468+00	1	users	\N	\N	2026-07-14 00:00:36.436468+00
2127	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 00:00:36.484372+00	1	audit	\N	\N	2026-07-14 00:00:36.484372+00
2128	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 00:00:36.489912+00	1	grades	\N	\N	2026-07-14 00:00:36.489912+00
2129	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 00:00:36.551066+00	1	audit	\N	\N	2026-07-14 00:00:36.551066+00
2130	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 00:00:36.551756+00	1	grades	\N	\N	2026-07-14 00:00:36.551756+00
2131	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 00:00:39.604584+00	1	users	\N	\N	2026-07-14 00:00:39.604584+00
2132	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 00:00:39.605163+00	1	audit	\N	\N	2026-07-14 00:00:39.605163+00
2133	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 00:00:39.60581+00	1	grades	\N	\N	2026-07-14 00:00:39.60581+00
2134	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 00:00:40.222241+00	1	users	\N	\N	2026-07-14 00:00:40.222241+00
2135	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 00:00:40.223+00	1	audit	\N	\N	2026-07-14 00:00:40.223+00
2136	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 00:00:40.224555+00	1	grades	\N	\N	2026-07-14 00:00:40.224555+00
2137	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:08:32.063138+00	1	users	\N	\N	2026-07-14 23:08:32.063138+00
2138	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:08:32.218286+00	1	grades	\N	\N	2026-07-14 23:08:32.218286+00
2139	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:08:32.360504+00	1	grades	\N	\N	2026-07-14 23:08:32.360504+00
2140	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:08:32.399169+00	1	audit	\N	\N	2026-07-14 23:08:32.399169+00
2141	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:08:32.406374+00	1	users	\N	\N	2026-07-14 23:08:32.406374+00
2142	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:08:32.603425+00	1	audit	\N	\N	2026-07-14 23:08:32.603425+00
2143	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:10:05.158423+00	1	users	\N	\N	2026-07-14 23:10:05.158423+00
2144	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:10:05.301648+00	1	users	\N	\N	2026-07-14 23:10:05.301648+00
2145	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:10:05.417888+00	1	audit	\N	\N	2026-07-14 23:10:05.417888+00
2146	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:10:05.424406+00	1	grades	\N	\N	2026-07-14 23:10:05.424406+00
2147	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:10:05.531254+00	1	audit	\N	\N	2026-07-14 23:10:05.531254+00
2148	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:10:05.532003+00	1	grades	\N	\N	2026-07-14 23:10:05.532003+00
2149	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:12:47.616511+00	1	users	\N	\N	2026-07-14 23:12:47.616511+00
2150	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:12:47.811879+00	1	grades	\N	\N	2026-07-14 23:12:47.811879+00
2151	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:12:47.843124+00	1	users	\N	\N	2026-07-14 23:12:47.843124+00
2152	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:12:47.958249+00	1	audit	\N	\N	2026-07-14 23:12:47.958249+00
2153	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:12:47.96292+00	1	grades	\N	\N	2026-07-14 23:12:47.96292+00
2154	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:12:48.200644+00	1	audit	\N	\N	2026-07-14 23:12:48.200644+00
2155	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:13:36.443323+00	1	users	\N	\N	2026-07-14 23:13:36.443323+00
2156	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:13:36.652655+00	1	audit	\N	\N	2026-07-14 23:13:36.652655+00
2157	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:13:36.797722+00	1	grades	\N	\N	2026-07-14 23:13:36.797722+00
2158	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:13:36.85488+00	1	users	\N	\N	2026-07-14 23:13:36.85488+00
2159	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:13:37.01546+00	1	audit	\N	\N	2026-07-14 23:13:37.01546+00
2160	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:13:37.017349+00	1	grades	\N	\N	2026-07-14 23:13:37.017349+00
2161	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:15:53.332602+00	1	users	\N	\N	2026-07-14 23:15:53.332602+00
2162	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:15:53.544079+00	1	users	\N	\N	2026-07-14 23:15:53.544079+00
2163	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:15:53.545971+00	1	grades	\N	\N	2026-07-14 23:15:53.545971+00
2164	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:15:53.548381+00	1	audit	\N	\N	2026-07-14 23:15:53.548381+00
2165	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:15:53.702034+00	1	audit	\N	\N	2026-07-14 23:15:53.702034+00
2166	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:15:53.820391+00	1	grades	\N	\N	2026-07-14 23:15:53.820391+00
2167	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:20:55.344422+00	1	users	\N	\N	2026-07-14 23:20:55.344422+00
2168	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:20:55.552036+00	1	audit	\N	\N	2026-07-14 23:20:55.552036+00
2169	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:20:55.560862+00	1	grades	\N	\N	2026-07-14 23:20:55.560862+00
2170	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:20:55.713581+00	1	users	\N	\N	2026-07-14 23:20:55.713581+00
2171	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:20:55.727733+00	1	audit	\N	\N	2026-07-14 23:20:55.727733+00
2172	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:20:55.913422+00	1	grades	\N	\N	2026-07-14 23:20:55.913422+00
2173	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:21:02.249762+00	1	users	\N	\N	2026-07-14 23:21:02.249762+00
2174	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:21:02.251416+00	1	audit	\N	\N	2026-07-14 23:21:02.251416+00
2175	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:21:02.25256+00	1	grades	\N	\N	2026-07-14 23:21:02.25256+00
2176	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:21:02.921028+00	1	users	\N	\N	2026-07-14 23:21:02.921028+00
2177	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:21:02.922301+00	1	audit	\N	\N	2026-07-14 23:21:02.922301+00
2178	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:21:02.922963+00	1	grades	\N	\N	2026-07-14 23:21:02.922963+00
2179	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:21:16.22081+00	1	audit	\N	\N	2026-07-14 23:21:16.22081+00
2180	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:21:16.411727+00	1	grades	\N	\N	2026-07-14 23:21:16.411727+00
2181	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:21:16.420632+00	1	users	\N	\N	2026-07-14 23:21:16.420632+00
2182	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:21:23.016127+00	1	users	\N	\N	2026-07-14 23:21:23.016127+00
2183	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:21:23.021657+00	1	users	\N	\N	2026-07-14 23:21:23.021657+00
2184	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:21:23.143901+00	1	users	\N	\N	2026-07-14 23:21:23.143901+00
2185	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:21:23.165686+00	1	users	\N	\N	2026-07-14 23:21:23.165686+00
2186	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:21:38.941639+00	1	audit	\N	\N	2026-07-14 23:21:38.941639+00
2187	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:21:38.942368+00	1	audit	\N	\N	2026-07-14 23:21:38.942368+00
2188	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:21:39.063496+00	1	audit	\N	\N	2026-07-14 23:21:39.063496+00
2189	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:21:39.072432+00	1	audit	\N	\N	2026-07-14 23:21:39.072432+00
2190	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:21:42.587198+00	1	users	\N	\N	2026-07-14 23:21:42.587198+00
2191	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:21:42.588416+00	1	audit	\N	\N	2026-07-14 23:21:42.588416+00
2192	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:21:42.594508+00	1	grades	\N	\N	2026-07-14 23:21:42.594508+00
2193	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:21:42.755439+00	1	audit	\N	\N	2026-07-14 23:21:42.755439+00
2194	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:21:42.884171+00	1	grades	\N	\N	2026-07-14 23:21:42.884171+00
2195	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:21:42.889653+00	1	users	\N	\N	2026-07-14 23:21:42.889653+00
2196	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:22:30.235278+00	1	users	\N	\N	2026-07-14 23:22:30.235278+00
2197	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:22:30.236951+00	1	users	\N	\N	2026-07-14 23:22:30.236951+00
2198	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:22:30.325388+00	1	users	\N	\N	2026-07-14 23:22:30.325388+00
2199	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:22:30.352028+00	1	users	\N	\N	2026-07-14 23:22:30.352028+00
2201	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:26:32.42931+00	1	users	\N	\N	2026-07-14 23:26:32.42931+00
2200	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-14 23:26:32.41711+00	1	users	\N	\N	2026-07-14 23:26:32.41711+00
2202	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 11:05:42.627641+00	1	users	\N	\N	2026-07-15 11:05:42.627641+00
2203	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 11:05:43.534197+00	1	audit	\N	\N	2026-07-15 11:05:43.534197+00
2204	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 11:05:43.566079+00	1	grades	\N	\N	2026-07-15 11:05:43.566079+00
2205	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 11:05:44.178295+00	1	users	\N	\N	2026-07-15 11:05:44.178295+00
2206	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 11:05:44.430698+00	1	audit	\N	\N	2026-07-15 11:05:44.430698+00
2207	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 11:05:44.456647+00	1	grades	\N	\N	2026-07-15 11:05:44.456647+00
2208	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 12:24:32.767134+00	1	audit	\N	\N	2026-07-15 12:24:32.767134+00
2209	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 12:24:32.925355+00	1	grades	\N	\N	2026-07-15 12:24:32.925355+00
2210	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 12:24:32.92719+00	1	users	\N	\N	2026-07-15 12:24:32.92719+00
2211	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 12:24:34.183137+00	1	audit	\N	\N	2026-07-15 12:24:34.183137+00
2212	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 12:24:35.814446+00	1	grades	\N	\N	2026-07-15 12:24:35.814446+00
2213	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 12:24:36.448889+00	1	users	\N	\N	2026-07-15 12:24:36.448889+00
2214	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 12:38:23.093054+00	1	users	\N	\N	2026-07-15 12:38:23.093054+00
2215	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 12:38:23.250178+00	1	audit	\N	\N	2026-07-15 12:38:23.250178+00
2216	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 12:38:23.417868+00	1	grades	\N	\N	2026-07-15 12:38:23.417868+00
2217	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 12:38:24.655623+00	1	audit	\N	\N	2026-07-15 12:38:24.655623+00
2218	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 12:38:24.676745+00	1	grades	\N	\N	2026-07-15 12:38:24.676745+00
2219	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 12:38:25.496104+00	1	users	\N	\N	2026-07-15 12:38:25.496104+00
2220	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 12:38:25.506539+00	1	audit	\N	\N	2026-07-15 12:38:25.506539+00
2221	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 12:38:25.535858+00	1	grades	\N	\N	2026-07-15 12:38:25.535858+00
2222	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 12:38:27.087575+00	1	audit	\N	\N	2026-07-15 12:38:27.087575+00
2223	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 12:38:27.094473+00	1	grades	\N	\N	2026-07-15 12:38:27.094473+00
2224	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 12:38:27.206654+00	1	users	\N	\N	2026-07-15 12:38:27.206654+00
2225	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 12:38:28.277578+00	1	users	\N	\N	2026-07-15 12:38:28.277578+00
2226	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 12:38:28.784332+00	1	audit	\N	\N	2026-07-15 12:38:28.784332+00
2227	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 12:38:28.803382+00	1	grades	\N	\N	2026-07-15 12:38:28.803382+00
2228	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 12:38:29.297233+00	1	users	\N	\N	2026-07-15 12:38:29.297233+00
2229	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 12:38:29.680905+00	1	audit	\N	\N	2026-07-15 12:38:29.680905+00
2230	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 12:38:30.140285+00	1	grades	\N	\N	2026-07-15 12:38:30.140285+00
2231	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 12:38:30.161891+00	1	users	\N	\N	2026-07-15 12:38:30.161891+00
2232	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:18:30.438028+00	1	users	\N	\N	2026-07-15 15:18:30.438028+00
2233	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:18:30.720382+00	1	users	\N	\N	2026-07-15 15:18:30.720382+00
2234	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:18:30.724007+00	1	grades	\N	\N	2026-07-15 15:18:30.724007+00
2235	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:18:30.725546+00	1	audit	\N	\N	2026-07-15 15:18:30.725546+00
2236	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:18:30.888385+00	1	audit	\N	\N	2026-07-15 15:18:30.888385+00
2237	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:18:30.903493+00	1	grades	\N	\N	2026-07-15 15:18:30.903493+00
2238	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:18:33.590486+00	1	users	\N	\N	2026-07-15 15:18:33.590486+00
2239	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:18:33.591214+00	1	audit	\N	\N	2026-07-15 15:18:33.591214+00
2240	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:18:33.592181+00	1	grades	\N	\N	2026-07-15 15:18:33.592181+00
2241	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:26:48.795735+00	1	courses	\N	\N	2026-07-15 15:26:48.795735+00
2242	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:26:48.806314+00	1	audit	\N	\N	2026-07-15 15:26:48.806314+00
2243	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:26:48.919639+00	1	courses	\N	\N	2026-07-15 15:26:48.919639+00
2244	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:26:48.934472+00	1	audit	\N	\N	2026-07-15 15:26:48.934472+00
2245	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:26:57.586896+00	1	users	\N	\N	2026-07-15 15:26:57.586896+00
2246	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:26:57.588438+00	1	users	\N	\N	2026-07-15 15:26:57.588438+00
2247	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:26:57.64302+00	1	users	\N	\N	2026-07-15 15:26:57.64302+00
2248	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:26:57.644361+00	1	users	\N	\N	2026-07-15 15:26:57.644361+00
2249	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:27:10.616932+00	1	users	\N	\N	2026-07-15 15:27:10.616932+00
2250	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:27:10.647534+00	1	users	\N	\N	2026-07-15 15:27:10.647534+00
2251	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:27:17.735286+00	1	audit	\N	\N	2026-07-15 15:27:17.735286+00
2252	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:27:17.790909+00	1	audit	\N	\N	2026-07-15 15:27:17.790909+00
2253	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:27:17.886654+00	1	audit	\N	\N	2026-07-15 15:27:17.886654+00
2254	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:27:17.945417+00	1	audit	\N	\N	2026-07-15 15:27:17.945417+00
2255	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:27:24.879912+00	1	users	\N	\N	2026-07-15 15:27:24.879912+00
2256	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:27:24.880446+00	1	users	\N	\N	2026-07-15 15:27:24.880446+00
2257	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:27:24.961696+00	1	users	\N	\N	2026-07-15 15:27:24.961696+00
2258	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:27:24.987095+00	1	users	\N	\N	2026-07-15 15:27:24.987095+00
2259	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:27:34.48708+00	1	users	\N	\N	2026-07-15 15:27:34.48708+00
2260	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:27:34.487865+00	1	audit	\N	\N	2026-07-15 15:27:34.487865+00
2261	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:27:34.629647+00	1	audit	\N	\N	2026-07-15 15:27:34.629647+00
2262	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:27:34.705113+00	1	users	\N	\N	2026-07-15 15:27:34.705113+00
2263	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:27:34.752005+00	1	grades	\N	\N	2026-07-15 15:27:34.752005+00
2264	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:27:34.774205+00	1	grades	\N	\N	2026-07-15 15:27:34.774205+00
2265	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:27:51.96522+00	1	users	\N	\N	2026-07-15 15:27:51.96522+00
2266	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:27:52.050522+00	1	audit	\N	\N	2026-07-15 15:27:52.050522+00
2267	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:27:52.055306+00	1	grades	\N	\N	2026-07-15 15:27:52.055306+00
2268	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:27:52.136247+00	1	audit	\N	\N	2026-07-15 15:27:52.136247+00
2269	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:27:52.137154+00	1	grades	\N	\N	2026-07-15 15:27:52.137154+00
2270	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:27:52.13818+00	1	users	\N	\N	2026-07-15 15:27:52.13818+00
2271	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:36:44.20703+00	2	courses	\N	\N	2026-07-15 15:36:44.20703+00
2272	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:36:44.289051+00	2	courses	\N	\N	2026-07-15 15:36:44.289051+00
2273	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:37:07.523555+00	2	courses	\N	\N	2026-07-15 15:37:07.523555+00
2274	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:37:07.562746+00	2	courses	\N	\N	2026-07-15 15:37:07.562746+00
2275	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:37:07.637801+00	2	courses	\N	\N	2026-07-15 15:37:07.637801+00
2276	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:37:07.638717+00	2	students	\N	\N	2026-07-15 15:37:07.638717+00
2277	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:37:07.654924+00	2	grades	\N	\N	2026-07-15 15:37:07.654924+00
2278	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:37:18.752009+00	2	courses	\N	\N	2026-07-15 15:37:18.752009+00
2279	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 15:37:18.769266+00	2	courses	\N	\N	2026-07-15 15:37:18.769266+00
2280	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 16:44:03.788638+00	2	courses	\N	\N	2026-07-15 16:44:03.788638+00
2281	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 16:44:03.864864+00	2	courses	\N	\N	2026-07-15 16:44:03.864864+00
2282	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 16:44:07.155522+00	2	courses	\N	\N	2026-07-15 16:44:07.155522+00
2283	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 16:44:07.194676+00	2	courses	\N	\N	2026-07-15 16:44:07.194676+00
2284	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 16:44:07.265475+00	2	courses	\N	\N	2026-07-15 16:44:07.265475+00
2285	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 16:44:07.267524+00	2	students	\N	\N	2026-07-15 16:44:07.267524+00
2286	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 16:44:07.283666+00	2	grades	\N	\N	2026-07-15 16:44:07.283666+00
2287	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 16:44:08.287434+00	2	courses	\N	\N	2026-07-15 16:44:08.287434+00
2288	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 16:44:08.365127+00	2	courses	\N	\N	2026-07-15 16:44:08.365127+00
2289	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 16:44:42.861301+00	6	grades	\N	\N	2026-07-15 16:44:42.861301+00
2290	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 16:44:42.920441+00	6	grades	\N	\N	2026-07-15 16:44:42.920441+00
2291	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 16:44:43.038036+00	6	enrollments	\N	\N	2026-07-15 16:44:43.038036+00
2292	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 16:44:43.093047+00	6	enrollments	\N	\N	2026-07-15 16:44:43.093047+00
2293	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 16:44:43.112854+00	6	grades	\N	\N	2026-07-15 16:44:43.112854+00
2294	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 16:44:43.210742+00	6	grades	\N	\N	2026-07-15 16:44:43.210742+00
2295	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 16:45:02.697203+00	6	courses	\N	\N	2026-07-15 16:45:02.697203+00
2296	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 16:45:02.715463+00	6	enrollments	\N	\N	2026-07-15 16:45:02.715463+00
2297	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 16:45:02.769616+00	6	courses	\N	\N	2026-07-15 16:45:02.769616+00
2298	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 16:45:02.816616+00	6	enrollments	\N	\N	2026-07-15 16:45:02.816616+00
2299	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 16:45:13.062132+00	6	grades	\N	\N	2026-07-15 16:45:13.062132+00
2300	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 16:45:13.095106+00	6	grades	\N	\N	2026-07-15 16:45:13.095106+00
2301	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 16:45:13.152121+00	6	grades	\N	\N	2026-07-15 16:45:13.152121+00
2302	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-15 16:45:13.161949+00	6	grades	\N	\N	2026-07-15 16:45:13.161949+00
2303	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 09:49:10.991672+00	1	audit	\N	\N	2026-07-16 09:49:10.991672+00
2304	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 09:49:11.212825+00	1	audit	\N	\N	2026-07-16 09:49:11.212825+00
2305	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 09:49:11.291502+00	1	grades	\N	\N	2026-07-16 09:49:11.291502+00
2306	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 09:49:11.291968+00	1	users	\N	\N	2026-07-16 09:49:11.291968+00
2307	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 09:49:11.375995+00	1	grades	\N	\N	2026-07-16 09:49:11.375995+00
2308	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 09:49:11.397025+00	1	users	\N	\N	2026-07-16 09:49:11.397025+00
2309	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 09:55:09.690243+00	1	audit	\N	\N	2026-07-16 09:55:09.690243+00
2310	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 09:55:09.792519+00	1	courses	\N	\N	2026-07-16 09:55:09.792519+00
2311	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 09:55:09.796543+00	1	audit	\N	\N	2026-07-16 09:55:09.796543+00
2312	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 09:55:09.882387+00	1	courses	\N	\N	2026-07-16 09:55:09.882387+00
2313	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 09:55:17.711026+00	1	audit	\N	\N	2026-07-16 09:55:17.711026+00
2314	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 09:55:17.712857+00	1	users	\N	\N	2026-07-16 09:55:17.712857+00
2315	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 09:55:17.720989+00	1	grades	\N	\N	2026-07-16 09:55:17.720989+00
2316	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 09:55:17.887158+00	1	audit	\N	\N	2026-07-16 09:55:17.887158+00
2317	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 09:55:17.88858+00	1	grades	\N	\N	2026-07-16 09:55:17.88858+00
2318	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 09:55:17.953748+00	1	users	\N	\N	2026-07-16 09:55:17.953748+00
2319	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 09:55:25.050563+00	1	users	\N	\N	2026-07-16 09:55:25.050563+00
2320	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 09:55:25.051774+00	1	audit	\N	\N	2026-07-16 09:55:25.051774+00
2321	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 09:55:25.052426+00	1	grades	\N	\N	2026-07-16 09:55:25.052426+00
2322	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 09:55:26.239057+00	1	users	\N	\N	2026-07-16 09:55:26.239057+00
2323	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 09:55:26.23974+00	1	audit	\N	\N	2026-07-16 09:55:26.23974+00
2324	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 09:55:26.240466+00	1	grades	\N	\N	2026-07-16 09:55:26.240466+00
2325	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 09:55:28.185998+00	1	courses	\N	\N	2026-07-16 09:55:28.185998+00
2326	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 09:55:28.186673+00	1	audit	\N	\N	2026-07-16 09:55:28.186673+00
2327	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 09:55:28.328161+00	1	courses	\N	\N	2026-07-16 09:55:28.328161+00
2328	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 09:55:28.347249+00	1	audit	\N	\N	2026-07-16 09:55:28.347249+00
2330	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 10:11:48.520676+00	1	courses	\N	\N	2026-07-16 10:11:48.520676+00
2329	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 10:11:48.517306+00	1	grades	\N	\N	2026-07-16 10:11:48.517306+00
2331	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 10:11:48.557356+00	1	students	\N	\N	2026-07-16 10:11:48.557356+00
2332	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 10:28:01.393971+00	1	courses	\N	\N	2026-07-16 10:28:01.393971+00
2333	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 10:28:01.39922+00	1	enrollments	\N	\N	2026-07-16 10:28:01.39922+00
2334	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 10:28:01.475774+00	1	courses	\N	\N	2026-07-16 10:28:01.475774+00
2335	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 10:28:01.476774+00	1	enrollments	\N	\N	2026-07-16 10:28:01.476774+00
2336	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 10:29:11.388005+00	1	courses	\N	\N	2026-07-16 10:29:11.388005+00
2337	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 10:29:11.456214+00	1	courses	\N	\N	2026-07-16 10:29:11.456214+00
2339	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 10:29:11.643012+00	1	students	\N	\N	2026-07-16 10:29:11.643012+00
2338	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 10:29:11.641689+00	1	courses	\N	\N	2026-07-16 10:29:11.641689+00
2340	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 10:29:11.65817+00	1	grades	\N	\N	2026-07-16 10:29:11.65817+00
2341	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:03:17.614769+00	1	users	\N	\N	2026-07-16 20:03:17.614769+00
2342	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:03:17.794673+00	1	users	\N	\N	2026-07-16 20:03:17.794673+00
2343	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:03:17.797459+00	1	grades	\N	\N	2026-07-16 20:03:17.797459+00
2344	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:03:17.798349+00	1	audit	\N	\N	2026-07-16 20:03:17.798349+00
2345	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:03:17.93401+00	1	audit	\N	\N	2026-07-16 20:03:17.93401+00
2346	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:03:17.934899+00	1	grades	\N	\N	2026-07-16 20:03:17.934899+00
2347	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:03:58.300956+00	1	enrollments	\N	\N	2026-07-16 20:03:58.300956+00
2348	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:03:58.312176+00	1	courses	\N	\N	2026-07-16 20:03:58.312176+00
2349	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:03:58.33851+00	1	enrollments	\N	\N	2026-07-16 20:03:58.33851+00
2350	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:03:58.34518+00	1	courses	\N	\N	2026-07-16 20:03:58.34518+00
2351	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:04:05.269851+00	1	grades	\N	\N	2026-07-16 20:04:05.269851+00
2352	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:04:05.3231+00	1	grades	\N	\N	2026-07-16 20:04:05.3231+00
2353	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:04:05.440031+00	1	grades	\N	\N	2026-07-16 20:04:05.440031+00
2354	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:04:05.441668+00	1	grades	\N	\N	2026-07-16 20:04:05.441668+00
2355	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:04:05.445203+00	1	enrollments	\N	\N	2026-07-16 20:04:05.445203+00
2356	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:04:05.478167+00	1	enrollments	\N	\N	2026-07-16 20:04:05.478167+00
2357	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:04:08.620227+00	1	enrollments	\N	\N	2026-07-16 20:04:08.620227+00
2358	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:04:08.621346+00	1	courses	\N	\N	2026-07-16 20:04:08.621346+00
2359	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:04:08.661405+00	1	enrollments	\N	\N	2026-07-16 20:04:08.661405+00
2360	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:04:08.688202+00	1	courses	\N	\N	2026-07-16 20:04:08.688202+00
2361	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:04:10.502496+00	1	grades	\N	\N	2026-07-16 20:04:10.502496+00
2362	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:04:10.503632+00	1	grades	\N	\N	2026-07-16 20:04:10.503632+00
2363	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:04:10.578592+00	1	grades	\N	\N	2026-07-16 20:04:10.578592+00
2364	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:04:10.580164+00	1	grades	\N	\N	2026-07-16 20:04:10.580164+00
2365	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:47:19.406933+00	1	users	\N	\N	2026-07-16 20:47:19.406933+00
2366	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:47:19.412305+00	1	grades	\N	\N	2026-07-16 20:47:19.412305+00
2367	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:47:19.526388+00	1	grades	\N	\N	2026-07-16 20:47:19.526388+00
2368	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:47:19.544403+00	1	users	\N	\N	2026-07-16 20:47:19.544403+00
2369	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:47:19.612083+00	1	audit	\N	\N	2026-07-16 20:47:19.612083+00
2370	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:47:19.731137+00	1	audit	\N	\N	2026-07-16 20:47:19.731137+00
2371	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:50:04.386587+00	1	audit	\N	\N	2026-07-16 20:50:04.386587+00
2372	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:50:04.535124+00	1	audit	\N	\N	2026-07-16 20:50:04.535124+00
2373	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:50:04.623172+00	1	grades	\N	\N	2026-07-16 20:50:04.623172+00
2374	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:50:04.654624+00	1	grades	\N	\N	2026-07-16 20:50:04.654624+00
2375	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:50:04.656304+00	1	users	\N	\N	2026-07-16 20:50:04.656304+00
2376	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:50:04.721976+00	1	users	\N	\N	2026-07-16 20:50:04.721976+00
2377	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:52:09.680119+00	1	users	\N	\N	2026-07-16 20:52:09.680119+00
2378	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:52:09.699278+00	1	audit	\N	\N	2026-07-16 20:52:09.699278+00
2379	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:52:09.680749+00	1	grades	\N	\N	2026-07-16 20:52:09.680749+00
2380	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:52:09.808369+00	1	audit	\N	\N	2026-07-16 20:52:09.808369+00
2381	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:52:09.877001+00	1	grades	\N	\N	2026-07-16 20:52:09.877001+00
2382	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:52:09.877593+00	1	users	\N	\N	2026-07-16 20:52:09.877593+00
2383	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:52:30.973032+00	1	users	\N	\N	2026-07-16 20:52:30.973032+00
2384	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:52:31.146265+00	1	users	\N	\N	2026-07-16 20:52:31.146265+00
2385	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:52:31.149522+00	1	audit	\N	\N	2026-07-16 20:52:31.149522+00
2387	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:52:31.283372+00	1	audit	\N	\N	2026-07-16 20:52:31.283372+00
2386	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:52:31.28283+00	1	grades	\N	\N	2026-07-16 20:52:31.28283+00
2388	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:52:31.345122+00	1	grades	\N	\N	2026-07-16 20:52:31.345122+00
2389	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:52:49.201228+00	1	enrollments	\N	\N	2026-07-16 20:52:49.201228+00
2391	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:52:49.23307+00	1	enrollments	\N	\N	2026-07-16 20:52:49.23307+00
2390	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:52:49.23246+00	1	courses	\N	\N	2026-07-16 20:52:49.23246+00
2392	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:52:49.261199+00	1	courses	\N	\N	2026-07-16 20:52:49.261199+00
2393	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:52:49.885533+00	1	users	\N	\N	2026-07-16 20:52:49.885533+00
2394	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:52:49.886804+00	1	grades	\N	\N	2026-07-16 20:52:49.886804+00
2395	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:52:49.891452+00	1	audit	\N	\N	2026-07-16 20:52:49.891452+00
2396	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:52:50.025944+00	1	grades	\N	\N	2026-07-16 20:52:50.025944+00
2397	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:52:50.036026+00	1	audit	\N	\N	2026-07-16 20:52:50.036026+00
2398	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 20:52:50.039753+00	1	users	\N	\N	2026-07-16 20:52:50.039753+00
2399	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 21:13:49.172711+00	1	audit	\N	\N	2026-07-16 21:13:49.172711+00
2400	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 21:13:49.448485+00	1	audit	\N	\N	2026-07-16 21:13:49.448485+00
2401	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 21:13:49.646779+00	1	grades	\N	\N	2026-07-16 21:13:49.646779+00
2402	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 21:13:49.690504+00	1	users	\N	\N	2026-07-16 21:13:49.690504+00
2403	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 21:13:49.809058+00	1	grades	\N	\N	2026-07-16 21:13:49.809058+00
2404	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 21:13:50.103711+00	1	users	\N	\N	2026-07-16 21:13:50.103711+00
2405	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 21:13:57.536059+00	1	courses	\N	\N	2026-07-16 21:13:57.536059+00
2407	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 21:13:57.590338+00	1	courses	\N	\N	2026-07-16 21:13:57.590338+00
2406	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 21:13:57.536732+00	1	enrollments	\N	\N	2026-07-16 21:13:57.536732+00
2408	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 21:13:57.615483+00	1	enrollments	\N	\N	2026-07-16 21:13:57.615483+00
2409	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 21:27:13.319772+00	1	users	\N	\N	2026-07-16 21:27:13.319772+00
2410	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 21:27:13.626079+00	1	users	\N	\N	2026-07-16 21:27:13.626079+00
2411	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 21:27:13.866282+00	1	audit	\N	\N	2026-07-16 21:27:13.866282+00
2412	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 21:27:13.970051+00	1	grades	\N	\N	2026-07-16 21:27:13.970051+00
2413	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 21:27:13.991181+00	1	audit	\N	\N	2026-07-16 21:27:13.991181+00
2414	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 21:27:14.174113+00	1	grades	\N	\N	2026-07-16 21:27:14.174113+00
2415	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 21:27:43.299312+00	1	users	\N	\N	2026-07-16 21:27:43.299312+00
2416	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 21:27:43.362261+00	1	users	\N	\N	2026-07-16 21:27:43.362261+00
2417	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 21:27:43.395596+00	1	users	\N	\N	2026-07-16 21:27:43.395596+00
2418	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 21:27:43.524871+00	1	users	\N	\N	2026-07-16 21:27:43.524871+00
2419	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 21:27:45.278441+00	1	users	\N	\N	2026-07-16 21:27:45.278441+00
2420	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 21:27:45.307918+00	1	users	\N	\N	2026-07-16 21:27:45.307918+00
2421	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 21:27:46.893237+00	1	audit	\N	\N	2026-07-16 21:27:46.893237+00
2422	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 21:27:46.898558+00	1	audit	\N	\N	2026-07-16 21:27:46.898558+00
2423	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 21:27:47.127407+00	1	audit	\N	\N	2026-07-16 21:27:47.127407+00
2424	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 21:27:47.128041+00	1	audit	\N	\N	2026-07-16 21:27:47.128041+00
2425	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 21:29:24.184843+00	2	courses	\N	\N	2026-07-16 21:29:24.184843+00
2426	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-16 21:29:24.262196+00	2	courses	\N	\N	2026-07-16 21:29:24.262196+00
2442	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 13:41:52.215578+00	1	users	\N	\N	2026-07-17 13:41:52.215578+00
2443	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 13:41:52.659828+00	1	users	\N	\N	2026-07-17 13:41:52.659828+00
2444	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 13:41:52.91037+00	1	audit	\N	\N	2026-07-17 13:41:52.91037+00
2445	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 13:41:53.15774+00	1	audit	\N	\N	2026-07-17 13:41:53.15774+00
2446	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 13:41:53.231147+00	1	grades	\N	\N	2026-07-17 13:41:53.231147+00
2447	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 13:41:53.264143+00	1	grades	\N	\N	2026-07-17 13:41:53.264143+00
2448	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:12:27.476124+00	1	users	\N	\N	2026-07-17 15:12:27.476124+00
2449	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:12:27.667371+00	1	users	\N	\N	2026-07-17 15:12:27.667371+00
2450	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:12:27.981349+00	1	grades	\N	\N	2026-07-17 15:12:27.981349+00
2451	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:12:27.983015+00	1	audit	\N	\N	2026-07-17 15:12:27.983015+00
2452	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:12:28.128507+00	1	audit	\N	\N	2026-07-17 15:12:28.128507+00
2453	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:12:28.130393+00	1	grades	\N	\N	2026-07-17 15:12:28.130393+00
2454	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:13:00.033638+00	1	audit	\N	\N	2026-07-17 15:13:00.033638+00
2455	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:13:00.158043+00	1	audit	\N	\N	2026-07-17 15:13:00.158043+00
2456	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:13:00.162645+00	1	courses	\N	\N	2026-07-17 15:13:00.162645+00
2457	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:13:00.290774+00	1	courses	\N	\N	2026-07-17 15:13:00.290774+00
2458	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:13:00.466719+00	1	users	\N	\N	2026-07-17 15:13:00.466719+00
2459	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:13:00.467978+00	1	users	\N	\N	2026-07-17 15:13:00.467978+00
2460	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:13:00.53491+00	1	users	\N	\N	2026-07-17 15:13:00.53491+00
2461	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:13:00.539422+00	1	users	\N	\N	2026-07-17 15:13:00.539422+00
2462	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:13:01.452103+00	1	audit	\N	\N	2026-07-17 15:13:01.452103+00
2463	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:13:01.45276+00	1	audit	\N	\N	2026-07-17 15:13:01.45276+00
2464	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:13:01.596619+00	1	audit	\N	\N	2026-07-17 15:13:01.596619+00
2465	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:13:01.604939+00	1	audit	\N	\N	2026-07-17 15:13:01.604939+00
2466	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:13:03.61583+00	1	users	\N	\N	2026-07-17 15:13:03.61583+00
2467	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:13:03.682906+00	1	users	\N	\N	2026-07-17 15:13:03.682906+00
2468	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:13:04.912639+00	1	audit	\N	\N	2026-07-17 15:13:04.912639+00
2469	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:13:04.914546+00	1	audit	\N	\N	2026-07-17 15:13:04.914546+00
2470	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:13:05.030035+00	1	audit	\N	\N	2026-07-17 15:13:05.030035+00
2471	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:13:05.036018+00	1	audit	\N	\N	2026-07-17 15:13:05.036018+00
2472	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:13:06.840206+00	1	users	\N	\N	2026-07-17 15:13:06.840206+00
2473	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:13:06.930415+00	1	users	\N	\N	2026-07-17 15:13:06.930415+00
2474	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:13:06.961692+00	1	users	\N	\N	2026-07-17 15:13:06.961692+00
2475	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:13:06.962409+00	1	users	\N	\N	2026-07-17 15:13:06.962409+00
2476	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:13:26.449319+00	1	users	\N	\N	2026-07-17 15:13:26.449319+00
2477	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:13:26.4606+00	1	grades	\N	\N	2026-07-17 15:13:26.4606+00
2478	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:13:26.566222+00	1	users	\N	\N	2026-07-17 15:13:26.566222+00
2479	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:13:26.569132+00	1	audit	\N	\N	2026-07-17 15:13:26.569132+00
2480	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:13:26.571541+00	1	grades	\N	\N	2026-07-17 15:13:26.571541+00
2481	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:13:26.718471+00	1	audit	\N	\N	2026-07-17 15:13:26.718471+00
2482	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:36:19.941998+00	1	audit	\N	\N	2026-07-17 15:36:19.941998+00
2483	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:36:20.188276+00	1	courses	\N	\N	2026-07-17 15:36:20.188276+00
2484	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:36:20.328781+00	1	courses	\N	\N	2026-07-17 15:36:20.328781+00
2485	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:36:20.329385+00	1	audit	\N	\N	2026-07-17 15:36:20.329385+00
2486	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:36:30.003555+00	1	users	\N	\N	2026-07-17 15:36:30.003555+00
2487	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:36:30.004022+00	1	audit	\N	\N	2026-07-17 15:36:30.004022+00
2488	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:36:30.009899+00	1	grades	\N	\N	2026-07-17 15:36:30.009899+00
2489	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:36:30.204629+00	1	audit	\N	\N	2026-07-17 15:36:30.204629+00
2490	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:36:30.205157+00	1	grades	\N	\N	2026-07-17 15:36:30.205157+00
2491	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:36:30.216565+00	1	users	\N	\N	2026-07-17 15:36:30.216565+00
2493	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:36:58.679626+00	1	users	\N	\N	2026-07-17 15:36:58.679626+00
2494	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:36:58.7422+00	1	users	\N	\N	2026-07-17 15:36:58.7422+00
2497	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:37:00.639393+00	1	grades	\N	\N	2026-07-17 15:37:00.639393+00
2499	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:37:00.804235+00	1	users	\N	\N	2026-07-17 15:37:00.804235+00
2503	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:37:04.916991+00	1	users	\N	\N	2026-07-17 15:37:04.916991+00
2504	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:37:05.057623+00	1	users	\N	\N	2026-07-17 15:37:05.057623+00
2507	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:37:07.541118+00	1	audit	\N	\N	2026-07-17 15:37:07.541118+00
2509	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:37:07.729428+00	1	grades	\N	\N	2026-07-17 15:37:07.729428+00
2511	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:37:07.814351+00	1	users	\N	\N	2026-07-17 15:37:07.814351+00
2492	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:36:58.679033+00	1	users	\N	\N	2026-07-17 15:36:58.679033+00
2495	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:36:58.762859+00	1	users	\N	\N	2026-07-17 15:36:58.762859+00
2496	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:37:00.638458+00	1	users	\N	\N	2026-07-17 15:37:00.638458+00
2498	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:37:00.803587+00	1	grades	\N	\N	2026-07-17 15:37:00.803587+00
2500	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:37:00.811562+00	1	audit	\N	\N	2026-07-17 15:37:00.811562+00
2501	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:37:00.968441+00	1	audit	\N	\N	2026-07-17 15:37:00.968441+00
2502	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:37:04.916432+00	1	users	\N	\N	2026-07-17 15:37:04.916432+00
2505	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:37:05.076031+00	1	users	\N	\N	2026-07-17 15:37:05.076031+00
2506	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:37:07.540588+00	1	users	\N	\N	2026-07-17 15:37:07.540588+00
2508	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:37:07.541835+00	1	grades	\N	\N	2026-07-17 15:37:07.541835+00
2510	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:37:07.730625+00	1	audit	\N	\N	2026-07-17 15:37:07.730625+00
2512	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:37:28.183118+00	1	audit	\N	\N	2026-07-17 15:37:28.183118+00
2513	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:37:28.195036+00	1	grades	\N	\N	2026-07-17 15:37:28.195036+00
2514	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:37:28.195877+00	1	users	\N	\N	2026-07-17 15:37:28.195877+00
2515	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:37:28.84713+00	1	users	\N	\N	2026-07-17 15:37:28.84713+00
2516	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:37:28.847666+00	1	audit	\N	\N	2026-07-17 15:37:28.847666+00
2517	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:37:28.84819+00	1	grades	\N	\N	2026-07-17 15:37:28.84819+00
2518	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:37:29.630786+00	1	users	\N	\N	2026-07-17 15:37:29.630786+00
2519	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:37:29.631254+00	1	audit	\N	\N	2026-07-17 15:37:29.631254+00
2520	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:37:29.631716+00	1	grades	\N	\N	2026-07-17 15:37:29.631716+00
2521	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:38:03.41124+00	1	users	\N	\N	2026-07-17 15:38:03.41124+00
2522	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:38:03.526296+00	1	audit	\N	\N	2026-07-17 15:38:03.526296+00
2523	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:38:03.652254+00	1	grades	\N	\N	2026-07-17 15:38:03.652254+00
2524	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:38:04.124454+00	1	users	\N	\N	2026-07-17 15:38:04.124454+00
2525	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:38:04.124983+00	1	audit	\N	\N	2026-07-17 15:38:04.124983+00
2526	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:38:04.125563+00	1	grades	\N	\N	2026-07-17 15:38:04.125563+00
2527	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:59:47.149121+00	1	users	\N	\N	2026-07-17 15:59:47.149121+00
2528	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:59:47.152643+00	1	grades	\N	\N	2026-07-17 15:59:47.152643+00
2529	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:59:47.153601+00	1	audit	\N	\N	2026-07-17 15:59:47.153601+00
2530	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:59:47.398098+00	1	grades	\N	\N	2026-07-17 15:59:47.398098+00
2531	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:59:47.419111+00	1	audit	\N	\N	2026-07-17 15:59:47.419111+00
2532	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 15:59:47.533652+00	1	users	\N	\N	2026-07-17 15:59:47.533652+00
2533	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:00:48.325289+00	1	grades	\N	\N	2026-07-17 16:00:48.325289+00
2534	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:00:48.33049+00	1	audit	\N	\N	2026-07-17 16:00:48.33049+00
2535	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:00:48.482359+00	1	users	\N	\N	2026-07-17 16:00:48.482359+00
2536	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:01:24.342553+00	1	audit	\N	\N	2026-07-17 16:01:24.342553+00
2537	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:01:24.344522+00	1	users	\N	\N	2026-07-17 16:01:24.344522+00
2538	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:01:24.351335+00	1	grades	\N	\N	2026-07-17 16:01:24.351335+00
2539	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:01:25.24252+00	1	audit	\N	\N	2026-07-17 16:01:25.24252+00
2540	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:01:25.243428+00	1	users	\N	\N	2026-07-17 16:01:25.243428+00
2541	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:01:25.24392+00	1	grades	\N	\N	2026-07-17 16:01:25.24392+00
2542	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:01:27.563602+00	1	users	\N	\N	2026-07-17 16:01:27.563602+00
2543	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:01:27.572629+00	1	audit	\N	\N	2026-07-17 16:01:27.572629+00
2544	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:01:27.780313+00	1	grades	\N	\N	2026-07-17 16:01:27.780313+00
2545	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:01:27.910469+00	1	audit	\N	\N	2026-07-17 16:01:27.910469+00
2546	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:01:27.941185+00	1	grades	\N	\N	2026-07-17 16:01:27.941185+00
2547	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:01:28.038084+00	1	users	\N	\N	2026-07-17 16:01:28.038084+00
2548	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:01:29.88252+00	1	audit	\N	\N	2026-07-17 16:01:29.88252+00
2549	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:01:29.883343+00	1	grades	\N	\N	2026-07-17 16:01:29.883343+00
2550	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:01:29.886766+00	1	users	\N	\N	2026-07-17 16:01:29.886766+00
2551	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:01:30.746906+00	1	users	\N	\N	2026-07-17 16:01:30.746906+00
2552	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:01:30.747337+00	1	audit	\N	\N	2026-07-17 16:01:30.747337+00
2553	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:01:30.747816+00	1	grades	\N	\N	2026-07-17 16:01:30.747816+00
2554	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:02:31.569206+00	1	users	\N	\N	2026-07-17 16:02:31.569206+00
2555	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:02:31.743578+00	1	grades	\N	\N	2026-07-17 16:02:31.743578+00
2556	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:02:31.777441+00	1	audit	\N	\N	2026-07-17 16:02:31.777441+00
2557	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:02:31.918164+00	1	users	\N	\N	2026-07-17 16:02:31.918164+00
2558	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:02:31.937187+00	1	grades	\N	\N	2026-07-17 16:02:31.937187+00
2559	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:02:32.038679+00	1	audit	\N	\N	2026-07-17 16:02:32.038679+00
2560	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:02:34.950872+00	1	users	\N	\N	2026-07-17 16:02:34.950872+00
2561	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:02:34.951661+00	1	audit	\N	\N	2026-07-17 16:02:34.951661+00
2562	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:02:34.952185+00	1	grades	\N	\N	2026-07-17 16:02:34.952185+00
2563	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:02:36.206196+00	1	users	\N	\N	2026-07-17 16:02:36.206196+00
2564	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:02:36.206657+00	1	audit	\N	\N	2026-07-17 16:02:36.206657+00
2565	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:02:36.207175+00	1	grades	\N	\N	2026-07-17 16:02:36.207175+00
2566	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:02:56.325665+00	1	courses	\N	\N	2026-07-17 16:02:56.325665+00
2567	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:02:56.335626+00	1	audit	\N	\N	2026-07-17 16:02:56.335626+00
2568	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:02:56.433293+00	1	courses	\N	\N	2026-07-17 16:02:56.433293+00
2569	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:02:56.433809+00	1	audit	\N	\N	2026-07-17 16:02:56.433809+00
2570	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:02:58.53867+00	1	users	\N	\N	2026-07-17 16:02:58.53867+00
2571	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:02:58.53915+00	1	users	\N	\N	2026-07-17 16:02:58.53915+00
2575	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:03:02.010274+00	1	courses	\N	\N	2026-07-17 16:03:02.010274+00
2576	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:03:02.115624+00	1	courses	\N	\N	2026-07-17 16:03:02.115624+00
2572	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:02:58.607773+00	1	users	\N	\N	2026-07-17 16:02:58.607773+00
2573	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:02:58.627001+00	1	users	\N	\N	2026-07-17 16:02:58.627001+00
2574	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:03:02.009318+00	1	audit	\N	\N	2026-07-17 16:03:02.009318+00
2577	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:03:02.1239+00	1	audit	\N	\N	2026-07-17 16:03:02.1239+00
2579	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:37:13.498023+00	1	grades	\N	\N	2026-07-17 16:37:13.498023+00
2580	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:37:13.4987+00	1	users	\N	\N	2026-07-17 16:37:13.4987+00
2578	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:37:13.477621+00	1	audit	\N	\N	2026-07-17 16:37:13.477621+00
2581	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:37:13.702039+00	1	grades	\N	\N	2026-07-17 16:37:13.702039+00
2582	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:37:13.702699+00	1	audit	\N	\N	2026-07-17 16:37:13.702699+00
2583	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:37:13.772615+00	1	users	\N	\N	2026-07-17 16:37:13.772615+00
2584	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:37:18.744375+00	1	users	\N	\N	2026-07-17 16:37:18.744375+00
2585	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:37:18.749834+00	1	audit	\N	\N	2026-07-17 16:37:18.749834+00
2586	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:37:18.754452+00	1	grades	\N	\N	2026-07-17 16:37:18.754452+00
2587	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:37:18.950332+00	1	grades	\N	\N	2026-07-17 16:37:18.950332+00
2588	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:37:18.97352+00	1	audit	\N	\N	2026-07-17 16:37:18.97352+00
2589	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:37:18.976226+00	1	users	\N	\N	2026-07-17 16:37:18.976226+00
2590	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:37:41.445273+00	1	audit	\N	\N	2026-07-17 16:37:41.445273+00
2591	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:37:41.58129+00	1	grades	\N	\N	2026-07-17 16:37:41.58129+00
2592	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:37:41.589964+00	1	users	\N	\N	2026-07-17 16:37:41.589964+00
2593	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:54:26.502671+00	1	users	\N	\N	2026-07-17 16:54:26.502671+00
2594	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:54:26.508152+00	1	audit	\N	\N	2026-07-17 16:54:26.508152+00
2595	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:54:27.527666+00	1	grades	\N	\N	2026-07-17 16:54:27.527666+00
2596	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:55:46.006737+00	1	audit	\N	\N	2026-07-17 16:55:46.006737+00
2597	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:55:46.024763+00	1	users	\N	\N	2026-07-17 16:55:46.024763+00
2598	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:55:46.103032+00	1	grades	\N	\N	2026-07-17 16:55:46.103032+00
2599	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:55:46.340492+00	1	audit	\N	\N	2026-07-17 16:55:46.340492+00
2600	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:55:46.358785+00	1	grades	\N	\N	2026-07-17 16:55:46.358785+00
2601	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:55:46.438264+00	1	users	\N	\N	2026-07-17 16:55:46.438264+00
2602	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:56:33.246972+00	1	audit	\N	\N	2026-07-17 16:56:33.246972+00
2603	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:56:33.446893+00	1	audit	\N	\N	2026-07-17 16:56:33.446893+00
2604	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:56:33.571395+00	1	grades	\N	\N	2026-07-17 16:56:33.571395+00
2605	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:56:33.572112+00	1	users	\N	\N	2026-07-17 16:56:33.572112+00
2606	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:56:33.644657+00	1	grades	\N	\N	2026-07-17 16:56:33.644657+00
2607	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 16:56:33.664654+00	1	users	\N	\N	2026-07-17 16:56:33.664654+00
2608	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 17:08:11.311975+00	1	users	\N	\N	2026-07-17 17:08:11.311975+00
2609	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 17:08:11.334379+00	1	audit	\N	\N	2026-07-17 17:08:11.334379+00
2610	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 17:08:11.505832+00	1	grades	\N	\N	2026-07-17 17:08:11.505832+00
2611	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 17:30:00.120021+00	1	courses	\N	\N	2026-07-17 17:30:00.120021+00
2612	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 17:30:00.148478+00	1	audit	\N	\N	2026-07-17 17:30:00.148478+00
2613	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 17:30:00.265545+00	1	courses	\N	\N	2026-07-17 17:30:00.265545+00
2614	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 17:30:00.267402+00	1	audit	\N	\N	2026-07-17 17:30:00.267402+00
2615	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 17:44:23.318203+00	6	grades	\N	\N	2026-07-17 17:44:23.318203+00
2616	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 17:44:23.647688+00	6	grades	\N	\N	2026-07-17 17:44:23.647688+00
2617	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 17:44:23.697567+00	6	enrollments	\N	\N	2026-07-17 17:44:23.697567+00
2618	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 17:44:23.789919+00	6	grades	\N	\N	2026-07-17 17:44:23.789919+00
2619	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 17:44:24.08213+00	6	enrollments	\N	\N	2026-07-17 17:44:24.08213+00
2620	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 17:44:24.0826+00	6	grades	\N	\N	2026-07-17 17:44:24.0826+00
2621	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 17:44:33.366095+00	6	courses	\N	\N	2026-07-17 17:44:33.366095+00
2622	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 17:44:33.372324+00	6	enrollments	\N	\N	2026-07-17 17:44:33.372324+00
2623	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 17:44:33.430551+00	6	enrollments	\N	\N	2026-07-17 17:44:33.430551+00
2624	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-17 17:44:33.437122+00	6	courses	\N	\N	2026-07-17 17:44:33.437122+00
2625	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 14:04:08.11316+00	1	users	\N	\N	2026-07-18 14:04:08.11316+00
2626	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 14:04:08.753432+00	1	audit	\N	\N	2026-07-18 14:04:08.753432+00
2627	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 14:04:08.968532+00	1	users	\N	\N	2026-07-18 14:04:08.968532+00
2628	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 14:04:09.031174+00	1	audit	\N	\N	2026-07-18 14:04:09.031174+00
2629	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 14:04:09.27466+00	1	grades	\N	\N	2026-07-18 14:04:09.27466+00
2630	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 14:04:09.33149+00	1	grades	\N	\N	2026-07-18 14:04:09.33149+00
2631	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 14:04:24.268619+00	1	courses	\N	\N	2026-07-18 14:04:24.268619+00
2632	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 14:04:24.28141+00	1	audit	\N	\N	2026-07-18 14:04:24.28141+00
2633	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 14:04:24.497177+00	1	courses	\N	\N	2026-07-18 14:04:24.497177+00
2634	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 14:04:24.51353+00	1	audit	\N	\N	2026-07-18 14:04:24.51353+00
2635	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 14:13:17.367224+00	1	students	\N	\N	2026-07-18 14:13:17.367224+00
2637	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 14:13:17.373923+00	1	grades	\N	\N	2026-07-18 14:13:17.373923+00
2636	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 14:13:17.365692+00	1	courses	\N	\N	2026-07-18 14:13:17.365692+00
2638	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 14:48:40.471932+00	1	users	\N	\N	2026-07-18 14:48:40.471932+00
2639	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 14:48:40.487043+00	1	users	\N	\N	2026-07-18 14:48:40.487043+00
2640	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 14:48:40.58587+00	1	users	\N	\N	2026-07-18 14:48:40.58587+00
2641	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 14:48:40.63214+00	1	users	\N	\N	2026-07-18 14:48:40.63214+00
2643	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:20:55.851957+00	1	users	\N	\N	2026-07-18 15:20:55.851957+00
2642	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:20:55.844945+00	1	users	\N	\N	2026-07-18 15:20:55.844945+00
2644	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:21:25.319098+00	1	users	\N	\N	2026-07-18 15:21:25.319098+00
2645	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:21:25.331542+00	1	users	\N	\N	2026-07-18 15:21:25.331542+00
2646	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:26:47.303867+00	1	users	\N	\N	2026-07-18 15:26:47.303867+00
2647	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:26:47.40007+00	1	users	\N	\N	2026-07-18 15:26:47.40007+00
2648	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:26:47.404287+00	1	users	\N	\N	2026-07-18 15:26:47.404287+00
2649	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:26:47.431769+00	1	users	\N	\N	2026-07-18 15:26:47.431769+00
2650	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:26:48.915737+00	1	users	\N	\N	2026-07-18 15:26:48.915737+00
2651	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:26:51.195707+00	1	users	\N	\N	2026-07-18 15:26:51.195707+00
2652	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:29:39.991293+00	1	users	\N	\N	2026-07-18 15:29:39.991293+00
2653	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:29:41.951618+00	1	users	\N	\N	2026-07-18 15:29:41.951618+00
2654	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:29:42.686994+00	1	users	\N	\N	2026-07-18 15:29:42.686994+00
2655	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:29:42.9609+00	1	users	\N	\N	2026-07-18 15:29:42.9609+00
2656	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:29:43.314814+00	1	users	\N	\N	2026-07-18 15:29:43.314814+00
2657	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:29:43.841349+00	1	users	\N	\N	2026-07-18 15:29:43.841349+00
2658	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:29:44.075763+00	1	users	\N	\N	2026-07-18 15:29:44.075763+00
2659	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:29:45.857333+00	1	users	\N	\N	2026-07-18 15:29:45.857333+00
2660	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:29:45.861584+00	1	users	\N	\N	2026-07-18 15:29:45.861584+00
2661	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:29:45.902789+00	1	users	\N	\N	2026-07-18 15:29:45.902789+00
2662	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:29:45.903341+00	1	users	\N	\N	2026-07-18 15:29:45.903341+00
2663	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:29:47.604514+00	1	users	\N	\N	2026-07-18 15:29:47.604514+00
2664	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:29:48.332108+00	1	users	\N	\N	2026-07-18 15:29:48.332108+00
2665	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:29:48.708504+00	1	users	\N	\N	2026-07-18 15:29:48.708504+00
2666	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:29:49.285541+00	1	users	\N	\N	2026-07-18 15:29:49.285541+00
2667	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:30:20.983177+00	1	users	\N	\N	2026-07-18 15:30:20.983177+00
2668	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:30:21.549615+00	1	users	\N	\N	2026-07-18 15:30:21.549615+00
2669	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:30:21.984031+00	1	users	\N	\N	2026-07-18 15:30:21.984031+00
2670	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:30:22.532078+00	1	users	\N	\N	2026-07-18 15:30:22.532078+00
2671	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:30:34.509219+00	1	users	\N	\N	2026-07-18 15:30:34.509219+00
2672	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:49:19.461785+00	1	users	\N	\N	2026-07-18 15:49:19.461785+00
2673	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:49:19.523487+00	1	users	\N	\N	2026-07-18 15:49:19.523487+00
2674	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:50:39.034356+00	1	users	\N	\N	2026-07-18 15:50:39.034356+00
2675	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:50:39.034845+00	1	users	\N	\N	2026-07-18 15:50:39.034845+00
2676	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:50:39.103451+00	1	users	\N	\N	2026-07-18 15:50:39.103451+00
2677	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:50:39.10442+00	1	users	\N	\N	2026-07-18 15:50:39.10442+00
2678	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:52:51.342251+00	1	users	\N	\N	2026-07-18 15:52:51.342251+00
2679	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 15:52:51.346487+00	1	users	\N	\N	2026-07-18 15:52:51.346487+00
2680	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:10:32.391529+00	1	users	\N	\N	2026-07-18 16:10:32.391529+00
2681	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:10:32.395924+00	1	users	\N	\N	2026-07-18 16:10:32.395924+00
2682	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:12:24.451156+00	1	users	\N	\N	2026-07-18 16:12:24.451156+00
2683	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:12:24.57548+00	1	users	\N	\N	2026-07-18 16:12:24.57548+00
2684	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:12:53.334423+00	1	users	\N	\N	2026-07-18 16:12:53.334423+00
2685	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:12:53.431706+00	1	users	\N	\N	2026-07-18 16:12:53.431706+00
2686	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:12:53.464148+00	1	users	\N	\N	2026-07-18 16:12:53.464148+00
2687	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:12:53.538839+00	1	users	\N	\N	2026-07-18 16:12:53.538839+00
2688	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:13:18.393053+00	1	users	\N	\N	2026-07-18 16:13:18.393053+00
2689	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:13:18.393603+00	1	users	\N	\N	2026-07-18 16:13:18.393603+00
2690	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:15:36.448569+00	1	audit	\N	\N	2026-07-18 16:15:36.448569+00
2691	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:15:36.459906+00	1	courses	\N	\N	2026-07-18 16:15:36.459906+00
2692	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:15:36.576395+00	1	audit	\N	\N	2026-07-18 16:15:36.576395+00
2693	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:15:36.72728+00	1	courses	\N	\N	2026-07-18 16:15:36.72728+00
2694	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:15:39.936707+00	1	users	\N	\N	2026-07-18 16:15:39.936707+00
2695	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:15:39.937436+00	1	grades	\N	\N	2026-07-18 16:15:39.937436+00
2696	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:15:39.948902+00	1	audit	\N	\N	2026-07-18 16:15:39.948902+00
2697	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:15:40.103331+00	1	audit	\N	\N	2026-07-18 16:15:40.103331+00
2698	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:15:40.10388+00	1	grades	\N	\N	2026-07-18 16:15:40.10388+00
2699	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:15:40.201846+00	1	users	\N	\N	2026-07-18 16:15:40.201846+00
2700	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:15:43.909275+00	1	courses	\N	\N	2026-07-18 16:15:43.909275+00
2701	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:15:43.957195+00	1	audit	\N	\N	2026-07-18 16:15:43.957195+00
2702	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:15:43.959607+00	1	courses	\N	\N	2026-07-18 16:15:43.959607+00
2703	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:15:44.042566+00	1	audit	\N	\N	2026-07-18 16:15:44.042566+00
2704	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:15:45.727483+00	1	users	\N	\N	2026-07-18 16:15:45.727483+00
2705	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:15:45.733847+00	1	users	\N	\N	2026-07-18 16:15:45.733847+00
2706	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:15:45.7828+00	1	users	\N	\N	2026-07-18 16:15:45.7828+00
2707	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:15:45.800286+00	1	users	\N	\N	2026-07-18 16:15:45.800286+00
2708	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:15:48.291399+00	1	users	\N	\N	2026-07-18 16:15:48.291399+00
2709	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:15:48.318319+00	1	users	\N	\N	2026-07-18 16:15:48.318319+00
2710	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:27:15.772663+00	1	users	\N	\N	2026-07-18 16:27:15.772663+00
2711	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:40:54.470645+00	1	users	\N	\N	2026-07-18 16:40:54.470645+00
2712	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:44:49.449361+00	1	users	\N	\N	2026-07-18 16:44:49.449361+00
2713	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:51:49.398529+00	1	users	\N	\N	2026-07-18 16:51:49.398529+00
2714	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:54:37.977561+00	1	users	\N	\N	2026-07-18 16:54:37.977561+00
2715	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:54:38.041165+00	1	users	\N	\N	2026-07-18 16:54:38.041165+00
2716	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 16:58:41.491597+00	1	users	\N	\N	2026-07-18 16:58:41.491597+00
2717	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:05:42.880202+00	1	audit	\N	\N	2026-07-18 17:05:42.880202+00
2718	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:05:42.93556+00	1	audit	\N	\N	2026-07-18 17:05:42.93556+00
2719	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:05:43.086023+00	1	audit	\N	\N	2026-07-18 17:05:43.086023+00
2720	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:05:44.621832+00	1	audit	\N	\N	2026-07-18 17:05:44.621832+00
2721	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:05:45.833296+00	1	users	\N	\N	2026-07-18 17:05:45.833296+00
2722	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:05:45.897235+00	1	users	\N	\N	2026-07-18 17:05:45.897235+00
2723	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:16:58.169692+00	1	audit	\N	\N	2026-07-18 17:16:58.169692+00
2724	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:16:58.173094+00	1	audit	\N	\N	2026-07-18 17:16:58.173094+00
2725	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:16:58.298887+00	1	audit	\N	\N	2026-07-18 17:16:58.298887+00
2726	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:16:58.306336+00	1	audit	\N	\N	2026-07-18 17:16:58.306336+00
2727	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:22:03.835585+00	1	audit	\N	\N	2026-07-18 17:22:03.835585+00
2728	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:22:03.836589+00	1	audit	\N	\N	2026-07-18 17:22:03.836589+00
2729	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:23:31.365626+00	1	audit	\N	\N	2026-07-18 17:23:31.365626+00
2730	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:23:31.469706+00	1	audit	\N	\N	2026-07-18 17:23:31.469706+00
2731	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:23:59.138511+00	1	audit	\N	\N	2026-07-18 17:23:59.138511+00
2732	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:23:59.143451+00	1	audit	\N	\N	2026-07-18 17:23:59.143451+00
2733	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:24:28.299954+00	1	audit	\N	\N	2026-07-18 17:24:28.299954+00
2734	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:24:28.323569+00	1	audit	\N	\N	2026-07-18 17:24:28.323569+00
2735	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:32:56.908977+00	1	audit	\N	\N	2026-07-18 17:32:56.908977+00
2736	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:32:57.072257+00	1	audit	\N	\N	2026-07-18 17:32:57.072257+00
2737	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:38:08.742986+00	1	audit	\N	\N	2026-07-18 17:38:08.742986+00
2738	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:38:08.744174+00	1	audit	\N	\N	2026-07-18 17:38:08.744174+00
2739	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:48:24.091378+00	1	audit	\N	\N	2026-07-18 17:48:24.091378+00
2740	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:48:24.260548+00	1	audit	\N	\N	2026-07-18 17:48:24.260548+00
2742	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:48:24.310636+00	1	audit	\N	\N	2026-07-18 17:48:24.310636+00
2741	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:48:24.292313+00	1	audit	\N	\N	2026-07-18 17:48:24.292313+00
2743	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:48:41.388687+00	1	users	\N	\N	2026-07-18 17:48:41.388687+00
2744	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:48:41.421999+00	1	users	\N	\N	2026-07-18 17:48:41.421999+00
2745	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:48:42.56265+00	1	audit	\N	\N	2026-07-18 17:48:42.56265+00
2746	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:48:42.623584+00	1	audit	\N	\N	2026-07-18 17:48:42.623584+00
2747	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:48:42.721429+00	1	audit	\N	\N	2026-07-18 17:48:42.721429+00
2748	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:48:42.812096+00	1	audit	\N	\N	2026-07-18 17:48:42.812096+00
2749	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:52:33.952287+00	1	audit	\N	\N	2026-07-18 17:52:33.952287+00
2750	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 17:52:34.150796+00	1	audit	\N	\N	2026-07-18 17:52:34.150796+00
2751	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:01:33.584596+00	1	users	\N	\N	2026-07-18 18:01:33.584596+00
2752	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:01:33.58412+00	1	users	\N	\N	2026-07-18 18:01:33.58412+00
2753	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:01:33.662525+00	1	users	\N	\N	2026-07-18 18:01:33.662525+00
2754	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:01:33.68664+00	1	users	\N	\N	2026-07-18 18:01:33.68664+00
2755	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:01:48.958997+00	1	users	\N	\N	2026-07-18 18:01:48.958997+00
2756	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:01:48.993389+00	1	users	\N	\N	2026-07-18 18:01:48.993389+00
2757	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:01:49.020911+00	1	users	\N	\N	2026-07-18 18:01:49.020911+00
2758	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:01:49.029453+00	1	users	\N	\N	2026-07-18 18:01:49.029453+00
2759	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:01:53.09905+00	1	users	\N	\N	2026-07-18 18:01:53.09905+00
2760	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:01:53.148524+00	1	users	\N	\N	2026-07-18 18:01:53.148524+00
2761	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:08:49.578501+00	1	users	\N	\N	2026-07-18 18:08:49.578501+00
2762	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:08:49.66989+00	1	users	\N	\N	2026-07-18 18:08:49.66989+00
2763	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:10:09.882732+00	1	audit	\N	\N	2026-07-18 18:10:09.882732+00
2764	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:10:10.069834+00	1	audit	\N	\N	2026-07-18 18:10:10.069834+00
2765	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:10:10.083933+00	1	audit	\N	\N	2026-07-18 18:10:10.083933+00
2766	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:10:10.227017+00	1	audit	\N	\N	2026-07-18 18:10:10.227017+00
2767	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:10:12.884204+00	1	users	\N	\N	2026-07-18 18:10:12.884204+00
2768	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:10:12.953268+00	1	users	\N	\N	2026-07-18 18:10:12.953268+00
2769	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:10:29.118473+00	1	users	\N	\N	2026-07-18 18:10:29.118473+00
2770	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:10:29.141764+00	1	users	\N	\N	2026-07-18 18:10:29.141764+00
2771	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:10:37.262983+00	1	users	\N	\N	2026-07-18 18:10:37.262983+00
2772	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:10:37.283748+00	1	users	\N	\N	2026-07-18 18:10:37.283748+00
2773	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:10:39.496888+00	1	users	\N	\N	2026-07-18 18:10:39.496888+00
2774	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:10:39.518801+00	1	users	\N	\N	2026-07-18 18:10:39.518801+00
2775	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:11:05.223335+00	1	users	\N	\N	2026-07-18 18:11:05.223335+00
2776	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:11:05.251931+00	1	users	\N	\N	2026-07-18 18:11:05.251931+00
2777	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:11:17.919125+00	1	users	\N	\N	2026-07-18 18:11:17.919125+00
2778	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:11:17.935377+00	1	users	\N	\N	2026-07-18 18:11:17.935377+00
2779	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:13:12.495345+00	1	audit	\N	\N	2026-07-18 18:13:12.495345+00
2780	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:13:12.662866+00	1	audit	\N	\N	2026-07-18 18:13:12.662866+00
2781	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:13:12.79228+00	1	courses	\N	\N	2026-07-18 18:13:12.79228+00
2782	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:13:12.814695+00	1	courses	\N	\N	2026-07-18 18:13:12.814695+00
2783	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:13:33.542856+00	1	users	\N	\N	2026-07-18 18:13:33.542856+00
2784	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:13:33.613512+00	1	users	\N	\N	2026-07-18 18:13:33.613512+00
2786	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:13:34.923334+00	1	courses	\N	\N	2026-07-18 18:13:34.923334+00
2790	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:13:36.03278+00	1	users	\N	\N	2026-07-18 18:13:36.03278+00
2785	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:13:34.891882+00	1	courses	\N	\N	2026-07-18 18:13:34.891882+00
2787	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:13:35.028407+00	1	audit	\N	\N	2026-07-18 18:13:35.028407+00
2788	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:13:35.144005+00	1	audit	\N	\N	2026-07-18 18:13:35.144005+00
2789	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:13:36.032878+00	1	users	\N	\N	2026-07-18 18:13:36.032878+00
2791	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:13:36.093006+00	1	users	\N	\N	2026-07-18 18:13:36.093006+00
2792	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:13:36.093363+00	1	users	\N	\N	2026-07-18 18:13:36.093363+00
2793	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:13:37.191816+00	1	users	\N	\N	2026-07-18 18:13:37.191816+00
2794	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:13:37.301518+00	1	users	\N	\N	2026-07-18 18:13:37.301518+00
2795	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:13:51.939058+00	1	users	\N	\N	2026-07-18 18:13:51.939058+00
2796	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:13:52.087777+00	1	users	\N	\N	2026-07-18 18:13:52.087777+00
2797	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:13:52.128493+00	1	users	\N	\N	2026-07-18 18:13:52.128493+00
2798	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:13:52.128826+00	1	users	\N	\N	2026-07-18 18:13:52.128826+00
2799	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:18:52.752794+00	1	users	\N	\N	2026-07-18 18:18:52.752794+00
2800	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:18:52.762817+00	1	users	\N	\N	2026-07-18 18:18:52.762817+00
2801	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:18:52.891114+00	1	users	\N	\N	2026-07-18 18:18:52.891114+00
2802	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:18:52.916658+00	1	users	\N	\N	2026-07-18 18:18:52.916658+00
2803	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:27:58.54056+00	1	users	\N	\N	2026-07-18 18:27:58.54056+00
2804	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:27:58.576448+00	1	users	\N	\N	2026-07-18 18:27:58.576448+00
2805	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:28:00.841257+00	1	users	\N	\N	2026-07-18 18:28:00.841257+00
2806	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:28:00.847502+00	1	users	\N	\N	2026-07-18 18:28:00.847502+00
2807	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:28:00.955555+00	1	users	\N	\N	2026-07-18 18:28:00.955555+00
2808	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:28:00.971278+00	1	users	\N	\N	2026-07-18 18:28:00.971278+00
2809	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:32:46.404263+00	1	users	\N	\N	2026-07-18 18:32:46.404263+00
2810	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:32:46.407125+00	1	users	\N	\N	2026-07-18 18:32:46.407125+00
2811	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:34:09.41227+00	1	users	\N	\N	2026-07-18 18:34:09.41227+00
2812	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:34:09.499157+00	1	users	\N	\N	2026-07-18 18:34:09.499157+00
2813	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:34:12.919178+00	1	users	\N	\N	2026-07-18 18:34:12.919178+00
2814	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:34:12.919585+00	1	users	\N	\N	2026-07-18 18:34:12.919585+00
2815	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:34:14.823004+00	1	users	\N	\N	2026-07-18 18:34:14.823004+00
2816	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:34:14.823419+00	1	users	\N	\N	2026-07-18 18:34:14.823419+00
2817	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:42:16.238776+00	1	audit	\N	\N	2026-07-18 18:42:16.238776+00
2818	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:42:16.239429+00	1	audit	\N	\N	2026-07-18 18:42:16.239429+00
2819	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:42:16.339631+00	1	audit	\N	\N	2026-07-18 18:42:16.339631+00
2820	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:42:16.430846+00	1	audit	\N	\N	2026-07-18 18:42:16.430846+00
2821	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:49:35.377247+00	1	users	\N	\N	2026-07-18 18:49:35.377247+00
2822	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:49:35.604838+00	1	users	\N	\N	2026-07-18 18:49:35.604838+00
2823	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:49:35.608117+00	1	grades	\N	\N	2026-07-18 18:49:35.608117+00
2824	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:49:35.608511+00	1	audit	\N	\N	2026-07-18 18:49:35.608511+00
2825	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:49:35.804682+00	1	audit	\N	\N	2026-07-18 18:49:35.804682+00
2826	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:49:35.810197+00	1	grades	\N	\N	2026-07-18 18:49:35.810197+00
2827	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:49:55.764732+00	1	users	\N	\N	2026-07-18 18:49:55.764732+00
2828	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:49:55.765387+00	1	users	\N	\N	2026-07-18 18:49:55.765387+00
2829	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:49:55.857385+00	1	users	\N	\N	2026-07-18 18:49:55.857385+00
2830	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:49:55.876884+00	1	users	\N	\N	2026-07-18 18:49:55.876884+00
2831	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:50:00.440017+00	1	audit	\N	\N	2026-07-18 18:50:00.440017+00
2832	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:50:00.560559+00	1	audit	\N	\N	2026-07-18 18:50:00.560559+00
2833	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:50:00.677981+00	1	audit	\N	\N	2026-07-18 18:50:00.677981+00
2834	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:50:00.698823+00	1	audit	\N	\N	2026-07-18 18:50:00.698823+00
2835	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:52:12.60787+00	1	audit	\N	\N	2026-07-18 18:52:12.60787+00
2836	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:52:12.775353+00	1	audit	\N	\N	2026-07-18 18:52:12.775353+00
2837	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:52:23.537022+00	1	audit	\N	\N	2026-07-18 18:52:23.537022+00
2838	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:52:23.839007+00	1	audit	\N	\N	2026-07-18 18:52:23.839007+00
2839	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:53:30.873678+00	1	users	\N	\N	2026-07-18 18:53:30.873678+00
2840	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:53:30.917842+00	1	users	\N	\N	2026-07-18 18:53:30.917842+00
2841	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:53:34.357701+00	1	users	\N	\N	2026-07-18 18:53:34.357701+00
2842	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:53:34.408754+00	1	users	\N	\N	2026-07-18 18:53:34.408754+00
2843	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:53:34.493629+00	1	users	\N	\N	2026-07-18 18:53:34.493629+00
2844	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:53:34.511634+00	1	users	\N	\N	2026-07-18 18:53:34.511634+00
2845	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:53:42.45013+00	1	audit	\N	\N	2026-07-18 18:53:42.45013+00
2846	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:53:42.451799+00	1	audit	\N	\N	2026-07-18 18:53:42.451799+00
2847	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:53:42.579384+00	1	audit	\N	\N	2026-07-18 18:53:42.579384+00
2848	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:53:42.589983+00	1	audit	\N	\N	2026-07-18 18:53:42.589983+00
2849	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:54:57.486769+00	1	users	\N	\N	2026-07-18 18:54:57.486769+00
2850	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:54:57.507644+00	1	users	\N	\N	2026-07-18 18:54:57.507644+00
2851	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:54:57.551532+00	1	users	\N	\N	2026-07-18 18:54:57.551532+00
2852	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:54:57.613093+00	1	users	\N	\N	2026-07-18 18:54:57.613093+00
2853	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:56:45.011225+00	2	courses	\N	\N	2026-07-18 18:56:45.011225+00
2854	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:56:45.060415+00	2	courses	\N	\N	2026-07-18 18:56:45.060415+00
2855	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 18:57:31.680954+00	2	courses	\N	\N	2026-07-18 18:57:31.680954+00
2856	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:04:13.455112+00	2	courses	\N	\N	2026-07-18 19:04:13.455112+00
2857	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:05:55.404159+00	2	courses	\N	\N	2026-07-18 19:05:55.404159+00
2858	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:05:55.427174+00	2	courses	\N	\N	2026-07-18 19:05:55.427174+00
2859	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:05:55.498312+00	2	courses	\N	\N	2026-07-18 19:05:55.498312+00
2860	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:05:55.514597+00	2	students	\N	\N	2026-07-18 19:05:55.514597+00
2861	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:05:55.525256+00	2	grades	\N	\N	2026-07-18 19:05:55.525256+00
2862	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:05:58.647869+00	2	courses	\N	\N	2026-07-18 19:05:58.647869+00
2863	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:05:58.760938+00	2	students	\N	\N	2026-07-18 19:05:58.760938+00
2864	\N	read	\N	2	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:05:58.761467+00	2	students	\N	\N	2026-07-18 19:05:58.761467+00
2865	\N	read	\N	2	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:05:58.824756+00	2	grades	\N	\N	2026-07-18 19:05:58.824756+00
2866	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:05:58.878741+00	2	courses	\N	\N	2026-07-18 19:05:58.878741+00
2867	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:05:58.919892+00	2	students	\N	\N	2026-07-18 19:05:58.919892+00
2868	\N	read	\N	2	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:05:58.920358+00	2	students	\N	\N	2026-07-18 19:05:58.920358+00
2869	\N	read	\N	2	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:05:58.940677+00	2	grades	\N	\N	2026-07-18 19:05:58.940677+00
2870	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:05:58.959878+00	2	grades	\N	\N	2026-07-18 19:05:58.959878+00
2871	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:05:58.977656+00	2	grades	\N	\N	2026-07-18 19:05:58.977656+00
2872	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:06:06.222351+00	2	courses	\N	\N	2026-07-18 19:06:06.222351+00
2873	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:06:06.244348+00	2	courses	\N	\N	2026-07-18 19:06:06.244348+00
2874	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:06:06.30504+00	2	courses	\N	\N	2026-07-18 19:06:06.30504+00
2875	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:06:06.305845+00	2	students	\N	\N	2026-07-18 19:06:06.305845+00
2876	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:06:06.306882+00	2	grades	\N	\N	2026-07-18 19:06:06.306882+00
2877	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:06:09.71444+00	2	courses	\N	\N	2026-07-18 19:06:09.71444+00
2878	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:06:09.761696+00	2	courses	\N	\N	2026-07-18 19:06:09.761696+00
2879	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:06:09.805031+00	2	students	\N	\N	2026-07-18 19:06:09.805031+00
2880	\N	read	\N	2	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:06:09.841867+00	2	students	\N	\N	2026-07-18 19:06:09.841867+00
2881	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:06:09.843454+00	2	grades	\N	\N	2026-07-18 19:06:09.843454+00
2882	\N	read	\N	2	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:06:09.849961+00	2	grades	\N	\N	2026-07-18 19:06:09.849961+00
2883	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:06:09.879885+00	2	students	\N	\N	2026-07-18 19:06:09.879885+00
2884	\N	read	\N	2	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:06:09.880281+00	2	students	\N	\N	2026-07-18 19:06:09.880281+00
2885	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:06:09.881764+00	2	grades	\N	\N	2026-07-18 19:06:09.881764+00
2886	\N	read	\N	2	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:06:10.011665+00	2	grades	\N	\N	2026-07-18 19:06:10.011665+00
2887	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:12:04.412707+00	2	courses	\N	\N	2026-07-18 19:12:04.412707+00
2888	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:12:04.650495+00	2	courses	\N	\N	2026-07-18 19:12:04.650495+00
2889	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:12:15.581741+00	2	courses	\N	\N	2026-07-18 19:12:15.581741+00
2890	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:12:15.631118+00	2	courses	\N	\N	2026-07-18 19:12:15.631118+00
2891	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:12:15.687237+00	2	courses	\N	\N	2026-07-18 19:12:15.687237+00
2892	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:12:15.720202+00	2	students	\N	\N	2026-07-18 19:12:15.720202+00
2893	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:12:15.7348+00	2	grades	\N	\N	2026-07-18 19:12:15.7348+00
2894	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:12:17.444119+00	2	courses	\N	\N	2026-07-18 19:12:17.444119+00
2895	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:12:17.549655+00	2	courses	\N	\N	2026-07-18 19:12:17.549655+00
2896	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:20:27.670126+00	2	courses	\N	\N	2026-07-18 19:20:27.670126+00
2897	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:20:27.739557+00	2	courses	\N	\N	2026-07-18 19:20:27.739557+00
2898	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:20:27.838549+00	2	courses	\N	\N	2026-07-18 19:20:27.838549+00
2899	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:20:27.839752+00	2	students	\N	\N	2026-07-18 19:20:27.839752+00
2900	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:20:27.854982+00	2	grades	\N	\N	2026-07-18 19:20:27.854982+00
2901	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:20:40.452897+00	2	courses	\N	\N	2026-07-18 19:20:40.452897+00
2902	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:20:40.530588+00	2	courses	\N	\N	2026-07-18 19:20:40.530588+00
2903	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:20:44.010543+00	2	courses	\N	\N	2026-07-18 19:20:44.010543+00
2904	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:20:44.062633+00	2	courses	\N	\N	2026-07-18 19:20:44.062633+00
2905	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:20:44.130353+00	2	courses	\N	\N	2026-07-18 19:20:44.130353+00
2906	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:20:44.13666+00	2	grades	\N	\N	2026-07-18 19:20:44.13666+00
2907	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 19:20:44.138238+00	2	students	\N	\N	2026-07-18 19:20:44.138238+00
2908	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 20:03:36.722413+00	2	courses	\N	\N	2026-07-18 20:03:36.722413+00
2909	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 20:03:36.79403+00	2	courses	\N	\N	2026-07-18 20:03:36.79403+00
2910	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 20:03:36.877823+00	2	courses	\N	\N	2026-07-18 20:03:36.877823+00
2911	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 20:03:36.879103+00	2	students	\N	\N	2026-07-18 20:03:36.879103+00
2912	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 20:03:36.896172+00	2	grades	\N	\N	2026-07-18 20:03:36.896172+00
2913	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 20:18:06.650148+00	2	courses	\N	\N	2026-07-18 20:18:06.650148+00
2914	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 20:18:06.679633+00	2	courses	\N	\N	2026-07-18 20:18:06.679633+00
2915	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 20:18:06.765006+00	2	courses	\N	\N	2026-07-18 20:18:06.765006+00
2916	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 20:18:06.869304+00	2	courses	\N	\N	2026-07-18 20:18:06.869304+00
2917	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 20:37:56.140893+00	2	courses	\N	\N	2026-07-18 20:37:56.140893+00
2918	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 20:37:56.161858+00	2	courses	\N	\N	2026-07-18 20:37:56.161858+00
2919	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 20:40:39.003365+00	2	courses	\N	\N	2026-07-18 20:40:39.003365+00
2920	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 20:40:39.126809+00	2	courses	\N	\N	2026-07-18 20:40:39.126809+00
2921	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 21:02:53.818225+00	2	courses	\N	\N	2026-07-18 21:02:53.818225+00
2922	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 21:02:53.880701+00	2	courses	\N	\N	2026-07-18 21:02:53.880701+00
2923	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 21:32:14.604836+00	2	courses	\N	\N	2026-07-18 21:32:14.604836+00
2924	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 21:32:14.659954+00	2	courses	\N	\N	2026-07-18 21:32:14.659954+00
2925	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 21:32:14.692637+00	2	courses	\N	\N	2026-07-18 21:32:14.692637+00
2926	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 21:32:14.715265+00	2	courses	\N	\N	2026-07-18 21:32:14.715265+00
2927	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 22:07:10.179313+00	2	courses	\N	\N	2026-07-18 22:07:10.179313+00
2928	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 22:07:10.258748+00	2	courses	\N	\N	2026-07-18 22:07:10.258748+00
2929	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 22:15:03.365046+00	2	courses	\N	\N	2026-07-18 22:15:03.365046+00
2930	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 22:15:03.431404+00	2	courses	\N	\N	2026-07-18 22:15:03.431404+00
2931	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 22:29:27.597457+00	2	courses	\N	\N	2026-07-18 22:29:27.597457+00
2932	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 22:33:37.769698+00	2	courses	\N	\N	2026-07-18 22:33:37.769698+00
2933	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 22:33:37.854419+00	2	courses	\N	\N	2026-07-18 22:33:37.854419+00
2934	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 22:33:45.846157+00	2	courses	\N	\N	2026-07-18 22:33:45.846157+00
2935	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 22:33:45.886106+00	2	courses	\N	\N	2026-07-18 22:33:45.886106+00
2936	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 22:33:45.965803+00	2	courses	\N	\N	2026-07-18 22:33:45.965803+00
2937	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 22:33:45.974247+00	2	grades	\N	\N	2026-07-18 22:33:45.974247+00
2938	\N	read	\N	1	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 22:33:45.976626+00	2	students	\N	\N	2026-07-18 22:33:45.976626+00
2939	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 22:33:51.860903+00	2	courses	\N	\N	2026-07-18 22:33:51.860903+00
2940	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 22:33:51.937917+00	2	courses	\N	\N	2026-07-18 22:33:51.937917+00
2941	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 22:33:54.918869+00	2	courses	\N	\N	2026-07-18 22:33:54.918869+00
2942	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 22:33:54.994602+00	2	courses	\N	\N	2026-07-18 22:33:54.994602+00
2943	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 22:33:55.060155+00	2	courses	\N	\N	2026-07-18 22:33:55.060155+00
2944	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-18 22:33:55.090814+00	2	courses	\N	\N	2026-07-18 22:33:55.090814+00
2945	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-19 16:03:02.441049+00	2	courses	\N	\N	2026-07-19 16:03:02.441049+00
2946	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-19 16:03:02.438147+00	2	courses	\N	\N	2026-07-19 16:03:02.438147+00
2947	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-19 16:03:02.570954+00	2	courses	\N	\N	2026-07-19 16:03:02.570954+00
2948	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-19 16:03:02.715777+00	2	courses	\N	\N	2026-07-19 16:03:02.715777+00
2949	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:53:47.077498+00	1	users	\N	\N	2026-07-20 20:53:47.077498+00
2950	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:53:47.319733+00	1	audit	\N	\N	2026-07-20 20:53:47.319733+00
2951	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:53:47.423485+00	1	audit	\N	\N	2026-07-20 20:53:47.423485+00
2952	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:53:47.427029+00	1	users	\N	\N	2026-07-20 20:53:47.427029+00
2953	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:53:47.429388+00	1	grades	\N	\N	2026-07-20 20:53:47.429388+00
2954	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:53:47.559667+00	1	grades	\N	\N	2026-07-20 20:53:47.559667+00
2955	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:54:11.805725+00	1	audit	\N	\N	2026-07-20 20:54:11.805725+00
2956	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:54:11.928771+00	1	audit	\N	\N	2026-07-20 20:54:11.928771+00
2957	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:54:11.936936+00	1	audit	\N	\N	2026-07-20 20:54:11.936936+00
2958	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:54:12.034915+00	1	audit	\N	\N	2026-07-20 20:54:12.034915+00
2959	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:54:21.955252+00	1	users	\N	\N	2026-07-20 20:54:21.955252+00
2960	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:54:22.002678+00	1	users	\N	\N	2026-07-20 20:54:22.002678+00
2961	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:56:09.444345+00	6	grades	\N	\N	2026-07-20 20:56:09.444345+00
2962	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:56:09.53006+00	6	grades	\N	\N	2026-07-20 20:56:09.53006+00
2963	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:56:09.568989+00	6	enrollments	\N	\N	2026-07-20 20:56:09.568989+00
2964	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:56:09.598881+00	6	grades	\N	\N	2026-07-20 20:56:09.598881+00
2965	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:56:09.644029+00	6	enrollments	\N	\N	2026-07-20 20:56:09.644029+00
2966	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:56:09.647042+00	6	grades	\N	\N	2026-07-20 20:56:09.647042+00
2967	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:56:36.205313+00	6	grades	\N	\N	2026-07-20 20:56:36.205313+00
2968	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:56:36.259893+00	6	grades	\N	\N	2026-07-20 20:56:36.259893+00
2969	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:56:36.327494+00	6	grades	\N	\N	2026-07-20 20:56:36.327494+00
2970	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:56:36.363319+00	6	grades	\N	\N	2026-07-20 20:56:36.363319+00
2971	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:57:02.781611+00	6	courses	\N	\N	2026-07-20 20:57:02.781611+00
2972	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:57:02.826766+00	6	enrollments	\N	\N	2026-07-20 20:57:02.826766+00
2973	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:57:02.863846+00	6	enrollments	\N	\N	2026-07-20 20:57:02.863846+00
2974	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:57:02.885544+00	6	courses	\N	\N	2026-07-20 20:57:02.885544+00
2975	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:57:18.523374+00	6	enrollments	\N	\N	2026-07-20 20:57:18.523374+00
2976	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:57:18.565977+00	6	enrollments	\N	\N	2026-07-20 20:57:18.565977+00
2977	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:57:18.587022+00	6	grades	\N	\N	2026-07-20 20:57:18.587022+00
2978	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:57:18.599723+00	6	grades	\N	\N	2026-07-20 20:57:18.599723+00
2979	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:57:18.664339+00	6	grades	\N	\N	2026-07-20 20:57:18.664339+00
2980	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 20:57:18.760297+00	6	grades	\N	\N	2026-07-20 20:57:18.760297+00
2981	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 21:02:44.665924+00	1	users	\N	\N	2026-07-20 21:02:44.665924+00
2982	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 21:02:44.862467+00	1	audit	\N	\N	2026-07-20 21:02:44.862467+00
2983	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 21:02:44.863366+00	1	grades	\N	\N	2026-07-20 21:02:44.863366+00
2984	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 21:02:44.965582+00	1	users	\N	\N	2026-07-20 21:02:44.965582+00
2985	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 21:02:44.979297+00	1	audit	\N	\N	2026-07-20 21:02:44.979297+00
2986	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 21:02:44.981199+00	1	grades	\N	\N	2026-07-20 21:02:44.981199+00
2987	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 21:02:51.518909+00	1	audit	\N	\N	2026-07-20 21:02:51.518909+00
2988	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 21:02:51.521625+00	1	audit	\N	\N	2026-07-20 21:02:51.521625+00
2989	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 21:02:51.634643+00	1	audit	\N	\N	2026-07-20 21:02:51.634643+00
2990	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-20 21:02:51.729657+00	1	audit	\N	\N	2026-07-20 21:02:51.729657+00
2992	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 11:58:33.752438+00	2	courses	\N	\N	2026-07-21 11:58:33.752438+00
2991	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 11:58:33.753217+00	2	courses	\N	\N	2026-07-21 11:58:33.753217+00
2993	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 11:58:33.82506+00	2	courses	\N	\N	2026-07-21 11:58:33.82506+00
2994	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 11:58:33.83349+00	2	courses	\N	\N	2026-07-21 11:58:33.83349+00
2995	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 11:58:39.238119+00	2	courses	\N	\N	2026-07-21 11:58:39.238119+00
2996	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 11:58:39.312764+00	2	courses	\N	\N	2026-07-21 11:58:39.312764+00
2997	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:05:10.402773+00	2	courses	\N	\N	2026-07-21 12:05:10.402773+00
2998	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:05:22.322768+00	2	courses	\N	\N	2026-07-21 12:05:22.322768+00
2999	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:06:25.32881+00	2	courses	\N	\N	2026-07-21 12:06:25.32881+00
3000	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:40:43.889587+00	2	courses	\N	\N	2026-07-21 12:40:43.889587+00
3001	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:40:44.014171+00	2	courses	\N	\N	2026-07-21 12:40:44.014171+00
3002	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:40:44.067032+00	2	courses	\N	\N	2026-07-21 12:40:44.067032+00
3003	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:40:44.268548+00	2	courses	\N	\N	2026-07-21 12:40:44.268548+00
3004	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:40:44.855588+00	2	courses	\N	\N	2026-07-21 12:40:44.855588+00
3005	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:40:44.936444+00	2	courses	\N	\N	2026-07-21 12:40:44.936444+00
3006	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:44:53.339513+00	2	courses	\N	\N	2026-07-21 12:44:53.339513+00
3007	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:45:28.340249+00	2	courses	\N	\N	2026-07-21 12:45:28.340249+00
3008	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:45:28.497618+00	2	courses	\N	\N	2026-07-21 12:45:28.497618+00
3009	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:46:16.873814+00	2	courses	\N	\N	2026-07-21 12:46:16.873814+00
3010	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:46:23.201668+00	2	courses	\N	\N	2026-07-21 12:46:23.201668+00
3011	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:46:23.328045+00	2	courses	\N	\N	2026-07-21 12:46:23.328045+00
3012	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:46:23.430048+00	2	courses	\N	\N	2026-07-21 12:46:23.430048+00
3013	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:46:23.464023+00	2	courses	\N	\N	2026-07-21 12:46:23.464023+00
3014	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:48:44.503048+00	2	courses	\N	\N	2026-07-21 12:48:44.503048+00
3015	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:48:46.386117+00	2	courses	\N	\N	2026-07-21 12:48:46.386117+00
3016	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:48:47.106033+00	2	courses	\N	\N	2026-07-21 12:48:47.106033+00
3017	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:50:30.562328+00	2	courses	\N	\N	2026-07-21 12:50:30.562328+00
3018	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:50:30.622306+00	2	courses	\N	\N	2026-07-21 12:50:30.622306+00
3019	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:50:30.676785+00	2	courses	\N	\N	2026-07-21 12:50:30.676785+00
3020	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:50:30.717218+00	2	courses	\N	\N	2026-07-21 12:50:30.717218+00
3021	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:50:35.624519+00	2	courses	\N	\N	2026-07-21 12:50:35.624519+00
3022	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:50:35.758502+00	2	courses	\N	\N	2026-07-21 12:50:35.758502+00
3023	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:50:35.868883+00	2	courses	\N	\N	2026-07-21 12:50:35.868883+00
3024	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:50:35.897574+00	2	courses	\N	\N	2026-07-21 12:50:35.897574+00
3025	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:51:41.165842+00	2	courses	\N	\N	2026-07-21 12:51:41.165842+00
3026	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:51:41.261771+00	2	courses	\N	\N	2026-07-21 12:51:41.261771+00
3027	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:51:41.319495+00	2	courses	\N	\N	2026-07-21 12:51:41.319495+00
3028	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:51:41.339381+00	2	courses	\N	\N	2026-07-21 12:51:41.339381+00
3029	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:53:16.550733+00	2	courses	\N	\N	2026-07-21 12:53:16.550733+00
3030	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:53:16.70164+00	2	courses	\N	\N	2026-07-21 12:53:16.70164+00
3031	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:53:16.767578+00	2	courses	\N	\N	2026-07-21 12:53:16.767578+00
3032	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:53:16.78643+00	2	courses	\N	\N	2026-07-21 12:53:16.78643+00
3033	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:55:42.279002+00	2	courses	\N	\N	2026-07-21 12:55:42.279002+00
3034	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:55:42.348451+00	2	courses	\N	\N	2026-07-21 12:55:42.348451+00
3035	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:55:42.419752+00	2	courses	\N	\N	2026-07-21 12:55:42.419752+00
3036	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:55:42.481947+00	2	courses	\N	\N	2026-07-21 12:55:42.481947+00
3037	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:57:11.172967+00	2	courses	\N	\N	2026-07-21 12:57:11.172967+00
3038	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:57:11.252729+00	2	courses	\N	\N	2026-07-21 12:57:11.252729+00
3039	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:57:11.318738+00	2	courses	\N	\N	2026-07-21 12:57:11.318738+00
3040	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:57:11.421892+00	2	courses	\N	\N	2026-07-21 12:57:11.421892+00
3041	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:57:59.427297+00	2	courses	\N	\N	2026-07-21 12:57:59.427297+00
3042	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:57:59.521137+00	2	courses	\N	\N	2026-07-21 12:57:59.521137+00
3043	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:57:59.613704+00	2	courses	\N	\N	2026-07-21 12:57:59.613704+00
3044	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:57:59.718123+00	2	courses	\N	\N	2026-07-21 12:57:59.718123+00
3045	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:58:30.332799+00	2	courses	\N	\N	2026-07-21 12:58:30.332799+00
3046	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:58:30.47659+00	2	courses	\N	\N	2026-07-21 12:58:30.47659+00
3047	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:58:36.228245+00	2	courses	\N	\N	2026-07-21 12:58:36.228245+00
3048	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:58:36.376356+00	2	courses	\N	\N	2026-07-21 12:58:36.376356+00
3049	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:59:59.580901+00	2	courses	\N	\N	2026-07-21 12:59:59.580901+00
3050	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:59:59.681579+00	2	courses	\N	\N	2026-07-21 12:59:59.681579+00
3051	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:59:59.761673+00	2	courses	\N	\N	2026-07-21 12:59:59.761673+00
3052	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 12:59:59.814849+00	2	courses	\N	\N	2026-07-21 12:59:59.814849+00
3053	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 13:00:00.337319+00	2	courses	\N	\N	2026-07-21 13:00:00.337319+00
3054	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 13:03:22.012465+00	2	courses	\N	\N	2026-07-21 13:03:22.012465+00
3055	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 13:03:22.036943+00	2	courses	\N	\N	2026-07-21 13:03:22.036943+00
3056	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 13:03:22.058231+00	2	courses	\N	\N	2026-07-21 13:03:22.058231+00
3057	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 13:03:22.076428+00	2	courses	\N	\N	2026-07-21 13:03:22.076428+00
3058	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 13:08:18.898673+00	2	courses	\N	\N	2026-07-21 13:08:18.898673+00
3059	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 13:08:18.991571+00	2	courses	\N	\N	2026-07-21 13:08:18.991571+00
3060	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 13:08:19.117253+00	2	courses	\N	\N	2026-07-21 13:08:19.117253+00
3061	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 13:08:19.160957+00	2	courses	\N	\N	2026-07-21 13:08:19.160957+00
3062	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 13:10:16.622951+00	2	courses	\N	\N	2026-07-21 13:10:16.622951+00
3063	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 13:10:16.708957+00	2	courses	\N	\N	2026-07-21 13:10:16.708957+00
3064	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 13:10:24.193004+00	2	my-profile	\N	\N	2026-07-21 13:10:24.193004+00
3065	\N	write	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 13:10:48.066388+00	2	my-profile	\N	\N	2026-07-21 13:10:48.066388+00
3066	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 13:17:24.834537+00	2	courses	\N	\N	2026-07-21 13:17:24.834537+00
3067	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 13:17:25.019451+00	2	courses	\N	\N	2026-07-21 13:17:25.019451+00
3068	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 15:33:44.878734+00	2	courses	\N	/api/v1/courses	2026-07-21 15:33:44.878734+00
3069	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 15:33:44.919734+00	2	courses	\N	/api/v1/courses	2026-07-21 15:33:44.919734+00
3070	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 15:35:59.761558+00	1	users	\N	/api/v1/admin/stats	2026-07-21 15:35:59.761558+00
3071	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 15:36:00.044564+00	1	audit	\N	/api/v1/admin/security-events	2026-07-21 15:36:00.044564+00
3072	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 15:36:00.045195+00	1	grades	\N	/api/v1/admin/grades/pending	2026-07-21 15:36:00.045195+00
3073	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 15:36:00.193439+00	1	audit	\N	/api/v1/admin/security-events	2026-07-21 15:36:00.193439+00
3074	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 15:36:00.227327+00	1	users	\N	/api/v1/admin/stats	2026-07-21 15:36:00.227327+00
3075	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 15:36:00.228586+00	1	grades	\N	/api/v1/admin/grades/pending	2026-07-21 15:36:00.228586+00
3076	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 15:36:55.212894+00	2	courses	\N	/api/v1/courses	2026-07-21 15:36:55.212894+00
3077	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 15:36:55.260721+00	2	courses	\N	/api/v1/courses/my/grading-progress	2026-07-21 15:36:55.260721+00
3078	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 15:36:55.31204+00	2	courses	\N	/api/v1/courses	2026-07-21 15:36:55.31204+00
3079	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-21 15:36:55.55413+00	2	courses	\N	/api/v1/courses/my/grading-progress	2026-07-21 15:36:55.55413+00
3080	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 12:56:54.576563+00	2	courses	\N	/api/v1/courses/my/grading-progress	2026-07-23 12:56:54.576563+00
3081	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 12:56:54.620999+00	2	courses	\N	/api/v1/courses	2026-07-23 12:56:54.620999+00
3082	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 12:56:54.759474+00	2	courses	\N	/api/v1/courses	2026-07-23 12:56:54.759474+00
3083	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 12:56:54.989513+00	2	courses	\N	/api/v1/courses/my/grading-progress	2026-07-23 12:56:54.989513+00
3084	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:05:53.12019+00	2	courses	\N	/api/v1/courses	2026-07-23 13:05:53.12019+00
3085	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:05:53.24132+00	2	courses	\N	/api/v1/courses/my/grading-progress	2026-07-23 13:05:53.24132+00
3086	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:05:53.34148+00	2	courses	\N	/api/v1/courses	2026-07-23 13:05:53.34148+00
3087	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:05:53.427136+00	2	courses	\N	/api/v1/courses/my/grading-progress	2026-07-23 13:05:53.427136+00
3088	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:09:29.922359+00	1	users	\N	/api/v1/admin/stats	2026-07-23 13:09:29.922359+00
3089	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:09:30.258844+00	1	grades	\N	/api/v1/admin/grades/pending	2026-07-23 13:09:30.258844+00
3090	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:09:30.27336+00	1	audit	\N	/api/v1/admin/security-events	2026-07-23 13:09:30.27336+00
3091	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:09:30.395744+00	1	users	\N	/api/v1/admin/stats	2026-07-23 13:09:30.395744+00
3092	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:09:30.405394+00	1	grades	\N	/api/v1/admin/grades/pending	2026-07-23 13:09:30.405394+00
3093	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:09:30.426389+00	1	audit	\N	/api/v1/admin/security-events	2026-07-23 13:09:30.426389+00
3094	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:10:26.965498+00	1	users	\N	/api/v1/admin/stats	2026-07-23 13:10:26.965498+00
3095	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:10:27.047029+00	1	users	\N	/api/v1/admin/access-matrix	2026-07-23 13:10:27.047029+00
3096	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:10:27.078512+00	1	users	\N	/api/v1/admin/access-matrix	2026-07-23 13:10:27.078512+00
3097	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:10:27.084863+00	1	users	\N	/api/v1/admin/stats	2026-07-23 13:10:27.084863+00
3098	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:11:30.695595+00	6	grades	\N	/api/v1/grades/my	2026-07-23 13:11:30.695595+00
3099	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:11:30.752425+00	6	grades	\N	/api/v1/grades/my	2026-07-23 13:11:30.752425+00
3100	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:11:31.039775+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 13:11:31.039775+00
3101	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:11:31.164771+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 13:11:31.164771+00
3102	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:11:31.185706+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 13:11:31.185706+00
3103	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:11:31.242135+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 13:11:31.242135+00
3104	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:19:24.437244+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 13:19:24.437244+00
3105	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:19:24.528511+00	6	grades	\N	/api/v1/grades/my	2026-07-23 13:19:24.528511+00
3106	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:19:24.654622+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 13:19:24.654622+00
3107	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:19:25.105389+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 13:19:25.105389+00
3108	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:19:25.109861+00	6	grades	\N	/api/v1/grades/my	2026-07-23 13:19:25.109861+00
3109	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:19:25.177874+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 13:19:25.177874+00
3110	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:19:54.432177+00	6	grades	\N	/api/v1/grades/my	2026-07-23 13:19:54.432177+00
3111	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:19:54.438362+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 13:19:54.438362+00
3112	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:19:54.585627+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 13:19:54.585627+00
3113	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:19:54.603714+00	6	grades	\N	/api/v1/grades/my	2026-07-23 13:19:54.603714+00
3114	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:19:54.604373+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 13:19:54.604373+00
3115	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:19:54.646412+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 13:19:54.646412+00
3116	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:22:37.533253+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 13:22:37.533253+00
3117	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:22:37.574072+00	6	grades	\N	/api/v1/grades/my	2026-07-23 13:22:37.574072+00
3118	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:22:37.636269+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 13:22:37.636269+00
3119	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:22:38.121788+00	6	grades	\N	/api/v1/grades/my	2026-07-23 13:22:38.121788+00
3120	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:22:38.16207+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 13:22:38.16207+00
3121	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 13:22:38.239962+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 13:22:38.239962+00
3122	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 14:47:56.537015+00	6	grades	\N	/api/v1/grades/my	2026-07-23 14:47:56.537015+00
3123	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 14:47:56.556169+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 14:47:56.556169+00
3124	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 14:47:56.720629+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 14:47:56.720629+00
3125	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 14:47:56.793514+00	6	grades	\N	/api/v1/grades/my	2026-07-23 14:47:56.793514+00
3126	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 14:47:56.802102+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 14:47:56.802102+00
3127	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 14:47:56.902682+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 14:47:56.902682+00
3128	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:10.021937+00	6	grades	\N	/api/v1/grades/my	2026-07-23 15:20:10.021937+00
3129	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:10.099532+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:20:10.099532+00
3130	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:10.165808+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 15:20:10.165808+00
3131	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:10.191973+00	6	grades	\N	/api/v1/grades/my	2026-07-23 15:20:10.191973+00
3132	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:10.213755+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:20:10.213755+00
3133	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:10.318294+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 15:20:10.318294+00
3134	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:12.679067+00	6	grades	\N	/api/v1/grades/my	2026-07-23 15:20:12.679067+00
3135	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:12.712875+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 15:20:12.712875+00
3136	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:12.716815+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:20:12.716815+00
3137	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:12.762335+00	6	grades	\N	/api/v1/grades/my	2026-07-23 15:20:12.762335+00
3138	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:12.777384+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 15:20:12.777384+00
3139	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:12.848091+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:20:12.848091+00
3140	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:46.803783+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:20:46.803783+00
3141	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:46.804225+00	6	grades	\N	/api/v1/grades/my	2026-07-23 15:20:46.804225+00
3142	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:46.908843+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 15:20:46.908843+00
3143	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:46.933351+00	6	grades	\N	/api/v1/grades/my	2026-07-23 15:20:46.933351+00
3144	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:46.933863+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:20:46.933863+00
3145	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:47.001189+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 15:20:47.001189+00
3146	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:49.38157+00	6	grades	\N	/api/v1/grades/my	2026-07-23 15:20:49.38157+00
3147	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:49.384943+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 15:20:49.384943+00
3148	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:49.385736+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:20:49.385736+00
3149	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:49.608025+00	6	grades	\N	/api/v1/grades/my	2026-07-23 15:20:49.608025+00
3150	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:49.609244+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:20:49.609244+00
3151	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:49.616816+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 15:20:49.616816+00
3152	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:51.757671+00	6	grades	\N	/api/v1/grades/my	2026-07-23 15:20:51.757671+00
3153	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:51.761284+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 15:20:51.761284+00
3154	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:51.761813+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:20:51.761813+00
3155	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:51.97809+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 15:20:51.97809+00
3156	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:51.979516+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:20:51.979516+00
3157	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:20:51.98849+00	6	grades	\N	/api/v1/grades/my	2026-07-23 15:20:51.98849+00
3158	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:21:05.402625+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 15:21:05.402625+00
3159	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:21:05.424509+00	6	grades	\N	/api/v1/grades/my	2026-07-23 15:21:05.424509+00
3160	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:21:05.464071+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 15:21:05.464071+00
3161	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:21:05.484412+00	6	grades	\N	/api/v1/grades/my	2026-07-23 15:21:05.484412+00
3162	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:21:05.492969+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:21:05.492969+00
3163	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:21:05.546228+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:21:05.546228+00
3164	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:21:06.460048+00	6	grades	\N	/api/v1/grades/my	2026-07-23 15:21:06.460048+00
3165	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:21:06.461384+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 15:21:06.461384+00
3166	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:21:06.468934+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:21:06.468934+00
3167	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:21:06.530139+00	6	grades	\N	/api/v1/grades/my	2026-07-23 15:21:06.530139+00
3168	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:21:06.53904+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 15:21:06.53904+00
3169	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:21:06.643177+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:21:06.643177+00
3170	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:21:09.946282+00	6	grades	\N	/api/v1/grades/my	2026-07-23 15:21:09.946282+00
3171	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:21:09.962659+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 15:21:09.962659+00
3172	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:21:09.967209+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:21:09.967209+00
3173	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:21:10.009228+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 15:21:10.009228+00
3174	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:21:10.009547+00	6	grades	\N	/api/v1/grades/my	2026-07-23 15:21:10.009547+00
3175	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:21:10.046811+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:21:10.046811+00
3176	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:21:39.018826+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 15:21:39.018826+00
3177	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:21:39.040635+00	6	grades	\N	/api/v1/grades/my	2026-07-23 15:21:39.040635+00
3178	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:21:39.07428+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:21:39.07428+00
3179	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:21:39.131124+00	6	grades	\N	/api/v1/grades/my	2026-07-23 15:21:39.131124+00
3180	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:21:39.160536+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 15:21:39.160536+00
3181	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:21:39.184+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:21:39.184+00
3182	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:26:26.669545+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:26:26.669545+00
3183	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:26:26.77823+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 15:26:26.77823+00
3184	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:26:26.925945+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:26:26.925945+00
3185	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:26:26.92627+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 15:26:26.92627+00
3186	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:26:27.101921+00	6	grades	\N	/api/v1/grades/my	2026-07-23 15:26:27.101921+00
3187	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:26:27.128996+00	6	grades	\N	/api/v1/grades/my	2026-07-23 15:26:27.128996+00
3188	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:31:17.224283+00	6	grades	\N	/api/v1/grades/my	2026-07-23 15:31:17.224283+00
3189	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:31:17.289046+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 15:31:17.289046+00
3190	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:31:17.379637+00	6	grades	\N	/api/v1/grades/my	2026-07-23 15:31:17.379637+00
3191	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:31:17.381019+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 15:31:17.381019+00
3192	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:31:17.403798+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:31:17.403798+00
3193	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:31:17.633237+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:31:17.633237+00
3194	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:31:21.979667+00	6	grades	\N	/api/v1/grades/my	2026-07-23 15:31:21.979667+00
3195	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:31:21.984464+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:31:21.984464+00
3196	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:31:22.136793+00	6	grades	\N	/api/v1/grades/my	2026-07-23 15:31:22.136793+00
3197	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:31:22.13821+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:31:22.13821+00
3198	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:31:42.837948+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:31:42.837948+00
3199	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:31:43.719715+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:31:43.719715+00
3200	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:31:44.375878+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:31:44.375878+00
3201	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:31:45.145671+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:31:45.145671+00
3202	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:33:59.073198+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:33:59.073198+00
3203	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:33:59.136039+00	6	grades	\N	/api/v1/grades/my	2026-07-23 15:33:59.136039+00
3204	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:33:59.172429+00	6	grades	\N	/api/v1/grades/transcript	2026-07-23 15:33:59.172429+00
3205	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:33:59.190358+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 15:33:59.190358+00
3206	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:33:59.281695+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-23 15:33:59.281695+00
3207	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-23 15:33:59.28251+00	6	grades	\N	/api/v1/grades/my	2026-07-23 15:33:59.28251+00
3208	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:15:10.39889+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 11:15:10.39889+00
3209	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:15:10.520888+00	6	grades	\N	/api/v1/grades/my	2026-07-25 11:15:10.520888+00
3210	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:15:10.633407+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 11:15:10.633407+00
3211	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:15:10.802098+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 11:15:10.802098+00
3212	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:15:10.883681+00	6	grades	\N	/api/v1/grades/my	2026-07-25 11:15:10.883681+00
3213	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:15:10.952741+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 11:15:10.952741+00
3214	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:17:13.036359+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 11:17:13.036359+00
3215	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:17:13.045002+00	6	grades	\N	/api/v1/grades/my	2026-07-25 11:17:13.045002+00
3216	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:17:13.141325+00	6	grades	\N	/api/v1/grades/my	2026-07-25 11:17:13.141325+00
3217	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:17:13.159028+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 11:17:13.159028+00
3218	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:18:07.943996+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 11:18:07.943996+00
3219	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:18:10.713776+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 11:18:10.713776+00
3220	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:18:10.785614+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 11:18:10.785614+00
3221	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:18:11.040125+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 11:18:11.040125+00
3222	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:18:11.143886+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 11:18:11.143886+00
3223	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:18:11.316232+00	6	grades	\N	/api/v1/grades/my	2026-07-25 11:18:11.316232+00
3224	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:18:11.366282+00	6	grades	\N	/api/v1/grades/my	2026-07-25 11:18:11.366282+00
3225	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:25:32.610255+00	6	grades	\N	/api/v1/grades/my	2026-07-25 11:25:32.610255+00
3226	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:25:32.622902+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 11:25:32.622902+00
3227	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:25:32.623559+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 11:25:32.623559+00
3228	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:25:33.255805+00	6	grades	\N	/api/v1/grades/my	2026-07-25 11:25:33.255805+00
3229	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:25:33.256916+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 11:25:33.256916+00
3230	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:25:33.275578+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 11:25:33.275578+00
3231	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:25:33.866374+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 11:25:33.866374+00
3232	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:25:33.867008+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 11:25:33.867008+00
3233	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:25:33.868772+00	6	grades	\N	/api/v1/grades/my	2026-07-25 11:25:33.868772+00
3234	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:25:34.191256+00	6	grades	\N	/api/v1/grades/my	2026-07-25 11:25:34.191256+00
3238	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:25:37.594748+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 11:25:37.594748+00
3235	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:25:34.191791+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 11:25:34.191791+00
3237	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:25:37.594011+00	6	grades	\N	/api/v1/grades/my	2026-07-25 11:25:37.594011+00
3236	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:25:34.193549+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 11:25:34.193549+00
3239	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:25:37.611637+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 11:25:37.611637+00
3241	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:41:01.719262+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 11:41:01.719262+00
3240	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:41:01.711245+00	6	grades	\N	/api/v1/grades/my	2026-07-25 11:41:01.711245+00
3242	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:41:01.815143+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 11:41:01.815143+00
3243	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:58:09.34776+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 11:58:09.34776+00
3244	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:58:09.402746+00	6	grades	\N	/api/v1/grades/my	2026-07-25 11:58:09.402746+00
3245	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:58:09.423765+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 11:58:09.423765+00
3246	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:58:09.465762+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 11:58:09.465762+00
3247	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:58:09.485473+00	6	grades	\N	/api/v1/grades/my	2026-07-25 11:58:09.485473+00
3248	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 11:58:09.604839+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 11:58:09.604839+00
3249	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:02:46.269993+00	6	grades	\N	/api/v1/grades/my	2026-07-25 12:02:46.269993+00
3250	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:02:46.383859+00	6	grades	\N	/api/v1/grades/my	2026-07-25 12:02:46.383859+00
3251	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:02:46.638516+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 12:02:46.638516+00
3252	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:02:46.706584+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 12:02:46.706584+00
3253	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:02:46.782423+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:02:46.782423+00
3254	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:02:46.965779+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:02:46.965779+00
3255	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:04:44.511276+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:04:44.511276+00
3256	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:04:44.56788+00	6	courses	\N	/api/v1/courses	2026-07-25 12:04:44.56788+00
3257	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:04:44.589057+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:04:44.589057+00
3258	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:04:44.623023+00	6	courses	\N	/api/v1/courses	2026-07-25 12:04:44.623023+00
3259	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:04:48.91669+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:04:48.91669+00
3260	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:04:48.917456+00	6	grades	\N	/api/v1/grades/my	2026-07-25 12:04:48.917456+00
3261	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:04:49.02269+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:04:49.02269+00
3262	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:04:49.032692+00	6	grades	\N	/api/v1/grades/my	2026-07-25 12:04:49.032692+00
3263	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:04:49.079128+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 12:04:49.079128+00
3264	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:04:49.107953+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 12:04:49.107953+00
3265	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:04:50.072258+00	6	courses	\N	/api/v1/courses	2026-07-25 12:04:50.072258+00
3266	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:04:50.07583+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:04:50.07583+00
3267	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:04:50.134902+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:04:50.134902+00
3268	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:04:50.136505+00	6	courses	\N	/api/v1/courses	2026-07-25 12:04:50.136505+00
3269	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:04:50.696382+00	6	grades	\N	/api/v1/grades/my	2026-07-25 12:04:50.696382+00
3270	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:04:50.697064+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 12:04:50.697064+00
3271	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:04:50.751344+00	6	grades	\N	/api/v1/grades/my	2026-07-25 12:04:50.751344+00
3272	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:04:50.76891+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 12:04:50.76891+00
3273	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:04:53.327603+00	6	grades	\N	/api/v1/grades/my	2026-07-25 12:04:53.327603+00
3274	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:04:53.390533+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:04:53.390533+00
3275	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:04:53.41798+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 12:04:53.41798+00
3276	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:04:53.421275+00	6	grades	\N	/api/v1/grades/my	2026-07-25 12:04:53.421275+00
3277	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:04:53.4658+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:04:53.4658+00
3278	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:04:53.47104+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 12:04:53.47104+00
3279	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:19:03.598663+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:19:03.598663+00
3280	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:19:03.622718+00	6	courses	\N	/api/v1/courses	2026-07-25 12:19:03.622718+00
3281	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:19:03.673324+00	6	courses	\N	/api/v1/courses	2026-07-25 12:19:03.673324+00
3282	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:19:03.749083+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:19:03.749083+00
3283	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:19:04.616489+00	6	grades	\N	/api/v1/grades/my	2026-07-25 12:19:04.616489+00
3284	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:19:04.68514+00	6	grades	\N	/api/v1/grades/my	2026-07-25 12:19:04.68514+00
3285	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:19:04.722431+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 12:19:04.722431+00
3286	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:19:04.749978+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 12:19:04.749978+00
3287	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:19:56.684887+00	6	grades	\N	/api/v1/grades/my	2026-07-25 12:19:56.684887+00
3288	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:19:56.751832+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:19:56.751832+00
3289	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:19:56.777331+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 12:19:56.777331+00
3290	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:19:56.800117+00	6	grades	\N	/api/v1/grades/my	2026-07-25 12:19:56.800117+00
3291	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:19:56.828178+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:19:56.828178+00
3292	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:19:56.845522+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 12:19:56.845522+00
3293	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:19:58.690998+00	6	courses	\N	/api/v1/courses	2026-07-25 12:19:58.690998+00
3294	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:19:58.692551+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:19:58.692551+00
3295	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:19:58.743646+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:19:58.743646+00
3296	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:19:58.769641+00	6	courses	\N	/api/v1/courses	2026-07-25 12:19:58.769641+00
3297	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:20:16.277464+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 12:20:16.277464+00
3298	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:20:16.277949+00	6	grades	\N	/api/v1/grades/my	2026-07-25 12:20:16.277949+00
3299	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:20:16.31136+00	6	grades	\N	/api/v1/grades/my	2026-07-25 12:20:16.31136+00
3300	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:20:16.315979+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 12:20:16.315979+00
3301	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:20:38.724906+00	6	grades	\N	/api/v1/grades/my	2026-07-25 12:20:38.724906+00
3302	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:20:38.742154+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 12:20:38.742154+00
3303	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:20:38.770644+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:20:38.770644+00
3304	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:20:38.819905+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:20:38.819905+00
3305	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:20:38.836602+00	6	grades	\N	/api/v1/grades/my	2026-07-25 12:20:38.836602+00
3306	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:20:38.855447+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 12:20:38.855447+00
3307	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:24:11.417697+00	6	courses	\N	/api/v1/courses	2026-07-25 12:24:11.417697+00
3308	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:24:11.420007+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:24:11.420007+00
3309	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:24:11.468945+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:24:11.468945+00
3310	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:24:11.472061+00	6	courses	\N	/api/v1/courses	2026-07-25 12:24:11.472061+00
3311	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:24:20.478302+00	6	courses	\N	/api/v1/courses	2026-07-25 12:24:20.478302+00
3312	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:24:20.489793+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:24:20.489793+00
3313	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:24:20.531042+00	6	courses	\N	/api/v1/courses	2026-07-25 12:24:20.531042+00
3314	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:24:20.557429+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:24:20.557429+00
3315	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:27:54.373571+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:27:54.373571+00
3316	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:27:54.417672+00	6	courses	\N	/api/v1/courses	2026-07-25 12:27:54.417672+00
3317	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:28:17.160717+00	6	courses	\N	/api/v1/courses	2026-07-25 12:28:17.160717+00
3318	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:28:17.209065+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:28:17.209065+00
3319	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:28:17.271003+00	6	courses	\N	/api/v1/courses	2026-07-25 12:28:17.271003+00
3320	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:28:17.328259+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:28:17.328259+00
3321	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:28:27.219335+00	6	courses	\N	/api/v1/courses	2026-07-25 12:28:27.219335+00
3322	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:28:27.328752+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:28:27.328752+00
3323	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:34:37.250666+00	6	grades	\N	/api/v1/grades/my	2026-07-25 12:34:37.250666+00
3324	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:34:37.267754+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 12:34:37.267754+00
3325	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:34:37.274201+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:34:37.274201+00
3326	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:34:37.306674+00	6	grades	\N	/api/v1/grades/my	2026-07-25 12:34:37.306674+00
3327	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:34:37.323011+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 12:34:37.323011+00
3328	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:34:37.324413+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:34:37.324413+00
3329	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:34:38.667819+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:34:38.667819+00
3330	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:34:38.669614+00	6	courses	\N	/api/v1/courses	2026-07-25 12:34:38.669614+00
3331	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:34:38.720997+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:34:38.720997+00
3332	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:34:38.74118+00	6	courses	\N	/api/v1/courses	2026-07-25 12:34:38.74118+00
3333	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:35:50.322209+00	6	courses	\N	/api/v1/courses	2026-07-25 12:35:50.322209+00
3334	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:35:50.413622+00	6	courses	\N	/api/v1/courses	2026-07-25 12:35:50.413622+00
3335	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:35:50.414916+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:35:50.414916+00
3336	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:35:50.447904+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:35:50.447904+00
3337	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:36:30.717928+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:36:30.717928+00
3338	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:36:30.829352+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:36:30.829352+00
3339	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:36:30.855259+00	6	courses	\N	/api/v1/courses	2026-07-25 12:36:30.855259+00
3340	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:36:30.900366+00	6	courses	\N	/api/v1/courses	2026-07-25 12:36:30.900366+00
3341	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:38:04.348691+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:38:04.348691+00
3342	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:38:04.366141+00	6	courses	\N	/api/v1/courses	2026-07-25 12:38:04.366141+00
3343	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:39:06.456409+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:39:06.456409+00
3344	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:39:06.503797+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:39:06.503797+00
3345	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:39:06.539395+00	6	grades	\N	/api/v1/grades/my	2026-07-25 12:39:06.539395+00
3346	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:39:06.587824+00	6	grades	\N	/api/v1/grades/my	2026-07-25 12:39:06.587824+00
3347	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:39:06.59321+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 12:39:06.59321+00
3348	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:39:06.626778+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 12:39:06.626778+00
3349	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:39:10.463932+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:39:10.463932+00
3350	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:39:10.464342+00	6	courses	\N	/api/v1/courses	2026-07-25 12:39:10.464342+00
3351	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:39:10.514596+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:39:10.514596+00
3352	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:39:10.52087+00	6	courses	\N	/api/v1/courses	2026-07-25 12:39:10.52087+00
3353	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:39:49.341494+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 12:39:49.341494+00
3354	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:39:49.379999+00	6	grades	\N	/api/v1/grades/my	2026-07-25 12:39:49.379999+00
3355	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:39:49.386051+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 12:39:49.386051+00
3356	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:39:49.40938+00	6	grades	\N	/api/v1/grades/my	2026-07-25 12:39:49.40938+00
3357	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:40:00.993278+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:40:00.993278+00
3358	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:40:01.040192+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:40:01.040192+00
3359	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:40:01.088101+00	6	courses	\N	/api/v1/courses	2026-07-25 12:40:01.088101+00
3360	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:40:01.120744+00	6	courses	\N	/api/v1/courses	2026-07-25 12:40:01.120744+00
3361	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:40:02.099981+00	6	grades	\N	/api/v1/grades/my	2026-07-25 12:40:02.099981+00
3362	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:40:02.100391+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 12:40:02.100391+00
3363	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:40:02.167808+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 12:40:02.167808+00
3364	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:40:02.168232+00	6	grades	\N	/api/v1/grades/my	2026-07-25 12:40:02.168232+00
3365	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:40:04.226039+00	6	grades	\N	/api/v1/grades/my	2026-07-25 12:40:04.226039+00
3366	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:40:04.226455+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:40:04.226455+00
3367	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:40:04.311017+00	6	grades	\N	/api/v1/grades/my	2026-07-25 12:40:04.311017+00
3368	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:40:04.316702+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:40:04.316702+00
3369	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:40:04.352775+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 12:40:04.352775+00
3370	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:40:04.383456+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 12:40:04.383456+00
3371	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:40:08.4603+00	6	courses	\N	/api/v1/courses	2026-07-25 12:40:08.4603+00
3372	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:40:08.46131+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:40:08.46131+00
3373	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:40:08.511583+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:40:08.511583+00
3374	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:40:08.525859+00	6	courses	\N	/api/v1/courses	2026-07-25 12:40:08.525859+00
3375	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:40:27.406755+00	6	grades	\N	/api/v1/grades/my	2026-07-25 12:40:27.406755+00
3376	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:40:27.414694+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:40:27.414694+00
3377	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:40:27.442737+00	6	grades	\N	/api/v1/grades/my	2026-07-25 12:40:27.442737+00
3378	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:40:27.466684+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:40:27.466684+00
3379	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:40:27.508032+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 12:40:27.508032+00
3380	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:40:27.609895+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 12:40:27.609895+00
3381	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:48:06.792371+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:48:06.792371+00
3382	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:48:06.829125+00	6	courses	\N	/api/v1/courses	2026-07-25 12:48:06.829125+00
3383	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:48:06.850455+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:48:06.850455+00
3384	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:48:06.878068+00	6	courses	\N	/api/v1/courses	2026-07-25 12:48:06.878068+00
3385	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:50:30.681979+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:50:30.681979+00
3386	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:50:30.692901+00	6	courses	\N	/api/v1/courses	2026-07-25 12:50:30.692901+00
3387	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:50:30.7474+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:50:30.7474+00
3388	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:50:30.785853+00	6	courses	\N	/api/v1/courses	2026-07-25 12:50:30.785853+00
3389	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:50:30.787401+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:50:30.787401+00
3390	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:50:30.851743+00	6	courses	\N	/api/v1/courses	2026-07-25 12:50:30.851743+00
3391	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:50:30.896504+00	6	courses	\N	/api/v1/courses	2026-07-25 12:50:30.896504+00
3392	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:50:30.943067+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:50:30.943067+00
3393	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:50:38.218964+00	6	courses	\N	/api/v1/courses	2026-07-25 12:50:38.218964+00
3394	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:50:38.21936+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:50:38.21936+00
3395	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:50:48.602177+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:50:48.602177+00
3396	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:50:48.630559+00	6	courses	\N	/api/v1/courses	2026-07-25 12:50:48.630559+00
3397	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:50:49.183871+00	6	courses	\N	/api/v1/courses	2026-07-25 12:50:49.183871+00
3398	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:50:49.184084+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:50:49.184084+00
3399	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:50:49.928819+00	6	courses	\N	/api/v1/courses	2026-07-25 12:50:49.928819+00
3400	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:50:49.929124+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:50:49.929124+00
3401	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:50:50.403563+00	6	courses	\N	/api/v1/courses	2026-07-25 12:50:50.403563+00
3402	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:50:50.403908+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:50:50.403908+00
3403	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:50:50.433856+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:50:50.433856+00
3404	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:50:50.445867+00	6	courses	\N	/api/v1/courses	2026-07-25 12:50:50.445867+00
3405	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:52:12.383152+00	6	courses	\N	/api/v1/courses	2026-07-25 12:52:12.383152+00
3406	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:52:12.420456+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:52:12.420456+00
3407	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:52:12.468639+00	6	courses	\N	/api/v1/courses	2026-07-25 12:52:12.468639+00
3408	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:52:12.498636+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:52:12.498636+00
3409	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:54:00.998169+00	6	courses	\N	/api/v1/courses	2026-07-25 12:54:00.998169+00
3410	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:54:01.061848+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:54:01.061848+00
3411	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:54:01.102047+00	6	courses	\N	/api/v1/courses	2026-07-25 12:54:01.102047+00
3412	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 12:54:01.105549+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 12:54:01.105549+00
3414	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:14:31.21146+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:14:31.21146+00
3413	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:14:31.203026+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:14:31.203026+00
3415	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:14:31.261341+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:14:31.261341+00
3416	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:14:31.304821+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:14:31.304821+00
3417	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:14:31.333658+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:14:31.333658+00
3418	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:14:31.334771+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:14:31.334771+00
3419	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:14:53.218971+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:14:53.218971+00
3420	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:14:53.346162+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:14:53.346162+00
3421	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:14:53.376164+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:14:53.376164+00
3422	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:14:53.829194+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:14:53.829194+00
3423	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:14:53.844388+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:14:53.844388+00
3424	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:14:53.861218+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:14:53.861218+00
3425	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:14:55.993883+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:14:55.993883+00
3426	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:14:55.994185+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:14:55.994185+00
3427	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:14:55.995198+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:14:55.995198+00
3428	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:14:56.047994+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:14:56.047994+00
3429	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:14:56.075191+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:14:56.075191+00
3430	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:14:56.07693+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:14:56.07693+00
3431	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:14:57.746429+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:14:57.746429+00
3432	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:14:57.747117+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:14:57.747117+00
3433	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:14:57.784575+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:14:57.784575+00
3434	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:13.768122+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:15:13.768122+00
3435	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:13.891455+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:15:13.891455+00
3436	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:13.969487+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:15:13.969487+00
3437	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:14.006348+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:15:14.006348+00
3438	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:14.040105+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:15:14.040105+00
3439	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:14.080406+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:15:14.080406+00
3440	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:16.418438+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:15:16.418438+00
3441	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:16.419+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:15:16.419+00
3442	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:16.422142+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:15:16.422142+00
3443	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:16.833559+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:15:16.833559+00
3444	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:16.834044+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:15:16.834044+00
3445	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:16.85217+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:15:16.85217+00
3446	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:17.559975+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:15:17.559975+00
3447	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:17.560316+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:15:17.560316+00
3448	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:17.560728+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:15:17.560728+00
3449	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:17.875258+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:15:17.875258+00
3450	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:17.877118+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:15:17.877118+00
3451	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:17.877639+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:15:17.877639+00
3452	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:18.278214+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:15:18.278214+00
3453	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:18.278682+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:15:18.278682+00
3454	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:18.279693+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:15:18.279693+00
3455	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:18.858991+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:15:18.858991+00
3456	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:18.86009+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:15:18.86009+00
3457	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:18.860612+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:15:18.860612+00
3458	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:19.319474+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:15:19.319474+00
3459	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:19.320139+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:15:19.320139+00
3460	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:19.320985+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:15:19.320985+00
3461	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:19.765664+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:15:19.765664+00
3462	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:19.7662+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:15:19.7662+00
3463	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:15:19.768027+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:15:19.768027+00
3464	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:09.543044+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:17:09.543044+00
3465	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:09.64152+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:17:09.64152+00
3466	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:09.642181+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:17:09.642181+00
3467	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:10.131964+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:17:10.131964+00
3474	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:11.398619+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:17:11.398619+00
3476	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:11.867628+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:17:11.867628+00
3480	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:12.184774+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:17:12.184774+00
3482	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:12.545836+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:17:12.545836+00
3486	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:12.905118+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:17:12.905118+00
3468	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:10.147947+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:17:10.147947+00
3469	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:10.153118+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:17:10.153118+00
3470	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:10.558344+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:17:10.558344+00
3471	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:10.567958+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:17:10.567958+00
3473	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:11.39738+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:17:11.39738+00
3477	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:11.86814+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:17:11.86814+00
3479	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:12.183016+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:17:12.183016+00
3481	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:12.185217+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:17:12.185217+00
3483	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:12.546555+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:17:12.546555+00
3485	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:12.904642+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:17:12.904642+00
3487	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:12.905483+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:17:12.905483+00
3472	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:10.589262+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:17:10.589262+00
3475	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:11.428345+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:17:11.428345+00
3478	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:11.868535+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:17:11.868535+00
3484	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:12.550196+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:17:12.550196+00
3488	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:49.363458+00	6	courses	\N	/api/v1/courses	2026-07-25 13:17:49.363458+00
3489	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:49.364942+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:17:49.364942+00
3490	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:49.40578+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:17:49.40578+00
3491	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:49.43081+00	6	courses	\N	/api/v1/courses	2026-07-25 13:17:49.43081+00
3492	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:52.248555+00	6	courses	\N	/api/v1/courses	2026-07-25 13:17:52.248555+00
3493	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:17:52.256218+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:17:52.256218+00
3494	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:18:31.745629+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:18:31.745629+00
3495	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:18:31.78863+00	6	courses	\N	/api/v1/courses	2026-07-25 13:18:31.78863+00
3496	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:18:34.325432+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:18:34.325432+00
3497	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:18:34.362795+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:18:34.362795+00
3498	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:18:34.415026+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:18:34.415026+00
3499	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:18:34.454608+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:18:34.454608+00
3500	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:18:34.477892+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:18:34.477892+00
3501	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:18:34.487329+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:18:34.487329+00
3502	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:18:35.522011+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:18:35.522011+00
3503	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:18:35.540047+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:18:35.540047+00
3504	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:18:35.540597+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:18:35.540597+00
3505	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:18:37.050481+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:18:37.050481+00
3506	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:18:37.051847+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:18:37.051847+00
3507	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:18:37.061397+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:18:37.061397+00
3508	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:18:37.666694+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:18:37.666694+00
3509	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:18:37.667035+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:18:37.667035+00
3510	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:18:37.667431+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:18:37.667431+00
3511	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:18:39.091479+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:18:39.091479+00
3512	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:18:39.09191+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:18:39.09191+00
3513	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:18:39.092299+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:18:39.092299+00
3514	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:20:58.487072+00	6	courses	\N	/api/v1/courses	2026-07-25 13:20:58.487072+00
3515	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:20:58.525343+00	6	courses	\N	/api/v1/courses	2026-07-25 13:20:58.525343+00
3516	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:20:58.52878+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:20:58.52878+00
3517	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:20:58.574716+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:20:58.574716+00
3518	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:21:05.835158+00	6	courses	\N	/api/v1/courses	2026-07-25 13:21:05.835158+00
3519	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:21:05.837518+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:21:05.837518+00
3520	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:21:39.481797+00	6	courses	\N	/api/v1/courses	2026-07-25 13:21:39.481797+00
3521	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:21:39.53592+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:21:39.53592+00
3522	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:22:43.246587+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:22:43.246587+00
3524	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:22:43.300288+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:22:43.300288+00
3523	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:22:43.281045+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:22:43.281045+00
3525	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:22:43.367739+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:22:43.367739+00
3526	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:34:04.632522+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:34:04.632522+00
3527	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:34:04.63981+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:34:04.63981+00
3528	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:36:17.176663+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:36:17.176663+00
3529	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:36:18.012246+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:36:18.012246+00
3530	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:36:18.851449+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:36:18.851449+00
3531	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:37:04.449738+00	6	courses	\N	/api/v1/courses	2026-07-25 13:37:04.449738+00
3532	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:37:04.498855+00	6	courses	\N	/api/v1/courses	2026-07-25 13:37:04.498855+00
3533	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:37:04.514546+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:37:04.514546+00
3534	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:37:04.552628+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 13:37:04.552628+00
3535	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:37:05.605916+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:37:05.605916+00
3536	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:37:05.611661+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:37:05.611661+00
3537	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:37:05.662414+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:37:05.662414+00
3538	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:37:05.688041+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:37:05.688041+00
3539	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:37:45.512752+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:37:45.512752+00
3540	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:37:45.528829+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:37:45.528829+00
3541	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:37:45.614154+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:37:45.614154+00
3542	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:37:45.61528+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:37:45.61528+00
3543	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:38:29.399594+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:38:29.399594+00
3544	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:38:29.563614+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:38:29.563614+00
3545	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:38:29.731319+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:38:29.731319+00
3546	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:38:29.750463+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:38:29.750463+00
3547	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:38:46.340458+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:38:46.340458+00
3548	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:38:46.424063+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:38:46.424063+00
3549	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:40:21.474452+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:40:21.474452+00
3550	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:40:21.494164+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:40:21.494164+00
3551	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:41:12.804625+00	6	grades	\N	/api/v1/grades/my	2026-07-25 13:41:12.804625+00
3552	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 13:41:12.821857+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 13:41:12.821857+00
3553	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 14:13:48.20913+00	6	grades	\N	/api/v1/grades/my	2026-07-25 14:13:48.20913+00
3554	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 14:13:48.271236+00	6	grades	\N	/api/v1/grades/my	2026-07-25 14:13:48.271236+00
3555	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 14:13:48.337789+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 14:13:48.337789+00
3556	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 14:13:48.401619+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 14:13:48.401619+00
3557	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 14:14:47.104334+00	6	grades	\N	/api/v1/grades/my	2026-07-25 14:14:47.104334+00
3558	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 14:14:47.141326+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 14:14:47.141326+00
3559	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 14:14:47.172008+00	6	grades	\N	/api/v1/grades/my	2026-07-25 14:14:47.172008+00
3560	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 14:14:47.191454+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 14:14:47.191454+00
3561	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 14:25:12.5667+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 14:25:12.5667+00
3562	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 14:25:12.600515+00	6	grades	\N	/api/v1/grades/my	2026-07-25 14:25:12.600515+00
3563	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 14:25:12.650783+00	6	grades	\N	/api/v1/grades/my	2026-07-25 14:25:12.650783+00
3564	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 14:25:12.651052+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 14:25:12.651052+00
3565	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 14:25:13.42425+00	6	courses	\N	/api/v1/courses	2026-07-25 14:25:13.42425+00
3566	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 14:25:13.428682+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 14:25:13.428682+00
3567	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 14:25:13.462098+00	6	courses	\N	/api/v1/courses	2026-07-25 14:25:13.462098+00
3568	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 14:25:13.462418+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 14:25:13.462418+00
3570	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 14:25:15.618356+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 14:25:15.618356+00
3569	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 14:25:15.617915+00	6	grades	\N	/api/v1/grades/my	2026-07-25 14:25:15.617915+00
3571	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 14:25:15.645811+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 14:25:15.645811+00
3572	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 14:25:15.707189+00	6	grades	\N	/api/v1/grades/my	2026-07-25 14:25:15.707189+00
3573	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 14:25:15.707788+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 14:25:15.707788+00
3574	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 14:25:15.745192+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 14:25:15.745192+00
3575	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 14:27:49.253418+00	6	grades	\N	/api/v1/grades/my	2026-07-25 14:27:49.253418+00
3576	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 14:27:49.297246+00	6	grades	\N	/api/v1/grades/my	2026-07-25 14:27:49.297246+00
3577	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 14:27:49.492821+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 14:27:49.492821+00
3578	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 14:27:49.540233+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 14:27:49.540233+00
3579	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 20:16:19.94713+00	1	users	\N	/api/v1/admin/stats	2026-07-25 20:16:19.94713+00
3580	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 20:16:20.244025+00	1	users	\N	/api/v1/admin/stats	2026-07-25 20:16:20.244025+00
3581	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 20:16:20.244956+00	1	audit	\N	/api/v1/admin/security-events	2026-07-25 20:16:20.244956+00
3582	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 20:16:20.246601+00	1	grades	\N	/api/v1/admin/grades/pending	2026-07-25 20:16:20.246601+00
3583	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 20:16:20.44984+00	1	audit	\N	/api/v1/admin/security-events	2026-07-25 20:16:20.44984+00
3584	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 20:16:20.46283+00	1	grades	\N	/api/v1/admin/grades/pending	2026-07-25 20:16:20.46283+00
3585	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 20:27:22.209817+00	6	grades	\N	/api/v1/grades/my	2026-07-25 20:27:22.209817+00
3586	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 20:27:22.238224+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 20:27:22.238224+00
3587	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 20:27:22.240098+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 20:27:22.240098+00
3588	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 20:27:22.284503+00	6	grades	\N	/api/v1/grades/my	2026-07-25 20:27:22.284503+00
3589	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 20:27:22.323818+00	6	enrollments	\N	/api/v1/enrollments/my	2026-07-25 20:27:22.323818+00
3590	\N	read	\N	\N	GRANTED	\N	::1	\N	{"layer": "ALL"}	2026-07-25 20:27:22.325973+00	6	grades	\N	/api/v1/grades/transcript	2026-07-25 20:27:22.325973+00
\.


--
-- Data for Name: context_policies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.context_policies (id, name, description, resource, action, condition, is_active, created_at) FROM stdin;
1	GradingWindow	Grades may only be submitted while grading is open	grades	write	{"allowedHours": [0, 23], "requiresActivePeriod": true}	t	2026-06-24 12:00:43.940183+00
\.


--
-- Data for Name: courses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.courses (id, code, title, lecturer_id, active, created_at, is_active, credits, department_id, academic_period_id, updated_at) FROM stdin;
1	CS-401	Advanced Cryptography & RASAC	2	t	2026-06-24 12:00:43.940183+00	t	4	1	1	2026-06-24 12:00:43.940183+00
2	CS302	Database Systems	2	t	2026-06-24 12:00:43.940183+00	t	3	1	1	2026-06-24 12:00:43.940183+00
3	CS201	Data Structures	3	t	2026-06-24 12:00:43.940183+00	t	3	1	1	2026-06-24 12:00:43.940183+00
\.


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.departments (id, name, code, created_at) FROM stdin;
1	Computer Science	CS	2026-06-24 12:00:43.940183+00
\.


--
-- Data for Name: enrollments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.enrollments (id, student_id, course_id, enrolled_at) FROM stdin;
1	4	1	2026-06-24 12:00:43.940183+00
2	4	2	2026-06-24 12:00:43.940183+00
3	5	1	2026-06-24 12:00:43.940183+00
4	5	3	2026-06-24 12:00:43.940183+00
5	6	1	2026-06-24 12:00:43.940183+00
6	6	2	2026-06-24 12:00:43.940183+00
7	7	1	2026-06-24 12:00:43.940183+00
8	7	3	2026-06-24 12:00:43.940183+00
9	8	1	2026-06-24 12:00:43.940183+00
10	8	2	2026-06-24 12:00:43.940183+00
\.


--
-- Data for Name: grades; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.grades (id, student_id, course_id, submitter_id, score, grade, remarks, submitted_at, approver_id, status, approved_at) FROM stdin;
1	4	1	2	92.00	A	\N	2026-06-29 22:08:45.2431+00	1	APPROVED	2026-06-29 22:13:01.192581+00
3	8	1	2	89.00	B+	\N	2026-06-26 11:21:03.145559+00	1	APPROVED	2026-06-30 10:31:51.943667+00
\.


--
-- Data for Name: grading_periods; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.grading_periods (id, course_id, starts_at, ends_at, is_active) FROM stdin;
\.


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.permissions (id, code, name, created_at, resource, action, description) FROM stdin;
1	users:read	Read Users	2026-06-24 12:00:43.940183+00	users	read	Read users
2	users:write	Manage Users	2026-06-24 12:00:43.940183+00	users	write	Manage users
3	courses:read	Read Courses	2026-06-24 12:00:43.940183+00	courses	read	Read courses
4	courses:write	Manage Courses	2026-06-24 12:00:43.940183+00	courses	write	Manage courses
5	enrollments:read	Read Enrollments	2026-06-24 12:00:43.940183+00	enrollments	read	Read enrollments
6	enrollments:write	Manage Enrollments	2026-06-24 12:00:43.940183+00	enrollments	write	Manage enrollments
7	grades:read	Read Grades	2026-06-24 12:00:43.940183+00	grades	read	Read grades
8	grades:write	Submit Grades	2026-06-24 12:00:43.940183+00	grades	write	Submit grades
9	grades:approve	Approve Grades	2026-06-24 12:00:43.940183+00	grades	approve	Approve grades
10	audit:read	Read Audit Logs	2026-06-24 12:00:43.940183+00	audit	read	Read audit logs
11	periods:write	Manage Periods	2026-06-24 12:00:43.940183+00	periods	write	Manage periods
12	my-profile:write	Edit Own Profile	2026-07-21 11:51:11.970357+00	my-profile	write	Edit own contact info
\.


--
-- Data for Name: role_conflicts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.role_conflicts (role_id, conflicting_role_id) FROM stdin;
\.


--
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.role_permissions (role_id, permission_id) FROM stdin;
1	1
1	2
1	3
1	4
1	5
1	6
1	7
1	8
1	9
1	10
1	11
2	3
2	5
2	7
2	8
2	10
3	3
3	5
3	7
3	10
1	12
2	12
3	12
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (id, code, name, created_at, description) FROM stdin;
1	ADMINISTRATOR	Administrator	2026-06-24 12:00:43.940183+00	Full system access
2	LECTURER	Lecturer	2026-06-24 12:00:43.940183+00	Manages courses and grades
3	STUDENT	Student	2026-06-24 12:00:43.940183+00	Views own academic data
\.


--
-- Data for Name: separation_of_duty_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.separation_of_duty_logs (id, user_id, violation, attempted, blocked, "timestamp") FROM stdin;
1	1	Grade not found	grades:approve	t	2026-06-24 12:11:34.476947+00
2	1	Grade not found	grades:approve	t	2026-06-24 12:11:34.581469+00
3	1	Grade not found	grades:approve	t	2026-06-24 13:23:36.305876+00
4	1	Grade not found	grades:approve	t	2026-06-24 13:23:36.342328+00
5	1	Grade not found	grades:approve	t	2026-06-24 13:23:41.64008+00
6	1	Grade not found	grades:approve	t	2026-06-24 13:23:41.697132+00
7	1	Grade not found	grades:approve	t	2026-06-24 13:24:11.853213+00
8	1	Grade not found	grades:approve	t	2026-06-24 13:24:11.878003+00
9	1	Grade not found	grades:approve	t	2026-06-24 13:58:47.079796+00
10	1	Grade not found	grades:approve	t	2026-06-24 13:58:47.128095+00
11	1	Grade not found	grades:approve	t	2026-06-24 15:36:25.571206+00
12	1	Grade not found	grades:approve	t	2026-06-24 15:36:25.606349+00
13	1	Grade not found	grades:approve	t	2026-06-24 15:36:32.717267+00
14	1	Grade not found	grades:approve	t	2026-06-24 15:36:32.808168+00
15	1	Grade not found	grades:approve	t	2026-06-24 15:36:35.528595+00
16	1	Grade not found	grades:approve	t	2026-06-24 15:36:35.618474+00
17	1	Grade not found	grades:approve	t	2026-06-24 15:36:49.515689+00
18	1	Grade not found	grades:approve	t	2026-06-24 15:36:49.554751+00
19	2	Submitter cannot approve own grade	grades:approve	t	2026-06-26 11:20:44.578187+00
20	2	Submitter cannot approve own grade	grades:approve	t	2026-06-26 11:21:07.34995+00
21	2	Submitter cannot approve own grade	grades:approve	t	2026-06-26 11:21:08.286038+00
22	2	Submitter cannot approve own grade	grades:approve	t	2026-06-26 11:21:08.902972+00
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sessions (id, user_id, refresh_token, ip_address, user_agent, is_revoked, expires_at, created_at) FROM stdin;
5e6c080c-0580-4582-87c7-e45b632a87c5	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjVlNmMwODBjLTA1ODAtNDU4Mi04N2M3LWU0NWI2MzJhODdjNSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgyMzAzMDk0LCJleHAiOjE3ODI5MDc4OTR9.klBtHH8tzRBqu9ZZ4sk01DMAwEizikQ_cgHeA89-8Xo	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-01 12:11:34.253302+00	2026-06-24 12:11:34.253302+00
369c7b64-621d-44f7-8c8b-18fca9c1a2fe	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjM2OWM3YjY0LTYyMWQtNDRmNy04YzhiLTE4ZmNhOWMxYTJmZSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgyMzA3NDE1LCJleHAiOjE3ODI5MTIyMTV9.fLa0_orMkQEiLrkoz6ry93JJZORiz-jOcb-vSR-cdX0	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-01 13:23:35.872484+00	2026-06-24 13:23:35.872484+00
2de7af67-8416-4691-9437-53e160f22094	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjJkZTdhZjY3LTg0MTYtNDY5MS05NDM3LTUzZTE2MGYyMjA5NCIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgyMzA5NTI2LCJleHAiOjE3ODI5MTQzMjZ9.ok5VNCODxLC7PS6ujERIyt67ybeP22DPdYK0G3EEzUc	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-01 13:58:46.726219+00	2026-06-24 13:58:46.726219+00
8c4e551e-fbc3-4d8d-b7dc-34eb494605b5	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjhjNGU1NTFlLWZiYzMtNGQ4ZC1iN2RjLTM0ZWI0OTQ2MDViNSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgyMzE1Mzg1LCJleHAiOjE3ODI5MjAxODV9.L3gOzYhlmBB0zo81K8U047PFya90Vlt3Xa1RQoP1Rp4	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-01 15:36:25.198462+00	2026-06-24 15:36:25.198462+00
e5c180b2-617d-4edf-a1c2-5702d5f6c807	3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjMsInNpZCI6ImU1YzE4MGIyLTYxN2QtNGVkZi1hMWMyLTU3MDJkNWY2YzgwNyIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4MjMxNTQ1NywiZXhwIjoxNzgyOTIwMjU3fQ.Sl9ngVtm-1uwfS8d5KwUb_DL6xkCZeXpE-MQ-Qqy9pY	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-01 15:37:37.037111+00	2026-06-24 15:37:37.037111+00
5a1ad2de-4afa-48cb-8ef6-dc22bcc63d34	3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjMsInNpZCI6IjVhMWFkMmRlLTRhZmEtNDhjYi04ZWY2LWRjMjJiY2M2M2QzNCIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4MjMxNTQ3NCwiZXhwIjoxNzgyOTIwMjc0fQ.mQtLC4ChcJah-NHF86k4v39fhJjK_xUfkdEllF7DJ1s	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-01 15:37:54.665457+00	2026-06-24 15:37:54.665457+00
900d2992-efef-44a5-b57d-4e72e3b40726	7	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjcsInNpZCI6IjkwMGQyOTkyLWVmZWYtNDRhNS1iNTdkLTRlNzJlM2I0MDcyNiIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzgyMzE3NjMzLCJleHAiOjE3ODI5MjI0MzN9.1davjNwN5dVkos2FeZLzKmbXtER6mPHoqqV47InCvX4	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-01 16:13:53.810249+00	2026-06-24 16:13:53.810249+00
4c7c3fec-1d48-4722-a37e-ae80568770a7	3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjMsInNpZCI6IjRjN2MzZmVjLTFkNDgtNDcyMi1hMzdlLWFlODA1Njg3NzBhNyIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4MjMxOTU2OCwiZXhwIjoxNzgyOTI0MzY4fQ.H08fMyAhcOhBS58UZsbt6XNPRQ25lumf9B2J18AFHQc	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-01 16:46:08.040376+00	2026-06-24 16:46:08.040376+00
401bd561-6a0d-4ca4-b4d3-f55c25d77721	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6IjQwMWJkNTYxLTZhMGQtNGNhNC1iNGQzLWY1NWMyNWQ3NzcyMSIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4MjMyMDA1NiwiZXhwIjoxNzgyOTI0ODU2fQ.t2EgmthnzFURCd4YtepsWkT_WWUkzTXnPC3-6KBgN6w	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456	f	2026-07-01 16:54:16.433234+00	2026-06-24 16:54:16.433234+00
f160aa33-9c53-4aab-923b-e80bf34cdc94	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6ImYxNjBhYTMzLTljNTMtNGFhYi05MjNiLWU4MGJmMzRjZGM5NCIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4MjQyNjM2NiwiZXhwIjoxNzgzMDMxMTY2fQ.nODPIdLNTbBbkJh5uMdqXQGm33Rq2vGOEbRqz5kU-qs	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-02 22:26:06.995809+00	2026-06-25 22:26:06.995809+00
d8b0cb45-72d4-4cf1-8079-d3b9761a02b1	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6ImQ4YjBjYjQ1LTcyZDQtNGNmMS04MDc5LWQzYjk3NjFhMDJiMSIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4MjQyODE4OSwiZXhwIjoxNzgzMDMyOTg5fQ.EzPyKZtn8htklnng-S_JjEbsh4Jf4_tZ-KzbhevOL4I	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-02 22:56:29.305341+00	2026-06-25 22:56:29.305341+00
a822c45f-179d-4e12-bd67-c9b942e6bbe3	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6ImE4MjJjNDVmLTE3OWQtNGUxMi1iZDY3LWM5Yjk0MmU2YmJlMyIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4MjQ3MjgxOCwiZXhwIjoxNzgzMDc3NjE4fQ.Z9v44VAL5qIhQEMs2EdbCTVVK-lFXR1H4AhYj1ADaIM	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-03 11:20:18.175558+00	2026-06-26 11:20:18.175558+00
d90a0900-6302-429d-ac74-30576b1e528c	7	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjcsInNpZCI6ImQ5MGEwOTAwLTYzMDItNDI5ZC1hYzc0LTMwNTc2YjFlNTI4YyIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzgyNTc1NTc0LCJleHAiOjE3ODMxODAzNzR9.EVIabrbdhiMQK99gJzqyI06R1l50580Otb2eAEfe7rI	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-04 15:52:54.415794+00	2026-06-27 15:52:54.415794+00
1755e73e-c64c-4475-817a-e7010b111345	7	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjcsInNpZCI6IjE3NTVlNzNlLWM2NGMtNDQ3NS04MTdhLWU3MDEwYjExMTM0NSIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzgyNTc1NTc1LCJleHAiOjE3ODMxODAzNzV9.5P74O4Qg0RQiYZlgtM_ZGqF6BpFsRK5ti-3QamZtrwA	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-04 15:52:55.780743+00	2026-06-27 15:52:55.780743+00
de231284-a6b3-4d5c-b1f7-01d4d446db8d	7	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjcsInNpZCI6ImRlMjMxMjg0LWE2YjMtNGQ1Yy1iMWY3LTAxZDRkNDQ2ZGI4ZCIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzgyNTc1NTc2LCJleHAiOjE3ODMxODAzNzZ9.ht_jSo44pVfJ8VKBRH23-xh-j6GG8yu04Vj8BZ3ouiM	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-04 15:52:56.555202+00	2026-06-27 15:52:56.555202+00
41fd54b9-aa39-476b-96dd-9bb37b4fde8b	7	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjcsInNpZCI6IjQxZmQ1NGI5LWFhMzktNDc2Yi05NmRkLTliYjM3YjRmZGU4YiIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzgyNTgwNzQ1LCJleHAiOjE3ODMxODU1NDV9.ovGQUzYx1Hr9Sq3xROszd27u6cGKnJUt0rNC7_MW-xQ	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-04 17:19:05.314289+00	2026-06-27 17:19:05.314289+00
1bfc4ed8-3a79-45ac-bf39-201d53b78121	7	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjcsInNpZCI6IjFiZmM0ZWQ4LTNhNzktNDVhYy1iZjM5LTIwMWQ1M2I3ODEyMSIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzgyNTgwNzY0LCJleHAiOjE3ODMxODU1NjR9.5zQlLk9IBVIYaqDuvG8Cgbvg-yuD5i89bMT3mVSVBlY	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-04 17:19:24.594096+00	2026-06-27 17:19:24.594096+00
874e34fe-ef32-45dc-a589-4a44975be000	7	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjcsInNpZCI6Ijg3NGUzNGZlLWVmMzItNDVkYy1hNTg5LTRhNDQ5NzViZTAwMCIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzgyNTgxOTg3LCJleHAiOjE3ODMxODY3ODd9.QDApzXo6RZxsTdIY79Q4Ga5_0_zZBgWznQSy9GIzinU	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-04 17:39:47.391387+00	2026-06-27 17:39:47.391387+00
7959b324-1188-4c51-bb6b-a2f1ac0ae4b4	7	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjcsInNpZCI6Ijc5NTliMzI0LTExODgtNGM1MS1iYjZiLWEyZjFhYzBhZTRiNCIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzgyNTgyNTc4LCJleHAiOjE3ODMxODczNzh9.hS9P2k65d7o1u7ERB7ZJ9l1t1yIByNx6rM4bPXt6cW8	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-04 17:49:38.992117+00	2026-06-27 17:49:38.992117+00
e703c024-83c1-4ed2-aa2f-bd6c075535c1	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImU3MDNjMDI0LTgzYzEtNGVkMi1hYTJmLWJkNmMwNzU1MzVjMSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgyNjgzODYzLCJleHAiOjE3ODMyODg2NjN9.Lsawz-zZLkJUVhsho3VexHrq7mYnU2J1NF2uLNKSaOU	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-05 21:57:43.479667+00	2026-06-28 21:57:43.479667+00
c3c4cc02-700d-4b4d-a5fa-618e3d8ee2a5	8	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjgsInNpZCI6ImMzYzRjYzAyLTcwMGQtNGI0ZC1hNWZhLTYxOGUzZDhlZTJhNSIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzgyNjg0MzQ2LCJleHAiOjE3ODMyODkxNDZ9.dNDilbzaahVZV4wCBNu35rfmXijr4oQ0U0ITgkg-5SQ	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-05 22:05:46.292563+00	2026-06-28 22:05:46.292563+00
1b26f0f5-deeb-4af1-b144-342b9704ff4e	8	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjgsInNpZCI6IjFiMjZmMGY1LWRlZWItNGFmMS1iMTQ0LTM0MmI5NzA0ZmY0ZSIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzgyNjg0MzU4LCJleHAiOjE3ODMyODkxNTh9.usGkPatq8yzLTLb7ed6vOwwuZUezn1Iea8s_j1xHirk	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-05 22:05:58.5019+00	2026-06-28 22:05:58.5019+00
70b54d66-736d-4d17-954b-d84f1b3310be	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjcwYjU0ZDY2LTczNmQtNGQxNy05NTRiLWQ4NGYxYjMzMTBiZSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgyNjg1MjIzLCJleHAiOjE3ODMyOTAwMjN9.yP_Gafz2bj6fVcpnmJnCGfUBSbt1kStMUbF0e9UVsPc	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-05 22:20:23.266862+00	2026-06-28 22:20:23.266862+00
1e520cf8-a72b-48a3-8a0c-47042e49e631	3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjMsInNpZCI6IjFlNTIwY2Y4LWE3MmItNDhhMy04YTBjLTQ3MDQyZTQ5ZTYzMSIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4MjY4NTI2MCwiZXhwIjoxNzgzMjkwMDYwfQ.Z3x1CW0gVAP-IrI7fJ_b8vRRFVoQ9Mvr1xLGUMuyYVg	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-05 22:21:00.489144+00	2026-06-28 22:21:00.489144+00
b9f48c33-2cfa-4a2d-a7e4-e33d0cce2de1	8	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjgsInNpZCI6ImI5ZjQ4YzMzLTJjZmEtNGEyZC1hN2U0LWUzM2QwY2NlMmRlMSIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzgyNjg1Mjg5LCJleHAiOjE3ODMyOTAwODl9.fVHOfIFiyWcjRvVVaJNOX8hhtf3WE0GeYeMZ2FwWVSo	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-05 22:21:29.507592+00	2026-06-28 22:21:29.507592+00
55d1d0d2-5727-4a4d-9ac7-1583802cde57	8	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjgsInNpZCI6IjU1ZDFkMGQyLTU3MjctNGE0ZC05YWM3LTE1ODM4MDJjZGU1NyIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzgyNjg2ODc5LCJleHAiOjE3ODMyOTE2Nzl9.CN9W55H2U7s9Vi3VS_TtySg1ELI58maVENm3m8rkpAM	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-05 22:47:59.29948+00	2026-06-28 22:47:59.29948+00
b7c84264-7eef-4589-9d90-16db30f67990	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImI3Yzg0MjY0LTdlZWYtNDU4OS05ZDkwLTE2ZGIzMGY2Nzk5MCIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgyNjg2OTQ3LCJleHAiOjE3ODMyOTE3NDd9.xxWhZKgiUXYCdMEIicV34gVO-Qr87vo2jNgXN1NAq4M	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-05 22:49:07.711567+00	2026-06-28 22:49:07.711567+00
b38dd060-7be8-444e-8572-411e1915757d	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImIzOGRkMDYwLTdiZTgtNDQ0ZS04NTcyLTQxMWUxOTE1NzU3ZCIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgyNzY3OTczLCJleHAiOjE3ODMzNzI3NzN9.OJQixb7D6_AzqNAINpkqmTKcj4fXMjkJ0mqvyTh5etI	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-06 21:19:33.445024+00	2026-06-29 21:19:33.445024+00
acebae88-e665-4e25-b75b-392f85603f90	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6ImFjZWJhZTg4LWU2NjUtNGUyNS1iNzViLTM5MmY4NTYwM2Y5MCIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4Mjc2ODExNSwiZXhwIjoxNzgzMzcyOTE1fQ.scuIU2E8DJscdgNwX_Pqd6Qun1rCCQYtqnezqsAZfMc	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-06 21:21:55.680524+00	2026-06-29 21:21:55.680524+00
7dfc681a-59c3-4f6b-8ab3-1bf847b1163c	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6IjdkZmM2ODFhLTU5YzMtNGY2Yi04YWIzLTFiZjg0N2IxMTYzYyIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4Mjc2OTMxNywiZXhwIjoxNzgzMzc0MTE3fQ.SgP1mAb46ZHD45gIiPJEcHCwze8NvuquOBd6lQpr6TE	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-06 21:41:57.653386+00	2026-06-29 21:41:57.653386+00
ee0b36fa-fefa-44a1-b7ea-1c06d0a633d9	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6ImVlMGIzNmZhLWZlZmEtNDRhMS1iN2VhLTFjMDZkMGE2MzNkOSIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4Mjc2OTY1MywiZXhwIjoxNzgzMzc0NDUzfQ.3M17_Hk_3IDOGep5Zv9ZMYwFcLeGQGuXrGxVXh1vymk	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-06 21:47:33.781099+00	2026-06-29 21:47:33.781099+00
dbf4a621-9c95-4a2e-8e06-788e20de0966	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImRiZjRhNjIxLTljOTUtNGEyZS04ZTA2LTc4OGUyMGRlMDk2NiIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgyNzY5ODA4LCJleHAiOjE3ODMzNzQ2MDh9.fdEzjOb5-LXdBXY63eiKrRrnnNMDIGOnw6uYWP37Chg	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456	f	2026-07-06 21:50:08.704345+00	2026-06-29 21:50:08.704345+00
0a9541d5-3de4-4950-b89f-406860c8d3aa	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjBhOTU0MWQ1LTNkZTQtNDk1MC1iODlmLTQwNjg2MGM4ZDNhYSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgyNzY5OTIwLCJleHAiOjE3ODMzNzQ3MjB9.NOatG9txJKo_qRkRZp4tR_yFchKjAhMoOF7Njtn1bW4	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-06 21:52:00.198858+00	2026-06-29 21:52:00.198858+00
4f5b4566-62ad-41b2-af31-34f27c9ccebf	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjRmNWI0NTY2LTYyYWQtNDFiMi1hZjMxLTM0ZjI3YzljY2ViZiIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgyNzcwNDEzLCJleHAiOjE3ODMzNzUyMTN9.ZueMMNWUUBSWlzUGFVMwv9BEJBLlE2mTZqaiIGkC0gk	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-06 22:00:13.386177+00	2026-06-29 22:00:13.386177+00
b9308d02-8a62-40c2-87eb-fdd181d09844	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6ImI5MzA4ZDAyLThhNjItNDBjMi04N2ViLWZkZDE4MWQwOTg0NCIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4Mjc3MDQ3NywiZXhwIjoxNzgzMzc1Mjc3fQ.g-vbjBKNg0zb_-snFPcvqvMb5g0rqDETu3xALyZDwDY	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-06 22:01:17.559159+00	2026-06-29 22:01:17.559159+00
36ebf007-fdba-496f-bfbb-a3008f26fc38	4	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjQsInNpZCI6IjM2ZWJmMDA3LWZkYmEtNDk2Zi1iZmJiLWEzMDA4ZjI2ZmMzOCIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzgyNzcxMDA2LCJleHAiOjE3ODMzNzU4MDZ9.MjunI4JQpbjVzvGHXb1tnfqKLev8MLncCBlGEkrQqO0	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-06 22:10:06.568282+00	2026-06-29 22:10:06.568282+00
5c5009d5-1307-4ead-a1d5-d83ba53590b2	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjVjNTAwOWQ1LTEzMDctNGVhZC1hMWQ1LWQ4M2JhNTM1OTBiMiIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgyNzcxMTE4LCJleHAiOjE3ODMzNzU5MTh9.JOVKYN7B-NCHNLYkG_SaLxCWoHB6EInaGCZzmTblRBQ	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-06 22:11:58.626924+00	2026-06-29 22:11:58.626924+00
fa9bfcc8-6266-4a30-ad4e-6f03ac3f31e3	4	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjQsInNpZCI6ImZhOWJmY2M4LTYyNjYtNGEzMC1hZDRlLTZmMDNhYzNmMzFlMyIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzgyNzcxMTk3LCJleHAiOjE3ODMzNzU5OTd9.N8jLpy84pS-4r2ixrTwuhIfKMbbcAWNIZr8QKJZQFSw	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-06 22:13:17.036913+00	2026-06-29 22:13:17.036913+00
8eec0179-262d-43f7-a1ec-66914f3ef169	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6IjhlZWMwMTc5LTI2MmQtNDNmNy1hMWVjLTY2OTE0ZjNlZjE2OSIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4Mjc3Mzg3NiwiZXhwIjoxNzgzMzc4Njc2fQ.1Og3MUD8HHic99x0bymw1oHMKFRwFSUcL0jeRDhRxrA	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-06 22:57:56.955117+00	2026-06-29 22:57:56.955117+00
3ba6b8c4-77bb-4dcf-b658-c444d1bffa84	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjNiYTZiOGM0LTc3YmItNGRjZi1iNjU4LWM0NDRkMWJmZmE4NCIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgyODE0MDk1LCJleHAiOjE3ODM0MTg4OTV9.bQpgI0KOqblJw9DoiRs31ttaUYxOhw3ie_eIxgIbv5Q	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-07 10:08:15.926204+00	2026-06-30 10:08:15.926204+00
afb9fd9b-ff24-474d-b00d-9ff7f014e3f2	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6ImFmYjlmZDliLWZmMjQtNDc0ZC1iMDBkLTlmZjdmMDE0ZTNmMiIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4MjgxNDM4NiwiZXhwIjoxNzgzNDE5MTg2fQ.BcOVVKXYMMj0KBqvFc1qPduObTphQhNJlAp1l-GjyHE	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-07 10:13:06.308642+00	2026-06-30 10:13:06.308642+00
38d6a560-4930-49e7-9b32-d2bbf822e3ef	8	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjgsInNpZCI6IjM4ZDZhNTYwLTQ5MzAtNDllNy05YjMyLWQyYmJmODIyZTNlZiIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzgyODE0MzkxLCJleHAiOjE3ODM0MTkxOTF9.QkGQf_7LmJhJ3d5XTu5y2PS5xM5BuHK2kpb1LPilA20	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-07 10:13:11.98652+00	2026-06-30 10:13:11.98652+00
6c477196-65c9-4cf5-8e15-794b26fe02ac	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjZjNDc3MTk2LTY1YzktNGNmNS04ZTE1LTc5NGIyNmZlMDJhYyIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgyODE1NDExLCJleHAiOjE3ODM0MjAyMTF9.wz8fisPq2GxFwVfNHUGFpmyfT9m-zkEL4PmFEeHBt7A	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-07 10:30:11.676083+00	2026-06-30 10:30:11.676083+00
788f7e70-22fa-49c4-98ed-083fd12aa862	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6Ijc4OGY3ZTcwLTIyZmEtNDljNC05OGVkLTA4M2ZkMTJhYTg2MiIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4MjgxNTQyNywiZXhwIjoxNzgzNDIwMjI3fQ.w5XaCf4oMzrJjBq0RUeUmAy0UB_8vlDvR1vfUwwUm4g	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-07 10:30:27.954396+00	2026-06-30 10:30:27.954396+00
8fa05377-c96e-48be-8ba6-c97eb088def4	8	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjgsInNpZCI6IjhmYTA1Mzc3LWM5NmUtNDhiZS04YmE2LWM5N2ViMDg4ZGVmNCIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzgyODE1NDQ5LCJleHAiOjE3ODM0MjAyNDl9.fZmsL-MBC4uMXMnfleXd3gtAwvxVL86YDagMvCCQqvs	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-07 10:30:49.126242+00	2026-06-30 10:30:49.126242+00
cb807b67-0cb5-4e5f-bb57-f2f6d22d23aa	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImNiODA3YjY3LTBjYjUtNGU1Zi1iYjU3LWYyZjZkMjJkMjNhYSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgyODE2OTIyLCJleHAiOjE3ODM0MjE3MjJ9.IMU5N7SKsLAr46OtUHG8DZFJURr9JceejAe9P0cdiJI	::1	Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Mobile Safari/537.36	f	2026-07-07 10:55:22.217735+00	2026-06-30 10:55:22.217735+00
4a58b00d-7f9a-4f9e-8bf1-e07c8af7adb7	4	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjQsInNpZCI6IjRhNThiMDBkLTdmOWEtNGY5ZS04YmYxLWUwN2M4YWY3YWRiNyIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzgyODE3MDc0LCJleHAiOjE3ODM0MjE4NzR9.27jJoeoa_Yg2tnMW_nDRc81yhDJ8gGRlTVbZjsCXmAs	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-07 10:57:54.277468+00	2026-06-30 10:57:54.277468+00
a0423b48-cc05-4075-909d-20192a5befe5	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImEwNDIzYjQ4LWNjMDUtNDA3NS05MDlkLTIwMTkyYTViZWZlNSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgyODE3MjA3LCJleHAiOjE3ODM0MjIwMDd9.tjFibifssT9ZgS4jFGl4A5UOjjQrLWSyOPWX_TEOhyE	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-07 11:00:07.467338+00	2026-06-30 11:00:07.467338+00
cb58929b-9aa1-4dbe-ba0b-4d61aba554ca	4	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjQsInNpZCI6ImNiNTg5MjliLTlhYTEtNGRiZS1iYTBiLTRkNjFhYmE1NTRjYSIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzgyODE3MjQxLCJleHAiOjE3ODM0MjIwNDF9.3XWT_0c05KskgpF5N0mfkZZx2ytFKSHlvYCqGlqd4W4	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-07 11:00:41.974828+00	2026-06-30 11:00:41.974828+00
1bf473be-01ca-41fb-b3c2-6eb280e2bda3	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjFiZjQ3M2JlLTAxY2EtNDFmYi1iM2MyLTZlYjI4MGUyYmRhMyIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgyODE4MTAzLCJleHAiOjE3ODM0MjI5MDN9.sblhQtV_EPumxNqQOmy4l1lt8JsprNEfeIGvSPo64-0	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-07 11:15:03.274627+00	2026-06-30 11:15:03.274627+00
1cef91ec-e71d-433f-ad2a-267b3e30f51d	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjFjZWY5MWVjLWU3MWQtNDMzZi1hZDJhLTI2N2IzZTMwZjUxZCIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgyODUzMTI0LCJleHAiOjE3ODM0NTc5MjR9.nDPnb5WpLzMqgVkhf6Ia8bpGukbHnltNe0DEo6zwJzM	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-07 20:58:44.03171+00	2026-06-30 20:58:44.03171+00
9ba778e3-910a-48a1-a77f-90d91ee9e498	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjliYTc3OGUzLTkxMGEtNDhhMS1hNzdmLTkwZDkxZWU5ZTQ5OCIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgyODU1MzQyLCJleHAiOjE3ODM0NjAxNDJ9.mzA4mtO0SeUEhRZY15bwP3hxk_HgVBXAcCvSfcbjamM	::1	Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Mobile Safari/537.36	f	2026-07-07 21:35:42.727307+00	2026-06-30 21:35:42.727307+00
ab04aa6c-730c-4c78-b3a4-c38c656cf632	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImFiMDRhYTZjLTczMGMtNGM3OC1iM2E0LWMzOGM2NTZjZjYzMiIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgyODU3NDMwLCJleHAiOjE3ODM0NjIyMzB9.nB8H9qvQUro878bmzaIgUAdPOzjJhV0RUpIUzMwR79M	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-07 22:10:30.410793+00	2026-06-30 22:10:30.410793+00
5967d499-2a81-4fe8-aa3a-b1fb9ebd1120	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjU5NjdkNDk5LTJhODEtNGZlOC1hYTNhLWIxZmI5ZWJkMTEyMCIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgyODU4MjE0LCJleHAiOjE3ODM0NjMwMTR9.JUHuP8Iyti9Vp_4mayuZ-KtGvp2JCc_zh4kZPhuBwE4	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456	f	2026-07-07 22:23:34.434221+00	2026-06-30 22:23:34.434221+00
27aabd87-8f9b-4a4f-ad0e-023d6b21a34a	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjI3YWFiZDg3LThmOWItNGE0Zi1hZDBlLTAyM2Q2YjIxYTM0YSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgyODU4NTUwLCJleHAiOjE3ODM0NjMzNTB9.cWr9e_LVVz5mgsM5KA89DmhAQk18H-6XwREiy5fDvCo	::1	Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Mobile Safari/537.36	f	2026-07-07 22:29:10.379735+00	2026-06-30 22:29:10.379735+00
54824afb-f122-4adc-a538-4313187d9b96	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjU0ODI0YWZiLWYxMjItNGFkYy1hNTM4LTQzMTMxODdkOWI5NiIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgyODYwMTg3LCJleHAiOjE3ODM0NjQ5ODd9.bqtJyvwq5D2n_3cTpa8CUHvuEOCNHrVHJ59PdhcPaOg	::1	Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Mobile Safari/537.36	f	2026-07-07 22:56:27.91827+00	2026-06-30 22:56:27.91827+00
a155e4a5-04c6-4308-87c7-7ab19b7030ca	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6ImExNTVlNGE1LTA0YzYtNDMwOC04N2M3LTdhYjE5YjcwMzBjYSIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4Mjg2MDI3OCwiZXhwIjoxNzgzNDY1MDc4fQ.QKh203KxowH5PQWjQAQceqqYncVQ09jil8JznXzDW_E	::1	Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Mobile Safari/537.36	f	2026-07-07 22:57:58.126722+00	2026-06-30 22:57:58.126722+00
d4e1476e-fc77-48bd-8bea-c469da44b772	8	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjgsInNpZCI6ImQ0ZTE0NzZlLWZjNzctNDhiZC04YmVhLWM0NjlkYTQ0Yjc3MiIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzgyODYwMzA0LCJleHAiOjE3ODM0NjUxMDR9.pyi4BUomNfqEH1ce71jwT8jg3f6yxpMvTSZbHh_rBSU	::1	Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Mobile Safari/537.36	f	2026-07-07 22:58:24.906609+00	2026-06-30 22:58:24.906609+00
c7efbb52-84f1-4ee4-8ef0-b49186590098	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImM3ZWZiYjUyLTg0ZjEtNGVlNC04ZWYwLWI0OTE4NjU5MDA5OCIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgyODYwNzYwLCJleHAiOjE3ODM0NjU1NjB9.8aoCHvBMZyHGtInGzAKcqgptsKNoVUZWpHfLTINbnP4	::1	Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Mobile Safari/537.36	f	2026-07-07 23:06:00.127388+00	2026-06-30 23:06:00.127388+00
8f04b420-7fc3-42f8-821c-e27ad51ad8b9	10	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEwLCJzaWQiOiI4ZjA0YjQyMC03ZmMzLTQyZjgtODIxYy1lMjdhZDUxYWQ4YjkiLCJyb2xlIjoiU1RVREVOVCIsImlhdCI6MTc4Mjg2MTE5MSwiZXhwIjoxNzgzNDY1OTkxfQ.dvWriZZdQAf3n8BEg6AVLxAA2nXC4yQO5UJMb7vkV7Q	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-07 23:13:11.442075+00	2026-06-30 23:13:11.442075+00
b23ebda6-e54f-4a6e-9e87-08a81b57fd40	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImIyM2ViZGE2LWU1NGYtNGE2ZS05ZTg3LTA4YTgxYjU3ZmQ0MCIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgzMTAxMzY5LCJleHAiOjE3ODM3MDYxNjl9.AcX1ZjOYLhCMyVWpsEIfh8i99B7Zmr9-KQc0PcUHgKk	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-10 17:56:09.194048+00	2026-07-03 17:56:09.194048+00
1b2e3b4f-f0b5-4d68-9224-9e5adec8dc2a	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6IjFiMmUzYjRmLWYwYjUtNGQ2OC05MjI0LTllNWFkZWM4ZGMyYSIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4MzEwNDAxMywiZXhwIjoxNzgzNzA4ODEzfQ.qzHXGq-h_WRW6EIP7CDxDY5z6ossqyjdMO3YZOlFS40	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	f	2026-07-10 18:40:13.577173+00	2026-07-03 18:40:13.577173+00
5198ead1-9739-4646-885a-b886a43b25b1	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6IjUxOThlYWQxLTk3MzktNDY0Ni04ODVhLWI4ODZhNDNiMjViMSIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4MzExMjM3OCwiZXhwIjoxNzgzNzE3MTc4fQ.ldKJgZZZ_uXbPrDytrnHQTHXgmc71WBN_U2A58ED0QQ	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456	f	2026-07-10 20:59:38.031567+00	2026-07-03 20:59:38.031567+00
afdb94a6-a7c4-4a5c-9728-f702d76d356c	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImFmZGI5NGE2LWE3YzQtNGE1Yy05NzI4LWY3MDJkNzZkMzU2YyIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgzMTEyNTg2LCJleHAiOjE3ODM3MTczODZ9.a6FZ2M3iAUtVu75_ocPjFMmSgWCHvx0uuxif5o1Q-OM	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456	f	2026-07-10 21:03:06.868902+00	2026-07-03 21:03:06.868902+00
7cba2250-925e-422f-9e26-5e626b1bb954	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjdjYmEyMjUwLTkyNWUtNDIyZi05ZTI2LTVlNjI2YjFiYjk1NCIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgzMTg0MTY2LCJleHAiOjE3ODM3ODg5NjZ9.6ICGstyiQgKv6wZ4nLKhQX-92DHpgbQh2i2BEZCVuio	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-11 16:56:06.803394+00	2026-07-04 16:56:06.803394+00
f1ee03ae-fe7b-4852-ba42-5b1d4e0dffe8	6	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsInNpZCI6ImYxZWUwM2FlLWZlN2ItNDg1Mi1iYTQyLTViMWQ0ZTBkZmZlOCIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzgzMTg3NzM1LCJleHAiOjE3ODM3OTI1MzV9.AsuBogzmwFOYKpCGPbR98hPVjdFLyato6B8d-8uUy-4	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-11 17:55:35.017793+00	2026-07-04 17:55:35.017793+00
023d0c16-bd2e-4787-a250-ed67890bdf0c	6	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsInNpZCI6IjAyM2QwYzE2LWJkMmUtNDc4Ny1hMjUwLWVkNjc4OTBiZGYwYyIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzgzMjAzMDM2LCJleHAiOjE3ODM4MDc4MzZ9.iVeNHGhc5F2zPor7W6IqkBMJ4QTCqltQ_Mj_4KGs8TY	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-11 22:10:36.33726+00	2026-07-04 22:10:36.33726+00
7025c604-c7f1-45ec-b5b8-aada10169ade	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjcwMjVjNjA0LWM3ZjEtNDVlYy1iNWI4LWFhZGExMDE2OWFkZSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgzMjc2NDk5LCJleHAiOjE3ODM4ODEyOTl9.w-4qiuyLILuJE4EyI7ByLjzyBZentmm0MnisE_zcFus	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-12 18:34:59.58725+00	2026-07-05 18:34:59.58725+00
5ade3ff6-4e57-4d77-bb8a-f737c1f41988	6	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsInNpZCI6IjVhZGUzZmY2LTRlNTctNGQ3Ny1iYjhhLWY3MzdjMWY0MTk4OCIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzgzMjc4ODc1LCJleHAiOjE3ODM4ODM2NzV9.vLVdOnRYwDIC706ioL8p_Ahq8syLez7BpEjq8bOTEYI	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-12 19:14:35.275782+00	2026-07-05 19:14:35.275782+00
5f9c6819-1597-499e-8987-6115ac342f0f	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjVmOWM2ODE5LTE1OTctNDk5ZS04OTg3LTYxMTVhYzM0MmYwZiIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgzMjc5OTIxLCJleHAiOjE3ODM4ODQ3MjF9.rXKmKFIg8h5rgsqtrn9v-UQY68HVDTldPoPNyxrc1Ok	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-12 19:32:01.54618+00	2026-07-05 19:32:01.54618+00
bfa78142-00ef-47d7-9afb-019d9aaae0bb	6	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsInNpZCI6ImJmYTc4MTQyLTAwZWYtNDdkNy05YWZiLTAxOWQ5YWFhZTBiYiIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzgzMjgwMDAzLCJleHAiOjE3ODM4ODQ4MDN9.n67Ngd5ex6KF_WAUz9--vKThjdsyqjYfwD1xdw5s6FU	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-12 19:33:23.407309+00	2026-07-05 19:33:23.407309+00
414d2727-d86d-4280-a246-c0b7f309b527	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6IjQxNGQyNzI3LWQ4NmQtNDI4MC1hMjQ2LWMwYjdmMzA5YjUyNyIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4MzI4MzI1OCwiZXhwIjoxNzgzODg4MDU4fQ.jwRuNcjyo3nT8npvZmhi8SL7mt5BPwQwavDX_kv_m4o	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-12 20:27:38.345613+00	2026-07-05 20:27:38.345613+00
b14a482c-4028-46cb-bc10-2e023470c54c	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImIxNGE0ODJjLTQwMjgtNDZjYi1iYzEwLTJlMDIzNDcwYzU0YyIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgzMjg0ODM0LCJleHAiOjE3ODM4ODk2MzR9.w1HZmM09KOaCKy4hzFupPr3spC_IG4CfFUL2LZJJ4tU	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-12 20:53:54.750389+00	2026-07-05 20:53:54.750389+00
8368266c-0250-4844-8b57-c33ca51c1fcc	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6IjgzNjgyNjZjLTAyNTAtNDg0NC04YjU3LWMzM2NhNTFjMWZjYyIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4MzI4NDkwOCwiZXhwIjoxNzgzODg5NzA4fQ.17qj9CHd0vRLYTmEQA-H74t9TD2WpZ4BiYvol2vax7E	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-12 20:55:08.11856+00	2026-07-05 20:55:08.11856+00
f7e613ee-bef5-459e-994f-123fca56b6d1	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6ImY3ZTYxM2VlLWJlZjUtNDU5ZS05OTRmLTEyM2ZjYTU2YjZkMSIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4MzI4NTE2OCwiZXhwIjoxNzgzODg5OTY4fQ.ls_wHdJVChrsCD5rq-bJxsleMBqWyDAITwo78SjQYZ8	::1	Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	f	2026-07-12 20:59:28.374751+00	2026-07-05 20:59:28.374751+00
80d8ddd8-c374-4d3c-84a1-a417102795c8	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjgwZDhkZGQ4LWMzNzQtNGQzYy04NGExLWE0MTcxMDI3OTVjOCIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgzMzY5NDY0LCJleHAiOjE3ODM5NzQyNjR9.LKw7ZtUx9gkSC5AfC5g42u2fwjd08-6MPNwrK_W1W0I	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-13 20:24:24.352589+00	2026-07-06 20:24:24.352589+00
f2cd3055-2269-42d0-83ed-074a3dc7cea4	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImYyY2QzMDU1LTIyNjktNDJkMC04M2VkLTA3NGEzZGM3Y2VhNCIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgzMzc2NjgyLCJleHAiOjE3ODM5ODE0ODJ9.81BRXFMMCRRPdWhwl5bZCuufXlL4_w9-mIZB7yZB2p0	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-13 22:24:42.664371+00	2026-07-06 22:24:42.664371+00
79c330ed-9b54-417e-ad0f-acfe1ea5f89e	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6Ijc5YzMzMGVkLTliNTQtNDE3ZS1hZDBmLWFjZmUxZWE1Zjg5ZSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgzNDY3NDU2LCJleHAiOjE3ODQwNzIyNTZ9.mOUk-IQgulikxGtuRYPlrEuUgjo-6GbclspQ7JH8taw	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-14 23:37:36.307767+00	2026-07-07 23:37:36.307767+00
a231a56c-c78c-4e15-b4b5-fc889e4620c7	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImEyMzFhNTZjLWM3OGMtNGUxNS1iNGI1LWZjODg5ZTQ2MjBjNyIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgzNTExMzE4LCJleHAiOjE3ODQxMTYxMTh9.W9_YcoEitY7ITdyw5Z8H4GflWKITrkSmghaNrgeKpbQ	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-15 11:48:38.565472+00	2026-07-08 11:48:38.565472+00
a2aa6113-fb56-403d-b6f2-2921af9823c0	6	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsInNpZCI6ImEyYWE2MTEzLWZiNTYtNDAzZC1iNmYyLTI5MjFhZjk4MjNjMCIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzgzNTEyNjUwLCJleHAiOjE3ODQxMTc0NTB9.fMXoEUMso79nBoSdd8ErEhZWVQQdYFbah7O9fV0tYL8	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-15 12:10:50.277251+00	2026-07-08 12:10:50.277251+00
412afd82-f5e7-4b6d-b4bf-65854be34dc1	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6IjQxMmFmZDgyLWY1ZTctNGI2ZC1iNGJmLTY1ODU0YmUzNGRjMSIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4MzUxMjY5MSwiZXhwIjoxNzg0MTE3NDkxfQ.MzWYxUO6N0wF5LH8dlfcdd4WARFu4Rir-wv7KgRhM_Y	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-15 12:11:31.61791+00	2026-07-08 12:11:31.61791+00
b06c4e5c-d347-49aa-a098-f9e66b6a3393	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImIwNmM0ZTVjLWQzNDctNDlhYS1hMDk4LWY5ZTY2YjZhMzM5MyIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgzNTE0MjAxLCJleHAiOjE3ODQxMTkwMDF9.FWCfS9DZN-SsfzS8Jqg5UqOC2nlZfmQD3iWRslv2NNI	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-15 12:36:41.503233+00	2026-07-08 12:36:41.503233+00
b2afe866-df86-4ca2-85f5-1a189bb095d1	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImIyYWZlODY2LWRmODYtNGNhMi04NWY1LTFhMTg5YmIwOTVkMSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgzNTg4MDcwLCJleHAiOjE3ODQxOTI4NzB9.kfUbaOfne-8tTkEgn-4KwlLgBui7t_W01VO3KNO_nhk	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-16 09:07:50.005141+00	2026-07-09 09:07:50.005141+00
89b3e210-29c1-4e1c-b9a2-b6ccce89d991	6	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsInNpZCI6Ijg5YjNlMjEwLTI5YzEtNGUxYy1iOWEyLWI2Y2NjZTg5ZDk5MSIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzgzNTkxNDQ3LCJleHAiOjE3ODQxOTYyNDd9.k_gVP7lpJ1pJRj4v-jYIzfBBC2NLUlL63TZr7oyq1dk	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-16 10:04:07.480713+00	2026-07-09 10:04:07.480713+00
6f7a5117-62ab-4252-8543-bdfb17cf4400	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjZmN2E1MTE3LTYyYWItNDI1Mi04NTQzLWJkZmIxN2NmNDQwMCIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgzNTkyMTYxLCJleHAiOjE3ODQxOTY5NjF9.9o665LDtbNSZfQZ9zaDmwMI65kvuPh1S2Y9bJVJMRNk	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-16 10:16:01.795927+00	2026-07-09 10:16:01.795927+00
cf434240-ab18-49f8-9268-d0b495528705	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6ImNmNDM0MjQwLWFiMTgtNDlmOC05MjY4LWQwYjQ5NTUyODcwNSIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4MzU5MjIyNywiZXhwIjoxNzg0MTk3MDI3fQ.x6MTAkwsFZgxS_R7EWRXrP1Npz9SLWudGmBn7uqUEac	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-16 10:17:07.501188+00	2026-07-09 10:17:07.501188+00
49eb30d1-3276-4c8c-afb4-041a56922bdc	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjQ5ZWIzMGQxLTMyNzYtNGM4Yy1hZmI0LTA0MWE1NjkyMmJkYyIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgzNjAxMzcxLCJleHAiOjE3ODQyMDYxNzF9.pPMnTcrnoOo27QOj2Giz93O4if6J1DrUJes7dGRZDN0	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-16 12:49:31.69067+00	2026-07-09 12:49:31.69067+00
1634b142-cd6d-47ef-a9bf-c1684b2d7185	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjE2MzRiMTQyLWNkNmQtNDdlZi1hOWJmLWMxNjg0YjJkNzE4NSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgzOTgwNzI5LCJleHAiOjE3ODQ1ODU1Mjl9.-kiEvdLeApwZtt_tMY4Mah_LMq9jAWBNsq82iSDbDZQ	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-20 22:12:09.802495+00	2026-07-13 22:12:09.802495+00
4f78e016-8953-48a0-9a41-c90055bdfd65	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjRmNzhlMDE2LTg5NTMtNDhhMC05YTQxLWM5MDA1NWJkZmQ2NSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgzOTg1OTg5LCJleHAiOjE3ODQ1OTA3ODl9.NCgOOFrEkvH_iKOq01xFquS9oOW_U_GeBuAlGy-cS2s	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-20 23:39:49.23335+00	2026-07-13 23:39:49.23335+00
620e07d6-bde7-477b-a333-3cdcbe0b8ef1	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjYyMGUwN2Q2LWJkZTctNDc3Yi1hMzMzLTNjZGNiZTBiOGVmMSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgzOTg2MzQyLCJleHAiOjE3ODQ1OTExNDJ9.lbTFWkzDCacP1hC8iVVwWX6vAI7ODemQjmMBn4D5FOM	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-20 23:45:42.501427+00	2026-07-13 23:45:42.501427+00
9d0c4243-7f73-4520-9c5b-818350abdd05	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjlkMGM0MjQzLTdmNzMtNDUyMC05YzViLTgxODM1MGFiZGQwNSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzgzOTg3MjM0LCJleHAiOjE3ODQ1OTIwMzR9.pJsOEyma_l54OR-pr4u_ZLWu8WZUhPiP32Fc6lwyMi4	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-21 00:00:34.197311+00	2026-07-14 00:00:34.197311+00
851306d8-fa51-4a7d-947d-3878e43d4c60	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6Ijg1MTMwNmQ4LWZhNTEtNGE3ZC05NDdkLTM4NzhlNDNkNGM2MCIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0MDcwNTA5LCJleHAiOjE3ODQ2NzUzMDl9.iqat1ys-zD6qjVC9F4ev9_uB5f7mB6AB753S5SiJyPs	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-21 23:08:29.873067+00	2026-07-14 23:08:29.873067+00
bea7cab0-3f0c-4b6c-ab35-bfd8dc658058	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImJlYTdjYWIwLTNmMGMtNGI2Yy1hYjM1LWJmZDhkYzY1ODA1OCIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0MDcwNjAzLCJleHAiOjE3ODQ2NzU0MDN9.zG-c9k09sDkkFfF4rU55L-FFgQh_mn6yNvZPZiju5-Q	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-21 23:10:03.018281+00	2026-07-14 23:10:03.018281+00
303d238e-a66f-478c-92cf-20aecea3beef	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjMwM2QyMzhlLWE2NmYtNDc4Yy05MmNmLTIwYWVjZWEzYmVlZiIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0MDcwNzY1LCJleHAiOjE3ODQ2NzU1NjV9.0FDNZcREsKrVPnbm3XRV5eWfRKAaQZIVZnTKcwt65_8	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-21 23:12:45.503621+00	2026-07-14 23:12:45.503621+00
399f8131-fa6f-49ed-848e-d0855185ac1e	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjM5OWY4MTMxLWZhNmYtNDllZC04NDhlLWQwODU1MTg1YWMxZSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0MDcwODE0LCJleHAiOjE3ODQ2NzU2MTR9.q_5LnFPoMQu-5rnxGWwQpVKZV0zsRj_k0tbBMY0ASBc	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-21 23:13:34.210899+00	2026-07-14 23:13:34.210899+00
e434dcc6-e413-4eec-96ea-0caf92c24691	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImU0MzRkY2M2LWU0MTMtNGVlYy05NmVhLTBjYWY5MmMyNDY5MSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0MDcwOTUxLCJleHAiOjE3ODQ2NzU3NTF9.VFalYEbttO7ZyksyQO8HdP5EZ5QFOsSz4EBEfLs1U4I	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-21 23:15:51.181686+00	2026-07-14 23:15:51.181686+00
3d09be74-6310-4005-9417-cbf3d7a2f0c6	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjNkMDliZTc0LTYzMTAtNDAwNS05NDE3LWNiZjNkN2EyZjBjNiIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0MDcxMjUzLCJleHAiOjE3ODQ2NzYwNTN9.OaQ7MEt3MFSoYyWbV8HWUJfEA5jcj7K1o2nee4Ll-8s	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-21 23:20:53.132983+00	2026-07-14 23:20:53.132983+00
be43ad6e-06a5-43a6-9dcf-9faa6016dde4	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImJlNDNhZDZlLTA2YTUtNDNhNi05ZGNmLTlmYWE2MDE2ZGRlNCIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0MTEzNTM3LCJleHAiOjE3ODQ3MTgzMzd9.B2pc2Au88HatuXyzi4FD133sxrVndT5lqDklq5AbpVM	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-22 11:05:37.12419+00	2026-07-15 11:05:37.12419+00
e5a946a6-ef5b-486d-b77c-3fdd86bf4b34	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImU1YTk0NmE2LWVmNWItNDg2ZC1iNzdjLTNmZGQ4NmJmNGIzNCIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0MTI4NzA4LCJleHAiOjE3ODQ3MzM1MDh9.aMPUkrNBL6n3c7VtD3M7cLsYpfyzzlagtOLUrIKi4KI	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-22 15:18:28.226509+00	2026-07-15 15:18:28.226509+00
2acf8e63-2e9a-4ec6-a234-432fce925d2a	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6IjJhY2Y4ZTYzLTJlOWEtNGVjNi1hMjM0LTQzMmZjZTkyNWQyYSIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4NDEyOTgwMSwiZXhwIjoxNzg0NzM0NjAxfQ.Wbn0YWddy0MLCQxBidfKYewOKPQzGEIWFIR8LHy2cik	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-22 15:36:41.945814+00	2026-07-15 15:36:41.945814+00
93ba3b77-a6c6-4178-9f01-ec5151240f73	6	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsInNpZCI6IjkzYmEzYjc3LWE2YzYtNDE3OC05ZjAxLWVjNTE1MTI0MGY3MyIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzg0MTMzODgwLCJleHAiOjE3ODQ3Mzg2ODB9.bvlpV64kzsKxrcTPg280jugrCjPO6LpjgQC8LVS8ut8	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-22 16:44:40.728125+00	2026-07-15 16:44:40.728125+00
b89a9ea8-670f-433d-8a38-0d33e035ad0e	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImI4OWE5ZWE4LTY3MGYtNDMzZC04YTM4LTBkMzNlMDM1YWQwZSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0MTk1MzQ4LCJleHAiOjE3ODQ4MDAxNDh9.qVMxjYlWQvU4Flnyc-gyLOuFAetyMz_fNZJLTP-GEo0	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-23 09:49:08.803422+00	2026-07-16 09:49:08.803422+00
ceb1c986-7cd2-498d-9169-ed548fc8eebe	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImNlYjFjOTg2LTdjZDItNDk4ZC05MTY5LWVkNTQ4ZmM4ZWViZSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0MjMyMTk1LCJleHAiOjE3ODQ4MzY5OTV9.RHnjfmdXYwzFIFGXOlt8vXGGpXveDc3Iu6OFIXssVNs	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-23 20:03:15.433283+00	2026-07-16 20:03:15.433283+00
b6e93630-14a1-4e58-817c-73b38c6ba80c	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImI2ZTkzNjMwLTE0YTEtNGU1OC04MTdjLTczYjM4YzZiYTgwYyIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0MjM1MTQ4LCJleHAiOjE3ODQ4Mzk5NDh9.UDnU3gm7qsFjs2Mc41O7vKcrKguUJEBt0uPDoyt0IYs	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-23 20:52:28.877295+00	2026-07-16 20:52:28.877295+00
de46bb46-f785-46de-9ce3-920c6ad6846c	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImRlNDZiYjQ2LWY3ODUtNDZkZS05Y2UzLTkyMGM2YWQ2ODQ2YyIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0MjM2MjIxLCJleHAiOjE3ODQ4NDEwMjF9.rJ7qbc8TOahy5MlfH8T8yRSYGJyTQ25-fffKcjnwb0E	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-23 21:10:21.23799+00	2026-07-16 21:10:21.23799+00
cdc5ca79-5d5e-4df5-98f0-b7de9ce6f8ae	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImNkYzVjYTc5LTVkNWUtNGRmNS05OGYwLWI3ZGU5Y2U2ZjhhZSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0MjM2NDI2LCJleHAiOjE3ODQ4NDEyMjZ9.vEX44ztkaGbfFyqQlE-DjwL-Asc4Cu5VsxyNBReSmAM	::1	Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	f	2026-07-23 21:13:46.944693+00	2026-07-16 21:13:46.944693+00
c75be258-e1cb-4aa1-ad06-8d8478fa1a35	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImM3NWJlMjU4LWUxY2ItNGFhMS1hZDA2LThkODQ3OGZhMWEzNSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0MjM3MTU1LCJleHAiOjE3ODQ4NDE5NTV9.uQDKnVFp2llVKZbyjHGtYQD0826BrvKAqJMSgEj--6E	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-23 21:25:55.371506+00	2026-07-16 21:25:55.371506+00
816e3207-1ff8-4436-880b-33d34cdc4b3c	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjgxNmUzMjA3LTFmZjgtNDQzNi04ODBiLTMzZDM0Y2RjNGIzYyIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0MjM3MTk3LCJleHAiOjE3ODQ4NDE5OTd9.tlTBrem6jkPRRX0v6zEMoQlwSb48ueXrfiizAf-GqYs	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-23 21:26:37.811733+00	2026-07-16 21:26:37.811733+00
239fc938-79a9-40d3-a6b0-d4ad594fb9df	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjIzOWZjOTM4LTc5YTktNDBkMy1hNmIwLWQ0YWQ1OTRmYjlkZiIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0MjM3MjMxLCJleHAiOjE3ODQ4NDIwMzF9.q-hXgdI9Hc__zyjBrCWNne3-09Tyh7N9Up5uUY8pvmk	::1	Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	f	2026-07-23 21:27:11.169047+00	2026-07-16 21:27:11.169047+00
c0f05d4a-6ca3-4c0c-be68-30cbbca9d345	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6ImMwZjA1ZDRhLTZjYTMtNGMwYy1iZTY4LTMwY2JiY2E5ZDM0NSIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4NDIzNzMyOCwiZXhwIjoxNzg0ODQyMTI4fQ.DoeP4sCnhER8uu-tyWtD9_q6X1-N3Fx08esC5YWlIqw	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-23 21:28:48.573325+00	2026-07-16 21:28:48.573325+00
f81f4d26-b41e-4b9c-b4c5-07337d6ef320	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6ImY4MWY0ZDI2LWI0MWUtNGI5Yy1iNGM1LTA3MzM3ZDZlZjMyMCIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4NDIzNzM2MSwiZXhwIjoxNzg0ODQyMTYxfQ._c51zKFYq3S4nDYk-srzH6WZkWVXkZgvvIkFl9F6uAE	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-23 21:29:21.905621+00	2026-07-16 21:29:21.905621+00
841caf31-e6a9-43c7-804d-2aedb897480a	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6Ijg0MWNhZjMxLWU2YTktNDNjNy04MDRkLTJhZWRiODk3NDgwYSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0Mjk1NjU4LCJleHAiOjE3ODQ5MDA0NTh9.86nzuFhqothMV4LBVx-NQSa3UYeLkWW_dx61NW8Nr28	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-24 13:40:58.554879+00	2026-07-17 13:40:58.554879+00
0c76093e-5e14-4a66-a905-f2fdf0f75b19	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjBjNzYwOTNlLTVlMTQtNGE2Ni1hOTA1LWYyZmRmMGY3NWIxOSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0Mjk1NzA5LCJleHAiOjE3ODQ5MDA1MDl9.gBr8VepIaEOnIAAazZFkHO8XhgKTN751Yl-mq6ZiQO8	::1	Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	f	2026-07-24 13:41:49.963263+00	2026-07-17 13:41:49.963263+00
5dd72e96-8488-4d3f-853f-862f3262530a	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjVkZDcyZTk2LTg0ODgtNGQzZi04NTNmLTg2MmYzMjYyNTMwYSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0MzAxMTQ1LCJleHAiOjE3ODQ5MDU5NDV9.yEsYFptkmSikWcbU2aaSruxL1dbFDaNefsczAOrLo50	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-24 15:12:25.280947+00	2026-07-17 15:12:25.280947+00
152f151a-0cc8-4814-a9c4-b4cbbe34e5c3	6	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsInNpZCI6IjE1MmYxNTFhLTBjYzgtNDgxNC1hOWM0LWI0Y2JiZTM0ZTVjMyIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzg0MzEwMTk4LCJleHAiOjE3ODQ5MTQ5OTh9.NPjQy36Z4_fH4LGH7IBYiR2ZBGhcSQNCGQpF7NFOfTQ	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-24 17:43:18.712663+00	2026-07-17 17:43:18.712663+00
2e46d7f0-f782-422c-940e-d3cd0b7c2e73	6	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsInNpZCI6IjJlNDZkN2YwLWY3ODItNDIyYy05NDBlLWQzY2QwYjdjMmU3MyIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzg0MzEwMjYxLCJleHAiOjE3ODQ5MTUwNjF9.IhRzZPLCsgU7z9_rN9dR_o_WkFGT_l6pRSjD0-nivss	::1	Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	f	2026-07-24 17:44:21.150984+00	2026-07-17 17:44:21.150984+00
ee441936-bc5a-4fb6-837e-bd8d1a1d089f	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImVlNDQxOTM2LWJjNWEtNGZiNi04MzdlLWJkOGQxYTFkMDg5ZiIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0MzgzMzc3LCJleHAiOjE3ODQ5ODgxNzd9.F3ZM4W5iIRanlTDcJLyFdy_Dv8RfaRxt22-RVZfsgpg	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-25 14:02:57.260993+00	2026-07-18 14:02:57.260993+00
cbb0709e-deb9-47d8-a10c-1730800015c0	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImNiYjA3MDllLWRlYjktNDdkOC1hMTBjLTE3MzA4MDAwMTVjMCIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0MzgzNDQ1LCJleHAiOjE3ODQ5ODgyNDV9.rIBlWDfXCaIcIHE6ipKvzaYeYPbjD0ylFUGM87l_z_k	::1	Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	f	2026-07-25 14:04:05.885453+00	2026-07-18 14:04:05.885453+00
93849ae6-06aa-4800-a49e-ee022070b39e	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6IjkzODQ5YWU2LTA2YWEtNDgwMC1hNDllLWVlMDIyMDcwYjM5ZSIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4NDQwMDQ3MywiZXhwIjoxNzg1MDA1MjczfQ.qmS_GegzFkj4b_JfJXz950i_UbnSbkXon4KB6GF72x0	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-25 18:47:53.160825+00	2026-07-18 18:47:53.160825+00
e9bdbb87-40ba-43d9-a80f-29351a028811	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImU5YmRiYjg3LTQwYmEtNDNkOS1hODBmLTI5MzUxYTAyODgxMSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0NDAwNTI4LCJleHAiOjE3ODUwMDUzMjh9.x1SK_thFVGLaziQnL02RFVKluOj7amwwHJbu_hZo6Bw	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-25 18:48:48.586753+00	2026-07-18 18:48:48.586753+00
5d570f0b-655a-4956-aec1-0b098c05c497	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjVkNTcwZjBiLTY1NWEtNDk1Ni1hZWMxLTBiMDk4YzA1YzQ5NyIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0NDAwNTczLCJleHAiOjE3ODUwMDUzNzN9.avZ35oPKzYIEkiEwcvYUX_TkBZwMMk7U6yy-vBNFRcg	::1	Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	f	2026-07-25 18:49:33.258021+00	2026-07-18 18:49:33.258021+00
d8b3bce7-d385-43c7-88e6-39df8601eaac	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6ImQ4YjNiY2U3LWQzODUtNDNjNy04OGU2LTM5ZGY4NjAxZWFhYyIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4NDQwMDk4MCwiZXhwIjoxNzg1MDA1NzgwfQ.FoBHNXSQZrQxGpsXl9WAJtgt78bePSVFcwmRmERcC9Y	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-25 18:56:21.001155+00	2026-07-18 18:56:21.001155+00
f8d561e0-94f8-4743-99e4-48d769486bd8	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6ImY4ZDU2MWUwLTk0ZjgtNDc0My05OWU0LTQ4ZDc2OTQ4NmJkOCIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4NDQwMTAwMiwiZXhwIjoxNzg1MDA1ODAyfQ.6mky3l67QQvy0CbeNxMNfEgPcJhhhbC0dsPyscnXTAI	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-25 18:56:42.893691+00	2026-07-18 18:56:42.893691+00
d12c8665-f13f-4e55-bd92-4c36cf383cc3	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6ImQxMmM4NjY1LWYxM2YtNGU1NS1iZDkyLTRjMzZjZjM4M2NjMyIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4NDQ3Njk1NiwiZXhwIjoxNzg1MDgxNzU2fQ.0IXNwqIkp84qJ1Mjz1Kgzaf2tRuZPRLrhoux-2ApZQg	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-26 16:02:36.257522+00	2026-07-19 16:02:36.257522+00
96349857-b21b-450d-bef0-1bbe12966a0f	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6Ijk2MzQ5ODU3LWIyMWItNDUwZC1iZWYwLTFiYmUxMjk2NmEwZiIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4NDQ3Njk4MCwiZXhwIjoxNzg1MDgxNzgwfQ.uhs8ZY7DZOLOJ9a74EYZ5yA_8gC08BsYbaFETivbXO0	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-26 16:03:00.109057+00	2026-07-19 16:03:00.109057+00
7119095e-a035-4e0c-a0dd-40df01cc5699	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjcxMTkwOTVlLWEwMzUtNGUwYy1hMGRkLTQwZGYwMWNjNTY5OSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0NTgwNzk0LCJleHAiOjE3ODUxODU1OTR9.Pt5JZaeqXdABRyGet_6KwY3BZngvz-N8eSXmqN14t7k	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-27 20:53:14.982635+00	2026-07-20 20:53:14.982635+00
005f7a03-15d8-412f-90f6-60b9f23f9565	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjAwNWY3YTAzLTE1ZDgtNDEyZi05MGY2LTYwYjlmMjNmOTU2NSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0NTgwODI0LCJleHAiOjE3ODUxODU2MjR9.1CoIIBaSBCgWzZMGmYCQYkTa0_rSgygIJM0vaOJiES0	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-27 20:53:44.94337+00	2026-07-20 20:53:44.94337+00
54f5dbbc-54cf-4529-b5b8-655c8f584014	6	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsInNpZCI6IjU0ZjVkYmJjLTU0Y2YtNDUyOS1iNWI4LTY1NWM4ZjU4NDAxNCIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzg0NTgwOTE5LCJleHAiOjE3ODUxODU3MTl9.Us89KsLnBOkE1TKr0z1POlYCWgW3WvwdPCco-T0mxdM	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-27 20:55:19.071229+00	2026-07-20 20:55:19.071229+00
f8acf62c-0b47-45e4-96da-c297db6d0554	6	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsInNpZCI6ImY4YWNmNjJjLTBiNDctNDVlNC05NmRhLWMyOTdkYjZkMDU1NCIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzg0NTgwOTY3LCJleHAiOjE3ODUxODU3Njd9.Q82LYvq4njbHlNT66LOSosV4Uw4xd-gAloJuDHnpyCo	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-27 20:56:07.265112+00	2026-07-20 20:56:07.265112+00
82cb22b0-95fc-40b3-8c79-a1e1f6db88a4	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjgyY2IyMmIwLTk1ZmMtNDBiMy04Yzc5LWExZTFmNmRiODhhNCIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0NTgxMzMwLCJleHAiOjE3ODUxODYxMzB9.rOhzSqzd_2Znc4oyzmb5wIR7ABZALV0REArUzi8VKtI	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-27 21:02:10.145151+00	2026-07-20 21:02:10.145151+00
6f34f405-1097-4ec4-860c-0ac4d2fcf3aa	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjZmMzRmNDA1LTEwOTctNGVjNC04NjBjLTBhYzRkMmZjZjNhYSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0NTgxMzYyLCJleHAiOjE3ODUxODYxNjJ9.2YrmQEgfIwqtk50l5vMKaYayYIQvQF_ZtUBnDOgS6rM	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-27 21:02:42.563884+00	2026-07-20 21:02:42.563884+00
29f769fe-6d8b-494e-ae9f-bdee619e75c6	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6IjI5Zjc2OWZlLTZkOGItNDk0ZS1hZTlmLWJkZWU2MTllNzVjNiIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4NDYzNTA4NywiZXhwIjoxNzg1MjM5ODg3fQ.QyiHje2QgZz7ro7qPwQWC5BAzcdglqdLVrsTr1fL4AA	::1	Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	f	2026-07-28 11:58:07.96018+00	2026-07-21 11:58:07.96018+00
32c73ca4-f86d-44f0-8226-8db50f5e3ae0	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6IjMyYzczY2E0LWY4NmQtNDRmMC04MjI2LThkYjUwZjVlM2FlMCIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4NDYzNTExMSwiZXhwIjoxNzg1MjM5OTExfQ.rJ_P0ZejUcl1EYjyO8-L1u013d_g-dOF4QglaWANjbE	::1	Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	f	2026-07-28 11:58:31.235218+00	2026-07-21 11:58:31.235218+00
f9956870-b21c-4e6d-bf36-26a421de0f65	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImY5OTU2ODcwLWIyMWMtNGU2ZC1iZjM2LTI2YTQyMWRlMGY2NSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0NjQ4MTMyLCJleHAiOjE3ODUyNTI5MzJ9.ptbn3DQ8Rs6_z1no2Xwv1EKJH5Q2vjr-evBu0Jj8j9k	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-28 15:35:32.967305+00	2026-07-21 15:35:32.967305+00
c34e707f-4641-4171-a1b8-5f96dd90ee19	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImMzNGU3MDdmLTQ2NDEtNDE3MS1hMWI4LTVmOTZkZDkwZWUxOSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0NjQ4MTU3LCJleHAiOjE3ODUyNTI5NTd9.IJSOVj9T5G5l8XD_lSZQfC3cqsW5svfjzRCEMqhJcjk	::1	Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	f	2026-07-28 15:35:57.627224+00	2026-07-21 15:35:57.627224+00
d67b30b2-dab7-4499-ab5f-4271d4de6038	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6ImQ2N2IzMGIyLWRhYjctNDQ5OS1hYjVmLTQyNzFkNGRlNjAzOCIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4NDY0ODE5NiwiZXhwIjoxNzg1MjUyOTk2fQ.O9Vnql8GLLSK6R3klsE9OBa0I8B4NWaOQo5X9pv785w	::1	Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	f	2026-07-28 15:36:36.397934+00	2026-07-21 15:36:36.397934+00
5300881d-cd33-40f8-af8f-2c78aa673bd0	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6IjUzMDA4ODFkLWNkMzMtNDBmOC1hZjhmLTJjNzhhYTY3M2JkMCIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4NDY0ODIxMiwiZXhwIjoxNzg1MjUzMDEyfQ.zpfhtu9fIkK0i3S9gFTkdMlUXcXs1yX6HmdNE5KKCL0	::1	Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	f	2026-07-28 15:36:52.888793+00	2026-07-21 15:36:52.888793+00
f5dd869c-73d4-4017-90c9-b2a231b5e11e	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6ImY1ZGQ4NjljLTczZDQtNDAxNy05MGM5LWIyYTIzMWI1ZTExZSIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4NDgxMTM4OSwiZXhwIjoxNzg1NDE2MTg5fQ.Ra256lKL7mwk7437LohGDbR1Pa1bOY228BtEFJI40Ps	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-30 12:56:29.214765+00	2026-07-23 12:56:29.214765+00
3a0c8416-e42a-4e93-96d1-8a699fc3abba	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6IjNhMGM4NDE2LWU0MmEtNGU5My05NmQxLThhNjk5ZmMzYWJiYSIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4NDgxMTQxMiwiZXhwIjoxNzg1NDE2MjEyfQ.V8H2vvo2Dd2DLyU-AjCEv1MJ1x1GEjU3M3gZses_qew	::1	Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	f	2026-07-30 12:56:52.109414+00	2026-07-23 12:56:52.109414+00
eee19b0a-1912-4053-9287-db83d1d317de	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjIsInNpZCI6ImVlZTE5YjBhLTE5MTItNDA1My05Mjg3LWRiODNkMWQzMTdkZSIsInJvbGUiOiJMRUNUVVJFUiIsImlhdCI6MTc4NDgxMTk1MCwiZXhwIjoxNzg1NDE2NzUwfQ.lDCc-qMM-Mup9fzWNOBYW9PuqpdY-HGKnQUIgtpAOho	::1	Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	f	2026-07-30 13:05:50.742656+00	2026-07-23 13:05:50.742656+00
1f1fddff-44e7-417f-a91d-483003798d17	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjFmMWZkZGZmLTQ0ZTctNDE3Zi1hOTFkLTQ4MzAwMzc5OGQxNyIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0ODExOTgwLCJleHAiOjE3ODU0MTY3ODB9.frDjYDkeTP9Z3uZL9fyALIrrBZ78OJAKuVlWjxkX-3g	::1	Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	f	2026-07-30 13:06:20.784858+00	2026-07-23 13:06:20.784858+00
e7371493-fcb1-4ad1-b7f7-19fa14646512	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6ImU3MzcxNDkzLWZjYjEtNGFkMS1iN2Y3LTE5ZmExNDY0NjUxMiIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg0ODEyMTY3LCJleHAiOjE3ODU0MTY5Njd9.h20w8O8E8qgmp3pBP5ZpYl56QqxmTjDkLjD-TKZSTZU	::1	Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	f	2026-07-30 13:09:27.794881+00	2026-07-23 13:09:27.794881+00
ddcc0bbf-db79-431d-8b1e-0a8a5d5bdb56	6	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsInNpZCI6ImRkY2MwYmJmLWRiNzktNDMxZC04YjFlLTBhOGE1ZDViZGI1NiIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzg0ODEyMjUxLCJleHAiOjE3ODU0MTcwNTF9.7u-1EoavlbsmE6HOJ2nsJdfA37tGlAidTJODEjlhz6w	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-30 13:10:51.884752+00	2026-07-23 13:10:51.884752+00
57c6ee9e-41fa-4377-b004-3041ba6a0653	6	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsInNpZCI6IjU3YzZlZTllLTQxZmEtNDM3Ny1iMDA0LTMwNDFiYTZhMDY1MyIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzg0ODEyMjg4LCJleHAiOjE3ODU0MTcwODh9.z1Zv4qVRY_MKfoZXOtgJQyvJQ2PYxJ0C2bFMLA-d9zA	::1	Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	f	2026-07-30 13:11:28.574016+00	2026-07-23 13:11:28.574016+00
5a42ef13-f1d5-4bc3-81ac-26d0a3047549	6	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsInNpZCI6IjVhNDJlZjEzLWYxZDUtNGJjMy04MWFjLTI2ZDBhMzA0NzU0OSIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzg0ODIwNjEwLCJleHAiOjE3ODU0MjU0MTB9.swJD5dmsEngPJ98EyqplRUzMGJiIn0iqbMwAG-lBiy4	::1	Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	f	2026-07-30 15:30:10.749073+00	2026-07-23 15:30:10.749073+00
70c6876e-2b17-4bd3-963a-15e445722ac8	6	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsInNpZCI6IjcwYzY4NzZlLTJiMTctNGJkMy05NjNhLTE1ZTQ0NTcyMmFjOCIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzg0ODIwNjc0LCJleHAiOjE3ODU0MjU0NzR9.ebk0LHHbtbYITL1PVUiGYvLMCMlS1a_Jh_nsX_rfmXw	::1	Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	f	2026-07-30 15:31:14.598188+00	2026-07-23 15:31:14.598188+00
a51cd9da-c66e-4751-9bfb-29a3a6787087	6	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsInNpZCI6ImE1MWNkOWRhLWM2NmUtNDc1MS05YmZiLTI5YTNhNjc4NzA4NyIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzg0ODI5ODQwLCJleHAiOjE3ODU0MzQ2NDB9.S1-Hl7tnpONJJhhSI6Xul5f_z8snQw4ml0j5nPZ0SjA	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-07-30 18:04:00.043863+00	2026-07-23 18:04:00.043863+00
5636dc71-e7db-4024-9527-869c32c71322	6	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsInNpZCI6IjU2MzZkYzcxLWU3ZGItNDAyNC05NTI3LTg2OWMzMmM3MTMyMiIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzg0OTc4MDg2LCJleHAiOjE3ODU1ODI4ODZ9.-A-_Bc18X3b3uKFTPaZvBIBoUTItwwgQY4WbhIjzMRU	::1	Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	f	2026-08-01 11:14:46.200206+00	2026-07-25 11:14:46.200206+00
22dfd741-f4a7-4d1b-a2b2-5ca8a7a3d333	6	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsInNpZCI6IjIyZGZkNzQxLWY0YTctNGQxYi1hMmIyLTVjYThhN2EzZDMzMyIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzg0OTc4MTA1LCJleHAiOjE3ODU1ODI5MDV9.opJdAk9FRMjc-0oclhTafeLwdVTkrLyRDSU7YCzdCZg	::1	Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	f	2026-08-01 11:15:05.243272+00	2026-07-25 11:15:05.243272+00
24e30b78-60bc-4268-87ba-3b644cbc5414	6	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsInNpZCI6IjI0ZTMwYjc4LTYwYmMtNDI2OC04N2JhLTNiNjQ0Y2JjNTQxNCIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzg0OTgwOTI5LCJleHAiOjE3ODU1ODU3Mjl9._6H3d1C3prLG3E4CmZEoYFHGhzE97vnf-bVv42jUkOA	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-08-01 12:02:09.078978+00	2026-07-25 12:02:09.078978+00
8b9d466a-7cf9-4081-92f4-ec45a7dae102	6	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsInNpZCI6IjhiOWQ0NjZhLTdjZjktNDA4MS05MmY0LWVjNDVhN2RhZTEwMiIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzg0OTgwOTY0LCJleHAiOjE3ODU1ODU3NjR9.3Rzfrpy1NnzhcBvs9eF3iyPLY1F3fbEJNzLaZl8bAwk	::1	Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	f	2026-08-01 12:02:44.098473+00	2026-07-25 12:02:44.098473+00
28619c34-b26d-435f-9615-d79471de410a	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInNpZCI6IjI4NjE5YzM0LWIyNmQtNDM1Zi05NjE1LWQ3OTQ3MWRlNDEwYSIsInJvbGUiOiJBRE1JTklTVFJBVE9SIiwiaWF0IjoxNzg1MDEwNTc3LCJleHAiOjE3ODU2MTUzNzd9.RjDKKBHs3usW9gCSeZq5JqbocxjpaiYpxrVHQ6XXLOQ	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-08-01 20:16:17.802835+00	2026-07-25 20:16:17.802835+00
31702f9d-a1a7-4591-b09c-85adefa5ac97	6	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYsInNpZCI6IjMxNzAyZjlkLWExYTctNDU5MS1iMDljLTg1YWRlZmE1YWM5NyIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzg1MDExMjM5LCJleHAiOjE3ODU2MTYwMzl9.Py05ZnUIOsbrC4hJ9mHEeOBBT_-kMe-nJEWek9ZJ1uU	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	f	2026-08-01 20:27:19.956068+00	2026-07-25 20:27:19.956068+00
\.


--
-- Data for Name: system_state; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.system_state (id, emergency_lockout_active, policy_config) FROM stdin;
1	f	{"matrix": {"STUDENT": {"read": true, "write": false, "delete": false, "approve": false}, "LECTURER": {"read": true, "write": true, "delete": false, "approve": true}, "ADMINISTRATOR": {"read": true, "write": true, "delete": true, "approve": true}}, "associations": {"assignedLecturer": {"isActive": true, "reauthCycle": "24h", "verificationDepth": "Direct Assignment"}, "enrolledInCourse": {"isActive": true, "timeoutMins": 120, "strengthThreshold": 85}}, "environmental": {"ipRanges": ["10.0.0.0/8", "192.168.1.0/24"], "timeWindow": {"end": "18:00", "start": "08:00", "blockOutside": true}, "gradingPeriod": {"daysLeft": 14, "requiredPeriod": "FINAL_EXAM_PERIOD"}}}
\.


--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_roles (user_id, role_id, assigned_at, assigned_by) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, password_hash, full_name, is_active, created_at, updated_at, first_name, last_name, role_id, student_id, staff_id, department, failed_logins, locked_until, last_login, last_login_ip, office_location, consultation_hours) FROM stdin;
1	admin@rasac.edu	$2b$12$WfA/87psv9wFZyqQGgxEz.f5WF9jnPHpdeJiL.X0P.v/oxBwZe7aK	System Admin	t	2026-06-24 12:00:43.940183+00	2026-07-25 20:16:17.783081+00	System	Admin	1	\N	ADM-001	\N	0	\N	2026-07-25 20:16:17.78+00	127.0.0.1	\N	\N
6	marcus.thorne@rasac.edu	$2b$12$Z4kF/HmoryI.qz1zG9Wt4uk./899vroDYIPo3CjF9KQxZzoH5ls2W	Marcus Thorne	t	2026-06-24 12:00:43.940183+00	2026-07-25 20:27:19.950057+00	Marcus	Thorne	3	11220911	\N	Computer Science	0	\N	2026-07-25 20:27:19.948+00	127.0.0.1	\N	\N
5	elena.rodriguez@rasac.edu	$2b$12$Z4kF/HmoryI.qz1zG9Wt4uk./899vroDYIPo3CjF9KQxZzoH5ls2W	Elena Rodriguez	f	2026-06-24 12:00:43.940183+00	2026-06-30 22:29:25.358834+00	Elena	Rodriguez	3	11450289	\N	Computer Science	0	\N	\N	\N	\N	\N
4	godsway.baniba@rasac.edu	$2b$12$Z4kF/HmoryI.qz1zG9Wt4uk./899vroDYIPo3CjF9KQxZzoH5ls2W	Godsway Baniba	f	2026-06-24 12:00:43.940183+00	2026-06-30 22:30:32.17541+00	Godsway	Baniba	3	11330842	\N	Computer Science	0	\N	2026-06-30 11:00:41.97+00	\N	\N	\N
7	liam.oconnor@rasac.edu	$2b$12$Z4kF/HmoryI.qz1zG9Wt4uk./899vroDYIPo3CjF9KQxZzoH5ls2W	Liam O'Connor	t	2026-06-24 12:00:43.940183+00	2026-06-27 17:49:38.973853+00	Liam	O'Connor	3	11330755	\N	Computer Science	0	\N	2026-06-27 17:49:38.967+00	\N	\N	\N
8	sarah.jenkins@rasac.edu	$2b$12$Z4kF/HmoryI.qz1zG9Wt4uk./899vroDYIPo3CjF9KQxZzoH5ls2W	Sarah Jenkins	t	2026-06-24 12:00:43.940183+00	2026-06-30 22:58:24.902279+00	Sarah	Jenkins	3	11440822	\N	Computer Science	0	\N	2026-06-30 22:58:24.9+00	\N	\N	\N
9	grace@gmail.com	$2b$12$2x9PwqzBRGg0d5WfIqXjKuIJ7JbJBlULHrqsUvUa0K0reTqSYeUJa	Prince Grace	t	2026-06-24 13:39:01.912466+00	2026-06-24 13:39:43.766267+00	Prince	Grace	3	11223ou2	\N	Computer Science	0	\N	\N	\N	\N	\N
3	prof.mensah@rasac.edu	$2b$12$NN7abtay8ziuksfPsBWeHutGAM87BOdWe9TMC7H1NI8yZfN9SAxLq	Prof. Mensah	t	2026-06-24 12:00:43.940183+00	2026-06-28 22:21:00.483543+00	Prof.	Mensah	2	\N	LEC-002	Computer Science	0	\N	2026-06-28 22:21:00.482+00	\N	\N	\N
2	dr.thorne@rasac.edu	$2b$12$FtRF6TeZdvWc7KBNyTINuOavCfVBgO3WDogxNBP5PSR42BrnNobtO	Dr. Aris Thorne	t	2026-06-24 12:00:43.940183+00	2026-07-23 15:30:44.937752+00	Dr. Aris	Thorne	2	\N	LEC-001	Computer Science	1	\N	2026-07-23 13:05:50.731+00	127.0.0.1	Computer Science Department RM 101	\N
10	amewohabenedicta@rasac.edu	$2b$12$CWvuXzkbuzpTlT/QE/opJOQ/L6d/WgHLhWNzVhbQve2Y6WPXTY/4i	Amewoha Benedicta	t	2026-06-30 23:12:38.462855+00	2026-06-30 23:13:11.436508+00	Amewoha	Benedicta	3	12983290	\N	Computer Science	0	\N	2026-06-30 23:13:11.434+00	\N	\N	\N
\.


--
-- Name: academic_periods_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.academic_periods_id_seq', 2, true);


--
-- Name: audit_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.audit_logs_id_seq', 3590, true);


--
-- Name: context_policies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.context_policies_id_seq', 1, true);


--
-- Name: courses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.courses_id_seq', 3, true);


--
-- Name: departments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.departments_id_seq', 1, true);


--
-- Name: enrollments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.enrollments_id_seq', 10, true);


--
-- Name: grades_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.grades_id_seq', 4, true);


--
-- Name: grading_periods_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.grading_periods_id_seq', 1, false);


--
-- Name: permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.permissions_id_seq', 12, true);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_id_seq', 3, true);


--
-- Name: separation_of_duty_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.separation_of_duty_logs_id_seq', 22, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 10, true);


--
-- Name: academic_periods academic_periods_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.academic_periods
    ADD CONSTRAINT academic_periods_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: context_policies context_policies_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.context_policies
    ADD CONSTRAINT context_policies_name_key UNIQUE (name);


--
-- Name: context_policies context_policies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.context_policies
    ADD CONSTRAINT context_policies_pkey PRIMARY KEY (id);


--
-- Name: courses courses_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_code_key UNIQUE (code);


--
-- Name: courses courses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (id);


--
-- Name: departments departments_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_code_key UNIQUE (code);


--
-- Name: departments departments_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_name_key UNIQUE (name);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: enrollments enrollments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_pkey PRIMARY KEY (id);


--
-- Name: enrollments enrollments_student_id_course_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_student_id_course_id_key UNIQUE (student_id, course_id);


--
-- Name: grades grades_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_pkey PRIMARY KEY (id);


--
-- Name: grades grades_student_id_course_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_student_id_course_id_key UNIQUE (student_id, course_id);


--
-- Name: grading_periods grading_periods_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grading_periods
    ADD CONSTRAINT grading_periods_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_code_key UNIQUE (code);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: role_conflicts role_conflicts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_conflicts
    ADD CONSTRAINT role_conflicts_pkey PRIMARY KEY (role_id, conflicting_role_id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (role_id, permission_id);


--
-- Name: roles roles_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_code_key UNIQUE (code);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: separation_of_duty_logs separation_of_duty_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.separation_of_duty_logs
    ADD CONSTRAINT separation_of_duty_logs_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_refresh_token_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_refresh_token_key UNIQUE (refresh_token);


--
-- Name: system_state system_state_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system_state
    ADD CONSTRAINT system_state_pkey PRIMARY KEY (id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (user_id, role_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_audit_logs_actor_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_logs_actor_time ON public.audit_logs USING btree (actor_user_id, created_at DESC);


--
-- Name: idx_courses_lecturer; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_courses_lecturer ON public.courses USING btree (lecturer_id);


--
-- Name: idx_enrollments_course; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_enrollments_course ON public.enrollments USING btree (course_id);


--
-- Name: idx_enrollments_student; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_enrollments_student ON public.enrollments USING btree (student_id);


--
-- Name: idx_grades_student; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_grades_student ON public.grades USING btree (student_id);


--
-- Name: audit_logs audit_logs_actor_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_actor_user_id_fkey FOREIGN KEY (actor_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: audit_logs audit_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: courses courses_academic_period_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_academic_period_id_fkey FOREIGN KEY (academic_period_id) REFERENCES public.academic_periods(id);


--
-- Name: courses courses_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: courses courses_lecturer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_lecturer_id_fkey FOREIGN KEY (lecturer_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: enrollments enrollments_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id) ON DELETE CASCADE;


--
-- Name: enrollments enrollments_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: grades grades_approver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_approver_id_fkey FOREIGN KEY (approver_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: grades grades_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id) ON DELETE CASCADE;


--
-- Name: grades grades_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: grades grades_submitted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_submitted_by_fkey FOREIGN KEY (submitter_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: grading_periods grading_periods_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grading_periods
    ADD CONSTRAINT grading_periods_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id) ON DELETE CASCADE;


--
-- Name: role_conflicts role_conflicts_conflicting_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_conflicts
    ADD CONSTRAINT role_conflicts_conflicting_role_id_fkey FOREIGN KEY (conflicting_role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: role_conflicts role_conflicts_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_conflicts
    ADD CONSTRAINT role_conflicts_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: role_permissions role_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON DELETE CASCADE;


--
-- Name: role_permissions role_permissions_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: separation_of_duty_logs separation_of_duty_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.separation_of_duty_logs
    ADD CONSTRAINT separation_of_duty_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_roles user_roles_assigned_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: user_roles user_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- PostgreSQL database dump complete
--

\unrestrict Fy7sC9khtKJ3VcNgwurCTPPhgVeVfXBglh51R0qvRvf3111dAWAp1Wz9wTe8CWy


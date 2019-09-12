--
-- PostgreSQL database dump
--

-- Dumped from database version 11.0
-- Dumped by pg_dump version 11.4

-- Started on 2019-07-31 08:26:34

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

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 504 (class 1259 OID 1562392)
-- Name: excludecapability; Type: TABLE; Schema: migration; Owner: postgres
--

CREATE TABLE migration.excludecapability (
    "TribalID" integer NOT NULL
);


ALTER TABLE migration.excludecapability OWNER TO postgres;

--
-- TOC entry 4817 (class 0 OID 1562392)
-- Dependencies: 504
-- Data for Name: excludecapability; Type: TABLE DATA; Schema: migration; Owner: postgres
--

COPY migration.excludecapability ("TribalID") FROM stdin;
4603
6410
989
15041
17133
99163
234343
\.


-- Completed on 2019-07-31 08:26:35

--
-- PostgreSQL database dump complete
--


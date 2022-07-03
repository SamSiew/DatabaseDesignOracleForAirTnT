drop table ACTIVITY_CONDUCT cascade constraints;
drop table CHECK_IN cascade constraints;
drop table CUSTOMER cascade constraints;
drop table HAS_ITEM cascade constraints;
drop table HAS_SPECIAL cascade constraints;
drop table HAS_TASK cascade constraints;
drop table HOUSESHARE cascade constraints;
drop table ITEM cascade constraints;
drop table ROOM cascade constraints;
drop table SPECIALISATION cascade constraints;
drop table ACTIVITY cascade constraints;
drop table BOOK cascade constraints;
drop table COSTCENTRE cascade constraints;
drop table HOUSEKEEPER cascade constraints;
drop table TOURGUIDE cascade constraints;
drop sequence ACTIVITYCODE;
drop sequence CUSTID;
drop sequence HKEEPERID;
drop sequence HSHARECODE;
drop sequence ROOMNUM;
drop sequence TGUIDEID;

spool "output.txt";

CREATE TABLE activity (
    activitycode   INTEGER NOT NULL,
    activityname   VARCHAR2(50) NOT NULL,
    description    LONG NOT NULL,
    duration       VARCHAR2(50) NOT NULL,
    activitycost   NUMBER NOT NULL
);

ALTER TABLE activity ADD CONSTRAINT activity_pk PRIMARY KEY ( activitycode );


ALTER TABLE activity DROP CONSTRAINT check_duration;

ALTER TABLE activity ADD CONSTRAINT check_duration CHECK (REGEXP_LIKE(duration,'[0-9]+:[0-5][0-9]:[0-5][0-9]$'));

CREATE TABLE activity_conduct (
    custid           INTEGER NOT NULL,
    checkintime      TIMESTAMP NOT NULL,
    activitytime     TIMESTAMP NOT NULL,
    activitycode     INTEGER NOT NULL,
    presc_tguideid   INTEGER NOT NULL,
    comp_tguideid    INTEGER
);

COMMENT ON COLUMN activity_conduct.custid IS
    'primary keys of customer entity, Customer ID';

ALTER TABLE activity_conduct
    ADD CONSTRAINT activity_conduct_pk PRIMARY KEY ( checkintime,
                                                     custid,
                                                     activitytime );

CREATE TABLE book (
    checkintime   TIMESTAMP NOT NULL,
    custid        INTEGER NOT NULL,
    roomnum       INTEGER NOT NULL,
    hsharecode    INTEGER NOT NULL
);

COMMENT ON COLUMN book.custid IS
    'primary keys of customer entity, Customer ID';

ALTER TABLE book
    ADD CONSTRAINT book_pk PRIMARY KEY ( checkintime,
                                         custid,
                                         roomnum,
                                         hsharecode );

CREATE TABLE check_in (
    custid         INTEGER NOT NULL,
    checkintime    TIMESTAMP NOT NULL,
    invoicecode    VARCHAR2(50) NOT NULL,
    checkouttime   TIMESTAMP,
    tguideid       INTEGER NOT NULL
);

COMMENT ON COLUMN check_in.custid IS
    'primary keys of customer entity, Customer ID';

ALTER TABLE check_in ADD CONSTRAINT check_in_pk PRIMARY KEY ( checkintime,
                                                              custid );

ALTER TABLE check_in ADD CONSTRAINT check_in_invoicecode_un UNIQUE ( invoicecode );

CREATE TABLE costcentre (
    ccentrecode   VARCHAR2(50) NOT NULL,
    title         LONG NOT NULL,
    admin_fname   VARCHAR2(50) NOT NULL,
    admin_lname   VARCHAR2(50) NOT NULL
);

ALTER TABLE costcentre ADD CONSTRAINT costcentre_pk PRIMARY KEY ( ccentrecode );

CREATE TABLE customer (
    custid           INTEGER NOT NULL,
    pnumber          NUMBER(30) NOT NULL,
    fname            VARCHAR2(50) NOT NULL,
    lname            VARCHAR2(50) NOT NULL,
    birthdate        DATE NOT NULL,
    housenum         VARCHAR2(30) NOT NULL,
    street_address   VARCHAR2(50) NOT NULL,
    city             VARCHAR2(50) NOT NULL,
    state            VARCHAR2(50) NOT NULL,
    country          VARCHAR2(50) NOT NULL,
    postcode         VARCHAR2(30) NOT NULL,
    urgent_contact   NUMBER(30),
    goven_id         VARCHAR2(50) NOT NULL,
    goven_country    VARCHAR2(3) NOT NULL,
    goven_type       VARCHAR2(8) NOT NULL
);

ALTER TABLE customer
    ADD CONSTRAINT check_govenidtype CHECK ( goven_type IN (
        'driving',
        'ic',
        'passport'
    ) );

COMMENT ON COLUMN customer.custid IS
    'primary keys of customer entity, Customer ID';

ALTER TABLE customer ADD CONSTRAINT customer_pk PRIMARY KEY ( custid );

ALTER TABLE customer
    ADD CONSTRAINT customer_goven_id UNIQUE ( goven_id,goven_country ,goven_type );

ALTER TABLE customer ADD CONSTRAINT customer_pnumber_un UNIQUE ( pnumber );

CREATE TABLE has_item (
    custid             INTEGER NOT NULL,
    checkintime        TIMESTAMP NOT NULL,
    activitytime       TIMESTAMP NOT NULL,
    itemcode           VARCHAR2(7) NOT NULL,
    total_itemcharge   NUMBER NOT NULL,
    quantity           INTEGER NOT NULL
);

ALTER TABLE has_item ADD CONSTRAINT check_totalitemcharge CHECK ( total_itemcharge > 0 );

ALTER TABLE has_item ADD CONSTRAINT check_quantity CHECK ( quantity > 0 );

COMMENT ON COLUMN has_item.custid IS
    'primary keys of customer entity, Customer ID';

ALTER TABLE has_item
    ADD CONSTRAINT has_item_pk PRIMARY KEY ( itemcode,
                                             checkintime,
                                             custid,
                                             activitytime );

CREATE TABLE has_special (
    tguideid   INTEGER NOT NULL,
    spname     VARCHAR2(50) NOT NULL
);

ALTER TABLE has_special ADD CONSTRAINT has_special_pk PRIMARY KEY ( tguideid,
                                                                    spname );

CREATE TABLE has_task (
    hsharecode      INTEGER NOT NULL,
    date_assigned   DATE NOT NULL,
    date_complete   DATE,
    hkeeperid       INTEGER NOT NULL
);

ALTER TABLE has_task ADD CONSTRAINT chk_date_complete CHECK ( date_complete > date_assigned );

ALTER TABLE has_task ADD CONSTRAINT has_task_pk PRIMARY KEY ( date_assigned,
                                                              hsharecode );

CREATE TABLE housekeeper (
    hkeeperid     INTEGER NOT NULL,
    fname         VARCHAR2(50) NOT NULL,
    lname         VARCHAR2(50) NOT NULL,
    pnumber       NUMBER(30),
    pcc_code      VARCHAR2(50),
    is_bankrupt   VARCHAR2(3)
);

ALTER TABLE housekeeper
    ADD CONSTRAINT chl_isbankrupt CHECK ( is_bankrupt IN (
        'no',
        'yes'
    ) );

ALTER TABLE housekeeper ADD CONSTRAINT housekeeper_pk PRIMARY KEY ( hkeeperid );

ALTER TABLE housekeeper ADD CONSTRAINT housekeeper_pnumber_un UNIQUE ( pnumber );

ALTER TABLE housekeeper ADD CONSTRAINT housekeeper_pcc_code_un UNIQUE ( pcc_code );

CREATE TABLE houseshare (
    hsharecode       INTEGER NOT NULL,
    hsharename       LONG NOT NULL,
    countrycode      VARCHAR2(3) NOT NULL,
    numofroom        INTEGER,
    numofemptyroom   INTEGER
);

ALTER TABLE houseshare ADD CONSTRAINT chk_numofroom CHECK ( numofroom >= 0 );

ALTER TABLE houseshare ADD CONSTRAINT chk_numofemptyroom CHECK ( numofemptyroom >= 0 );

ALTER TABLE houseshare ADD CONSTRAINT houseshare_pk PRIMARY KEY ( hsharecode );

CREATE TABLE item (
    itemcode      VARCHAR2(7) NOT NULL,
    itemcost      NUMBER NOT NULL,
    stock         INTEGER NOT NULL,
    description   LONG NOT NULL,
    ccentrecode   VARCHAR2(50) NOT NULL
);

ALTER TABLE item ADD CONSTRAINT check_stock CHECK ( stock >= 0 );

ALTER TABLE item ADD CONSTRAINT item_pk PRIMARY KEY ( itemcode );

CREATE TABLE room (
    roomnum        INTEGER NOT NULL,
    hsharecode     INTEGER NOT NULL,
    is_available   VARCHAR2(3) NOT NULL,
    roomtype       VARCHAR2(8) NOT NULL,
    pnumber        NUMBER(30)
);

ALTER TABLE room
    ADD CONSTRAINT chk_is_available CHECK ( is_available IN (
        'no',
        'yes'
    ) );

ALTER TABLE room
    ADD CONSTRAINT chk_roomtype CHECK ( roomtype IN (
        'fixed',
        'openplan'
    ) );

ALTER TABLE room ADD CONSTRAINT room_pk PRIMARY KEY ( roomnum,
                                                      hsharecode );

ALTER TABLE room ADD CONSTRAINT room_pnumber_un UNIQUE ( pnumber );

CREATE TABLE specialisation (
    spname   VARCHAR2(50) NOT NULL
);

ALTER TABLE specialisation ADD CONSTRAINT specialisation_pk PRIMARY KEY ( spname );

CREATE TABLE tourguide (
    tguideid        INTEGER NOT NULL,
    pnumber         NUMBER(30) NOT NULL,
    instag_handle   VARCHAR2(50) NOT NULL,
    fname           VARCHAR2(50) NOT NULL,
    lname           VARCHAR2(50) NOT NULL
);

ALTER TABLE tourguide ADD CONSTRAINT tourguide_pk PRIMARY KEY ( tguideid );

ALTER TABLE tourguide ADD CONSTRAINT tourguide_pnumber_un UNIQUE ( pnumber );

ALTER TABLE tourguide ADD CONSTRAINT tourguide_instag_handle_un UNIQUE ( instag_handle );

ALTER TABLE activity_conduct
    ADD CONSTRAINT activity_conduct_activity_fk FOREIGN KEY ( activitycode )
        REFERENCES activity ( activitycode );

ALTER TABLE activity_conduct
    ADD CONSTRAINT activity_conduct_check_in_fk FOREIGN KEY ( checkintime,
                                                              custid )
        REFERENCES check_in ( checkintime,
                              custid );

ALTER TABLE activity_conduct
    ADD CONSTRAINT activity_conduct_comp_tguided  FOREIGN KEY ( comp_tguideid )
        REFERENCES tourguide ( tguideid );

ALTER TABLE activity_conduct
    ADD CONSTRAINT activity_conduct_presc_tguide  FOREIGN KEY ( presc_tguideid )
        REFERENCES tourguide ( tguideid );

ALTER TABLE book
    ADD CONSTRAINT book_check_in_fk FOREIGN KEY ( checkintime,
                                                  custid )
        REFERENCES check_in ( checkintime,
                              custid );

ALTER TABLE book
    ADD CONSTRAINT book_room_fk FOREIGN KEY ( roomnum,
                                              hsharecode )
        REFERENCES room ( roomnum,
                          hsharecode );

ALTER TABLE check_in
    ADD CONSTRAINT check_in_customer_fk FOREIGN KEY ( custid )
        REFERENCES customer ( custid );

ALTER TABLE check_in
    ADD CONSTRAINT check_in_tourguide_fk FOREIGN KEY ( tguideid )
        REFERENCES tourguide ( tguideid );

ALTER TABLE has_item
    ADD CONSTRAINT has_item_activity_conduct_fk FOREIGN KEY ( checkintime,
                                                              custid,
                                                              activitytime )
        REFERENCES activity_conduct ( checkintime,
                                      custid,
                                      activitytime );

ALTER TABLE has_item
    ADD CONSTRAINT has_item_item_fk FOREIGN KEY ( itemcode )
        REFERENCES item ( itemcode );

ALTER TABLE has_special
    ADD CONSTRAINT has_special_specialisation_fk FOREIGN KEY ( spname )
        REFERENCES specialisation ( spname );

ALTER TABLE has_special
    ADD CONSTRAINT has_special_tourguide_fk FOREIGN KEY ( tguideid )
        REFERENCES tourguide ( tguideid );

ALTER TABLE has_task
    ADD CONSTRAINT has_task_housekeeper_fk FOREIGN KEY ( hkeeperid )
        REFERENCES housekeeper ( hkeeperid );

ALTER TABLE has_task
    ADD CONSTRAINT has_task_houseshare_fk FOREIGN KEY ( hsharecode )
        REFERENCES houseshare ( hsharecode )
            ON DELETE CASCADE;

ALTER TABLE item
    ADD CONSTRAINT item_costcentre_fk FOREIGN KEY ( ccentrecode )
        REFERENCES costcentre ( ccentrecode );

ALTER TABLE room
    ADD CONSTRAINT room_houseshare_fk FOREIGN KEY ( hsharecode )
        REFERENCES houseshare ( hsharecode )
            ON DELETE CASCADE;

CREATE SEQUENCE activitycode START WITH 1 NOCACHE ORDER;

CREATE SEQUENCE custid START WITH 1 NOCACHE ORDER;

CREATE SEQUENCE hkeeperid START WITH 1 NOCACHE ORDER;

CREATE SEQUENCE hsharecode START WITH 1 NOCACHE ORDER;

CREATE SEQUENCE roomnum START WITH 1 NOCACHE ORDER;

CREATE SEQUENCE tguideid START WITH 1 NOCACHE ORDER;

spool off;


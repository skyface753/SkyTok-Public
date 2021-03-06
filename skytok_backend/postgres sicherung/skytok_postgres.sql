PGDMP                         z            skytok    14.2 (Debian 14.2-1.pgdg110+1)    14.3 o    ?           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            ?           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            ?           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            ?           1262    16384    skytok    DATABASE     Z   CREATE DATABASE skytok WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.utf8';
    DROP DATABASE skytok;
                postgres    false            ?            1259    16385    comments    TABLE     ?   CREATE TABLE public.comments (
    id bigint NOT NULL,
    video_id bigint NOT NULL,
    user_id integer NOT NULL,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    comment text NOT NULL
);
    DROP TABLE public.comments;
       public         heap    postgres    false            ?            1259    16391    comments_id_seq    SEQUENCE     x   CREATE SEQUENCE public.comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.comments_id_seq;
       public          postgres    false    209            ?           0    0    comments_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;
          public          postgres    false    210            ?            1259    16392    comments_liked    TABLE     ?   CREATE TABLE public.comments_liked (
    comment_id bigint NOT NULL,
    user_id integer NOT NULL,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
 "   DROP TABLE public.comments_liked;
       public         heap    postgres    false            ?            1259    16396 	   following    TABLE     f   CREATE TABLE public.following (
    from_user_id integer NOT NULL,
    to_user_id integer NOT NULL
);
    DROP TABLE public.following;
       public         heap    postgres    false            ?            1259    16399 	   languages    TABLE     z   CREATE TABLE public.languages (
    id integer NOT NULL,
    name text NOT NULL,
    "iso_639-1" character(2) NOT NULL
);
    DROP TABLE public.languages;
       public         heap    postgres    false            ?            1259    16404    languages_id_seq    SEQUENCE     ?   CREATE SEQUENCE public.languages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.languages_id_seq;
       public          postgres    false    213            ?           0    0    languages_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.languages_id_seq OWNED BY public.languages.id;
          public          postgres    false    214            ?            1259    16405    messages    TABLE     >  CREATE TABLE public.messages (
    id bigint NOT NULL,
    from_user_id integer NOT NULL,
    message text NOT NULL,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    to_user_id integer NOT NULL,
    "unReaded" boolean DEFAULT true NOT NULL,
    video_id bigint,
    record_path text
);
    DROP TABLE public.messages;
       public         heap    postgres    false            ?            1259    16412    messages_id_seq    SEQUENCE     x   CREATE SEQUENCE public.messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.messages_id_seq;
       public          postgres    false    215            ?           0    0    messages_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.messages_id_seq OWNED BY public.messages.id;
          public          postgres    false    216            ?            1259    16413    tags    TABLE     L   CREATE TABLE public.tags (
    id bigint NOT NULL,
    tag text NOT NULL
);
    DROP TABLE public.tags;
       public         heap    postgres    false            ?            1259    16418    tags_id_seq    SEQUENCE     t   CREATE SEQUENCE public.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.tags_id_seq;
       public          postgres    false    217            ?           0    0    tags_id_seq    SEQUENCE OWNED BY     ;   ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;
          public          postgres    false    218            ?            1259    16419    users    TABLE     =  CREATE TABLE public.users (
    id integer NOT NULL,
    username text NOT NULL,
    mail text NOT NULL,
    password text NOT NULL,
    language_id smallint NOT NULL,
    created_timestamp timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "isActive" boolean DEFAULT false NOT NULL,
    firstname text NOT NULL,
    lastname text NOT NULL,
    biography text,
    "picturePath" text,
    "averageTags" numeric(3,2) DEFAULT 0.33,
    "averageFollowing" numeric(3,2) DEFAULT 0.33,
    "averageTrends" numeric(3,2) DEFAULT 0.33,
    gender smallint NOT NULL
);
    DROP TABLE public.users;
       public         heap    postgres    false            ?            1259    16429    users_gender    TABLE     Y   CREATE TABLE public.users_gender (
    id smallint NOT NULL,
    gender text NOT NULL
);
     DROP TABLE public.users_gender;
       public         heap    postgres    false            ?            1259    16434    users_id_seq    SEQUENCE     u   CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.users_id_seq;
       public          postgres    false    219            ?           0    0    users_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;
          public          postgres    false    221            ?            1259    16435 
   users_live    TABLE     V   CREATE TABLE public.users_live (
    user_id bigint NOT NULL,
    stream_name text
);
    DROP TABLE public.users_live;
       public         heap    postgres    false            ?            1259    16440    users_tags_XREF    TABLE     ?   CREATE TABLE public."users_tags_XREF" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    tag_id integer NOT NULL,
    worth smallint NOT NULL,
    date date NOT NULL,
    "time" time with time zone NOT NULL
);
 %   DROP TABLE public."users_tags_XREF";
       public         heap    postgres    false            ?            1259    16443    users_tags_XREF_id_seq    SEQUENCE     ?   CREATE SEQUENCE public."users_tags_XREF_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public."users_tags_XREF_id_seq";
       public          postgres    false    223            ?           0    0    users_tags_XREF_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public."users_tags_XREF_id_seq" OWNED BY public."users_tags_XREF".id;
          public          postgres    false    224            ?            1259    16444    videos    TABLE     ?  CREATE TABLE public.videos (
    id bigint NOT NULL,
    path text NOT NULL,
    length smallint NOT NULL,
    user_id integer NOT NULL,
    descryption text,
    shares integer DEFAULT 0 NOT NULL,
    "enableComments" boolean DEFAULT true NOT NULL,
    "thumbnailPath" text NOT NULL,
    views bigint DEFAULT 0 NOT NULL,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    privacy_id smallint NOT NULL
);
    DROP TABLE public.videos;
       public         heap    postgres    false            ?            1259    16453    videos_liked    TABLE     ?   CREATE TABLE public.videos_liked (
    user_id integer NOT NULL,
    video_id bigint NOT NULL,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
     DROP TABLE public.videos_liked;
       public         heap    postgres    false            ?            1259    16457    video_likes_view    VIEW     ?   CREATE VIEW public.video_likes_view AS
 SELECT count(videos_liked.video_id) AS count,
    videos.id
   FROM (public.videos
     LEFT JOIN public.videos_liked ON ((videos.id = videos_liked.video_id)))
  GROUP BY videos.id;
 #   DROP VIEW public.video_likes_view;
       public          postgres    false    225    226            ?            1259    16461    videos_id_seq    SEQUENCE     v   CREATE SEQUENCE public.videos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.videos_id_seq;
       public          postgres    false    225            ?           0    0    videos_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.videos_id_seq OWNED BY public.videos.id;
          public          postgres    false    228            ?            1259    16462    videos_privacy_modes    TABLE     _   CREATE TABLE public.videos_privacy_modes (
    id smallint NOT NULL,
    mode text NOT NULL
);
 (   DROP TABLE public.videos_privacy_modes;
       public         heap    postgres    false            ?            1259    16467    videos_privacy_modes_id_seq    SEQUENCE     ?   CREATE SEQUENCE public.videos_privacy_modes_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.videos_privacy_modes_id_seq;
       public          postgres    false    229            ?           0    0    videos_privacy_modes_id_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.videos_privacy_modes_id_seq OWNED BY public.videos_privacy_modes.id;
          public          postgres    false    230            ?            1259    16468    videos_tags_XREF    TABLE     e   CREATE TABLE public."videos_tags_XREF" (
    video_id bigint NOT NULL,
    tag_id bigint NOT NULL
);
 &   DROP TABLE public."videos_tags_XREF";
       public         heap    postgres    false            ?            1259    16471    videos_watched    TABLE     ?   CREATE TABLE public.videos_watched (
    video_id bigint NOT NULL,
    user_id integer NOT NULL,
    length smallint NOT NULL,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
 "   DROP TABLE public.videos_watched;
       public         heap    postgres    false            ?           2604    16475    comments id    DEFAULT     j   ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);
 :   ALTER TABLE public.comments ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    210    209            ?           2604    16476    languages id    DEFAULT     l   ALTER TABLE ONLY public.languages ALTER COLUMN id SET DEFAULT nextval('public.languages_id_seq'::regclass);
 ;   ALTER TABLE public.languages ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    214    213            ?           2604    16477    messages id    DEFAULT     j   ALTER TABLE ONLY public.messages ALTER COLUMN id SET DEFAULT nextval('public.messages_id_seq'::regclass);
 :   ALTER TABLE public.messages ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    216    215            ?           2604    16478    tags id    DEFAULT     b   ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);
 6   ALTER TABLE public.tags ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    218    217            ?           2604    16479    users id    DEFAULT     d   ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);
 7   ALTER TABLE public.users ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    221    219            ?           2604    16480    users_tags_XREF id    DEFAULT     |   ALTER TABLE ONLY public."users_tags_XREF" ALTER COLUMN id SET DEFAULT nextval('public."users_tags_XREF_id_seq"'::regclass);
 C   ALTER TABLE public."users_tags_XREF" ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    224    223            ?           2604    16481 	   videos id    DEFAULT     f   ALTER TABLE ONLY public.videos ALTER COLUMN id SET DEFAULT nextval('public.videos_id_seq'::regclass);
 8   ALTER TABLE public.videos ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    228    225            ?           2604    16482    videos_privacy_modes id    DEFAULT     ?   ALTER TABLE ONLY public.videos_privacy_modes ALTER COLUMN id SET DEFAULT nextval('public.videos_privacy_modes_id_seq'::regclass);
 F   ALTER TABLE public.videos_privacy_modes ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    230    229            ?          0    16385    comments 
   TABLE DATA           O   COPY public.comments (id, video_id, user_id, "timestamp", comment) FROM stdin;
    public          postgres    false    209   ?       ?          0    16392    comments_liked 
   TABLE DATA           J   COPY public.comments_liked (comment_id, user_id, "timestamp") FROM stdin;
    public          postgres    false    211   	?       ?          0    16396 	   following 
   TABLE DATA           =   COPY public.following (from_user_id, to_user_id) FROM stdin;
    public          postgres    false    212   ??       ?          0    16399 	   languages 
   TABLE DATA           :   COPY public.languages (id, name, "iso_639-1") FROM stdin;
    public          postgres    false    213   ߊ       ?          0    16405    messages 
   TABLE DATA           y   COPY public.messages (id, from_user_id, message, "timestamp", to_user_id, "unReaded", video_id, record_path) FROM stdin;
    public          postgres    false    215   Ώ       ?          0    16413    tags 
   TABLE DATA           '   COPY public.tags (id, tag) FROM stdin;
    public          postgres    false    217   C?       ?          0    16419    users 
   TABLE DATA           ?   COPY public.users (id, username, mail, password, language_id, created_timestamp, "isActive", firstname, lastname, biography, "picturePath", "averageTags", "averageFollowing", "averageTrends", gender) FROM stdin;
    public          postgres    false    219   *?       ?          0    16429    users_gender 
   TABLE DATA           2   COPY public.users_gender (id, gender) FROM stdin;
    public          postgres    false    220   0?       ?          0    16435 
   users_live 
   TABLE DATA           :   COPY public.users_live (user_id, stream_name) FROM stdin;
    public          postgres    false    222   c?       ?          0    16440    users_tags_XREF 
   TABLE DATA           U   COPY public."users_tags_XREF" (id, user_id, tag_id, worth, date, "time") FROM stdin;
    public          postgres    false    223   ??       ?          0    16444    videos 
   TABLE DATA           ?   COPY public.videos (id, path, length, user_id, descryption, shares, "enableComments", "thumbnailPath", views, "timestamp", privacy_id) FROM stdin;
    public          postgres    false    225   ??       ?          0    16453    videos_liked 
   TABLE DATA           F   COPY public.videos_liked (user_id, video_id, "timestamp") FROM stdin;
    public          postgres    false    226   ֠       ?          0    16462    videos_privacy_modes 
   TABLE DATA           8   COPY public.videos_privacy_modes (id, mode) FROM stdin;
    public          postgres    false    229   9?       ?          0    16468    videos_tags_XREF 
   TABLE DATA           >   COPY public."videos_tags_XREF" (video_id, tag_id) FROM stdin;
    public          postgres    false    231   u?       ?          0    16471    videos_watched 
   TABLE DATA           P   COPY public.videos_watched (video_id, user_id, length, "timestamp") FROM stdin;
    public          postgres    false    232    ?       ?           0    0    comments_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.comments_id_seq', 45458, true);
          public          postgres    false    210            ?           0    0    languages_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.languages_id_seq', 1, true);
          public          postgres    false    214            ?           0    0    messages_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.messages_id_seq', 71, true);
          public          postgres    false    216            ?           0    0    tags_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.tags_id_seq', 95104, true);
          public          postgres    false    218            ?           0    0    users_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.users_id_seq', 11, true);
          public          postgres    false    221            ?           0    0    users_tags_XREF_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public."users_tags_XREF_id_seq"', 133, true);
          public          postgres    false    224            ?           0    0    videos_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.videos_id_seq', 33337, true);
          public          postgres    false    228            ?           0    0    videos_privacy_modes_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.videos_privacy_modes_id_seq', 1, false);
          public          postgres    false    230            ?           2606    16484 "   comments_liked comments_liked_pkey 
   CONSTRAINT     q   ALTER TABLE ONLY public.comments_liked
    ADD CONSTRAINT comments_liked_pkey PRIMARY KEY (comment_id, user_id);
 L   ALTER TABLE ONLY public.comments_liked DROP CONSTRAINT comments_liked_pkey;
       public            postgres    false    211    211            ?           2606    16486    comments comments_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.comments DROP CONSTRAINT comments_pkey;
       public            postgres    false    209            ?           2606    16488    following following_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.following
    ADD CONSTRAINT following_pkey PRIMARY KEY (from_user_id, to_user_id);
 B   ALTER TABLE ONLY public.following DROP CONSTRAINT following_pkey;
       public            postgres    false    212    212            ?           2606    16490    languages languages_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.languages DROP CONSTRAINT languages_pkey;
       public            postgres    false    213            ?           2606    16492    messages messages_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.messages DROP CONSTRAINT messages_pkey;
       public            postgres    false    215            ?           2606    16494    messages messages_record_path 
   CONSTRAINT     _   ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_record_path UNIQUE (record_path);
 G   ALTER TABLE ONLY public.messages DROP CONSTRAINT messages_record_path;
       public            postgres    false    215            ?           2606    16496    tags tags_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.tags DROP CONSTRAINT tags_pkey;
       public            postgres    false    217            ?           2606    16498    tags tags_tag 
   CONSTRAINT     G   ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_tag UNIQUE (tag);
 7   ALTER TABLE ONLY public.tags DROP CONSTRAINT tags_tag;
       public            postgres    false    217            ?           2606    16499 "   users users_check_averageFollowing    CHECK CONSTRAINT     ?   ALTER TABLE public.users
    ADD CONSTRAINT "users_check_averageFollowing" CHECK ((("averageFollowing" >= (0)::numeric) AND ("averageFollowing" <= (1)::numeric))) NOT VALID;
 I   ALTER TABLE public.users DROP CONSTRAINT "users_check_averageFollowing";
       public          postgres    false    219    219            ?           2606    16500    users users_check_averageTags    CHECK CONSTRAINT     ?   ALTER TABLE public.users
    ADD CONSTRAINT "users_check_averageTags" CHECK ((("averageTags" >= (0)::numeric) AND ("averageTags" <= (1)::numeric))) NOT VALID;
 D   ALTER TABLE public.users DROP CONSTRAINT "users_check_averageTags";
       public          postgres    false    219    219            ?           2606    16501    users users_check_averageTrends    CHECK CONSTRAINT     ?   ALTER TABLE public.users
    ADD CONSTRAINT "users_check_averageTrends" CHECK ((("averageTrends" >= (0)::numeric) AND ("averageTrends" <= (1)::numeric))) NOT VALID;
 F   ALTER TABLE public.users DROP CONSTRAINT "users_check_averageTrends";
       public          postgres    false    219    219            ?           2606    16503    users_gender users_gender_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.users_gender
    ADD CONSTRAINT users_gender_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.users_gender DROP CONSTRAINT users_gender_pkey;
       public            postgres    false    220            ?           2606    16505    users_live users_live_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.users_live
    ADD CONSTRAINT users_live_pkey PRIMARY KEY (user_id);
 D   ALTER TABLE ONLY public.users_live DROP CONSTRAINT users_live_pkey;
       public            postgres    false    222            ?           2606    16507    users users_mail 
   CONSTRAINT     K   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_mail UNIQUE (mail);
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT users_mail;
       public            postgres    false    219            ?           2606    16509    users users_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
       public            postgres    false    219            ?           2606    16511 $   users_tags_XREF users_tags_XREF_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public."users_tags_XREF"
    ADD CONSTRAINT "users_tags_XREF_pkey" PRIMARY KEY (id);
 R   ALTER TABLE ONLY public."users_tags_XREF" DROP CONSTRAINT "users_tags_XREF_pkey";
       public            postgres    false    223            ?           2606    16513    users users_username 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username UNIQUE (username);
 >   ALTER TABLE ONLY public.users DROP CONSTRAINT users_username;
       public            postgres    false    219            ?           2606    16515    videos_liked videos_liked_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY public.videos_liked
    ADD CONSTRAINT videos_liked_pkey PRIMARY KEY (user_id, video_id);
 H   ALTER TABLE ONLY public.videos_liked DROP CONSTRAINT videos_liked_pkey;
       public            postgres    false    226    226            ?           2606    16517    videos videos_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.videos
    ADD CONSTRAINT videos_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.videos DROP CONSTRAINT videos_pkey;
       public            postgres    false    225            ?           2606    16519 .   videos_privacy_modes videos_privacy_modes_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.videos_privacy_modes
    ADD CONSTRAINT videos_privacy_modes_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.videos_privacy_modes DROP CONSTRAINT videos_privacy_modes_pkey;
       public            postgres    false    229            ?           2606    16521 &   videos_tags_XREF videos_tags_XREF_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public."videos_tags_XREF"
    ADD CONSTRAINT "videos_tags_XREF_pkey" PRIMARY KEY (video_id, tag_id);
 T   ALTER TABLE ONLY public."videos_tags_XREF" DROP CONSTRAINT "videos_tags_XREF_pkey";
       public            postgres    false    231    231            ?           2606    16523 "   videos_watched videos_watched_pkey 
   CONSTRAINT     o   ALTER TABLE ONLY public.videos_watched
    ADD CONSTRAINT videos_watched_pkey PRIMARY KEY (video_id, user_id);
 L   ALTER TABLE ONLY public.videos_watched DROP CONSTRAINT videos_watched_pkey;
       public            postgres    false    232    232            ?           2606    16524 '   comments_liked comments_liked_commentFK    FK CONSTRAINT     ?   ALTER TABLE ONLY public.comments_liked
    ADD CONSTRAINT "comments_liked_commentFK" FOREIGN KEY (comment_id) REFERENCES public.comments(id) NOT VALID;
 S   ALTER TABLE ONLY public.comments_liked DROP CONSTRAINT "comments_liked_commentFK";
       public          postgres    false    209    3261    211            ?           2606    16529 $   comments_liked comments_liked_userFK    FK CONSTRAINT     ?   ALTER TABLE ONLY public.comments_liked
    ADD CONSTRAINT "comments_liked_userFK" FOREIGN KEY (user_id) REFERENCES public.users(id) NOT VALID;
 P   ALTER TABLE ONLY public.comments_liked DROP CONSTRAINT "comments_liked_userFK";
       public          postgres    false    3279    211    219            ?           2606    16534    comments comments_userFK    FK CONSTRAINT     ?   ALTER TABLE ONLY public.comments
    ADD CONSTRAINT "comments_userFK" FOREIGN KEY (user_id) REFERENCES public.users(id) NOT VALID;
 D   ALTER TABLE ONLY public.comments DROP CONSTRAINT "comments_userFK";
       public          postgres    false    3279    219    209            ?           2606    16539    comments comments_videoFK    FK CONSTRAINT     |   ALTER TABLE ONLY public.comments
    ADD CONSTRAINT "comments_videoFK" FOREIGN KEY (video_id) REFERENCES public.videos(id);
 E   ALTER TABLE ONLY public.comments DROP CONSTRAINT "comments_videoFK";
       public          postgres    false    209    225    3289            ?           2606    16544    following following_from_userFK    FK CONSTRAINT     ?   ALTER TABLE ONLY public.following
    ADD CONSTRAINT "following_from_userFK" FOREIGN KEY (from_user_id) REFERENCES public.users(id) NOT VALID;
 K   ALTER TABLE ONLY public.following DROP CONSTRAINT "following_from_userFK";
       public          postgres    false    212    219    3279            ?           2606    16549    following following_to_userFK    FK CONSTRAINT     ?   ALTER TABLE ONLY public.following
    ADD CONSTRAINT "following_to_userFK" FOREIGN KEY (to_user_id) REFERENCES public.users(id) NOT VALID;
 I   ALTER TABLE ONLY public.following DROP CONSTRAINT "following_to_userFK";
       public          postgres    false    219    3279    212            ?           2606    16554    messages messages_to_userFK    FK CONSTRAINT     ?   ALTER TABLE ONLY public.messages
    ADD CONSTRAINT "messages_to_userFK" FOREIGN KEY (to_user_id) REFERENCES public.users(id) NOT VALID;
 G   ALTER TABLE ONLY public.messages DROP CONSTRAINT "messages_to_userFK";
       public          postgres    false    3279    219    215            ?           2606    16559    messages messages_userFK    FK CONSTRAINT     ?   ALTER TABLE ONLY public.messages
    ADD CONSTRAINT "messages_userFK" FOREIGN KEY (from_user_id) REFERENCES public.users(id) NOT VALID;
 D   ALTER TABLE ONLY public.messages DROP CONSTRAINT "messages_userFK";
       public          postgres    false    3279    219    215            ?           2606    16564    messages messages_videoFK    FK CONSTRAINT     ?   ALTER TABLE ONLY public.messages
    ADD CONSTRAINT "messages_videoFK" FOREIGN KEY (video_id) REFERENCES public.videos(id) NOT VALID;
 E   ALTER TABLE ONLY public.messages DROP CONSTRAINT "messages_videoFK";
       public          postgres    false    3289    225    215            ?           2606    16569    users users_genderfk    FK CONSTRAINT     ?   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_genderfk FOREIGN KEY (gender) REFERENCES public.users_gender(id) NOT VALID;
 >   ALTER TABLE ONLY public.users DROP CONSTRAINT users_genderfk;
       public          postgres    false    220    3283    219            ?           2606    16574    users users_languagefk    FK CONSTRAINT     ?   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_languagefk FOREIGN KEY (language_id) REFERENCES public.languages(id) NOT VALID;
 @   ALTER TABLE ONLY public.users DROP CONSTRAINT users_languagefk;
       public          postgres    false    213    219    3267            ?           2606    16579    users_live users_live_userfk    FK CONSTRAINT     ?   ALTER TABLE ONLY public.users_live
    ADD CONSTRAINT users_live_userfk FOREIGN KEY (user_id) REFERENCES public.users(id) NOT VALID;
 F   ALTER TABLE ONLY public.users_live DROP CONSTRAINT users_live_userfk;
       public          postgres    false    219    3279    222            ?           2606    16584     users_tags_XREF users_tags_tagFK    FK CONSTRAINT     ?   ALTER TABLE ONLY public."users_tags_XREF"
    ADD CONSTRAINT "users_tags_tagFK" FOREIGN KEY (tag_id) REFERENCES public.tags(id) NOT VALID;
 N   ALTER TABLE ONLY public."users_tags_XREF" DROP CONSTRAINT "users_tags_tagFK";
       public          postgres    false    223    3273    217            ?           2606    16589 !   users_tags_XREF users_tags_userFK    FK CONSTRAINT     ?   ALTER TABLE ONLY public."users_tags_XREF"
    ADD CONSTRAINT "users_tags_userFK" FOREIGN KEY (user_id) REFERENCES public.users(id);
 O   ALTER TABLE ONLY public."users_tags_XREF" DROP CONSTRAINT "users_tags_userFK";
       public          postgres    false    3279    219    223            ?           2606    16594     videos_liked videos_liked_userFK    FK CONSTRAINT     ?   ALTER TABLE ONLY public.videos_liked
    ADD CONSTRAINT "videos_liked_userFK" FOREIGN KEY (user_id) REFERENCES public.users(id) NOT VALID;
 L   ALTER TABLE ONLY public.videos_liked DROP CONSTRAINT "videos_liked_userFK";
       public          postgres    false    226    219    3279            ?           2606    16599 !   videos_liked videos_liked_videoFK    FK CONSTRAINT     ?   ALTER TABLE ONLY public.videos_liked
    ADD CONSTRAINT "videos_liked_videoFK" FOREIGN KEY (video_id) REFERENCES public.videos(id) NOT VALID;
 M   ALTER TABLE ONLY public.videos_liked DROP CONSTRAINT "videos_liked_videoFK";
       public          postgres    false    226    225    3289            ?           2606    16604    videos videos_privacyfk    FK CONSTRAINT     ?   ALTER TABLE ONLY public.videos
    ADD CONSTRAINT videos_privacyfk FOREIGN KEY (privacy_id) REFERENCES public.videos_privacy_modes(id) NOT VALID;
 A   ALTER TABLE ONLY public.videos DROP CONSTRAINT videos_privacyfk;
       public          postgres    false    3293    229    225            ?           2606    16609 (   videos_tags_XREF videos_tags_XREF_tagsfk    FK CONSTRAINT     ?   ALTER TABLE ONLY public."videos_tags_XREF"
    ADD CONSTRAINT "videos_tags_XREF_tagsfk" FOREIGN KEY (tag_id) REFERENCES public.tags(id) NOT VALID;
 V   ALTER TABLE ONLY public."videos_tags_XREF" DROP CONSTRAINT "videos_tags_XREF_tagsfk";
       public          postgres    false    217    231    3273            ?           2606    16614 *   videos_tags_XREF videos_tags_XREF_videosfk    FK CONSTRAINT     ?   ALTER TABLE ONLY public."videos_tags_XREF"
    ADD CONSTRAINT "videos_tags_XREF_videosfk" FOREIGN KEY (video_id) REFERENCES public.videos(id) NOT VALID;
 X   ALTER TABLE ONLY public."videos_tags_XREF" DROP CONSTRAINT "videos_tags_XREF_videosfk";
       public          postgres    false    231    3289    225            ?           2606    16619    videos videos_usersfk    FK CONSTRAINT     ~   ALTER TABLE ONLY public.videos
    ADD CONSTRAINT videos_usersfk FOREIGN KEY (user_id) REFERENCES public.users(id) NOT VALID;
 ?   ALTER TABLE ONLY public.videos DROP CONSTRAINT videos_usersfk;
       public          postgres    false    225    3279    219            ?           2606    16624 $   videos_watched videos_watched_userfk    FK CONSTRAINT     ?   ALTER TABLE ONLY public.videos_watched
    ADD CONSTRAINT videos_watched_userfk FOREIGN KEY (user_id) REFERENCES public.users(id) NOT VALID;
 N   ALTER TABLE ONLY public.videos_watched DROP CONSTRAINT videos_watched_userfk;
       public          postgres    false    232    219    3279            ?           2606    16629 %   videos_watched videos_watched_videofk    FK CONSTRAINT     ?   ALTER TABLE ONLY public.videos_watched
    ADD CONSTRAINT videos_watched_videofk FOREIGN KEY (video_id) REFERENCES public.videos(id) NOT VALID;
 O   ALTER TABLE ONLY public.videos_watched DROP CONSTRAINT videos_watched_videofk;
       public          postgres    false    225    3289    232            ?   ?  x?}?Kk1???S?^"F??????&u??%?˚]?S?[?v?~?JrBB?*????Y????.??
?ʠ29D?ړ8?7 ?e?i?aP???7????6"G?@!`??է????۱@_????`?f+??X?M3?*2T A*?}`?yhꐌ ??,??@???p?G?:????U?1h$?R?s?Gu??EI]??:?ON??g?>LE?3?/T?L??2;??]??헾?"]E???v?$d?}???=??*??Đ5???!????%?=??Z'T6???a?e#猸׆??ixѰ&֖ެn??????z??W?w?S??J9 ??ш?70?yue2????E?9???	]?P??t?N;ǖ?w?Nu???ƸK?$g??]??????y?Hf?u?LO?G7m???eL?H??^?[?~T9+?M?n?tO%_$?Jn3'?1.??a?/ g?/??`5Z/P??pJ?~??U߶?????M??/0?      ?   ?   x?e?A?0D?u|??? ??????N%Wi???17?-60p???h????]????TqSV<J?,???՘?b&3ɰղ??r??.?Z?7u?J:!????
\ls=??j?_M"^bV?_????ޓ?=s???G`??y I=0??M??5??|      ?   "   x?3?????4?2?4?2?4a??!W? :??      ?   ?  x?MU?r?F<?|IrpD????ز#?V,ڎS??%??K?????]?XDcfgz?????'?R?s?݋#.?v3r?bH6\???(b<ɞ+??qzK2sM?N6??qC??ˬ?"????y'$g?????F??Mr?lEw??Q;?gݩI\?)?Fq??]?z$I?笠;?r?f?????B?Y????I??	??K?YMk?Q!???5t?T? ????%???;????m????_?v???<??jBk?g?s??v?yA??8?S???C*kwἢ??Hj⼦?????`I!vCχk??-???
T??.??{T?"+zRn??????6˹??"zѴᢠ7??M??[.Jz????????g.jz?R??@ck??y5an????пm??'.:z?J??+?? ????D/4?9??f?i?\t?,?cp\??6?pK?f??;??!???飐F??oi?e?7??e$=r???QKM?p??w[,?oI{?2z??.?????S'?'?
?M??Ԩ᪤oz?K?x?\U0?[c???)?߆?"?@??U?L??H:N\a}d?????۰??1??=Z???r????Yc?G?uA??-$??uI??????x溢?褡I????N?-4!b?CJ7!fc?,}??]:y?y?BHѧ#7+?z?g?{n2@??&??V???8??????扛?~???Kcg?M<???`?M,ǀpP??z?f?M??C?????G?h?|?vE$?HF????:`rd??h1`???mA?;?e?r[???V?Km??V????|????Z?}?3?5=E?Y??7?d?; fKO?B?7O1??B???????C?nED? 6?{?.?O?@>^}???[En?.O?i??ᮠŖ?:?]I??_??|Wsw???w5=CKG?y?7??;??d??%?s??3dӾ??jy??j???A???CW=O????G?|A???'?(s?	?@%=?y?䪢g0G?=tr5?6?:?w?fɿ@(?
ܴ?%%?0???Fp?p?BC?7?G? ??ZV?A?$?N?N??e????%?Մ	P??C????G
P?$??h
?B?ֽKݤ??????F?
1_c?'?S@??g???
A_c?P*=M?J????Ո? ?k|#?M_???!??G'ziPDFh?g??S??>_6???????V?\??Gp?????HG䇪????)???,D?	Y?f]??????A/=?$cE?)?%?߿0????N?      ?   e  x????nG???S??Ȅ_Ù?K?"@zi.)?K?@?6?ڎ?Z6??
?zmO???	?%wY?]????????p???1/??????c?C??鮛??Y׼???  z??!l?????3?7 Z?,޾??y???r?J???!45!D?!?????N? ?Y?[?{?qNP?% ?88??&?}~???r?Dy??Z? @Y???ˏ???f?o?????-? ??q ?Ű7???/Ϻ???$??:?`;r?????h?)"R?ٰ?????64???))$
?~r[Z?jBZ??,??0>LH
ȘJ?Wd7]!Ĭ?????9????0K???8???\??2?R??C?p??Z??p~}q??"?*??F`?O"UZ?@??T1<{p?t??X2T?"O???% (q?Z?9? ??29???O?msޭo^Ԙ??E"V=?<????????U=CZ??Q?T2&W??WWݶy?o??s??$I@+tP?r??????anѺ??U?yN@?8??4vY?' [?? +ݱ?b?^????uƜ?mT??2?0n?ͬ??*TBb?u+?V??s?6X??9?>?^rH??(FL?,ڝ?w?g??M???w??????r????mz??;?[????O?!	?????L???qL?`#??֞?LU?
Ū/KŤ??{?r?`??]???iL%?jf?1??~??)??fZ[ϡ?Z?
?'??z{qq?=b,h?EP?T?m*??E?A???L2??~??ezq?O????b?????0&?j?GW?E????th???,3?N?q?#H9???_?ծ_]?*βH)$?? t????dw?W]??0?%?
M?x?; ?Ӱi_N)??(?R}?<w2????Sr?????H???i?T?z????_+????$?:
:t????
 l\9?2J?`*?)?D?X.?<3D?-??p?'???)MQ?ĩxX??j??z?????X+??~W4?6>?.???vy?m?_wg?W??|??9i?????v????,O4?af?J?>}R:?؜?|`?@?Rl4v??]kd?d??ʓ?f???v?Ԯ???'?(>?.?E"?qH0cW??	r?'?,?i??3v=Ė6?|8y??n?+?????'''?1?      ?   ?   x?5?K??0?uq?߆?e6L0??NB?????ݫ?eYVUZ7?b?N*?4?M????????#?QX t?s??+	*?{?N??C?C??Vc?~6???L?%o?PvkߗUz??????ب?N\ z????mR?????
=???mѶ?恕-?H^b???lp?c???y??Z??)?s?0?꼱l??FY`p???Ar???KGJ~?$?a?      ?   ?  x???On?@???Sx?]?a???Mmٵ?Il??R??`?0?3??E?}/?#ZWr?D?D???????{OGU҈<qS?ꊗ??I?+?9?7?t0Y?@???]>?M?<MFS?A82e?̔??:?~???T??M??!  W?]Q?S0A5??LU?? ??I?vy????!????d2Pr/??ly???g?[??6??%-?sD?e ??sȋ
'?Q??`???vE?6?S??C?T7	5U?1@eO+?[9?2?S˂׸(
?0Ba??,??ZP???zn$??j׻U????G???R˛???vn????}vB4o#?qϭD?fh??{y?x?2???c?Ї?=PШ?F#????4E3?,?@?m,?w???SЕFZ0)?C|0?%?jL??????p?S-Ҏ?5[/҉}???????b6???3nEѦU??4????}?񂧴G	??J і????{7???i&?4CSտd????ZΣ?ftm?+A?dzc#?q?????N      ?   #   x?3??M?I?2?tK?1?8]2?R???b???? {??      ?      x?????? ? ?      ?   $  x???[r?(@?;[??KO$y-??u?@?ݙR??[???I?^?
???????v?B-?????
u????FÅ;??%??:Vm???)qs?u???m??'??????E5O w????FNlG?
??ر?G??e,???~???K?O?CT?y!oY?È@k??a???l2Yݲ
Gk????N?C[??n??uƈ??X#:A???h?-SL?}/m?u?	??h???q@?,/v??XsS?KmɲЭ?~7ڊ???іl?CxS.h㭳}?A6.m?Q;???v???rU?yKj?d??;o?5r?<㝷d?@W??y;o??-????;o?r?*?,/eO??~???o?ˎ,??N?W?????unņ,Y???}???????F?qL?i?b=?=lb+6B?>N??XG?*?B???,??x4??? ??m?D??Dֱk?@Å?:??Zf{???c+֩???????଒????h?????Lٳ?෹%,?4?B?ꖰ??V?dݐF????`??8?=v??f36?S??.??rX??n?r~?Rݍ?8?֭:??'?Zx???h0G???q??k??UWp??jGm?????????i?k0??`w?&k?;w?j??v??mF????+??߷???A?h?K^ª?*q?K^½w??<?S??m?K6f????lI?zD??m;uŲ??SW?????37?tZ?ݙ+֙j???9??)4K<????OV???>?{????O8?q3N??>??VQ?ٟ?ݬ?DU??Y?'??Qm?Y?'?1?Kv??fB?q9???'y??????%???3|r?0?5"Ո?S^?<?d???|???p??]??U?:s?8*}??0???9{fہ
?w?%Ηl???K\???S\????s?6?.Y?2<?v????f?????|??ؖ0f	???;?%?|?ˈ;?%?N?k=i????^?+~??n35%
???|?<?sx?	?պ????,?)O?bn????O?7$?????d^????????_??>???z?!?g????V??:????$??ʾ
????F??[??
?????K	?/)???^?kק??^p?Z?Ӹ????????F??7?OL?D3@\??<]?2?K?7???M??4x?^????g?Ncg0k2d?;????5_y?H?3Xp??X?3?X?????????P?? ??5O#k?\yc?`i0W??p???<???;??ڷ18a??E???;??,/ʮ??c?Z?h%??ҘKgJ?/??_:K]g?M3>/m??ֿJ?p>Ջ~W?G?oD??'?{Z#/ ?????????	?      ?     x????n?F???S?eav?en\?E??? E??@@`lF&,?)%p???"%??Hum?05????搈@'_????~?Ԉ??,??M??5'@?O~?tj?4jUlJ?j?-?M??J?<??l?????s]T?3R?z)???j???r2?љ??h??։?!A?kg??]? 5G?\??`恜?=r?#?^????;$?	$?o?v??=???^?諸??I??V?߿ʪ??m??)\T?`?9G??h??ųx???ƈp???o???j?e]??O??r?j???*???l???N???67&??1i???\???Ks?s??:?C???S}<????P??O??}ۨ?C[}/?bӬ;???z??)NT&?5?9d?KEE??"?E??h?*??eQW??b'????{?ۃ???t?d6j???<N	?Pv??u|,f???˼A??d?????l??{w|??x.????KSi????'3!??>?b}Rg??M&%??M???ԧ?UZC???]?>?????c?~.ۥJ_o??Y:?|*{???e?;S??dRʌ<q?8J?M??J??,Vm?V????/?]	*}[-T????iV*??^?]uW??Gݝ???J?@;?Di1'̂cH+??TPT?}??????????7b?V?t?&L??E"? y??T?t.5(??ta ǐ?A?i??t??#?M?>? =!?8??x?? ?RQ$???Q`7??6??ɋ??2?? ??HrQ.?	3???&?8?#+??*H?T??2ce8?%G?: ]i??"?>J?4M??"?h?D4H?!??#P?fK?cH^f?ீt??#y?9?,0?J?`?D ?(??(ұ?	)??n????|x?t<2?? ?RQ$/?)?l?MD????P?mQ??^*FD ?BƁ??6?iZ?:?@?A[O??8E7?؁cV(;@?A>????v????[?sC[??q#??v?A;?G?oGA?????????[???-dg?n??????㡨?T?ͬ??LA?_?,s@V<?p????:?3up,5C????Ȑ??1????? t.?      ?   S   x?]̻	?0E?ښ?}???>?5K??#8M p??]?????!?Q???????????u2?+????]Q?e??Уn&???       ?   ,   x?3?,(M??L?2?L????/O-*?2?,(?,K,I?????? ??
?      ?   {   x?M?A Dѵ?@??????:&?wo??O???Q?O4?-x?	/{?>p]W??}????e'????.{?????a?????l6c?	c'?s??~~?BW?
]-?"{۳????7??Y?      ?   ;   x?36664?4?4?4202?50?5?T04?25?26ѳ?4160?60?2?3"?.F??? ?     
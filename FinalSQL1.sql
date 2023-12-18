--design of the database: users and videos each stores the main information of users or videos
--  using users_follower, video_coin, video_favorite, video_likes, video_view to connect both site which has been shown in their names
--  danmu table connects the users who sent it and the video it belongs to, also indicate its content and the time in the video it been sent

--users table: mid, name, sex, birthday, level, sign, identity
create table users (
    mid bigint primary key check (mid >0)  ,
    name varchar(30) unique check(char_length(name) >= 1), -- maximum 16, minimum3
    sex varchar(2) check (sex in ('男', '女', '保密')),-- three chooses '男', '女' or '保密'
    birthday varchar(6),
    level int check (level between 0 and 6),-- between 0 and 6
    sign text,
    identity varchar(9) check (identity in ('user', 'superuser')),-- two chooses 'user' or 'superuser'
    coin int check (coin > 0),
    qq bigint,
    wechat varchar(30)
);

--the relationship between user and its follower
--users_follower table: mid(user mid), following(follower mid)
create table users_follower(
    mid bigint,
    follower bigint,
    foreign key (mid) references users  (mid),
    foreign key (follower) references users  (mid),
    primary key (mid,follower)-- ensure that each pair of mid and follower is unique
);

--videos table: BV, title, owner_mid, owner_name, commit_time, review_time, public_time, duration, description, reviewer
create table videos(
    BV varchar(12) check (BV like 'BV__________') primary key , -- restrict length and start with 'BV'
    title varchar(100) check (not null), -- restrict length 100
    owner_mid bigint,
    owner_name varchar(40),--usually appear with mid, put here for efficiancy
    commit_time timestamp not null,
    review_time timestamp check (review_time >= videos.commit_time),-- must after commit_time
    public_time timestamp check (public_time >= videos.review_time),-- must after review_time
    duration int check (duration >= 0),-- the length of the video >= 0s
    description text,
    reviewer bigint,
    foreign key (owner_mid) references users (mid),
    foreign key(owner_name) references users (name),
    foreign key (reviewer) references users (mid)
);

--references tables: video_like, video_coin, video_favorite, video_view
create table video_likes(
    BV varchar(12),
    likes_mid bigint,
    foreign key (BV) references videos (BV),
    foreign key (likes_mid) references users  (mid),
    primary key (BV,likes_mid)
);

create table video_coin(
    BV varchar(12),
    coin_mid bigint,
    foreign key (BV) references videos (BV),
    foreign key (coin_mid) references users  (mid),
    primary key (BV,coin_mid)
);

create table video_favorite(
    BV varchar(12),
    favorite_mid bigint,
    foreign key (BV) references videos (BV),
    foreign key (favorite_mid) references users  (mid),
    primary key (BV,favorite_mid)
);

create table video_view(
    BV varchar(12),
    view_mid bigint,
    view_time int check (view_time >= 0), -- the length of the time the viewer views the video >= 0s
    foreign key (BV) references videos (BV),
    foreign key (view_mid) references users  (mid),
    primary key (BV,view_mid)
);

--danmu table: BV, mid, time, content
create table danmu(
    --adding this Unique identifier, auto-incrementing column to classify them
    danmu_id serial primary key, -- since there can be: in the same video, the same user at the same time sending two or more same content danmus

    BV varchar(12),
    mid bigint,
    time NUMERIC(10, 3) CHECK (time >= 0), -- the time the danmu being sent must above 0, the inputs were all rounded to three decimal places
    content text check (not null), -- danmu can not be null
    postTime timestamp,
    foreign key (BV) references videos (BV),
    foreign key (mid) references users (mid)
);

create table danmu_like(
    danmu_id serial,
    like_mid bigint,
    foreign key (danmu_id) references danmu (danmu_id),
    foreign key (like_mid) references users  (mid),
    primary key (danmu_id,like_mid)
);

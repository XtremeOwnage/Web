---
title: "Gitea - Slow Dashboard"
date: 2024-12-26
tags:
  - Development/Gitea
---

# Gitea - Slow Dashboard

For a few weeks now, I have noticed my Gitea instance takes nearly two minutes to load.

Turns out, when you use gitea for archiving lots of public repos, this will build up many entries in the actions table, which can drastically increase the loading time needed.

To fix this, I made a query & cron job, which removes actions for my "Archive" organization. 

This- fixes the issue.

IF, you aren't archiving/mirroring a lot of repositories, this post will not help you.

<!-- more -->

## The issue

After googling for a bit, I came across [This Issue](https://github.com/go-gitea/gitea/issues/21611#issuecomment-1510428410){target=_blank} for another user who was having issues with slow loading performance.

The issue is, when mirroring a large number of repos, it tracks a large number of actions.

For me- since I use a dedicated organization for my repository archiving/mirror- This is easy to fix. Just delete the associated records for my archive organization.

I took the details from that comment- and made a slightly customized query, which only deletes the actions from a specific organization I use for archiving public repos.

!!! danger
    Make sure you have working backups before you go poking around in your database.

    I am not responsible for you losing data. Take backups.

Here is the resulting query:

``` sql
DELETE a
FROM action a
JOIN user u on u.id = a.user_id
WHERE
  -- This is the name of my organization, which contains all of my public archives.
	u.name = 'ArchiveForks'
  -- Full list of action types: https://github.com/go-gitea/gitea/blob/67103eb2bc3cb73fab2363fda811c43b50ac9d89/models/activities/action.go#L39
  -- ActionMirrorSyncPush                                  // 18
	-- ActionMirrorSyncCreate                                // 19
	-- ActionMirrorSyncDelete                                // 20
	AND a.op_type IN (18, 19, 20);
```

And.... after running the query...

``` bash
MariaDB [gitea]> DELETE a FROM action a JOIN user u on u.id = a.user_id WHERE u.name = 'ArchiveForks' AND a.op_type IN (18, 19, 20);
Query OK, 438029 rows affected (0.540 sec)
```

The issue went away.

### Create "Event"

Originally, I was going to schedule this using CRON.

However, I discovered "Events" in MariaDB. [MariaDB: Events](https://mariadb.com/kb/en/events/){target=_blank}

The TLDR; You can schedule the query to execute directly in the database. This makes it portable. If you backup and restore your database elsewhere- the query/schedule goes with it.

Creating the event, is quite easy.

``` sql
CREATE EVENT delete_archiveforks_actions
ON SCHEDULE EVERY 1 MONTH
STARTS '2024-01-01 00:00:00'
DO
DELETE a
FROM action a
JOIN user u ON u.id = a.user_id
WHERE u.name = 'ArchiveForks'
AND a.op_type IN (18, 19, 20);
```

Full output:

``` bash
git:~# mysql -D gitea
mysql: Deprecated program name. It will be removed in a future release, use '/usr/bin/mariadb' instead
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 448
Server version: 11.4.4-MariaDB Alpine Linux

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [gitea]> CREATE EVENT delete_archiveforks_actions
    -> ON SCHEDULE EVERY 1 MONTH
    -> STARTS '2024-01-01 00:00:00'
    -> DO
    -> DELETE a
    -> FROM action a
    -> JOIN user u ON u.id = a.user_id
    -> WHERE u.name = 'ArchiveForks'
    -> AND a.op_type IN (18, 19, 20);
Query OK, 0 rows affected (0.004 sec)
MariaDB [gitea]> show events;
+-------+-----------------------------+----------------+-----------+-----------+------------+----------------+----------------+---------------------+------+---------+------------+----------------------+----------------------+-----------------------+
| Db    | Name                        | Definer        | Time zone | Type      | Execute at | Interval value | Interval field | Starts              | Ends | Status  | Originator | character_set_client | collation_connection | Database Collation
   |
+-------+-----------------------------+----------------+-----------+-----------+------------+----------------+----------------+---------------------+------+---------+------------+----------------------+----------------------+-----------------------+
| gitea | delete_archiveforks_actions | root@localhost | SYSTEM    | RECURRING | NULL       | 1              | MONTH          | 2024-01-01 00:00:00 | NULL | ENABLED |          1 | utf8mb3              | utf8mb3_general_ci   | utf8mb4_uca1400_as_cs |
+-------+-----------------------------+----------------+-----------+-----------+------------+----------------+----------------+---------------------+------+---------+------------+----------------------+----------------------+-----------------------+
1 row in set (0.003 sec)
```

And, honestly, thats it.

#### Make sure the event scheduler is running

Before- calling it good- DO make sure your events scheduler is running.

``` sql
SHOW PROCESSLIST;

+-----+-----------------+-----------------+-------+---------+------+-----------------------------+------------------+----------+
| Id  | User            | Host            | db    | Command | Time | State                       | Info             | Progress |
+-----+-----------------+-----------------+-------+---------+------+-----------------------------+------------------+----------+
| 441 | event_scheduler | localhost       | NULL  | Daemon  |  372 | Waiting for next activation | NULL             |    0.000 |
| 448 | root            | localhost       | gitea | Query   |    0 | starting                    | SHOW PROCESSLIST |    0.000 |
| 538 | gitea           | localhost:46298 | gitea | Sleep   |    1 |                             | NULL             |    0.000 |
+-----+-----------------+-----------------+-------+---------+------+-----------------------------+------------------+----------+
3 rows in set (0.000 sec)
```

If, you don't see `event_scheduler` then you need to enable it.

``` sql
SET GLOBAL event_scheduler = ON;
```

#### How to delete the event?

If, you wish to delete this event...

``` sql
DROP EVENT delete_archiveforks_actions
```

#### View execution history

This query will give you execution history: `SELECT * FROM INFORMATION_SCHEMA.events\G`

``` sql
MariaDB [gitea]> SELECT * FROM INFORMATION_SCHEMA.events\G
*************************** 1. row ***************************
       EVENT_CATALOG: def
        EVENT_SCHEMA: gitea
          EVENT_NAME: delete_archiveforks_actions
             DEFINER: root@localhost
           TIME_ZONE: SYSTEM
          EVENT_BODY: SQL
    EVENT_DEFINITION: DELETE a
FROM action a
JOIN user u ON u.id = a.user_id
WHERE u.name = 'ArchiveForks'
AND a.op_type IN (18, 19, 20)
          EVENT_TYPE: RECURRING
          EXECUTE_AT: NULL
      INTERVAL_VALUE: 1
      INTERVAL_FIELD: MONTH
            SQL_MODE: STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
              STARTS: 2024-01-01 00:00:00
                ENDS: NULL
              STATUS: ENABLED
       ON_COMPLETION: NOT PRESERVE
             CREATED: 2024-12-26 19:56:48
        LAST_ALTERED: 2024-12-26 19:56:48
       LAST_EXECUTED: NULL
       EVENT_COMMENT:
          ORIGINATOR: 1
CHARACTER_SET_CLIENT: utf8mb3
COLLATION_CONNECTION: utf8mb3_general_ci
  DATABASE_COLLATION: utf8mb4_uca1400_as_cs
1 row in set (0.001 sec)
```
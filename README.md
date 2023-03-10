# acidtmn/nodebb3

[![dockerhub](https://img.shields.io/docker/pulls/acidtmn/nodebb3?label=Docker%20pulls)](https://hub.docker.com/r/acidtmn/nodebb3)
[![GitLab](https://img.shields.io/badge/Sources-GitHub-orange)](https://github.com/acidtmn/nodebb3)
[![paypal](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://#)

A simple Docker image for quick-launching a NodeBB forum.

## Description

This repo contains the files for the automatic build of the Docker image `acidtmn/nodebb3` hosted on [GitLab](https://gitlab.com/acidtmn/nodebb3).

The NodeBB comes with no plugins and the forum data is stored in a [Redis](http://redis.io) within the container.
The Redis is configured for [AOF persistence](http://redis.io/topics/persistence).
Not the fastest but the least chance for data loss on unexpected shutdowns.

### Stay up to date

New releases of the NodeBB image come with a corresponding tag in the repo.


### Tags

- `v3.0.0-beta.2`


Be advised, any other tags are for experimental purpose and might not be runnable.
Best stick to `latest` or a specific version tag.

## Setup

### Create the container

`docker create --name myNodeBB --init --restart always -p 4567:4567 -v nodebb-data:/var/lib/redis -v nodebb-files:/opt/nodebb/public/uploads -v nodebb-config:/etc/nodebb acidtmn/nodebb3`

In this case the container named `myNodeBB` and is bound to local port 4567.
The three volumes are linked to the named volumes `nodebb-data`, `nodebb-files` and `nodebb-config`.
Change things as you like.

### Start the container

`docker start myNodeBB`

On first run, NodeBB will start it's web installer interface.
There you can create your admin account and set things up.
**Switch the database to Redis** and click "Install NodeBB".
When everything is done, click "Launch NodeBB".
The container will restart and the browser switch to the forum.

### Environment Variables

#### Public URL

If your NodeBB forum is accessible via a public URL, it needs to be told about that.
Otherwise some features might break.
WebSockets for example.
Tell NodeBB about it's public URL by setting the `url` environment variable on container creation.
Example: `-e url=https://www.myforum.com:8080`

#### Timezone

Per default, the container uses UTC as timezone.
If you want to specify a different timezone, add `timezone` as ENV on container creation.
Example: `-e timezone=Europe/Moscow`

### Volumes

- `/etc/nodebb` contains NodeBB's `config.json`
- `/var/lib/redis` contains the Redis data
- `/opt/nodebb/public/uploads` contains NodeBB uploads like avatars

## Backup and restore

Save the contents of the three volumes for creating a backup.
To restore, copy the contents back.

## Update to latest version

If you want to update your NodeBB to the latest version, make backups of the volumes first.
After that just stop and remove your current container.
Then recreate it with the `create` command from the install section.
On startup, the container will run a `nodebb upgrade` and thus prepare the database for the new version of NodeBB.

## Restarting

Since NodeBB is started via the `app.js`, restarting from admin panel is disabled.
If you want to, just restart the container.

## Troubleshooting

### Problem

The NodeBB web-client notifies about broken web socket connections and tries to reestablish infinitely.

### Solution

The public URL and port in the `config.json` are not set correctly.
When creating the container, you can set the public URL via `-e url="http://127.0.0.1:4567"`.

### Problem

The web installer tells the database connection cannot be established and/or the container is restarting infinitely.

### Solution

May be you are using preexisting named volumes or host volumes.
If so, make sure redis can access them.
Anyway, fresh named volumes is the preferred way.

### Problem

Something went wrong while updating to a newer version of NodeBB.
Now the forum is broken.

### Solution

- Delete the container.
- Restore the volumes, using the backups you created before updating.
- Create a new container using the `create` command from the install section with a fixed image version.
  - Append the version number of the previously used image to the image name.
  - For example: `nilsramsperger/nodebb:v1.13.0`

### Problem

NodeBB shows an "invalid-event" error after performing updates and installation of the quill editor plugin.
An example is documented here:

- [Invalid-Event when switching editor to quill.](https://community.nodebb.org/topic/15233/cannot-write-post-or-reply-after-1-15-1-16/4)
- [Followup pull request](https://github.com/acidtmn/nodebb3)

### Solution

It is not quite sure, what actually caused the problem.
The following actions solved the issue:

- Make sure only quill **or** markdown and default composer are active.
- Restart server and container

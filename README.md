# nilsramsperger/nodebb

[![dockerhub](https://img.shields.io/docker/pulls/nilsramsperger/nodebb?label=Docker%20pulls)](https://hub.docker.com/r/nilsramsperger/nodebb)
[![GitLab](https://img.shields.io/badge/Sources-GitLab-orange)](https://gitlab.com/nilsramsperger/docker-nodebb)
[![paypal](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.me/NilsRamsperger)

A simple Docker image for quick-launching a NodeBB forum.

## Description

This repo contains the files for the automatic build of the Docker image `nilsramsperger/nodebb` hosted on [DockerHub](https://hub.docker.com/r/nilsramsperger/nodebb/).

The NodeBB comes with no plugins and the forum data is stored in a [Redis](http://redis.io) within the container.
The Redis is configured for [AOF persistence](http://redis.io/topics/persistence).
Not the fastest but the least chance for data loss on unexpected shutdowns.

### Stay up to date

New releases of the NodeBB image come with a corresponding tag in the repo.
You can subscribe the (atom feed)[https://gitlab.com/nilsramsperger/docker-nodebb/-/tags?feed_token=3gGKWx2TxunMet1JQ7QG&format=atom] to be notified about updates.

### Tags

Currently NodeBB has two active branches for v2 and v1.
The image tagged as `latest` is equal to the latest version of the v2 branch.

With the arrival of the v2 branch, the NodeBB team updated it's release policy.
Updates come with a much more high frequency now.
I cannot guarantee that every release will find it's way into a new build of the image.
But I will build an up to date image asap.

#### 2.x.x branch

- `latest`
- `v2.4.1`
- `v2.4.0`
- `v2.3.1`
- `v2.2.5`
- `v2.2.4`
- `v2.2.3`
- `v2.2.0`
- `v2.1.1`
- `v2.1.0`
- `v2.0.1`
- `v2.0.0`

#### 1.x.x branch

- `v1.19.8`
- `v1.19.7`
- `v1.19.6`
- `v1.19.5`
- `v1.19.4`
- `v1.19.2`
- `v1.19.1`
- `v1.19.0`

Be advised, any other tags are for experimental purpose and might not be runnable.
Best stick to `latest` or a specific version tag.

## Setup

### Create the container

`docker create --name myNodeBB --init --restart always -p 4567:4567 -v nodebb-data:/var/lib/redis -v nodebb-files:/opt/nodebb/public/uploads -v nodebb-config:/etc/nodebb nilsramsperger/nodebb`

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

### Attention

I am not sure, if an upgrade from 1.19.x to 2.x.x works well in terms of the DB schema upgrade.
So be sure to backup your volumes in case anything goes awry.

The Web Installer of 1.19.4 leaks the admin password to the log!
Be sure to change it right after a fresh installation.

If an image of version 1.5.x or less is used, the container will not restart on "Launch NodeBB".
The restart must be done manually.

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
Example: `-e timezone=Europe/Brussels`

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
- [Followup pull request](https://github.com/nilsramsperger/docker-nodebb/pull/10)

### Solution

It is not quite sure, what actually caused the problem.
The following actions solved the issue:

- Make sure only quill **or** markdown and default composer are active.
- Restart server and container

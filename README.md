# rizon-docker
This is a automation script that can deploy one or multiple (up to 10) ircd servers, with service and network bots, among other things, on one Linux box. Docker containers are used for this purpose. The object is to provide an easy, simple and fast method to deploy multiple linked servers for testing and development purposes.

## Requirements
* Linux
* Docker
* bash
* TCP ports 6630-6639, 6660-6669, 6697 and 9999 free to use

## Servers supported
As the name of the project suggests, the main focus is servers used in Rizon IRC network.
* **ircd:** 
  - plexus 3
  - plexus 4
* **services:** 
  - anope 1.8 (partial support, not recommended for use)
  - anope 2.0
* **service bots:** 
  - acid
  - moo (WIP)
* **others:** 
  - users (bots that just connect and join channels)

## How to Install and Run
**No installation is required.**

**TL;DR**

1. Copy `config.example.sh` to `config.sh` and change the variable values in the latter according to your needs.

2. Run `./rizon-docker.sh build all`

3. Run `./rizon-docker.sh create all`

4. Run `./rizon-docker.sh start all`

5. Voilà! Now you can open your favorite irc client, and connect using `/server <your_ip> 666x`, where **x** is the index of the ircd server you want to connect to. The ircd servers in your config file are numbered starting from zero, so the first ircd server is listening on port 6660, the second (if any) on port 6661, and so on.

## Full command help for the brave ones
The syntax of the script is:

```rizon-docker.sh <command> <args>```

### Commands:
* **build:** builds the docker images from custom templates and Dockerfiles. Required in the first time to run, and whenever there is any change to `config.sh`.
* **create:** creates the docker containers from the corresponding docker images. You only need to use this command again if you delete the container(s).
* **start:** starts the container(s).
* **stop:** stops the container(s).
* **restart:** you guessed right! It restarts the container(s).
* **delete:** destroy the container(s) and remove them from disk, even if they were still running.
* **shell:** connects you to a shell running inside a container.
* **list:** lists some or all rizon-docker created containers.

### Arguments:
* **all:** everything in `config.sh`, with exception of servers that have index values equal or greater than `$NUMBER_OF_SERVERS`. 
* **server <x>:** where *x* is the server index number in `config.sh`.
* **<servicetype> <x>:** only the *servicetype* belonging to server *x*. *servicetype* can be: ***ircd***, ***services***, ***acid***, ***moo*** and ***users***.

### Config file
Explained by the comments within.

### Examples
* `./rizon-docker.sh build all`
* `./rizon-docker.sh create server 1`
* `./rizon-docker.sh start ircd 3`
* `./rizon-docker.sh stop services 0`
* `./rizon-docker.sh list server 0`
* `./rizon-docker.sh list`

### Various notes
* The `list` command is the only command that can run without arguments, the result being equivalent to `list all`.
* Servicetypes ***services***, ***acid*** and ***moo*** can run only in server 0.
* Only server 0 accepts SSL connections, on ports 6697 and 9999.

## License
BSD license, which can be found in LICENSE file.

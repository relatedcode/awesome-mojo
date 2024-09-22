# MidjourneyAPI

---------------------------------------------------------------------------------------------------------------------------------

## Deployment

1. Update your server address in the config.ini file.

```
host = 11.22.33.44
```

2. Install `paramiko` to use SSH in Python.

```bash
pip3 install paramiko
```

3. For uploading the repo, run the following script.

```bash
python3 utils/reop_upload.py
```

4. To initiate the API, enter one of the following commands.

```bash
sh xdocker/up_dev.sh
sh xdocker/up_live.sh
sh xdocker/up_caddy.sh
```

5. To shut down the API, enter one of the following commands.

```bash
sh xdocker/down_dev.sh
sh xdocker/down_live.sh
sh xdocker/down_caddy.sh
```

---------------------------------------------------------------------------------------------------------------------------------

## Docker

1. Cleanup everything:

```bash
sh xdocker/prune.sh
```

2. Enter into container:

```bash
sh xdocker/enter.sh
```

3. Check the logs:

```bash
sh xdocker/logs.sh midjourney
sh xdocker/logs.sh caddy
```

---------------------------------------------------------------------------------------------------------------------------------

## FastAPI GUI

http://localhost:8080/docs

---------------------------------------------------------------------------------------------------------------------------------

# automate

Nothing special to see here. It's a small effortless (yet?) Lua script handler
to trigger automations based on incoming MQTT events.

## Install (Ubuntu 20.04)

Install dependencies and build required lua modules:

    apt install git libmosquitto-dev mosquitto-clients \
      lua5.3 lua-filesystem luarocks liblua5.3-dev

    luarocks install lua-mosquitto
    luarocks install dkjson

Clone the repo into your `$HOMEDIR` so the systemd service can pull it:

    su -l ubuntu
    git clone git://<your-git-repository>/automate
    exit

Install and enable systemd service:

    cat > /etc/systemd/system/automate.service << "EOF"
    [Unit]
    Description=Lua Home Automation

    [Service]
    WorkingDirectory=/home/ubuntu/automate
    ExecStartPre=git pull
    ExecStart=lua automate.lua
    Restart=always
    User=ubuntu
    Group=ubuntu

    [Install]
    WantedBy=multi-user.target
    EOF

    systemctl enable automate

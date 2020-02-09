FROM debian:stretch

# Prerequisites
RUN apt-get update && apt-get install -y \
	lib32stdc++6 libstdc++6 lib32gcc1 curl rsync && \
	apt-get clean autoclean && \
	apt-get autoremove -y && \
	rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
	useradd -m steam

RUN rm /bin/sh && ln -sf /bin/bash /bin/sh

# Switch to the user
USER steam

# Install SteamCMD
RUN mkdir -p /home/steam/steamcmd && cd /home/steam/steamcmd && \
	curl -o steamcmd_linux.tar.gz "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" && \
	tar zxf steamcmd_linux.tar.gz && \
	mkdir -p /home/steam/csgo-dedicated/ && \
	mkdir -p /home/steam/csgo-override/ && \
	rm steamcmd_linux.tar.gz && echo 2

VOLUME /home/steam/csgo-dedicated
ENV SRCDS_FPSMAX=300 SRCDS_TICKRATE=128 SRCDS_PORT=27015 SRCDS_TV_PORT=27020 \
	SRCDS_MAXPLAYERS=14 SRCDS_TOKEN=0 \
	SRCDS_RCONPW="changeme" SRCDS_PW="changeme" \
	CSGO_DIR="/home/steam/csgo-dedicated" \
	SRCDS_STARTUP_CMDS="+game_type 1 +game_mode 0 +mapgroup mg_armsrace_custom +map de_lake"
EXPOSE 27015 27020 27005 51840

ADD scripts/ /usr/local/bin
RUN /usr/local/bin/csgo-compile-addons.sh

ADD csgo/ /home/steam/csgo-files/ 

CMD /usr/local/bin/csgo-run.sh


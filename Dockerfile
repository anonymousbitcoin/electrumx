FROM python:3.6
# Prepare user
RUN useradd -ms /bin/bash anonuser
WORKDIR /home/anonuser

# Install zcl dependencies
RUN apt-get update
RUN apt-get install -y apt-utils
RUN apt-get install -y libleveldb1 libleveldb-dev
RUN apt-get install -y build-essential pkg-config libc6-dev m4 g++-multilib autoconf libtool ncurses-dev unzip git python zlib1g-dev wget bsdmainutils automake

# Build zcl node daemon
RUN git clone https://github.com/anonymousbitcoin/anon.git
RUN mkdir /home/anonuser/anon_electrum_db
RUN /home/anonuser/anon/anonutil/build.sh 

# Install electrumx dependencies
RUN pip install pylru==1.0.9
RUN pip install aiohttp==1.0.5
RUN pip install x11_hash==1.4
RUN pip install plyvel==0.9

COPY run_electrumx_docker.sh /home/anonuser/run_electrumx_docker.sh
RUN chown -R anonuser:anonuser /home/anonuser/anon_electrum_db /home/anonuser/run_electrumx_docker.sh
RUN chmod 755 /home/anonuser/run_electrumx_docker.sh

USER anonuser
RUN /home/anonuser/anon/anonutil/fetch-params.sh
RUN git clone https://github.com/anonymousbitcoin/electrumx.git
# RUN wget -q https://github.com/z-classic/zclassic/releases/download/Config/zclassic.conf
RUN sed -ie '/^rpcport=8232/a txindex=1 testnet=1' anon.conf

ENTRYPOINT ["/bin/sh", "-c", "/home/anonuser/run_electrumx_docker.sh"]

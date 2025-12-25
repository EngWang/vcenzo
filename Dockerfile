FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /opt

RUN apt update && apt install -y \
    build-essential git curl wget unzip \
    python3 python3-pip \
    golang-go libpcap-dev nmap \
    && apt clean

# -------------------------
# NUCLEI (FIXED PATH)
# -------------------------
RUN git clone https://github.com/projectdiscovery/nuclei.git && \
    cd nuclei/cmd/nuclei && \
    go build && \
    mv nuclei /usr/local/bin/

# -------------------------
# AMASS
# -------------------------
RUN wget https://github.com/owasp-amass/amass/releases/latest/download/amass_linux_amd64.zip && \
    unzip amass_linux_amd64.zip && \
    mv amass_linux_amd64/amass /usr/local/bin/ && \
    rm -rf amass_linux_amd64*

# -------------------------
# FFUF
# -------------------------
RUN git clone https://github.com/ffuf/ffuf && \
    cd ffuf && go build && \
    mv ffuf /usr/local/bin/

# -------------------------
# MASSCAN
# -------------------------
RUN git clone https://github.com/robertdavidgraham/masscan && \
    cd masscan && make && make install

# -------------------------
# OSMEDEUS
# -------------------------
RUN git clone https://github.com/j3ssie/Osmedeus.git && \
    cd Osmedeus && \
    ./install.sh

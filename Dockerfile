FROM debian:trixie-slim
LABEL MAINTAINER="Kyle Bernier"
LABEL Description="KiCad Automation"
LABEL org.opencontainers.image.description="KiCad Automation"
LABEL org.opencontainers.image.source="https://github.com/kylebernier/kicad_auto"

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
COPY dl_deb.py /usr/bin/
COPY kicad_version.py /usr/bin/
COPY debian-backports.sources /etc/apt/sources.list.d/
COPY debconf.conf /etc/
RUN sed -i -e's/ main/ main contrib non-free/g' /etc/apt/sources.list.d/debian.sources  && \
    apt-get update  && \
    apt-get -y install --no-install-recommends git make unrar-free bzip2 librsvg2-bin ghostscript && \
    apt-get -y install --no-install-recommends imagemagick python3-qrcodegen poppler-utils python3-requests python3-xlsxwriter python3-mistune && \
    echo "KiCost Digi-Key plugin dependencies"  && \
    apt -y install --no-install-recommends python3-certifi python3-dateutil python3-inflection python3-openssl python3-pkg-resources python3-requests python3-six python3-tldextract python3-urllib3 && \
    echo "KiCost dependencies"  && \
    apt -y install --no-install-recommends python3-bs4 python3-colorama python3-lxml python3-requests python3-tqdm python3-validators python3-wxgtk4.0 python3-yaml && \
    echo "KiKit dependencies"  && \
    apt -y install --no-install-recommends python3-click python3-commentjson python3-markdown2 python3-numpy openscad python3-shapely && \
    echo "KiAuto dependencies"  && \
    apt -y install --no-install-recommends python3-psutil python3-xvfbwrapper recordmydesktop xdotool xsltproc xclip  && \
    echo "KiDiff dependencies"  && \
    apt -y install --no-install-recommends xdg-utils  && \
    echo "Needed for GitHub, seen on git 2.39.1"  && \
    echo "[safe]" >> /etc/gitconfig && \
    echo "	directory = *" >> /etc/gitconfig && \
    echo '[protocol "file"]' >> /etc/gitconfig && \
    echo '	allow = always' >> /etc/gitconfig && \
    echo "Install Stuff"  && \
    apt-get update  && \
    apt-get -y install --no-install-recommends \
        flake8    \
        python3-pytest python3-pytest-xdist \
        python3-pip python3-wheel python3-setuptools \
        python3-markdown2 \
        diffutils openssh-client \
        x11-utils fluxbox x11vnc wmctrl \
        unzip \
        zbar-tools \
        procps \
        fonts-dejavu \
        xlsx2csv gnome-themes-extra-data && \
    echo "ODBC support (for KiCad 7+) and GIT LFS" && \
    apt-get -y install libodbc2 libsqliteodbc git-lfs && \
    echo "PanDoc w/LaTeX"  && \
    apt-get -y install pandoc texlive-latex-base texlive-latex-recommended && \
    echo "Install Coveralls helpers (KiBot coverage)" && \
    apt-get -y install curl python3-coverage && \
    dl_deb.py set-soft/coveralls-python && \
    apt-get -y install --no-install-recommends ./*.deb && \
    rm *.deb && \
    echo "Install Kicad" && \
    apt-get install -y -t trixie-backports --no-install-recommends \
        kicad \
        kicad-footprints \
        kicad-symbols \
        kicad-templates && \
    echo "Install Kicad Tools" && \
    dl_deb.py INTI-CMNB/KiBoM && \
    dl_deb.py INTI-CMNB/kicad-git-filters && \
    dl_deb.py set-soft/kicost-digikey-api-v3 && \
    dl_deb.py hildogjr/KiCost && \
    dl_deb.py INTI-CMNB/InteractiveHtmlBom && \
    dl_deb.py set-soft/pcbnewTransition && \
    dl_deb.py INTI-CMNB/KiKit --skip kikit-doc && \
    dl_deb.py INTI-CMNB/KiAuto && \
    dl_deb.py INTI-CMNB/kidiff && \
    dl_deb.py INTI-CMNB/KiBot && \
    dpkg -i kicad-git*.deb && \
    dpkg -i kibom*.deb && \
    dpkg -i interactivehtmlbom*.deb && \
    dpkg -i kicost-digi*.deb && \
    dpkg -i kicost_*.deb && \
    dpkg -i python3-pcbnewtransition*.deb && \
    dpkg -i python3-pymeta*.deb python3-pybars*.deb kikit*.deb && \
    dpkg -i kiauto_*.deb && \
    dpkg -i kidiff_*.deb && \
    dpkg -i kibot_*.deb && \
    rm /*.deb && \
    echo "Install Cleanup" && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* /var/cache/debconf/templates.dat-old /var/lib/dpkg/status-old && \
    rm -rf /usr/share/icons/Adwaita/ /*.deb && \
    echo "Start?" && \
    kibot --version | sed 's/.* \([0-9]\+\.[0-9]\+\.[0-9]\+\) .*/\1/' | tr -d '\n' > /etc/kiauto_tag && \
    kicad_version.py >> /etc/kiauto_tag && \
    echo -n _d >> /etc/kiauto_tag && \
    cat /etc/debian_version | tr -d '\n' >> /etc/kiauto_tag

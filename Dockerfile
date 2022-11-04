#
# Build stage
#
FROM pandoc/latex:2.19-ubuntu as build-env

RUN apt-get update && apt-get install -y curl python3 python3-pip

# make slim-jdk
RUN wget https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz -P /tmp/
RUN tar xfvz /tmp/openjdk-11.0.2_linux-x64_bin.tar.gz -C /tmp/
RUN /tmp/jdk-11.0.2/bin/jlink --output /opt/openjdk-11-slim \
    --add-modules java.base,java.datatransfer,java.desktop,java.logging,java.prefs,java.scripting,java.xml

# make plant UML
ENV PLANTUML_VERSION 1.2022.6
RUN mkdir -p /opt/plantuml/ 
RUN curl -L https://sourceforge.net/projects/plantuml/files/plantuml.${PLANTUML_VERSION}.jar/download -o /opt/plantuml/plantuml.jar
RUN echo '#!/bin/bash\n\
    /opt/openjdk-11-slim/bin/java -jar /opt/plantuml/plantuml.jar $@' > /usr/bin/plantuml
RUN chmod a+x /usr/bin/plantuml

# pandoc filters
COPY resources /data/resources
RUN pip3 install --no-cache-dir /data/resources/pandoc_plantuml_filter_tool pandoc-include


#
# Run stage
#   
FROM pandoc/latex:2.19-ubuntu

ARG UID=1000
ARG GID=1000

RUN apt-get update && apt-get install -y python3 graphviz libfreetype6 fontconfig \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN tlmgr list
RUN tlmgr update --self && \
    tlmgr install \
    merriweather \
    fontaxes \
    mweights \
    mdframed \
    needspace \
    sourcesanspro \
    sourcecodepro \
    titling \
    ly1 \
    pagecolor \
    adjustbox \
    collectbox \
    titlesec \
    fvextra \
    pdftexcmds \
    footnotebackref \
    zref \
    fontawesome5 \
    footmisc \
    sectsty \
    koma-script \
    lineno \
    awesomebox \
    background \
    everypage \
    xurl \
    epstopdf \
    wallpaper \
    eso-pic \
    blindtext \
    seqsplit \
    lastpage \
    xpatch

COPY --from=build-env /usr/local/bin/pandoc-plantuml /usr/local/bin/pandoc-plantuml
COPY --from=build-env /usr/local/bin/pandoc-include /usr/local/bin/pandoc-include
COPY --from=build-env /usr/local/lib/python3.10/dist-packages/ /usr/local/lib/python3.10/dist-packages/
COPY --from=build-env /usr/bin/plantuml/ /usr/bin/plantuml
COPY --from=build-env /opt/plantuml/ /opt/plantuml/
COPY --from=build-env /opt/openjdk-11-slim/ /opt/openjdk-11-slim/

ENTRYPOINT [ "pandoc" ]
CMD [ "--help" ]
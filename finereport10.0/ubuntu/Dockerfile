#
# FineReport 10.0 Dockerfile
#
# Version 1.0.1 2019081719

# https://github.com/ysslang/finedocker
# https://www.finereport.com
#

# Pull base image.
FROM ubuntu:18.04

# Pass some arguments
ARG FR10_LINUX_DEPLOY_PACK_URL="https://fine-build.oss-cn-shanghai.aliyuncs.com/finereport/10.0/tomcat/tomcat-linux.tar.gz"
ARG FINEDOCKER_SCRIPT_URL="https://raw.githubusercontent.com/ysslang/FineDocker/master/finedocker.sh"
ARG TZ="Asia/Shanghai"

# Label some informations about this docker image
LABEL \
  maintainer="ysslang@qq.com" \
  description="With this image, you can easily run a FineReport10.0 by using command 'docker run -d -p8080:8080 ysslang/finedocker'" 

# Set some environment variables
ENV \
  TZ=$TZ \
  LANG=C.UTF-8 \
  JAVA_HOME=/0/tomcat/jre/ \
  CATALINA_HOME=/0/tomcat/ \
  PATH="/0/tomcat/jre/bin:/0/tomcat/bin:$PATH" \
  HEALTH_CHECK_URL="http://localhost:8080/webroot/decision/system/health" \
  HEALTH_CHECK_PATTERN="{\"data\":\"OK\"}"

# Create work directory
WORKDIR /0/

# Deploy FineReport 10
RUN set -eux; \
  \
## Handle timezone
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime; \
  echo $TZ > /etc/timezone; \
  \
## Install some necessary packages
  apt-get update -qq; \
  apt-get install -y -qq --no-install-recommends \
                  gosu \
                  curl \
                  wget \
                  tzdata \
                  iproute2 \
                  fontconfig \
                  lsb-release \
  > /dev/null; \
  rm -rf /var/lib/apt/lists/*; \
  \
## Add FineReport 10.0 deployment package, with jre and tomcat, and add finedocker script
  wget --no-check-certificate --no-verbose -O /0/tomcat-linux.tar.gz $FR10_LINUX_DEPLOY_PACK_URL; \
  wget --no-check-certificate --no-verbose -O /0/finedocker.sh $FINEDOCKER_SCRIPT_URL; \
  \
## Unpack FineReport 10.0 package
  tar xzf tomcat-linux.tar.gz; \
  rm tomcat-linux.tar.gz; \
  mv tomcat-linux tomcat; \
  \
## Handle permission issues
  chown root:root -R .; \
  chmod +x  finedocker.sh \
            tomcat/bin/*.sh \
            tomcat/jre/bin/* \
            tomcat/webapps/webroot/WEB-INF/assist/phantomjs/*linux*/bin/*; \
## Precreate some folders and links
  mkdir -p  /0/tomcat/jre/lib/fonts/fallback \
            /0/links; \
  ln -fnrs  finedocker.sh tomcat/bin/finedocker.sh; \
  ln -fns   ~/.FineReport100 ./links/; \
  ln -fnrs  tomcat/bin/catalina.sh \
            tomcat/bin/startup.sh \
            tomcat/bin/shutdown.sh \
            tomcat/conf/ \
            tomcat/conf/server.xml \
            tomcat/jre/ \
            tomcat/jre/lib/fonts/ \
            tomcat/logs/ \
            tomcat/temp/ \
            tomcat/webapps/ \
            tomcat/webapps/webroot/ \
            tomcat/webapps/webroot/help \
            tomcat/webapps/webroot/WEB-INF/ \
            tomcat/webapps/webroot/WEB-INF/classes \
            tomcat/webapps/webroot/WEB-INF/embed/finedb \
            tomcat/webapps/webroot/WEB-INF/config \
            tomcat/webapps/webroot/WEB-INF/lib/ \
            tomcat/webapps/webroot/WEB-INF/plugins/ \
            tomcat/webapps/webroot/WEB-INF/reportlets/ \
            tomcat/webapps/webroot/WEB-INF/resources/ \
            tomcat/webapps/webroot/WEB-INF/schedule/ \
            tomcat/webapps/webroot/WEB-INF/web.xml \
            ./links/

# Mount writable layer as volume
VOLUME [ "/0/tomcat/" ]

# Check FineReport 10.0 working status
HEALTHCHECK --interval=3m --timeout=3s --start-period=3m --retries=3 \
  CMD curl $HEALTH_CHECK_URL -s | grep $HEALTH_CHECK_PATTERN -q || exit 1

# Expose HTTP port and WebSocket port
EXPOSE 8080
EXPOSE 38888

# Define default command and running mode
ENTRYPOINT ["sh", "finedocker.sh"]
CMD ["run"]

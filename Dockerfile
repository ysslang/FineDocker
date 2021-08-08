#
# FineReport 10.0 Dockerfile
#
# Version 2.0.1 20210809

# https://github.com/ysslang/FineDocker
# https://www.finereport.com
#

# Pull base image.
FROM ubuntu

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
  JAVA_HOME=/opt/tomcat/jdk/jre/ \
  CATALINA_HOME=/opt/tomcat/ \
  PATH="/opt/tomcat/jdk/bin:/opt/tomcat/jdk/jre/bin:/opt/tomcat/bin:$PATH" \
  HEALTH_CHECK_URL="http://localhost:8080/webroot/decision/system/health" \
  HEALTH_CHECK_PATTERN="\"level\":\"HEALTH\""

# Deploy FineReport 10
RUN set -eux; \
  \
## Handle timezone
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime; \
  echo $TZ > /etc/timezone; \
  \
## Change apt sources to USTC
  sed -i 's/httpredir.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list; \
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
                  ca-certificates \
  > /dev/null; \
  rm -rf /var/lib/apt/lists/*; \
  \
## Add FineReport 10.0 deployment package, with jre and tomcat, and add finedocker script
  cd /opt; \
  wget --no-check-certificate --no-verbose -O /opt/tomcat-linux.tar.gz $FR10_LINUX_DEPLOY_PACK_URL; \
  wget --no-check-certificate --no-verbose -O /opt/finedocker.sh $FINEDOCKER_SCRIPT_URL; \
  \
## Unpack FineReport 10.0 package
  tar xzf tomcat-linux.tar.gz; \
  rm tomcat-linux.tar.gz; \
  mv tomcat-linux tomcat; \
  mv finedocker.sh tomcat/bin/; \
  \
## Handle permission issues
  chown root:root -R .; \
  chmod +x  tomcat/bin/*.sh \
            tomcat/jdk/bin/* \
            tomcat/jdk/jre/bin/* \
            tomcat/webapps/webroot/WEB-INF/assist/*/bin/*; 


# Create work directory
WORKDIR /opt/tomcat/bin

# Mount writable layer as volume
VOLUME [ "/opt/tomcat/" ]

# Check FineReport 10.0 working status
HEALTHCHECK --interval=1m --timeout=5s --start-period=10m --retries=3 \
  CMD curl $HEALTH_CHECK_URL -s | grep $HEALTH_CHECK_PATTERN -q || exit 1

# Expose HTTP port and WebSocket port
EXPOSE 8080
EXPOSE 38888

# Define default command and running mode
ENTRYPOINT ["sh", "finedocker.sh"]
CMD ["run"]

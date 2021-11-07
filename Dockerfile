FROM httpd:2.4.51-alpine

ARG MOD_PERL_VERSION=2.0.11

RUN apk add --no-cache gettext \
    && apk add --no-cache --virtual .build-dependencies apr-dev apr-util-dev gcc libc-dev make wget perl-dev \
    && cd /tmp \
    && wget https://dlcdn.apache.org/perl/mod_perl-${MOD_PERL_VERSION}.tar.gz \
    && tar xf mod_perl-${MOD_PERL_VERSION}.tar.gz \
    && cd mod_perl-${MOD_PERL_VERSION} \
    && perl Makefile.PL MP_APXS=/usr/local/apache2/bin/apxs MP_APR_CONFIG=/usr/bin/apr-1-config --cflags --cppflags --includes \
    && make -j4 \
    && mv src/modules/perl/mod_perl.so /usr/local/apache2/modules/ \
    && echo 'LoadModule perl_module modules/mod_perl.so' >> /usr/local/apache2/conf/httpd.conf \
    && echo 'Include conf/awstats_httpd.conf' >> /usr/local/apache2/conf/httpd.conf \
    && cd .. \
    && rm -rf ./mod_perl-${MOD_PERL_VERSION}* \
    && apk del --no-cache .build-dependencies
#RUN sed -i  -e 's/^#\(Include .*httpd-ssl.conf\)/\1/'  conf/httpd.conf

ARG TZDATA_VERSION=2021e-r0
ARG AWSTATS_VERSION=7.8-r1

RUN apk add --no-cache awstats=${AWSTATS_VERSION} tzdata=${TZDATA_VERSION}

COPY awstats.*.conf /etc/awstats/
COPY extra.conf /etc/awstats/
COPY default.conf /etc/awstats/
COPY site.httpd.conf /usr/local/apache2/conf/awstats_httpd.conf
COPY entrypoint.sh /usr/local/bin/

ENV AWSTATS_CONF_LOGFILE="/log/access.log"
ENV AWSTATS_CONF_LOGFORMAT="%host %other %logname %time1 %methodurl %code %bytesd %refererquot %uaquot %other %extra1 %extra2 %extra3"
ENV AWSTATS_CONF_SITEDOMAIN="ibworks.com.br"
ENV AWSTATS_CONF_HOSTALIASES="localhost 127.0.0.1 REGEX[^.*$]"
ENV AWSTATS_CONF_INCLUDE="."

ENTRYPOINT ["entrypoint.sh"]
CMD ["httpd-foreground"]

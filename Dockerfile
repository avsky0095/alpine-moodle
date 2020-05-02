FROM erseco/alpine-php7-webserver

MAINTAINER Ernesto Serrano <info@ernesto.es>

USER root
COPY --chown=nobody config/ /

# crond needs root, so install dcron and cap package and set the capabilities
# on dcron binary https://github.com/inter169/systs/blob/master/alpine/crond/README.md
RUN apk add --no-cache dcron libcap ghostscript && \
    chown nobody:nobody /usr/sbin/crond && \
    setcap cap_setgid=ep /usr/sbin/crond

# Install moosh-cli and its depends
ENV MOOSH_URL=https://github.com/tmuras/moosh/archive/master.tar.gz

RUN apk add --no-cache php7-xmlwriter php7-posix ncurses postgresql-client && \
    mkdir -p /var/www/moosh/ && \
    curl --location $MOOSH_URL | tar xz --strip-components=1 -C /var/www/moosh/ && \
    apk add --no-cache --virtual .build-deps composer git && \
    cd /var/www/moosh/ && \
    composer install --no-ansi --no-dev --no-interaction --no-plugins --no-progress --no-scripts --no-suggest --optimize-autoloader && \
    apk del .build-deps

USER nobody

# Change MOODLE_38_STABLE for new versions
ENV MOODLE_URL=https://github.com/moodle/moodle/archive/MOODLE_38_STABLE.tar.gz \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    SITE_URL=http://localhost \
    DB_TYPE=pgsql \
    DB_HOST=postgres \
    DB_PORT=5432 \
    DB_NAME=moodle \
    DB_USER=moodle \
    DB_PASS=moodle \
    DB_PREFIX=mdl_ \
    SSLPROXY=false \
    MOODLE_EMAIL=user@example.com \
    MOODLE_LANGUAGE=en \
    MOODLE_SITENAME=New-Site \
    MOODLE_USERNAME=moodleuser \
    MOODLE_PASSWORD=PLEASE_CHANGEME \
    SMTP_HOST=smtp.gmail.com \
    SMTP_PORT=587 \
    SMTP_USER=your_email@gmail.com \
    SMTP_PASSWORD=your_password \
    SMTP_PROTOCOL=tls \
    MOODLE_MAIL_NOREPLY_ADDRESS=noreply@localhost \
    MOODLE_MAIL_PREFIX=[moodle]

RUN curl --location $MOODLE_URL | tar xz --strip-components=1 -C /var/www/html/


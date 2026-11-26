FROM ruby:2.6-slim

ENV LANG=C.UTF-8 \
    BUNDLER_VERSION=1.17.3 \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    RAILS_SERVE_STATIC_FILES=true

# Debian 11 (the last base image for Ruby 2.6) is end of life, so its
# packages are only served from archive.debian.org.
# nodejs: ExecJS runtime for uglifier and coffee-script.
# libxrender1 ... fonts-dejavu-core: shared libraries and fonts for wkhtmltopdf.
RUN printf '%s\n' \
    'deb http://archive.debian.org/debian bullseye main' \
    'deb http://archive.debian.org/debian bullseye-updates main' \
    'deb http://archive.debian.org/debian-security bullseye-security main' \
    > /etc/apt/sources.list \
  && apt-get update -qq \
  && apt-get install -y --no-install-recommends \
    build-essential \
    libsqlite3-dev \
    libpq-dev \
    nodejs \
    libxrender1 \
    libfontconfig1 \
    libxext6 \
    libjpeg62-turbo \
    libpng16-16 \
    libssl1.1 \
    fonts-dejavu-core \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v "$BUNDLER_VERSION" --no-document \
  && bundle "_${BUNDLER_VERSION}_" install \
  && bundle exec wkhtmltopdf --version

COPY . .

RUN groupadd --system ldws \
  && useradd --system --gid ldws --create-home --home-dir /home/ldws ldws \
  && mkdir -p tmp/pids log storage \
  && chown -R ldws:ldws tmp log db storage
USER ldws

EXPOSE 3000

ENTRYPOINT ["bin/docker-entrypoint"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]

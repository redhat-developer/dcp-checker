FROM centos:7.3.1611
MAINTAINER ihamilto@redhat.com

RUN yum install -y  epel-release gcc gcc-c++ git libcurl-devel libffi-devel libtool libxml2 libxml2-devel libxslt \
    libxslt-devel libyaml-devel openssl-devel patch readline-devel ruby-devel tar which wget make && yum clean all

# install ruby and rubygems
WORKDIR /tmp
RUN wget http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.2.tar.gz \
    && tar -xzf /tmp/ruby-2.1.2.tar.gz \
    && cd ruby-2.1.2/ \
    && ./configure --disable-install-doc \
    && make \
    && make install \
    && rm -rf /tmp/*

RUN wget http://rubygems.org/rubygems/rubygems-2.6.13.tgz \
    && tar -zxf /tmp/rubygems-2.6.13.tgz \
    && cd /tmp/rubygems-2.6.13 \
    && ruby setup.rb \
    && rm -rf /tmp/* \
    && echo "gem: --no-ri --no-rdoc" > ~/.gemrc

RUN gem install bundler --version 1.16.1 --no-rdoc --no-ri

COPY Gemfile Gemfile.lock ./
RUN bundle install -j 10

RUN groupadd -g 1000 rhd-dcp-checker
RUN useradd -g rhd-dcp-checker -m -s /bin/bash -u 1000 rhd-dcp-checker
USER rhd-dcp-checker
WORKDIR /home/rhd-dcp-checker

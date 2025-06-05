FROM jekyll/jekyll:latest AS build

# 设置时区
ENV TZ=Asia/Shanghai

# 设置 RubyGems 镜像
RUN gem sources --add https://mirrors.aliyun.com/rubygems/ --remove https://rubygems.org/



# 安装时区数据
RUN apk add --no-cache tzdata

WORKDIR /srv/jekyll

ADD . /srv/jekyll

# 设置 Linux 平台标识
ENV BUNDLE_FORCE_RUBY_PLATFORM=1

# 确保所有 gem 命令都在 RUN 指令中
RUN gem install bundler:2.5.23 && \
    chmod -R 777 /srv/jekyll && \
    gem uninstall sass --all --executables --force || true && \
    gem install sassc && \
    gem install jekyll-sass-converter -v '~> 2.0' && \
    rm -rf /srv/jekyll/.jekyll-cache /srv/jekyll/.sass-cache || true

# 确保所有 bundle 命令也在 RUN 指令中
RUN bundle _2.5.23_ config set mirror.https://rubygems.org https://mirrors.aliyun.com/rubygems/ && \
    bundle _2.5.23_ config set force_ruby_platform true && \
    bundle _2.5.23_ install
RUN chown -R jekyll:jekyll /srv/jekyll && \
    chmod -R 755 /srv/jekyll

USER jekyll

ARG build_command
ENV BUILD_COMMAND=${build_command}

CMD ["sh", "-c", "${BUILD_COMMAND}"]

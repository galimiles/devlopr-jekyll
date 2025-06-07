---
layout: post
title:  "Docker 部署jekyll个人博客"
summary: 暗黑模式的程序员主题 
author: miles
date: '2025-06-07 06:35:23 +0530'
category: docker 
thumbnail: /assets/img/posts/code.jpg
keywords: debian jekyll, how to use devlopr, devlopr, how to use devlopr-jekyll, devlopr-jekyll docker,best jekyll themes
usemathjax: true
permalink: /blog/2025-06-07-jekyllsupport/
---
[toc]
# 创建文件目录
```
cd /data
mkdir -p jekyll
cd jekyll
chown -R 1000:1000 .
# 从github仓库中迁出代码到目录中
git clone git@github.com:galimiles/devlopr-jekyll.git .


```
# 编写docker-compose.yml文件
```
vim docker-compose.yml

services:
  jekyll:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        build_command: "bundle exec jekyll serve --host 0.0.0.0 --port 4000 --watch --trace"
    volumes:
      - ".:/srv/jekyll"
    ports:
      - "4000:4000"
      - "35729:35729"
    environment:
      - JEKYLL_ENV=production
    networks:
      - app
networks:
  app:
    name: app
    external: true

```
## 创建本地构建的dockerfile
```

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

```
## _config.yml
```
sass:
  sass_dir: _sass
  style: compressed
```

## Gemfile
```
#source "https://rubygems.org"
source "https://mirrors.aliyun.com/rubygems/"


gem 'bundler', '~> 2.5.15'
gem 'faraday-retry'
gem 'backports', '~> 3.25.0'
gem 'kramdown'
gem 'puma'
gem 'csv'
gem 'base64'

# If you want to use GitHub Pages, remove the "gem "jekyll"" above and
# uncomment the line below. To upgrade, run `bundle update github-pages`.
# gem "github-pages", group: :jekyll_plugins
# you can read more about it here
# https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/about-github-pages-and-jekyll
# https://pages.github.com/versions/

# Plugins
group :jekyll_plugins do
    # gem 'devlopr', '~> 0.4.5'
    gem 'jgd', '~> 1.14.0'
    gem 'jekyll-feed', '~> 0.17.0'
    gem 'jekyll-paginate', '~> 1.1.0'
    gem 'jekyll-gist', '~> 1.5.0'
    gem 'jekyll-seo-tag', '~> 2.8.0'
    gem 'jekyll-sitemap', '~> 1.4.0'
    gem 'sass', '~> 3.7.4'
    gem 'jekyll', '~> 4.2.2'
    gem 'jekyll-sass-converter', '~> 2.2.0'
    # gem 'jekyll-admin', '~> 0.11.1'
end


# Windows and JRuby does not include zoneinfo files, so bundle the tzinfo-data gem
# and associated library.
#install_if -> { RUBY_PLATFORM =~ %r!mingw|mswin|java! } do
#  gem "tzinfo", "~> 2.0"
#  gem "tzinfo-data"
#end

# Performance-booster for watching directories on Windows
#gem "wdm", "~> 0.1.1", :install_if => Gem.win_platform?
gem "webrick", "~> 1.7"

```

## 部署发布运行
```
docker compose  up --build --remove-orphans -d
#开发者模式用
docker compose -f docker-compose-dev.yml up --build --remove-orphans -d

```




### 说明 
官方的镜像jekyll/jekyll:latest 中bundle （2.3.x） 版本低
必须安装 EXACT 匹配版本的 Bundler -v 2.5.23（重要！）
所有 bundle 命令使用 bundle _2.5.23_ 语法指定版本

## 使用本地构建的镜像部署
```
services:
  jekyll:
    #image: jekyll/jekyll:latest
    build: .
    container_name: jekyll
    ports:
      - "4000:4000"
    volumes:
      - ./site:/srv/jekyll
      - gem_cache:/usr/local/bundle  # 添加 gem 缓存卷
    # 指定用户和权限设置
    user: "1000:1000"  # jekyll 用户的 UID:GID
    working_dir: /srv/jekyll
    command: >
      sh -c "bundle _2.5.15_ exec jekyll serve --host 0.0.0.0 --port 4000 --force_polling --watch"
      #      sh -c "gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/ &&
      #             bundle config mirror.https://rubygems.org https://gems.ruby-china.com &&
      #             bundle install --retry 3 --jobs=4 &&
      #             bundle exec jekyll serve --192.168.101.222 --port 4000 --force_polling --watch"
      #

volumes:
  gem_cache:  # 定义 gem 缓存卷
    driver: local
    driver_opts:
      type: 'none'
      o: 'bind'
      device: './.gem-cache'  # 本地缓存目录


```
# 启动容器
```
docker compose up -d

docker exec -it jekyll /bin/bash
apk add --no-cache build-base libxml2-dev libxslt-dev curl tar gzip
bundle config set force_ruby_platform true
bundle config set --local path '/usr/local/bundle'
bundle install --retry 3 --jobs=4

```

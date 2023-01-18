# starseeker

**Seek your following's stars!**

http://starseeker.so

## Requirements

* Git    (>= 2.0.0)
* Docker (>= 2.1.0)

## Setup

``` sh
$ git clone git://github.com:tricknotes/starseeker.git
$ cd starseeker
$ docker compose run --rm app bundle install
$ docker compose run --rm app rails db:create db:migrate
```

Initialize stub data for **local development**.
``` sh
$ docker compose run --rm -e GITHUB_LOGIN="your github account" app rails db:seeds_stub_event
```

Setup environment variables that are described in `docker-compose.yml`.

And run:
``` sh
$ docker compose up -d app
```

## Tasks

Schedule users as to be sent mail:
``` sh
$ docker compose run --rm app rails schedule_sending_hot_repositories
```

Send daily hot repositories mail to scheduled users:
``` sh
$ docker compose run --rm app rails send_hot_repositories
```

Refresh repository data for chache:
``` sh
$ docker compose run --rm app rails fetch_repositories
```

Update user account info:
``` sh
$ docker compose run --rm rails update_account_info
```

## Test

``` sh
$ docker compose run --rm -e RAILS_ENV=test app rails db:migrate
$ docker compose run --rm app bundle exec rspec
```

## License

(The MIT License)

Copyright (c) 2012- Ryunosuke SATO &lt;tricknotes.rs@gmail.com&gt;
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

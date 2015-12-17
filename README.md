# starseeker

**Seek your following's stars!**

http://starseeker.so

## Requirements

* Ruby    (2.2.4)
* MongoDB (>= 2.6.0)
* Redis   (>= 3.0.0)
* Bundler (>= 1.10.0)

## Setup

``` sh
$ git clone git://github.com:tricknotes/starseeker.git
$ cd starseeker
$ bundle install
$ rake db:create db:migrate
```

Initialize stub data for **local development**.
``` sh
$ GITHUB_LOGIN="your github account" rake db:seeds_stub_event
```

Edit config:
``` sh
$ cp config/settings.yml.example config/settings.yml
```

Write your settings to `config/settings.yml`

And run:
``` sh
$ rails server
```

## Tasks

Schedule users as to be sent mail:
``` sh
$ rake schedule_sending_hot_repositories
```

Send daily hot repositories mail to scheduled users:
``` sh
$ rake send_hot_repositories
```

Refresh repository data for chache:
``` sh
$ rake fetch_repositories
```

Update user account info:
``` sh
$ rake update_account_info
```

## Test

``` sh
$ rake
```

## License

(The MIT License)

Copyright (c) 2012-2014 Ryunosuke SATO &lt;tricknotes.rs@gmail.com&gt;
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Stethoscope

Stethoscope is Rack Middleware that provides heartbeats for your application.  Heartbeats are used to check that your application is functioning correctly.

Typically, a tool like Nagios will monitor a heartbeat URL which will return a 200 OK status if everything is ok, or a 500 response for any issues.

## Usage

### Rack

    use Stethoscope
    run MyApp

### Rails 2

    # config/environment.rb
    config.middleware.use Stethoscope

### Rails 3

Just require Stethoscope in your application. Stethoscope has a Railtie that will configure Stethoscope to work.

## Customizing Stethoscope

### Heartbeat URL

Default: `/heartbeat`

    Stethoscope.url = "/some/custom/path"

### Checks

Stethoscope uses _checks_ to check some component of the application.  A check is simply a block that is executed when the heartbeat url is hit.

You don't need any checks.  If you don't include one, Stethoscope will respond if the application is running.

If you do want to check some other pieces of your stack, checks is where it's at.

A response hash is made available to store any information which is then made available to the heartbeat template.

Returning a response _:status_ outside 200..299 will trigger Stethoscope to return a 500 status code to the client.



#### Example

    Stethoscope.check :database do |response|
      ActiveRecord::Base.connection.execute('select 1')
    end

    Stethoscope.check :some_service do |response|
      start   = Time.now
      response['result']    = SomeSerivce.check_availability!
      response['Ping Time'] = Time.now - start
      response[:status]     = 245 # Any status outside 200..299 will result in a 500 status being returned from the heartbeat
    end

Any exceptions are caught and added to the response with the _:error_ key.  The template can then handle them appropriately

Checks can be placed into buckets to target specific checks.

    Stethoscope.check :database, :critical, :quick do |response|
      ActiveRecord::Base.connection.execute("select 1")
    end

    Stethoscope.check :something_big, :critical, :expensive do |response|
      do_something_expensive
    end

Now you have the put into buckets, you can choose which checks you want to execute. By default, all check are performed, but if you want to check only one type of check (all the checks in a given bucket) then you can just append the bucket name onto the url.

#### Example

    curl http://my.awesomeapp.com/heartbeat/critical.json # check the critical checks only
    curl http://my.awesomeapp.com/heartbeat/quick.json    # check the quick checks only
    curl http://my.awesomeapp.com/heartbeat.json          # check all the things

#### Defaults

* ActiveRecord
  * Check name - :database
  * require 'stethoscope/checks/active\_record'
  * Included if the ActiveRecord constant is present in Rails 3
* DataMapper
  * Check name - :database
  * require 'stethoscope/checks/data\_mapper'
  * Included if the DataMapper constant is present in Rails 3
* Mongoid 2.x
  * Check name - :database
  * require 'stethoscope/checks/mongoid2'
  * Included if the Mongoid constant is present in Rails 3
* Mongoid 3.x
  * Check name - :database
  * require 'stethoscope/checks/mongoid'
  * Included if the Mongoid and Moped constants are present in Rails 3

### Template

Stethoscope uses [Tilt](http://github.com/rtomayko/tilt) to render a template for the heartbeat response

By default, Stethoscope provides a simple template to render the responses of the checks in the _lib/stethoscope/template.erb_ file.

You can overwrite the template used:

    Stethoscope.template = Tilt.new("my_new_tempalte_file.haml")


## Testing

_How do I run the project's automated tests?_

### Run Tests

* `bundle exec rake test`

## Contributing changes

* Fork it.
* Create a branch (git checkout -b my_changes)
* Commit your changes (git commit -am "Added Some Changes")
* Push to the branch (git push origin my_changes)
* Open a Pull Request
* Enjoy a refreshing Dr. Pepper© and wait

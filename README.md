# Awslive::Poster
[![Gem Version](https://badge.fury.io/rb/awslive-poster.svg)](https://badge.fury.io/rb/awslive-poster)

Welcome to your awslive-poster gem!. 
Currently there is no easy and cost effective way to get the poster image URL for a AWS medialive channel.
This utility auto computes the poster URL for a AWS media channel and creates a presigned URL to access poster image.

## High-Level System View

![alt text](https://github.com/cloudaffair/awslive-poster/blob/master/misc/highlevel-view.png)

* `1` Cloudwatch Events pushed for Channel State change.
* `2` Cloudwatch Rule for channel state change triggers Channel monitor Lambda
* `3` Lambda identifies the channel Id and its start Time.
* `4` Records the Start time of the channel in a Media channel Tag with name `channel_start_time`

* `Z` Media Channel is configured for a framecapture output group that pushes the captured images onto configured S3 bucket

* `A` `aws-poster` gem when invoked for `get_url`, inspects the channel and identifies the channel start time using the tag `channel_start_time` provisioned.
* `B` Once the start time is identified, `aws-poster` gem computes the sequential counter and constructs the current preview presigned URL.
* `C` Returns the presigned URL constructed.

## Deploy the channel Monitor Lambda using Terraform.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'awslive-poster'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install awslive-poster

## Usage

#### Awslive Poster Initialisation
    
    require 'awslive-poster'
    
    awslive_poster = Awslive::Poster.new(channel_id)

    awslive_poster.get_url
    
## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cloudaffair/awslive-poster. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Awslive::Poster project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/awslive-poster/blob/master/CODE_OF_CONDUCT.md).

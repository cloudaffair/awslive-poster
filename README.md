# Awslive::Poster

Welcome to your awslive-poster gem!. 
Currently there is not easy and cost effective ay to get the poster image URL for the AWS medialive channel.
This utility auto computes the poster URL for the AWS media channel and creates a presigned URL fto access the poster image.

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

# NoopBackup

Ruby gem for backing up PostgreSQL databases with minimum effort.

## Installation

If using bundler, add the gem to your `Gemfile`:

```bash
bundle add noop-backup
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install noop-backup
```

The gem requires `pg_dump` to be installed on the machine that is running it.

## Usage

### Automatic

#### Rails 8 with Solid Queue

(soon) NoopBackup will run automatically using the Solid Queue scheduler.

#### Sidekiq, Good Job, whenever

(soon)

### Manually

```sh
bundle exec nbu backup
```

This command will dump the database and stream it to S3 without writing anything to disk. Use any
scheduler or even cron to run it periodically.

## Configuration

The gem needs AWS credentials and a bucket name:

```
AWS_REGION=region
AWS_ACCESS_KEY_ID=your-key
AWS_SECRET_ACCESS_KEY=your-secret-key
NBU_BUCKET=s3-bucket
NBU_MIN_SIZE=2048
```

If your app already has the AWS SDK set up, only the bucket needs to be configured.

Alternatively, the gem can be configured with an initializer:

```rb
# config/initializers/noop-backup.rb

NoopBackup.configure do |config|
  config.bucket = 'bucket-name'
  config.region = 'eu-central-1'
  config.prefix = Rails.env
  config.min_size = 2048

  config.notifier :slack do |slack|
    slack.webhook_url = 'https://hooks.slack.com/services/whatever'
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gmitrev/noop-backup.

## Wishlist

- [ ] S3-compatible backends
- [ ] file backends
- [ ] email notifier
- [ ] SMS notifier
- [ ] restore command
- [ ] test command

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

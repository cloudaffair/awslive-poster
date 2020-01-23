require 'aws-sdk-medialive'
require 'aws-sdk-lambda'
require 'aws-sdk-cloudwatchevents'
require 'json'


def lambda_handler(event:, context:)
  state = nil
  channel_id = nil
  puts "Event #{event}"
  if event["detail-type"] == "MediaLive Channel State Change"
    puts "Event : #{event}"
    state = event["detail"]["state"]
    channel_arn = event["detail"]["channel_arn"]
    role_arn = ENV["role_arn"]
    channel_id = channel_arn.split(":").last
    puts "channel ID : #{channel_id}  State : #{state}"
  end

  if !channel_id.nil?
    @medialiveclient = Aws::MediaLive::Client.new
    if state == "RUNNING"
      puts "Provisioning tag"
      start_time = event["time"]
      begin
        @medialiveclient.create_tags({
                                         resource_arn: "#{channel_arn}",
                                         tags: {
                                             "channel_start_time" => "#{start_time}"
                                         }

                                     })
      rescue StandardError => e
        puts "Rescued: #{e.inspect}"
      end
    elsif state == "STOPPED"
      begin
        puts "Deleting the tag"
        resp = @medialiveclient.delete_tags({
                                                resource_arn: "#{channel_arn}",
                                                tag_keys: [ "channel_start_time" ]

                                            })
      rescue StandardError => e
        puts "Rescued: #{e.inspect}"
      end
    end
  end
end

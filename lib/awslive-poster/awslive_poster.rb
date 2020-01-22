require 'aws-sdk-medialive'
require 'aws-sdk-s3'
require 'uri'

module Awslive
  class Poster

    class InvalidChannelState < StandardError; end
    class NoFrameCaptureOutputGroup < StandardError; end
    class PosterImageDoesNotExist < StandardError; end
    class NoStartTimeInTag < StandardError; end

    MAX_CHANNEL_START_TIME = 2 * 60

    def initialize(channel_id)
      credentials = Aws::SharedCredentials.new
      if credentials.set?
        @medialiveclient = Aws::MediaLive::Client.new(:credentials => credentials)
        @s3 = Aws::S3::Resource.new(:credentials => credentials)
      else
        @medialiveclient = Aws::MediaLive::Client.new
        @s3 = Aws::S3::Resource.new
      end
      @channel_id = channel_id
      @last_computed_time = nil
      @last_preview_url = nil
      @interval = nil
    end

    def get_url(channel_info = nil)
      if !@last_computed_time.nil? && !@last_preview_url.nil? && !@interval.nil?
        threshold_gap = @interval > MAX_CHANNEL_START_TIME ? MAX_CHANNEL_START_TIME : @interval
        current_time = Time.now.to_i
        if current_time - @last_computed_time < threshold_gap
          # quick fetch hence returning already computed preview URL.
          puts "returning from cache"
          return @last_preview_url
        end
      end
      preview_url = nil
      channel_info = @medialiveclient.describe_channel({ :channel_id => "#{@channel_id}" }) if channel_info.nil?
      channel_state = channel_info[:state]
      if channel_state == "RUNNING"
        @last_computed_time = Time.now.to_i
        out_group = get_framecapture_group(channel_info["encoder_settings"])
        raise NoFrameCaptureOutputGroup.new("Framecapture output group should be configured!") if out_group.nil?
        start_time = get_channel_start_time(channel_info)
        raise NoStartTimeInTag.new("channel_start_time should be provisioned in Channel tag!") if start_time.nil?
        dest_id = get_dest_info(out_group)
        url = get_dest_url(dest_id, channel_info)
        uri = URI(url)
        modifier = get_framecapture_modifier(out_group)
        @interval = get_framecapture_interval(out_group, channel_info)
        seq_counter = compute_index(start_time, @interval)
        suffix = uri.path[1..-1]
        bucket = @s3.bucket("#{uri.host}")
        obj = bucket.object("#{suffix}#{modifier}.#{seq_counter}.jpg")
        if obj.exists?
          preview_url = obj.presigned_url(:get)
        else
          raise PosterImageDoesNotExist.new("Poster Image #{suffix}#{modifier}.#{seq_counter}.jpg Does not exist!")
        end
      else
        raise InvalidChannelState.new("Channel Need to be in running state!, current state is #{channel_state}")
      end
      @last_preview_url = preview_url
      preview_url
    end

    def compute_index(start_time, interval)
      channel_start_time = Time.iso8601(start_time).to_i
      current_time = Time.now.utc.to_i
      diff_time = current_time - channel_start_time
      image_index = (diff_time / interval.to_i).to_i
      index =  image_index.to_s.rjust(5,'0')
      index
    end

    def get_channel_start_time(channel_info)
      start_time = channel_info.tags["channel_start_time"]
      start_time
    end

    def get_framecapture_group(encode_setting)
      out_grp = nil
      outputgroups = encode_setting["output_groups"] rescue nil
      unless outputgroups.nil?
        outputgroups.each do | output |
          if !output["output_group_settings"]["frame_capture_group_settings"].nil?
            out_grp = output
            break if !out_grp.nil?
          end
        end
      end
      out_grp
    end

    def get_dest_info(out_grp)
      dest =  nil
      if !out_grp["output_group_settings"]["frame_capture_group_settings"].nil?
        dest = out_grp["output_group_settings"]["frame_capture_group_settings"]["destination"]["destination_ref_id"] rescue nil
      end
      dest
    end

    def get_dest_url(dest_info, channel_info)
      url = nil
      if !channel_info["destinations"].nil?
        channel_info["destinations"].each do | dest |
          if dest["id"] == dest_info
            url = dest["settings"][0]["url"]
            break if !url.nil?
          end
        end
      end
      url
    end

    def get_framecapture_modifier(out_grp)
      modifier = out_grp["outputs"][0]["output_settings"]["frame_capture_output_settings"]["name_modifier"] rescue nil
      modifier
    end

    def get_framecapture_interval(out_grp, channel_info)
      interval = nil
      video_desc_name = out_grp["outputs"][0]["video_description_name"]
      if !video_desc_name.nil?
        video_desc_info = get_video_description_info(video_desc_name, channel_info)
        if !video_desc_info.nil?
          interval = video_desc_info["codec_settings"]["frame_capture_settings"]["capture_interval"]
        end
      end
      interval
    end

    def get_video_description_info(desc_name, channel_info)
      video_info = nil
      videos_desc = channel_info["encoder_settings"]["video_descriptions"]
      if !videos_desc.nil?
        videos_desc.each do | description |
          if description["name"] == desc_name
            video_info = description
            break
          end
        end
      end
      video_info
    end
  end
end
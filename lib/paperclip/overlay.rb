# frozen_string_literal: true

module Paperclip
  class Overlay < Paperclip::Processor
    # Handles watermarking of images that are uploaded.
    # This image processor allows you to have an main image and insert another
    # one as overlay,this works as a watermark.
    # Params:
    # base_path: the relative path of the base image to apply overlay
    # overlay_path: the relative path of the image to use as overlay

    attr_accessor :current_geometry, :target_geometry, :format, :whiny,
      :convert_options, :base_path, :overlay_path, :position,
      :image_id

    def initialize(file, options = {}, attachment = nil)
      super
      geometry          = options[:geometry]
      @file             = file
      @crop             = geometry[-1, 1] == '#' if geometry.present?
      @target_geometry  = Geometry.parse geometry
      @current_geometry = Geometry.from_file @file
      @convert_options  = options[:convert_options]
      @whiny            = if options[:whiny].nil?
                            true
                          else
                            options[:whiny]
                          end
      @format           = options[:format]
      @base_path        = options[:base_path]
      @image_id         = options[:image_id]
      @overlay_path     = image_path
      @position         = if options[:position].nil?
                            "NorthWest"
                          else
                            options[:position]
                          end
      @current_format   = File.extname(@file.path)
      @basename         = File.basename(@file.path, @current_format)
    end

    # Returns true if the +target_geometry+ is meant to crop.
    def crop?
      @crop
    end

    # Returns true if the image is meant to make use of additional convert
    # options.
    def convert_options?
      ![*@convert_options].reject(&:blank?).empty?
    end

    # Performs the conversion of the +file+ into a watermark. Returns the
    # Tempfile that contains the new image.
    def make
      src = @file
      dst = Tempfile.new([@basename, @format].compact.join("."))
      dst.binmode

      begin
        command = 'convert'

        params = []
        params << File.expand_path(src.path)
        params += transformation_command
        params << File.expand_path(dst.path)

        params = params.flatten.compact.join(' ').strip.squeeze(' ')

        Paperclip.run(command, params)
      rescue Terrapin::ExitStatusError => e
        if @whiny
          message = "There was an error processing the thumbnail for #{@basename}:\n" + e.message
          raise Paperclip::Error, message
        end
      rescue Terrapin::CommandNotFoundError => e
        message = "Could not run the `convert` command. Please install ImageMagick."
        raise Paperclip::Errors::CommandNotFoundError, message
      end

      if base_path
        begin
          command = 'composite'

          params = []
          params += composite_command(dst)
          params << [format, File.expand_path(dst.path)].compact.join(':')

          params = params.flatten.compact.join(' ').strip.squeeze(' ')

          Paperclip.run(command, params)
        rescue Terrapin::ExitStatusError => e
          if @whiny
            message = "There was an error processing the thumbnail for #{@basename}:\n" + e.message
            raise Paperclip::Error, message
          end
        rescue Terrapin::CommandNotFoundError
          message = "Could not run the `composite` command. Please install ImageMagick."
          raise Paperclip::Errors::CommandNotFoundError, message
        end
      end

      if overlay_path
        begin
          command = 'composite'

          params = []
          params += composite_command(dst)
          params << [format, File.expand_path(dst.path)].compact.join(':')

          params = params.flatten.compact.join(' ').strip.squeeze(' ')

          Paperclip.run(command, params)
        rescue Terrapin::ExitStatusError => e
          if @whiny
            message = "There was an error processing the thumbnail for #{@basename}:\n" + e.message
            raise Paperclip::Error, message
          end
        rescue Terrapin::CommandNotFoundError
          message = "Could not run the `composite` command. Please install ImageMagick."
          raise Paperclip::Errors::CommandNotFoundError, message
        end
      end

      dst
    end

    def transformation_command
      if @target_geometry.present?
        scale, crop = @current_geometry.transformation_to(@target_geometry, crop?)
      else
        scale, crop = @current_geometry.transformation_to(@current_geometry, crop?)
      end

      trans = []

      trans << %W[-resize #{scale}]
      trans << %w[-background white]
      trans << %w[-strip]
      trans << %w[-auto-orient]
      trans << %w[-colorspace sRGB]
      trans << %w[-gravity center]
      trans << %W[-extent #{scale}]
      trans << %W[-crop #{crop} +repage] if crop
      trans << [*convert_options] if convert_options?

      trans
    end

    def composite_command(dst = nil)
      comp = []

      comp << %w[-compose Over]
      comp << %W[-gravity #{position}]
      comp << %W[#{File.expand_path(dst.path)}] if base_path
      comp << %W[#{base_path}] if base_path
      comp << %W[#{overlay_path}] if overlay_path
      comp << %W[#{File.expand_path(dst.path)}] if overlay_path
      comp << %W[-resize #{target_geometry}]

      comp
    end

    def image_path
      feed_image = Spree::ProductFeed.where(id: image_id).first
      feed_image.try(:overlay_image).try(:attachment).try(:path) || nil
    end
  end
end

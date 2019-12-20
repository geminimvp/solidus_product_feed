# frozen_string_literal: true

module Paperclip
  class ColorFill < Paperclip::Processor
    # Handles watermarking of images that are uploaded.
    # This image processor allows you to have an main image and as background it
    # will be use a fill color that you especified:
    # https://shopify.flexify.net/facebook-product-feed-app/documentation/#solid-color-fill
    # Params:
    # color: The color you chose to use
    # overlay_path: the relative path of the image to use as overlay
    # image_id: ID of Spree::ProductFeed to find overlay_image object

    attr_accessor :current_geometry, :target_geometry, :format, :whiny,
      :convert_options, :crop, :image_id, :color, :overlay_path

    def initialize(file, options = {}, attachment = nil)
      super
      geometry          = options[:geometry]
      @file             = file
      @crop             = geometry[-1, 1] == '#' if geometry.present?
      @target_geometry  = Geometry.parse geometry
      @current_geometry = Geometry.from_file @file
      @convert_options  = options[:convert_options]
      @color            = options[:color]
      @image_id         = options[:image_id]
      @overlay_path     = image_path
      @whiny            = options.fetch(:whiny, true)
      @format           = options[:format]
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
      rescue Terrapin::CommandNotFoundError
        message = "Could not run the `convert` command. Please install ImageMagick."
        raise Paperclip::Errors::CommandNotFoundError, message
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
      scale, crop = @current_geometry.transformation_to(@target_geometry, crop?)

      trans = []
      trans << %W[-resize #{scale}]
      trans << %W[-background #{color}] if color
      trans << %w[-gravity center]
      trans << %W[-extent #{scale}]
      trans << %W[-crop %[#{crop}] +repage] if crop
      trans << [*convert_options] if convert_options?
      trans
    end

    def composite_command(dst)
      comp = []

      comp << %w[-compose Over]
      comp << %w[-gravity center]
      comp << %W[#{overlay_path}]
      comp << %W[#{File.expand_path(dst.path)}]
      comp << %W[-resize #{target_geometry}]

      comp
    end

    def image_path
      feed_image = Spree::ProductFeed.where(id: image_id).first
      feed_image.try(:overlay_image).try(:attachment).try(:path) || ''
    end
  end
end

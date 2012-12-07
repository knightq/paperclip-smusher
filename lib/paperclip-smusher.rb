module Paperclip
  class Thumbnail < Processor

    # Performs the conversion of the +file+ into a thumbnail. Returns the Tempfile
    # that contains the new image.
    def make
      src = @file
      conv = Tempfile.new([@basename, @format ? ".#{@format}" : ''])
      conv.binmode
      dst = Tempfile.new([@basename, @format ? ".#{@format}" : ''])
      dst.binmode

      begin
        parameters = []
        parameters << source_file_options
        parameters << ":source"
        parameters << transformation_command
        parameters << convert_options
        parameters << ":dest"

        parameters = parameters.flatten.compact.join(" ").strip.squeeze(" ")

        success = Paperclip.run("convert", parameters, :source => "#{File.expand_path(src.path)}#{'[0]' unless animated?}", :dest => File.expand_path(conv.path))
        if conv.size > 0
          format = begin
            Paperclip.run("identify", "-format %m :file", :file => "#{File.expand_path(conv.path)}[0]")
          rescue PaperclipCommandLineError
            ""
          end

          case format.strip
          when 'JPEG'
            # Part of libjpeg-progs deb package
            success = Paperclip.run('jpegtran', "-copy none -optimize -perfect :source > :dest", :source => File.expand_path(conv.path), :dest => File.expand_path(dst.path))
          when 'PNG'
            success = Paperclip.run('pngcrush', "-q -rem alla -reduce -brute :source :dest", :source => File.expand_path(conv.path), :dest => File.expand_path(dst.path))
          else
            dst = conv
          end
        end
      rescue Cocaine::ExitStatusError => e
        raise PaperclipError, "There was an error processing the thumbnail for #{@basename}" if @whiny
      rescue Cocaine::CommandNotFoundError => e
        raise Paperclip::CommandNotFoundError.new("Could not run the `convert` command. Please install ImageMagick.")
      rescue Exception => e
        Rails.logger.error "There was an error processing the thumbnail for #{@basename}. Check imagemagick, jpegtran and pngcrush installed."
        Rails.logger.error e.message
      end

      dst.size > 0 ? dst : conv
    end
  end
end

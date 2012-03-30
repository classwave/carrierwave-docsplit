require "carrierwave-docsplit/version"

require 'carrierwave'
require 'docsplit'
require 'json'
require 'pathname'
require 'fileutils'

module CarrierWave
  module DocsplitIntegration

    class NoModelError < Exception
      def message
        "Text extraction requires a model for the uploader to write results to."
      end
    end

    # Setup the extraction.
    #
    #

    def extract(options = {})
      if options[:images]
        self.setup_image_extraction options[:images]
      end

      if options[:text]
        self.setup_text_extraction options[:text]
      end
    end

    def setup_text_extraction(options)
      self.instance_eval do
        process :enact_text_extraction

        define_method :enact_text_extraction do
          raise NoModelError if @model.nil?

          out = File.join self.store_dir, self.file.basename
          FileUtils.mkdir_p out
          Docsplit.extract_text self.file.path, :ocr => false, :output => out
          text = File.read Dir.glob(File.join(out, '*.txt')).first

          @model.send "#{options[:to]}=", text
        end
      end
    end

    def setup_image_extraction(options)
       self.instance_eval do

        define_method :output_path do
          return nil if self.file.nil?
          File.join self.store_dir, self.file.basename
        end

        # Latch our extraction method into the processing queue.
        process :enact_extraction => options[:sizes]


        # Define a reader to access the thumbnails stored on disk.
        #
        # Returns a hash structured like so.
        #
        # {
        #   '700x700' => ['/uploads/w9/700x/w9_1.png']
        # }
        #
        # This allows for accessing the sizes like this:
        #
        # file.thumbs['700x700']

        define_method options[:to] do
          path = File.join(self.output_path, '*')

          dirs_or_files = Dir.glob(path)
          reduced = {}

          # Multiple Sizes
          if dirs_or_files.any? { |entry| entry.match /\d+x\d*/ }

            Dir.glob(path) do |dirs|
              if dirs.is_a?(String)
                dirs = [] << dirs
              end

              dirs.each do |dir|
                thumbs = Dir.glob(File.join(dir, '*'))
                key = File.basename(dir)
                reduced[key] = thumbs
              end
            end

          # Only as single size supplied
          else
            options.delete :to
            size = options.values.first
            reduced[size] = dirs_or_files
          end

          reduced
        end

        define_method :enact_extraction do |*args|
          args.flatten!

          # zip the args back into the hash the user wrote them in.
          if args.size == 0 || (args.size % 2) > 0
            raise ArgumentError, "Need an even amount of arguments (Given #{args.size} #{args.size % 2})"
          end

          sizes = args.each_slice(2).reduce({}) { |mem, pair| mem.merge({ pair.first => pair.last }) }

          self.class.class_eval do
            sizes.keys.each { |size| version size }
          end

          out = self.output_path

          FileUtils.mkdir_p out

          Docsplit.extract_images self.file.path, :size => sizes.values, :output => out
        end
      end
    end
  end
end

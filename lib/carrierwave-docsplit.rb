require "carrierwave-docsplit/version"

require 'carrierwave'
require 'docsplit'
require 'json'
require 'pathname'

module CarrierWave
  module DocsplitIntegration
    def extract_images(options = {})

      self.instance_eval do

        define_method :output_path do
          return nil if self.file.nil?
          File.join self.store_dir, self.file.basename
        end

        @sizes = options[:sizes]

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

          reduced = {}

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

          inverted_sizes = sizes.invert

          # sizes.values.each do |size|
          #   path = File.join(out, size, '*')
          #   version_accessor = inverted_sizes[size]
          #   self.send (version_accessor.to_s + "=").to_sym, path
          # end
        end

        # TODO: Enable this shit.
      end
    end
  end
end

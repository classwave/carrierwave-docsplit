require 'carrierwave'
require 'fileutils'

ROOT = File.dirname(__FILE__)

$:.unshift File.join "../lib", ROOT

require 'carrierwave-docsplit'

require 'minitest/unit'
begin; require 'turn/autorun'; rescue LoadError; end

class TestUploader < CarrierWave::Uploader::Base
  extend CarrierWave::DocsplitIntegration

  def store_dir
    File.join(ROOT, 'uploads')
  end

  storage :file

  extract_images :to => :thumbs, :sizes => { :large => "300x", :medium => "500x" }
end

class TestCarrierWaveDocsplit < MiniTest::Unit::TestCase
  include CarrierWave::DocsplitIntegration

  def setup
    @uploader = TestUploader.new
    @uploader.retrieve_from_store! File.join(ROOT, 'w9.pdf')

    CarrierWave.configure do |config|
      config.root = ROOT
    end
  end

  def verify_extracted_images!
    path = File.join(ROOT, 'uploads/w9')
    unless File.exist?(path) && Dir.glob(File.join(path, "*")).any?
      uploader = TestUploader.new
      file = File.open(File.join(ROOT, 'data/w9.pdf'))
      uploader.store! file
    end
  end

  def test_that_read_accessor_is_being_generated
    assert @uploader.respond_to? :thumbs
  end

  def test_that_reader_returns_valid_hash
    verify_extracted_images!

    thumbs = @uploader.thumbs

    assert thumbs.include?('300x'), "Thumbs does not include 300x"
    assert thumbs.include?('500x'), "Thumbs does not include 500x"

    assert thumbs.values.all? { |val| val.is_a? Array }
  end


  def test_that_output_path_returns_nil_if_no_file_stored
    uploader = TestUploader.new
    assert_equal nil, uploader.output_path
  end
end
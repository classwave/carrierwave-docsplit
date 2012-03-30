# CarrierWave + Docsplit: A Loving Union

carrierwave-docsplit is a thin wrapper around docsplit that knows how to talk to carrierwave.

# Usage

1. Require the file and drop it into your module.

```ruby extend CarrierWave::DocsplitIntegration ```

2. Hook in the integration.

```ruby
extract_images :to => :thumbs, :sizes => { :large => "300x", :medium => "500x" }
```

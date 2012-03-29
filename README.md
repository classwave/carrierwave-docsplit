# CarrierWave + Docsplit: A Loving Union

carrierwave-docsplit is a thin wrapper arund docsplit that knows how to talk to carrierwave.

# Usage

1. Require the file and drop it into your module.

2. Wire it into the processing queue.

```ruby
process :extract_text_and_images
```

You can also pass in a `:sizes` option.  Docsplit will generate a set of images of the pages in each.

```ruby
process :extract_text_and_images, :sizes => ['200x200', '1000x']
```

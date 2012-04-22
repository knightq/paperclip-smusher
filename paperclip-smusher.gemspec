Gem::Specification.new do |s|
  s.name        = "paperclip-smusher"
  s.version     = "0.2.0"
  s.date        = "2012-04-22"
  s.summary     = "Image compression for Paperclip"
  s.description = "JPEG and PNG compression for Paperclip gem"
  s.author      = "Andrea Salicetti"
  s.email       = "andrea.salicetti@gmail.com"
  s.files       = ["lib/paperclip-smusher.rb"]
  s.homepage    = "http://github.com/knightq/paperclip-smusher"
  s.add_runtime_dependency "paperclip", ["~> 2.4"]
  s.requirements << "jpegtran for JPEG compression"
  s.requirements << "optipng for PNG compression"
end

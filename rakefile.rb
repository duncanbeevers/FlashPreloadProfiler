require 'rubygems'
require 'bundler'
require 'bundler/setup'

require 'flashsdk'

compc "bin/FlashPreloadProfiler.swc" do |t|
  t.target_player = '10.1.0'
  t.source_path << 'src'
  t.include_classes << 'net.jpauclair.FlashPreloadProfiler'

  t.title       = 'FlashPreloadProfiler'
  t.creator     = 'jpauclair'
  t.contributor = 'duncanbeevers'
  t.language    = 'EN'
end

task :swc => "bin/FlashPreloadProfiler.swc"

desc "Build FlashPreloadProfiler.swc"
task :default => :swc


#!/usr/bin/env ruby
require 'tempfile'
require 'rest_client'
require 'fileutils'
require 'zip'

print 'Ghost Version: '
version = gets.strip

download_file = "https://github.com/TryGhost/Ghost/releases/download/#{version}/Ghost-#{version}.zip"

file = Tempfile.new 'ghost'
begin
  res = nil
  begin
    res = RestClient.get(download_file)
  rescue RestClient::Exception => e
    puts "Invalid ghost version (server returned #{e.http_code})"
    exit(-1)
  end
  file.write res.body
  file.close

  folders =  ['core', 'content/themes/casper']
  folders.each do |folder|
    FileUtils.rm_rf(folder)
  end

  files = ['package.json', 'index.js']
  files.each do |file|
    FileUtils.rm(file)
  end

  Zip::File.open(file.path) do |zip_file|
    folders.map{|f| "#{f}/**/*" }.each do |glob|
      zip_file.glob(glob).each do |entry|
        FileUtils.mkdir_p File.dirname(entry.name)
        puts "Extracting #{entry.name}..."
        entry.extract(entry.name)
      end
    end

    files.each do |file|
      entry = zip_file.glob(file).first
      FileUtils.mkdir_p File.dirname(entry.name)
      puts "Extracting #{entry}"
      entry.extract(entry.name)
    end
  end

  File.open('version', 'w') do |f|
    f.puts version
  end
ensure
  file.unlink
end

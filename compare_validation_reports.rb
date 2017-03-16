#!/usr/bin/env ruby
require 'optparse'
require 'json'


options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: compare_validation_reports.rb [options]"
  
  opts.on("-d d", "--dir=dir", "Path to the validation reports dir.") do |dir|
    options[:dir] = (dir[-1,1] == "/" ? dir : dir + "/")
  end

  opts.on("-c", "--classification", "Select only classification reports from dir.") do |c|
    if options[:regression]
      puts "Don't use optional parameters -c and -r at the same time. Mixed by default."
      exit
    end
    options[:classification] = c
  end

  opts.on("-r", "--regression", "Select only regression reports from dir.") do |r|
    if options[:classification]
      puts "Don't use optional parameters -c and -r at the same time. Mixed by default."
      exit
    end
    options[:regression] = r
  end

  opts.on("-v", "--verbose", "Display verbose report. Standard for -d mode without -c or -r parameters.") do |v|
    options[:verbose] = v
  end

  opts.on("-f f", "--file=files", "Select two or more comma seperated reports.") do |files|
    list = files.split(",")
    unless list.size == 2
      puts "You have to pass at least two files as argument with full path."
      exit
    end
    options[:files] = list
  end
  
  opts.on("-h", "--help", "Displays help") do
    puts opts
    exit
  end

end.parse!

if options.empty? || (!options[:files] && !options[:dir])
  puts "Usage: compare_validation_reports.rb -h"
  exit
end

if options[:dir]
  if options[:verbose]
    if !options[:classification] && !options[:regression]
      json = Dir[options[:dir]+'*.json'].sort.map { |f| JSON.parse File.read(f) }.flatten
      puts JSON.pretty_generate json
    end
    if options[:classification]
      json = Dir[options[:dir]+'*_classification_*.json'].sort.map { |f| JSON.parse File.read(f) }.flatten
      puts JSON.pretty_generate json
    end
    if options[:regression]
      json = Dir[options[:dir]+'*_regression_*.json'].sort.map { |f| JSON.parse File.read(f) }.flatten
      puts JSON.pretty_generate json
    end
  else

    main = {}

    if !options[:classification] && !options[:regression] && !options[:verbose]
      json = Dir[options[:dir]+'*.json'].sort.map { |f| JSON.parse File.read(f) }.flatten
      puts JSON.pretty_generate json
    end
    if options[:classification]
      json = Dir[options[:dir]+'*_classification_*.json'].sort.map { |f| JSON.parse File.read(f) }.flatten
      json.each do |report|
        main[report["endpoint"]] ||= []
        main[report["endpoint"]] << [report["species"], report["created_at"], report["crossvalidations"].map{|cv| {"accuracy": cv[1]["statistics"]["accuracy"], "weighted_accuracy": cv[1]["statistics"]["weighted_accuracy"], "true_rate": cv[1]["statistics"]["true_rate"], "predictivity": cv[1]["statistics"]["predictivity"]}}.flatten]
      end
      puts JSON.pretty_generate main
    end
    if options[:regression]
      json = Dir[options[:dir]+'*_regression_*.json'].sort.map { |f| JSON.parse File.read(f) }.flatten
      json.each do |report|
        main[report["endpoint"]] ||= []
        main[report["endpoint"]] << [report["species"], report["created_at"], report["crossvalidations"].map{|cv| {"rmse": cv[1]["statistics"]["rmse"], "r_squared": cv[1]["statistics"]["r_squared"]}}.flatten]
      end
      puts JSON.pretty_generate main
    end
  end
end

if options[:files]
  json = []
  options[:files].each do |file|
    json << JSON.parse(File.read(file))
  end
  puts JSON.pretty_generate json.flatten

end


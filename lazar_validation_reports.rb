ENV["LAZAR_ENV"] = "production"
require_relative '../lazar/lib/lazar'
#require 'lazar'
require 'json'
include OpenTox

models = Model::Validation.all
size = models.size
puts "#{size} reports to store."

# create dir if not exists
path = "#{ENV['HOME']}/lazar-validation-reports"
dir = FileUtils.mkdir_p path

models.each_with_index do |model, idx|

  @json = {}
  
  # define file name
  type = model.regression? ? "regression" : "classification"
  #name = model.model.name.gsub!(/[^0-9A-Za-z.\-]/, '_')
  date = model.created_at.to_s.split.first
  name = (model.endpoint + "_" + model.species).gsub!(/[^0-9A-Za-z.\-]/, '_')
  branch = model.model.version["branch"]
  commit = model.model.version["commit"]
  filename = [date,type,branch,commit,name].join("_")

  # collect object data
  @json["endpoint"] = model.endpoint
  @json["species"] = model.species
  @json["source"] = model.source
  @json["training_dataset"] = model.training_dataset.source
  @json["training_compounds"] = model.training_dataset.data_entries.size
  @json["algorithms"] = model.algorithms
  @json["name"] = model.model.name
  @json["created_at"] = model.created_at
  @json["unit"] = model.unit
  @json["version"] = model.model.version
  @json["crossvalidations"] = {} 
  model.crossvalidations.each_with_index do |cv,idx|
    @json["crossvalidations"][idx.to_s] = {"folds": cv.folds, "instances": cv.nr_instances, "unpredicted": cv.nr_unpredicted, "statistics": cv.statistics}
  end

  # write report to file
  File.open("#{path}/#{filename}.json", "w") do |f|
    f.write(JSON.pretty_generate(JSON.parse(@json.to_json)))
  end

  puts "#{size - (idx+1)} left to store."

end

# store database dump
puts "Storing database dump."
`mongodump -h 127.0.0.1 -o #{path}/#{Time.now.to_s.split.first}-dump-#{ENV["LAZAR_ENV"]} -d #{ENV["LAZAR_ENV"]}`

ENV["LAZAR_ENV"] = "production"
require_relative "#{ENV["HOME"]}/lazar/lib/lazar" unless $LOADED_FEATURES.include?("#{ENV["HOME"]}/lazar/lib/lazar.rb")
#require 'lazar'
require 'json'
include OpenTox

models = Model::Validation.all
size = models.size
puts "#{size} reports to store."

# store in users home dir subfolder
path = "#{ENV['HOME']}/lazar-validation-reports"
FileUtils.mkdir_p path

models.each_with_index do |model, idx|

  @json = {}
  
  # define file name
  type = model.regression? ? "regression" : "classification"
  date = model.created_at.to_s.split.first
  dataset_name = model.training_dataset.source.split("/").last
  name = (model.endpoint + "_" + model.species + "_" + dataset_name).gsub!(/[^0-9A-Za-z.\-]/, '_').gsub!(/\.csv$/,"")
  branch = model.model.version["branch"].gsub(/\//,"-")
  commit = model.model.version["commit"]
  filename = [date,type,branch,commit,name].join("_")

  # collect object data
  @json["endpoint"] = model.endpoint
  @json["species"] = model.species
  @json["source"] = model.source
  @json["training_dataset"] = dataset_name
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

# store database dump in users home dir subfolder
if !CENTRAL_MONGO_IP.blank?
	#TODO Can not dump because mongo commands missing in linked container !
	#`mongodump -h #{CENTRAL_MONGO_IP} -o #{path}/#{Time.now.to_s.split.first}-dump-#{ENV["LAZAR_ENV"]} -d #{ENV["LAZAR_ENV"]}`
else
	puts "Storing database dump."
	`mongodump -h 127.0.0.1 -o #{path}/#{Time.now.to_s.split.first}-dump-#{ENV["LAZAR_ENV"]} -d #{ENV["LAZAR_ENV"]}`
end

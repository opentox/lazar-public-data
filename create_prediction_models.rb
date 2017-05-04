ENV["LAZAR_ENV"] = "production"
require_relative '../lazar/lib/lazar'
#require 'lazar'
include OpenTox
$mongo.database.drop
$gridfs = $mongo.database.fs # recreate GridFS indexes

@models = OpenTox::Model::Validation.all

def delete_models type
  case type
  when "classification"
    models = @models.delete_if{|m| !m.classification?}
  when "regression"
    models = @models.delete_if{|m| !m.regression?}
  else
    puts "Unknown model type #{type}"
    exit
  end
  models.each do |m|
    m.training_dataset.delete
    m.crossvalidations.each{|cv| cv.delete}
    m.model.delete
    m.delete
  end unless models.empty?
end

puts CENTRAL_MONGO_IP.blank? ? "Use local mongodb on port: 127.0.0.1" : "Use central mongodb on port: #{CENTRAL_MONGO_IP}"

#=begin
# classification models
#delete_models "classification"
Dir["classification/*csv"].each do |file|
  unless file.match(/hamster|mutagenicity/i)#until mutagenicity is refined
    puts "### #{file} ###\n"
    Model::Validation.from_csv_file file
  end
  puts "### done: #{file} ###\n"
end
#=end

#=begin
# regression models
#delete_models "regression"
Dir["regression/*log10.csv"].each do |file|
  unless file.match(/fathead/)#until dublicates not cleared
    puts "### #{file} ###\n"
    Model::Validation.from_csv_file file
  end
  puts "### done: #{file} ###\n"
end
#=end

## nano-lazar
=begin

# creates 3 models: one with physchem, one with proteomics, one with fingerprints
feature_categories = ["fingerprint", "P-CHEM", "Proteomics"]

feature_categories.each do |category|
  if category == "fingerprint"
		algorithms = {
			:descriptors => { :method => "fingerprint", :type => "MP2D", },
			:feature_selection => nil,
			:similarity => {
				:method => "Algorithm::Similarity.tanimoto",
				:min => 0.1
			}
		}
		
		OpenTox::Model::Validation.from_enanomapper algorithms: algorithms
	else
		algorithms = {
			:descriptors => {
				:method => "properties",
				:categories => (category.is_a?(Array) ? [category].flatten : [category]),
			},
			:similarity => {
				:method => "Algorithm::Similarity.weighted_cosine",
				:min => 0.5
			},
			:prediction => {
				:method => "Algorithm::Caret.rf",
			},
			:feature_selection => {
				:method => "Algorithm::FeatureSelection.correlation_filter",
			},
		}

		OpenTox::Model::Validation.from_enanomapper algorithms: algorithms
	end
end
=end

# remove existing local dump
`rm -r dump/#{ENV["LAZAR_ENV"]}`
# store local dump but git ignored
`mongodump -h #{CENTRAL_MONGO_IP.blank? ? "127.0.0.1" : CENTRAL_MONGO_IP} -d #{ENV["LAZAR_ENV"]}`

# build reports and users dump
eval File.read('./lazar_validation_reports.rb')

# restore
#`mongorestore --host #{(CENTRAL_MONGO_IP.blank? ? "127.0.0.1" : CENTRAL_MONGO_IP)}`

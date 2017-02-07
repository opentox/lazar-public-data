ENV["LAZAR_ENV"] = "development"
require_relative '../lazar/lib/lazar'
#require 'lazar'
include OpenTox
#$mongo.database.drop
#$gridfs = $mongo.database.fs # recreate GridFS indexes

=begin
# classification models
Dir["classification/*csv"].each do |file|
  unless file.match(/hamster/)
    Model::Prediction.from_csv_file file
  end
end

# regression models
Dir["regression/*log10.csv"].each do |file|
  Model::Prediction.from_csv_file file
end
=end

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

# save

#`mongodump -h 127.0.0.1 -d development`
#`mongorestore --host 127.0.0.1`

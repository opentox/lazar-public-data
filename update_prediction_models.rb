ENV["LAZAR_ENV"] = "production"
require_relative '../lazar/lib/lazar'
#require 'lazar'
include OpenTox

# use mongodb how it is configured by lazar lib
#=begin
$mongo.database.drop
$gridfs = $mongo.database.fs # recreate GridFS indexes
`mongorestore --host #{ CENTRAL_MONGO_IP.blank? ? "127.0.0.1" : CENTRAL_MONGO_IP}`
#=end


# overwrite lazar congif to load in particular to localhost mongodb
=begin
$mongo = Mongo::Client.new("mongodb://127.0.0.1:27017/#{ENV['LAZAR_ENV']}")
$mongo.database.drop
$gridfs = $mongo.database.fs # recreate GridFS indexes
`mongorestore --host 127.0.0.1`
=end


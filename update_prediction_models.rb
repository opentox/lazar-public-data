ENV["LAZAR_ENV"] = "production"
require_relative '../lazar/lib/lazar'
#require 'lazar'
include OpenTox
$mongo.database.drop
$gridfs = $mongo.database.fs # recreate GridFS indexes

# uncomment to load in particular to local mongodb
#mongorestore --host 127.0.0.1

`mongorestore --host #{ CENTRAL_MONGO_IP.blank? ? "127.0.0.1" : CENTRAL_MONGO_IP}`

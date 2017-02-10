ENV["LAZAR_ENV"] = "production"
require_relative '../lazar/lib/lazar'
#require 'lazar'
include OpenTox
$mongo.database.drop
$gridfs = $mongo.database.fs # recreate GridFS indexes

`mongorestore --host 127.0.0.1`

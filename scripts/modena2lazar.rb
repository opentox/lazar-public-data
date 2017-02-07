require_relative '../../lazar/lib/lazar'
include OpenTox

descriptors = ["Material","Coating","Primary size 1st Dimension [nm]","Primary size 2nd Dimension [nm]","Aspect ratio","Surface area [m2/g]","Zeta potential [mV]","Size in situ  [nm]"]

conditions = ["Assay","Treatment time","Cell type","Serum concentration","Dispersion protocol"]
endpoints = ["EC25 (ug/ml)","EC50 (ug/ml)","slope EC50 (ug/ml)","EC25 (mm2/ml)","EC50 (mm2/ml)","slope EC50 (surface area)","EC25 (10E12 particles/ml)","EC50 (10E12 particles/ml)","slope EC50 (number)"] 

descriptor_csv = CSV.open("../regression/MODENA-descriptors.csv", "wb")
#endpoint_csvs 
#endpoins.each do |e| 

#descriptor_csv << ["ID"]+descriptors
input = CSV.read("../src/MODENA-EC50_EC25.csv")
header = input.shift
descriptor_indices = descriptors.collect{|d| header.index d}
condition_indices = conditions.collect{|c| header.index c}
condition_parameters = []
condition_counts = {}
input.each do |line|
  id = line[0]+"_"+line[1].gsub(" ","_")
  #descriptor_csv << [id]+descriptor_indices.collect{|i| line[i]}
  conds = condition_indices.collect{|i| line[i]}
  condition_parameters << conds
  condition_counts[conds] ||= 0
  condition_counts[conds] += 1
end
#descriptor_csv.close
p condition_parameters.size
p condition_parameters.uniq.size
p condition_counts.sort{|a,b| b.last <=> a.last}

require_relative '../../lazar/lib/lazar'
include OpenTox

CSV.open("../classification/blood-brain-barrier.csv", "wb") do |csv|
  CSV.read("../classification/bbp2.smi",{:col_sep => "\t"}).each do |line|
    smi = line.first
    act = line[-2]
    p smi, act
    if act =~ /p/i
      csv << [smi, "penetrating"]
    elsif act =~ /n/i
      csv << [smi, "nonpenetrating"]
    else
      p "unknown act '#{act}'"
    end
  end
end


MAXBID=500
if Setting.table_exists? && Setting.collective.nil?
  Setting.collective=0
end

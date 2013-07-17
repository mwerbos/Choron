module DelayUtils
  def find_jobs(object,time=nil,method=nil)
    #Finds all the jobs associates with object, optinonally at a certain time.
    if time
      jobs=DelayedJob.where("run_at = ?",time)
    else
      jobs=DelayedJob.all
    end
    jobs.select! do |job|
      begin
        handler=YAML.load(job.handler)
        puts "******************"
        puts job.handler
        puts (handler.object==object) && (method.nil? || handler.method_name==method)
        puts "=================="
        (handler.object==object) && (method.nil? || handler.method_name==method)
      rescue Delayed::DeserializationError
        false
      end
    end
    
  end
end

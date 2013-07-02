module DelayUtils
  def findJobs(object,time=nil)
    #Finds all the jobs associates with object, optinonally at a certain time.
    if time
      jobs=DelayedJob.where("run_at = ?",time)
    else
      jobs=DelayedJob.all
    end
    jobs.select do |job|
      begin
        puts job.handler
        YAML.load(job.handler).object==object
      rescue Delayed::DeserializationError
        puts "EXCEPTION"
        false
      end
    end
  end
end

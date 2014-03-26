class AddStoryPositions < ActiveRecord::Migration
  def self.up
    # Rails doesn't support temp tables, mysql doesn't support update
    # from same-table subselect

    unless RbStory.trackers.size == 0
      max = 0
	      dbconfig = YAML.load_file(File.join(File.dirname(__FILE__), '../../../../config/database.yml'))#[Rails.env]['username']
    
		if dbconfig[Rails.env]['adapter'] == 'sqlserver' then
			database = dbconfig[Rails.env]['database']
			dataserver = dbconfig[Rails.env]['dataserver']
			mode = dbconfig[Rails.env]['mode']
			port = dbconfig[Rails.env]['port']
			username = dbconfig[Rails.env]['username']
			password = dbconfig[Rails.env]['password']

			client = TinyTds::Client.new(
				:database => database,
				:dataserver => dataserver,
				:mode => mode,
				:port => port,
				:username => username,
				:password => password)
		  
			client.execute("select max(position) from issues").each{|row| max = row[0]}

			client.execute "update issues
               set position = #{max} + id
               where position is null and tracker_id in (#{RbStory.trackers(:type=>:string)})"
		else
			execute("select max(position) from issues").each{|row| max = row[0]}

			execute "update issues
               set position = #{max} + id
               where position is null and tracker_id in (#{RbStory.trackers(:type=>:string)})"
		end

    end
  end

  def self.down
    puts "Reverting irreversible migration"
  end
end

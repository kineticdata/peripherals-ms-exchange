# Require the dependencies file to load the vendor libraries
require File.expand_path(File.join(File.dirname(__FILE__), 'dependencies'))

class ExchangeAppointmentFindOccurrenceV1
  def initialize(input)
    # Set the input document attribute
    @input_document = REXML::Document.new(input)

    # Store the info values in a Hash of info names to values.
    @info_values = {}
    REXML::XPath.each(@input_document,"/handler/infos/info") { |item|
      @info_values[item.attributes['name']] = item.text
    }

    @enable_debug_logging = @info_values['enable_debug_logging'] == 'Yes'

    # Store parameters values in a Hash of parameter names to values.
    @parameters = {}
    REXML::XPath.match(@input_document, '/handler/parameters/parameter').each do |node|
      @parameters[node.attribute('name').value] = node.text.to_s
    end
  end

  def execute()
    puts @parameters if @enable_debug_logging

    # Validate required parameters exist
    if @parameters['start'].to_s.empty? || @parameters['end'].to_s.empty? || @parameters['recurring_master_id'].to_s.empty?
      raise "Start, End, and Recurring Master ID parameters are required."
    end

    endpoint = @info_values['server_address'] + "/ews/exchange.asmx"

    client = Viewpoint::EWSClient.new(
      endpoint, 
      @info_values['username'], 
      @info_values['password']#, 
      #http_opts: {ssl_verify_mode: 0}
    )

    calendar = client.get_folder(:calendar)

    puts calendar.class
    puts calendar.folder_id[:id]

    # Extract items from the calendar view so instances of recurring events are also returned.
    items = client.find_items({:folder_id => calendar.folder_id, :calendar_view => {:start_date => @parameters["start"], :end_date => @parameters["end"]}})

    raise ("No items found within date range #{@parameters['start']} to #{@parameters['end']}") if items.nil?

    if @enable_debug_logging
      puts "Total items in range: #{items.size}"

      # Loop over each item and display some info about it.
      items.each{|x|
        y =  x.get_all_properties!
        puts "Id: #{x.id}"
        puts "Recurrence: #{x.recurrence}"
        puts "Start: #{x.start}"
        puts "End: #{x.end}"
        puts "Subject: #{x.subject}"
        puts "Type: #{y[:calendar_item_type][:text]}\n\n"
      }
    end

    # Create an array of only the id and change_key for each returned item that is an 'Occurrence' or an 'Exception'.
    occurrence_item_ids = items.select{|x| 
      x.get_all_properties![:calendar_item_type][:text] == "Occurrence" || x.get_all_properties![:calendar_item_type][:text] == "Exception"
    }.map{|item| {"id" => item.id, "change_key" => item.change_key}}

    raise ("No recurring items occurrences found in the date range  #{@parameters['start']} to #{@parameters['end']}") if occurrence_item_ids.nil?

    puts "Total occurrence items in range: #{items.size}" if @enable_debug_logging
    puts "Occurrence item IDs: #{occurrence_item_ids}" if @enable_debug_logging

    
    # Declare an occurrence_id for use in output
    occurrence_id = ""

    # Retrieve each occurrence and check to see if the related master ID matches the input parameter value.
    # If a match is found, break out of loop and continue
    occurrence_item_ids.each{|item|
      item_detail = client.get_item(item['id'],{:item_ids => [{:recurring_master_item_id => {:occurrence_id => item['id'], :change_key => item['change_key']}}]})
      
      if @enable_debug_logging
        puts "Occurrence Details:"
        puts "   Occurrence ID: #{item['id']}"
        puts "   Master ID: #{item_detail.id}"
      end

      # Break out of loop if master is found
      # Only looking for first match.  Could multiples exist
      if (item_detail.id == @parameters['recurring_master_id'])
        occurrence_id = item['id']
        puts "Master ID match found" if @enable_debug_logging
        break
      end
    }

    raise ("No matching recurring entry for the Recurring Master ID #{@parameters['recurring_master_id']}") if occurrence_id.empty?

    <<-RESULTS
    <results>
      <result name="occurrence_id">#{occurrence_id}</result>
    </results>
    RESULTS
  end


  # This is a template method that is used to escape results values (returned in
  # execute) that would cause the XML to be invalid.  This method is not
  # necessary if values do not contain character that have special meaning in
  # XML (&, ", <, and >), however it is a good practice to use it for all return
  # variable results in case the value could include one of those characters in
  # the future.  This method can be copied and reused between handlers.
  def escape(string)
    # Globally replace characters based on the ESCAPE_CHARACTERS constant
    string.to_s.gsub(/[&"><]/) { |special| ESCAPE_CHARACTERS[special] } if string
  end
  # This is a ruby constant that is used by the escape method
  ESCAPE_CHARACTERS = {'&'=>'&amp;', '>'=>'&gt;', '<'=>'&lt;', '"' => '&quot;'}

end


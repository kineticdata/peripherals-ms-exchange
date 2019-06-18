# Require the dependencies file to load the vendor libraries
require File.expand_path(File.join(File.dirname(__FILE__), 'dependencies'))

class ExchangeAppointmentUpdateRecurringV2
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

    # Validate the send_invitations parameter
    invitation_types = ['SendToNone','SendOnlyToAll','SendOnlyToChanged','SendToAllAndSaveCopy','SendToChangedAndSaveCopy']
    if !invitation_types.include? @parameters['send_invitations']
      raise StandardError, "Send Invitations value '#{@parameters['send_invitations']}' doesn't match one of #{invitation_types.join(",")}"
    end

    # validate inputs only if recurrence has been updated
    if !@parameters['recurrence_type'].to_s.empty? && !@parameters['duration_type'].to_s.empty?

      # validate inputs
      if ['relativeyear', 'absoluteyear', 'relativemonth', 'absolutemonth', 'weekly', 'daily'].include? (@parameters['recurrence_type'].downcase)
        validate_recurrence_params(@parameters['recurrence_type'].downcase)
      else
        raise "Recurrence Type (#{@parameters['recurrence_type']}) is invalid" 
      end

      # validate more inputs
      if @parameters['recurring_start'].empty?
        raise "Start Date of Recurrence is required."
      end

      # validate more inputs
      if ['no end date','has end date','number of occurrences'].include? (@parameters['duration_type'].downcase)
        if @parameters['duration_type'].downcase == "has end date" && @parameters['recurring_end'].empty?
          raise "End Date of Recurrence is required when the duration type of 'Has End Date' is specified."
        end 
        if @parameters['duration_type'].downcase == "number of occurrences" && @parameters['number_of_occurrences'].empty?
          raise "Number of Occurrences is required when the duration type of 'Number of Occurrences' is specified."
        end 
        if @parameters['duration_type'].downcase == "number of occurrences" && (@parameters['number_of_occurrences'] =~ /^[1-9][0-9]{0,2}$/).nil?
          raise "Number of Occurrences (#{@parameters['number_of_occurrences']}) must be from 1 to 999."
        end 
      end
    end

    endpoint = @info_values['server_address'] + "/ews/exchange.asmx"

    client = Viewpoint::EWSClient.new(
      endpoint, 
      @info_values['username'], 
      @info_values['password']#, 
      #http_opts: {ssl_verify_mode: 0}
    )

    calendar = client.get_folder(:calendar)

    updates = {}
    updates[:subject] = @parameters['subject'] if !@parameters['subject'].to_s.empty?
    updates[:start] = @parameters['start'] if !@parameters['start'].to_s.empty?
    updates[:end] = @parameters['end'] if !@parameters['end'].to_s.empty?
    updates[:location] = @parameters['location'] if !@parameters['location'].to_s.empty?
    updates[:body] = @parameters['body'] if !@parameters['body'].to_s.empty?
    updates[:required_attendees] = format_attendees(@parameters['required_attendees'])
    updates[:optional_attendees] = format_attendees(@parameters['optional_attendees'])
    #updates[:recurrence] = {:sub_elements => recurrence(@parameters['recurrence_type'].downcase, @parameters['duration_type'].downcase)} if !@parameters['recurrence_type'].to_s.empty? && !@parameters['duration_type'].to_s.empty?
    updates[:recurrence] = recurrence(@parameters['recurrence_type'].downcase, @parameters['duration_type'].downcase) if !@parameters['recurrence_type'].to_s.empty? && !@parameters['duration_type'].to_s.empty?
    if @parameters["manual_time_zone"].downcase == "yes"
      tz_id = convertTZNameToId(@parameters["time_zone_name"])
      updates[:start_time_zone] = {:id => tz_id}
      updates[:end_time_zone] = {:id => tz_id}
    end

    puts updates if @enable_debug_logging

    item = calendar.get_item(@parameters['appointment_id'])
    updated_item = item.update_item!(updates,{:send_meeting_invitations_or_cancellations => @parameters['send_invitations']})

    if updated_item == nil
      raise StandardError, "There was an unexpected error encountered when attempting to update the appointment with the inputted details"
    end

    "<results/>"
  end


  def format_attendees(attendees)
    split = attendees.split(",")
    if split != []
      # * Added an Array type to /lib/ews/types/calendar_item.rb at lines 80-85 for update_item!
      # NOTE: If you are passing an Array, you will need to use the build_xml 
      # structure when structuring your arrays.
      # ie. If you are passing text, {:name => {:text => "First Name"}}
      # If you are passing nested elements {:attendee => {:sub_elements => [{:name => {:text => "First Name"}}]}}
      sub_elements = []
      for email in split
        sub_elements.push({:attendee => {:sub_elements => [{:mailbox => {:sub_elements => [{:email_address => {:text =>email}}]}}]}})
      end
      return sub_elements
    else
      return nil
    end
  end

  def recurrence(recurrence_type,duration_type)
    recurrence_obj = []
    
    case recurrence_type
    when 'relativeyear'
      recurrence_obj.push({:relative_yearly_recurrence => {:sub_elements => [
        {:days_of_week => {:text => @parameters['days_of_week']}},
        {:day_of_week_index => {:text => @parameters['day_of_week_index']}},
        {:month => {:text => @parameters['month']}}
      ]}})
    when 'absoluteyear'
      recurrence_obj.push({:absolute_yearly_recurrence => {:sub_elements => [
        {:day_of_month => {:text => @parameters['day_of_month']}},
        {:month => {:text => @parameters['month']}}
      ]}})
    when 'relativemonth'
      recurrence_obj.push({:relative_monthly_recurrence => {:sub_elements => [
        {:interval => {:text => @parameters['interval']}},
        {:days_of_week => {:text => @parameters['days_of_week']}},
        {:day_of_week_index => {:text => @parameters['day_of_week_index']}}
      ]}})
    when 'absolutemonth'
      recurrence_obj.push({:absolute_monthly_recurrence => {:sub_elements => [
        {:interval => {:text => @parameters['interval']}},
        {:day_of_month => {:text => @parameters['day_of_month']}}
      ]}})
    when 'weekly'
      recurrence_obj.push({:weekly_recurrence => {:sub_elements => [
        {:interval => {:text => @parameters['interval']}},
        {:days_of_week => {:text => @parameters['days_of_week']}} #,
        # Per MS Specs, the First Day Of Week parameter is required, but it doesn't work if provided.  Commenting out this line
        #:first_day_of_week => {:text => @parameters['first_day_of_week']},
      ]}})
    when 'daily'
      recurrence_obj.push({:daily_recurrence => {:sub_elements => [
        {:interval => {:text => @parameters['interval']}}
      ]}})
    end

    case duration_type
    when 'no end date'
      ## The GEM works different for update than create. Create entries
      #  For update, use the start_date_r/end_date_r is necessary for create, start_date/end_date for update
      recurrence_obj.push({:no_end_recurrence => {:sub_elements => [
        #:start_date_r => {:text => @parameters['recurring_start']}
        {:start_date => {:text => @parameters['recurring_start']}}
      ]}})
    when 'has end date'
      recurrence_obj.push({:end_date_recurrence => {:sub_elements => [
        #:start_date_r => {:text => @parameters['recurring_start']},
        {:start_date => {:text => @parameters['recurring_start']}},
        #:end_date_r => {:text => @parameters['recurring_end']}
        {:end_date => {:text => @parameters['recurring_end']}}
      ]}})
    when 'number of occurrences'
      recurrence_obj.push({:numbered_recurrence => {:sub_elements => [
        #{:start_date_r => {:text => @parameters['recurring_start']}},
        {:start_date => {:text => @parameters['recurring_start']}},
        {:number_of_occurrences => {:text => @parameters['number_of_occurrences']}} 
      ]}})
    end

    return recurrence_obj
  end

  def validate_recurrence_params(recurrence_type)
      case recurrence_type
      when "relativeyear"
        raise "'Days of Week', 'Day of Week Index', and 'Month' are required inputs for #{@parameters['recurrence_type']} recurring events." if @parameters['days_of_week'].empty? || @parameters['day_of_week_index'].empty? || @parameters['month'].empty?
        validate_days_of_week(recurrence_type, @parameters['days_of_week'])
        validate_day_of_week_index(@parameters['day_of_week_index'])
        validate_month(@parameters['month'])
      when "absoluteyear"
        raise "'Month', 'Day of Month' are required inputs for #{@parameters['recurrence_type']} recurring events." if @parameters['month'].empty? || @parameters['day_of_month'].empty?
        validate_month(@parameters['month'])
        validate_day_of_month(@parameters['day_of_month'])
      when "relativemonth"
        raise "'Days of Week', 'Day of Week Index', and 'Interval' are required inputs for #{@parameters['recurrence_type']} recurring events." if @parameters['days_of_week'].empty? || @parameters['day_of_week_index'].empty? || @parameters['interval'].empty?
        validate_days_of_week(recurrence_type, @parameters['days_of_week'])
        validate_day_of_week_index(@parameters['day_of_week_index'])
        validate_interval(recurrence_type, @parameters['interval'])
      when "absolutemonth"
        raise "'Day of Month' and 'Interval' are required inputs for #{@parameters['recurrence_type']} recurring events." if @parameters['day_of_month'].empty? || @parameters['interval'].empty?
        validate_day_of_month(@parameters['day_of_month'])
        validate_interval(recurrence_type, @parameters['interval']) 
      when "weekly"
        # Per MS Specs, the First Day Of Week is required, but it doesn't work if provided.  Commendint out this line.
        #raise "'Days of Week', 'Interval', and 'First Day of Week' are required inputs for #{@parameters['recurrence_type']} recurring events." if @parameters['days_of_week'].empty? || @parameters['interval'].empty? || @parameters['first_day_of_week'].empty?
        raise "'Days of Week' and 'Interval' are required inputs for #{@parameters['recurrence_type']} recurring events." if @parameters['days_of_week'].empty? || @parameters['interval'].empty?
        validate_days_of_week(recurrence_type, @parameters['days_of_week'])
        validate_interval(recurrence_type, @parameters['interval'])
        # Per MS Specs, the First Day Of Week is required, but it doesn't work if provided.  Commenting out this line.
        #validate_first_day_of_week(@parameters['first_day_of_week'])
      when "daily"
        raise "'Interval' is a required input for #{@parameters['recurrence_type']} recurring events." if @parameters['interval'].empty?
        validate_interval(recurrence_type, @parameters['interval'])
      end
  end

  # Validate the days of the week input element.
  # Weekly recurring types can include multiple days
  def validate_days_of_week(recurrence_type,days_of_week)
    day_of_week_optons = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Day','Weekday','Weekend Day']
    if recurrence_type == "weekly"
      day_of_week_optons.slice!(-3)
      valid=true;
      days_of_week.split(" ").each{|value|
        if valid
          valid = day_of_week_optons.include? (value)
        end
      }
      if valid
        return true
      else
        raise "Days of Week value '#{days_of_week}' is invalid. Options are 'Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday' (or combinations of these, separated by a space)."
      return valid
    end
    else
      if day_of_week_optons.include? (days_of_week)
        return true
      else
        raise "Days of Week value '#{days_of_week}' is invalid. Options are 'Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Day','Weekday','Weekend Day'."
      end
    end
  end

  # Validate the day of the week index
  def validate_day_of_week_index(day_of_week_index)
    day_of_week_index_optons = ['First','Second','Third','Fourth','Last']
    if day_of_week_index_optons.include? (day_of_week_index)
      return true
    else
      raise "Days of Week Index value '#{day_of_week_index}' is invalid. Valid options are 'First','Second','Third','Fourth','Last'."
    end
  end
  
  # Validate the month
  def validate_month(month)
    month_options=['January','February','March','April','May','June','July','August','September','October','November','December']
    if month_options.include? (month)
      return true
    else
      raise "Month value '#{month}' is invalid. Valid options are 'January','February','March','April','May','June','July','August','September','October','November','December'."
    end
  end

  # Validate the day of month
  def validate_day_of_month(day_of_month)
    if day_of_month =~ /^([1-9]|[1-2][0-9]|30|31)$/
      return true
    else
      raise "Day of Month value '#{day_of_month}' is invalid. Values from 1 to 31 are the valid options."
    end
  end

  # Validate the interval
  def validate_interval(recurrence_type,interval)
    if recurrence_type=='daily'
      if interval =~ /^[1-9][0-9]{0,2}$/
        return true
      else
        raise "Interval value '#{interval}' is invalid. Values from 1 to 999 are the valid options."
      end
    else
      if interval =~ /^[1-9][0-9]{0,1}$/
        return true
      else
        raise "Interval value ('#{interval}') is invalid. Values from 1 to 99 are the only options."
      end
    end
  end

  # Validate the first_day_of_week
  def validate_first_day_of_week(first_day_of_week)
    first_day_of_week_options = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday']
    if first_day_of_week_options.include? (first_day_of_week)
      return true
    else
      raise "First Day of Week value ('#{first_day_of_week}') is invalid. Valid options are 'Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'."
    end
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

  def convertTZNameToId(name)
    time_zone_map = {
      "(UTC-12:00) International Date Line West" => "Dateline Standard Time",
      "(UTC-11:00) Coordinated Universal Time-11" => "UTC-11",
      "(UTC-11:00) Midway Island; Samoa" => "Samoa Standard Time",
      "(UTC-10:00) Aleutian Islands" => "Aleutian Standard Time",
      "(UTC-10:00) Hawaii" => "Hawaiian Standard Time",
      "(UTC-09:30) Marquesas Islands" => "Marquesas Standard Time",
      "(UTC-09:00) Alaska" => "Alaskan Standard Time",
      "(UTC-09:00) Coordinated Universal Time-09" => "UTC-09",
      "(UTC-08:00) Coordinated Universal Time-08" => "UTC-08",
      "(UTC-08:00) Pacific Time (US & Canada)" => "Pacific Standard Time",
      "(UTC-08:00) Tijuana; Baja California" => "Pacific Standard Time (Mexico)",
      "(UTC-07:00) Arizona" => "US Mountain Standard Time",
      "(UTC-07:00) Chihuahua; La Paz; Mazatlan" => "Mountain Standard Time (Mexico)",
      "(UTC-07:00) Mountain Time (US & Canada)" => "Mountain Standard Time",
      "(UTC-05:00) Chetumal" => "Eastern Standard Time (Mexico)",
      "(UTC-06:00) Central America" => "Central America Standard Time",
      "(UTC-06:00) Central Time (US & Canada)" => "Central Standard Time",
      "(UTC-06:00) Easter Island" => "Easter Island Standard Time",
      "(UTC-06:00) Guadalajara; Mexico City; Monterrey" => "Central Standard Time (Mexico)",
      "(UTC-06:00) Saskatchewan" => "Canada Central Standard Time",
      "(UTC-04:00) Turks and Caicos" => "Turks And Caicos Standard Time",
      "(UTC-05:00) Bogota; Lima; Quito" => "SA Pacific Standard Time",
      "(UTC-05:00) Eastern Time (US & Canada)" => "Eastern Standard Time",
      "(UTC-05:00) Haiti" => "Haiti Standard Time",
      "(UTC-05:00) Havana" => "Cuba Standard Time",
      "(UTC-05:00) Indiana (East)" => "US Eastern Standard Time",
      "(UTC-04:30) Caracas" => "Venezuela Standard Time",
      "(UTC-04:00) Asuncion" => "Paraguay Standard Time",
      "(UTC-04:00) Atlantic Time (Canada)" => "Atlantic Standard Time",
      "(UTC-04:00) Georgetown; La Paz; San Juan" => "SA Western Standard Time",
      "(UTC-04:00) Manaus" => "Central Brazilian Standard Time",
      "(UTC-04:00) Santiago" => "Pacific SA Standard Time",
      "(UTC-03:30) Newfoundland" => "Newfoundland Standard Time",
      "(UTC-03:00) Araguaina" => "Tocantins Standard Time",
      "(UTC-03:00) Brasilia" => "E. South America Standard Time",
      "(UTC-03:00) Buenos Aires" => "Argentina Standard Time",
      "(UTC-03:00) Cayenne" => "SA Eastern Standard Time",
      "(UTC-03:00) Greenland" => "Greenland Standard Time",
      "(UTC-03:00) Montevideo" => "Montevideo Standard Time",
      "(UTC-03:00) Saint Pierre and Miquelon" => "Saint Pierre Standard Time",
      "(UTC-03:00) Salvador" => "Bahia Standard Time",
      "(UTC-02:00) Coordinated Universal Time-02" => "UTC-02",
      "(UTC-02:00) Mid-Atlantic" => "Mid-Atlantic Standard Time",
      "(UTC-01:00) Azores" => "Azores Standard Time",
      "(UTC-01:00) Cape Verde Is." => "Cape Verde Standard Time",
      "(UTC) Casablanca" => "Morocco Standard Time",
      "(UTC) Coordinated Universal Time" => "UTC",
      "(UTC) Greenwich Mean Time : Dublin; Edinburgh; Lisbon; London" => "GMT Standard Time",
      "(UTC) Monrovia; Reykjavik" => "Greenwich Standard Time",
      "(UTC+01:00) Amsterdam; Berlin; Bern; Rome; Stockholm; Vienna" => "W. Europe Standard Time",
      "(UTC+01:00) Belgrade; Bratislava; Budapest; Ljubljana; Prague" => "Central Europe Standard Time",
      "(UTC+01:00) Brussels; Copenhagen; Madrid; Paris" => "Romance Standard Time",
      "(UTC+01:00) Sarajevo; Skopje; Warsaw; Zagreb" => "Central European Standard Time",
      "(UTC+01:00) West Central Africa" => "W. Central Africa Standard Time",
      "(UTC+02:00) Tripoli" => "Libya Standard Time",
      "(UTC+02:00) Windhoek" => "Namibia Standard Time",
      "(UTC+02:00) Amman" => "Jordan Standard Time",
      "(UTC+02:00) Athens; Bucharest; Istanbul" => "GTB Standard Time",
      "(UTC+02:00) Beirut" => "Middle East Standard Time",
      "(UTC+02:00) Cairo" => "Egypt Standard Time",
      "(UTC+02:00) Damascus" => "Syria Standard Time",
      "(UTC+02:00) Gaza; Hebron" => "West Bank Standard Time",
      "(UTC+02:00) Harare; Pretoria" => "South Africa Standard Time",
      "(UTC+02:00) Helsinki; Kyiv; Riga; Sofia; Tallinn; Vilnius" => "FLE Standard Time",
      "(UTC+02:00) Istanbul" => "Turkey Standard Time",
      "(UTC+02:00) Jerusalem" => "Israel Standard Time",
      "(UTC+02:00) Kaliningrad" => "Kaliningrad Standard Time",
      "(UTC+02:00) Minsk" => "E. Europe Standard Time",
      "(UTC+03:00) Minsk" => "Belarus Standard Time",
      "(UTC+03:00) Baghdad" => "Arabic Standard Time",
      "(UTC+03:00) Kuwait; Riyadh" => "Arab Standard Time",
      "(UTC+03:00) Moscow; St. Petersburg; Volgograd" => "Russian Standard Time",
      "(UTC+03:00) Nairobi" => "E. Africa Standard Time",
      "(UTC+04:00) Astrakhan; Ulyanovsk" => "Astrakhan Standard Time",
      "(UTC+04:00) Izhevsk; Samara" => "Russia Time Zone 3",
      "(UTC+03:30) Tehran" => "Iran Standard Time",
      "(UTC+03:00) Tbilisi" => "Georgian Standard Time",
      "(UTC+04:00) Abu Dhabi; Muscat" => "Arabian Standard Time",
      "(UTC+04:00) Baku" => "Azerbaijan Standard Time",
      "(UTC+04:00) Port Louis" => "Mauritius Standard Time",
      "(UTC+04:00) Yerevan" => "Caucasus Standard Time",
      "(UTC+04:30) Kabul" => "Afghanistan Standard Time",
      "(UTC+05:00) Ekaterinburg" => "Ekaterinburg Standard Time",
      "(UTC+05:00) Islamabad; Karachi" => "Pakistan Standard Time",
      "(UTC+05:00) Tashkent" => "West Asia Standard Time",
      "(UTC+05:30) Chennai; Kolkata; Mumbai; New Delhi" => "India Standard Time",
      "(UTC+05:30) Sri Jayawardenepura" => "Sri Lanka Standard Time",
      "(UTC+05:45) Kathmandu" => "Nepal Standard Time",
      "(UTC+06:00) Almaty; Novosibirsk" => "N. Central Asia Standard Time",
      "(UTC+06:00) Astana" => "Central Asia Standard Time",
      "(UTC+06:00) Dhaka" => "Bangladesh Standard Time",
      "(UTC+07:00) Barnaul; Gorno-Altaysk" => "Altai Standard Time",
      "(UTC+07:00) Tomsk" => "Tomsk Standard Time",
      "(UTC+06:30) Yangon (Rangoon)" => "Myanmar Standard Time",
      "(UTC+07:00) Bangkok; Hanoi; Jakarta" => "SE Asia Standard Time",
      "(UTC+07:00) Hovd" => "W. Mongolia Standard Time",
      "(UTC+07:00) Krasnoyarsk" => "North Asia Standard Time",
      "(UTC+08:00) Beijing; Chongqing; Hong Kong; Urumqi" => "China Standard Time",
      "(UTC+08:00) Irkutsk; Ulaan Bataar" => "North Asia East Standard Time",
      "(UTC+08:00) Kuala Lumpur; Singapore" => "Singapore Standard Time",
      "(UTC+08:00) Perth" => "W. Australia Standard Time",
      "(UTC+08:00) Taipei" => "Taipei Standard Time",
      "(UTC+08:00) Ulaanbaatar" => "Ulaanbaatar Standard Time",
      "(UTC+09:00) Chita" => "Transbaikal Standard Time",
      "(UTC+08:30) Pyongyang" => "North Korea Standard Time",
      "(UTC+08:45) Eucla" => "Aus Central W. Standard Time",
      "(UTC+09:00) Osaka; Sapporo; Tokyo" => "Tokyo Standard Time",
      "(UTC+09:00) Seoul" => "Korea Standard Time",
      "(UTC+09:00) Yakutsk" => "Yakutsk Standard Time",
      "(UTC+09:30) Adelaide" => "Cen. Australia Standard Time",
      "(UTC+09:30) Darwin" => "AUS Central Standard Time",
      "(UTC+10:00) Brisbane" => "E. Australia Standard Time",
      "(UTC+10:00) Canberra; Melbourne; Sydney" => "AUS Eastern Standard Time",
      "(UTC+10:00) Guam; Port Moresby" => "West Pacific Standard Time",
      "(UTC+10:00) Hobart" => "Tasmania Standard Time",
      "(UTC+10:00) Vladivostok" => "Vladivostok Standard Time",
      "(UTC+11:00) Bougainville Island" => "Bougainville Standard Time",
      "(UTC+11:00) Magadan" => "Magadan Standard Time",
      "(UTC+11:00) Sakhalin" => "Sakhalin Standard Time",
      "(UTC+10:30) Lord Howe Island" => "Lord Howe Standard Time",
      "(UTC+11:00) Chokurdakh" => "Russia Time Zone 10",
      "(UTC+11:00) Magadan; Solomon Is.; New Caledonia" => "Central Pacific Standard Time",
      "(UTC+11:00) Norfolk Island" => "Norfolk Standard Time",
      "(UTC+12:00) Anadyr; Petropavlovsk-Kamchatsky" => "Russia Time Zone 11",
      "(UTC+12:00) Auckland; Wellington" => "New Zealand Standard Time",
      "(UTC+12:00) Coordinated Universal Time+12" => "UTC+12",
      "(UTC+12:00) Fiji; Marshall Is." => "Fiji Standard Time",
      "(UTC+12:00) Petropavlovsk-Kamchatsky" => "Kamchatka Standard Time",
      "(UTC+12:45) Chatham Islands" => "Chatham Islands Standard Time",
      "(UTC+13:00) Nuku'alofa" => "Tonga Standard Time",
      "(UTC+14:00) Kiritimati Island" => "Line Islands Standard Time"
    }
    return time_zone_map[name]
  end

end


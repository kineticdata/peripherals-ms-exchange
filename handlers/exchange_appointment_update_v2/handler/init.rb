# Require the dependencies file to load the vendor libraries
require File.expand_path(File.join(File.dirname(__FILE__), 'dependencies'))

class ExchangeAppointmentUpdateV2
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

    # Validate the send_invitations parameter
    invitation_types = ['SendToNone','SendOnlyToAll', 'SendOnlyToChanged','SendToAllAndSaveCopy','SendToChangedAndSaveCopy']
    if !invitation_types.include? @parameters['send_invitations']
      raise StandardError, "The value '#{@parameters['send_invitations']}' doesn't match one of #{invitation_types.join(",")}"
    end
  end

  def execute()

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
    updates[:required_attendees] = format_attendees(@parameters['required_attendees'].to_s)
    updates[:optional_attendees] = format_attendees(@parameters['optional_attendees'].to_s)
    if @parameters["manual_time_zone"].downcase == "yes"
      tz_id = convertTZNameToId(@parameters["time_zone_name"])
      updates[:start_time_zone] = {:id => tz_id}
      updates[:end_time_zone] = {:id => tz_id}
    end

    puts updates

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


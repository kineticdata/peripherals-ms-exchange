# Require the dependencies file to load the vendor libraries
require File.expand_path(File.join(File.dirname(__FILE__), 'dependencies'))

class ExchangeAppointmentSearchV1
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
    endpoint = @info_values['server_address'] + "/ews/exchange.asmx"

    client = Viewpoint::EWSClient.new(
      endpoint, 
      @info_values['username'], 
      @info_values['password']#,
      #http_opts: {ssl_verify_mode: 0}
    )

    calendar = client.get_folder(:calendar)

    sd = Date.iso8601 @parameters['start']
    ed = Date.iso8601 @parameters['end']
    items = calendar.items_between sd,ed

    if !@parameters['subject'].to_s.empty?
      matched_items = []
      for item in items 
        matched_items.push(item) if item.subject.downcase.include?(@parameters['subject'].downcase)
      end
      items = matched_items
    end

    json = []
    for item in items
      item_json = {
        'id' => item.id,
        'subject' => item.subject,
        'location' => item.location,
        'body' => item.body,
        'start' => item.start.iso8601,
        'end' => item.end.iso8601,
        'all_day' => item.all_day?,
        'required_attendees' => item.required_attendees,
        'optional_attendees' => item.optional_attendees
      }
      json.push(item_json)
    end

    <<-RESULTS
<results>
  <result name="appointments_json">#{escape(json)}</result>
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


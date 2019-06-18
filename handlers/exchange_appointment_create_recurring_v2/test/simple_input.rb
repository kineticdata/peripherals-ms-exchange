{
  'info' => {
    'username' => '',
    'password' => '',
    'server_address' => '',
    'enable_debug_logging' => 'Yes'
  },
  'parameters' => {
    'recurrence_type' => 'Weekly',         # Options are 'RelativeYear', 'AbsoluteYear', 'RelativeMonth', 'AbsoluteMonth', 'Weekly', 'Daily'
    'duration_type' => 'Number of Occurrences',           # Options are 'No End Date', 'Has End Date', 'Number of Occurrences'
    'days_of_week' => 'Sunday',            # Options are 'Sunday', 'Monday', 'Tuesday', 'Wednesday', Thursday', 'Friday', 'Saturday', 'Day', 'Weekday', 'Weekend Day'
    'day_of_week_index' => '',       # Options are 'First', 'Second', 'Third', 'Fourth', 'Last'
    'month' => '',                   # Options are 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'
    'day_of_month' => '',            # Options are 1 to 31
    'interval' => '1',                # 1 to 99 or 1 to 999 depending on recurrence type
    #'first_day_of_week' => '',      # Options are 'Sunday', 'Monday', 'Tuesday', 'Wednesday', Thursday', 'Friday', 'Saturday'
                                     # Per MS Spec, First Day Of Week is required, but it doesn't work if provided. Removed from node.xml
    'recurring_start' => '2016-09-04',         # YYYY-MM-DD or YYYY-MM-DD
    'recurring_end' => '',           # YYYY-MM-DD or YYYY-MM-DD-HH:MM
    'number_of_occurrences' => '3',   # 1 to 999
    'subject' => 'Go to bed, its 2AM on Sunday', 
    'location' => '',
    'body' => '',
    'start' => '2016-09-04T02:00:00',
    'end' => '2016-09-04T03:00:00',
    'manual_time_zone' => 'Yes',
    'time_zone_name' => '',
    'required_attendees' => 'scott.gerike@kineticdata.com',
    'optional_attendees' => '',
    'send_invitations' => 'SendToAllAndSaveCopy'
  }
}
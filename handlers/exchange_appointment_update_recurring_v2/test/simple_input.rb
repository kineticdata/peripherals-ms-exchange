{
  'info' => {
    'username' => '',
    'password' => '',
    'server_address' => '',
    'enable_debug_logging' => 'Yes'
  },
  'parameters' => {
    'appointment_id' => 'AAMkADVjNDJhODA5LThjZjMtNDBhMy1hZmM3LTgwNjRmMTlmN2NlYgBGAAAAAACP7mhANVbKQKOlXkOdVPjvBwCZxDoUBM37Qpr7RY2rEhHPAAAA2ZCeAACZxDoUBM37Qpr7RY2rEhHPAAId5ubFAAA=',
    'recurrence_type' => 'Weekly',         # Options are 'RelativeYear', 'AbsoluteYear', 'RelativeMonth', 'AbsoluteMonth', 'Weekly', 'Daily'
    'duration_type' => 'Number of Occurrences',           # Options are 'No End Date', 'Has End Date', 'Number of Occurrences'
    'days_of_week' => 'Thursday',            # Options are 'Sunday', 'Monday', 'Tuesday', 'Wednesday', Thursday', 'Friday', 'Saturday', 'Day', 'Weekday', 'Weekend Day'
    'day_of_week_index' => '',       # Options are 'First', 'Second', 'Third', 'Fourth', 'Last'
    'month' => '',                   # Options are 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'
    'day_of_month' => '',            # Options are 1 to 31
    'interval' => '1',                # 1 to 99 or 1 to 999 depending on recurrence type
    #'first_day_of_week' => '',      # Options are 'Sunday', 'Monday', 'Tuesday', 'Wednesday', Thursday', 'Friday', 'Saturday'
                                     # Per MS Spec, First Day Of Week is required, but it doesn't work if provided. Removed from node.xml
    'recurring_start' => '2016-09-08',         # YYYY-MM-DD or YYYY-MM-DD
    'recurring_end' => '',           # YYYY-MM-DD or YYYY-MM-DD-HH:MM
    'number_of_occurrences' => '3',   # 1 to 999
    'subject' => 'Updating to Thursday', 
    'location' => '',
    'body' => '',
    'start' => '2016-09-08T09:00:00',
    'end' => '2016-09-08T10:00:00',
    'manual_time_zone' => 'Yes',
    'time_zone_name' => '(UTC-06:00) Central Time (US & Canada)',
    'required_attendees' => '',
    'optional_attendees' => '',
    'send_invitations' => 'SendToAllAndSaveCopy'
  }
}
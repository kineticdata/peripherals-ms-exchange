=begin
  This file is part of Viewpoint; the Ruby library for Microsoft Exchange Web Services.

  Copyright © 2011 Dan Wanek <dan.wanek@gmail.com>

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
=end

module Viewpoint
  module EWS
    module ItemFieldUriMap

      FIELD_URIS= {
        :folder_id  => {:text => 'folder:FolderId', :writable => true},
        :parent_folder_id  => {:text => 'folder:ParentFolderId', :writable => true},
        :display_name  => {:text => 'folder:DisplayName', :writable => true},
        :unread_count  => {:text => 'folder:UnreadCount', :writable => true},
        :total_count  => {:text => 'folder:TotalCount', :writable => true},
        :child_folder_count  => {:text => 'folder:ChildFolderCount', :writable => true},
        :folder_class  => {:text => 'folder:FolderClass', :writable => true},
        :search_parameters  => {:text => 'folder:SearchParameters', :writable => true},
        :managed_folder_information  => {:text => 'folder:ManagedFolderInformation', :writable => true},
        :permission_set  => {:text => 'folder:PermissionSet', :writable => true},
        :effective_rights  => {:text => 'folder:EffectiveRights', :writable => true},
        :sharing_effective_rights  => {:text => 'folder:SharingEffectiveRights', :writable => true},
        :item_id  => {:text => 'item:ItemId', :writable => true},
        :parent_folder_id  => {:text => 'item:ParentFolderId', :writable => true},
        :item_class  => {:text => 'item:ItemClass', :writable => true},
        :mime_content  => {:text => 'item:MimeContent', :writable => true},
        :attachments  => {:text => 'item:Attachments', :writable => true},
        :subject  => {:text => 'item:Subject', :writable => true},
        :date_time_received  => {:text => 'item:DateTimeReceived', :writable => true},
        :size  => {:text => 'item:Size', :writable => true},
        :categories  => {:text => 'item:Categories', :writable => true},
        :has_attachments  => {:text => 'item:HasAttachments', :writable => true},
        :importance  => {:text => 'item:Importance', :writable => true},
        :in_reply_to  => {:text => 'item:InReplyTo', :writable => true},
        :internet_message_headers  => {:text => 'item:InternetMessageHeaders', :writable => true},
        :is_associated  => {:text => 'item:IsAssociated', :writable => true},
        :is_draft  => {:text => 'item:IsDraft', :writable => true},
        :is_from_me  => {:text => 'item:IsFromMe', :writable => true},
        :is_resend  => {:text => 'item:IsResend', :writable => true},
        :is_submitted  => {:text => 'item:IsSubmitted', :writable => true},
        :is_unmodified  => {:text => 'item:IsUnmodified', :writable => true},
        :date_time_sent  => {:text => 'item:DateTimeSent', :writable => true},
        :date_time_created  => {:text => 'item:DateTimeCreated', :writable => true},
        :body  => {:text => 'item:Body', :writable => true},
        :response_objects  => {:text => 'item:ResponseObjects', :writable => true},
        :sensitivity  => {:text => 'item:Sensitivity', :writable => true},
        :reminder_due_by  => {:text => 'item:ReminderDueBy', :writable => true},
        :reminder_is_set  => {:text => 'item:ReminderIsSet', :writable => true},
        :reminder_minutes_before_start  => {:text => 'item:ReminderMinutesBeforeStart', :writable => true},
        :display_to  => {:text => 'item:DisplayTo', :writable => true},
        :display_cc  => {:text => 'item:DisplayCc', :writable => true},
        :culture  => {:text => 'item:Culture', :writable => true},
        :effective_rights  => {:text => 'item:EffectiveRights', :writable => true},
        :last_modified_name  => {:text => 'item:LastModifiedName', :writable => true},
        :last_modified_time  => {:text => 'item:LastModifiedTime', :writable => true},
        :conversation_id  => {:text => 'item:ConversationId', :writable => true},
        :unique_body  => {:text => 'item:UniqueBody', :writable => true},
        :web_client_read_form_query_string  => {:text => 'item:WebClientReadFormQueryString', :writable => true},
        :web_client_edit_form_query_string  => {:text => 'item:WebClientEditFormQueryString', :writable => true},
        :conversation_index  => {:text => 'message:ConversationIndex', :writable => true},
        :conversation_topic  => {:text => 'message:ConversationTopic', :writable => true},
        :internet_message_id  => {:text => 'message:InternetMessageId', :writable => true},
        :is_read  => {:text => 'message:IsRead', :writable => true},
        :is_response_requested  => {:text => 'message:IsResponseRequested', :writable => true},
        :is_read_receipt_requested  => {:text => 'message:IsReadReceiptRequested', :writable => true},
        :is_delivery_receipt_requested  => {:text => 'message:IsDeliveryReceiptRequested', :writable => true},
        :references  => {:text => 'message:References', :writable => true},
        :reply_to  => {:text => 'message:ReplyTo', :writable => true},
        :from  => {:text => 'message:From', :writable => true},
        :sender  => {:text => 'message:Sender', :writable => true},
        :to_recipients  => {:text => 'message:ToRecipients', :writable => true},
        :cc_recipients  => {:text => 'message:CcRecipients', :writable => true},
        :bcc_recipients  => {:text => 'message:BccRecipients', :writable => true},
        :associated_calendar_item_id  => {:text => 'meeting:AssociatedCalendarItemId', :writable => true},
        :is_delegated  => {:text => 'meeting:IsDelegated', :writable => true},
        :is_out_of_date  => {:text => 'meeting:IsOutOfDate', :writable => true},
        :has_been_processed  => {:text => 'meeting:HasBeenProcessed', :writable => true},
        :response_type  => {:text => 'meeting:ResponseType', :writable => true},
        :meeting_request_type  => {:text => 'meetingRequest:MeetingRequestType', :writable => true},
        :intended_free_busy_status  => {:text => 'meetingRequest:IntendedFreeBusyStatus', :writable => true},
        :start  => {:text => 'calendar:Start', :writable => true},
        :end  => {:text => 'calendar:End', :writable => true},
        :original_start  => {:text => 'calendar:OriginalStart', :writable => true},
        :is_all_day_event  => {:text => 'calendar:IsAllDayEvent', :writable => true},
        :legacy_free_busy_status  => {:text => 'calendar:LegacyFreeBusyStatus', :writable => true},
        :location  => {:text => 'calendar:Location', :writable => true},
        :when  => {:text => 'calendar:When', :writable => true},
        :is_meeting  => {:text => 'calendar:IsMeeting', :writable => true},
        :is_cancelled  => {:text => 'calendar:IsCancelled', :writable => true},
        :is_recurring  => {:text => 'calendar:IsRecurring', :writable => true},
        :meeting_request_was_sent  => {:text => 'calendar:MeetingRequestWasSent', :writable => true},
        :is_response_requested  => {:text => 'calendar:IsResponseRequested', :writable => true},
        :calendar_item_type  => {:text => 'calendar:CalendarItemType', :writable => true},
        :my_response_type  => {:text => 'calendar:MyResponseType', :writable => true},
        :organizer  => {:text => 'calendar:Organizer', :writable => true},
        :required_attendees  => {:text => 'calendar:RequiredAttendees', :writable => true},
        :optional_attendees  => {:text => 'calendar:OptionalAttendees', :writable => true},
        :resources  => {:text => 'calendar:Resources', :writable => true},
        :conflicting_meeting_count  => {:text => 'calendar:ConflictingMeetingCount', :writable => true},
        :adjacent_meeting_count  => {:text => 'calendar:AdjacentMeetingCount', :writable => true},
        :conflicting_meetings  => {:text => 'calendar:ConflictingMeetings', :writable => true},
        :adjacent_meetings  => {:text => 'calendar:AdjacentMeetings', :writable => true},
        :duration  => {:text => 'calendar:Duration', :writable => true},
        :time_zone  => {:text => 'calendar:TimeZone', :writable => true},
        :appointment_reply_time  => {:text => 'calendar:AppointmentReplyTime', :writable => true},
        :appointment_sequence_number  => {:text => 'calendar:AppointmentSequenceNumber', :writable => true},
        :appointment_state  => {:text => 'calendar:AppointmentState', :writable => true},
        :recurrence  => {:text => 'calendar:Recurrence', :writable => true},
        :first_occurrence  => {:text => 'calendar:FirstOccurrence', :writable => true},
        :last_occurrence  => {:text => 'calendar:LastOccurrence', :writable => true},
        :modified_occurrences  => {:text => 'calendar:ModifiedOccurrences', :writable => true},
        :deleted_occurrences  => {:text => 'calendar:DeletedOccurrences', :writable => true},
        :meeting_time_zone  => {:text => 'calendar:MeetingTimeZone', :writable => true},
        :conference_type  => {:text => 'calendar:ConferenceType', :writable => true},
        :allow_new_time_proposal  => {:text => 'calendar:AllowNewTimeProposal', :writable => true},
        :is_online_meeting  => {:text => 'calendar:IsOnlineMeeting', :writable => true},
        :meeting_workspace_url  => {:text => 'calendar:MeetingWorkspaceUrl', :writable => true},
        :net_show_url  => {:text => 'calendar:NetShowUrl', :writable => true},
        :u_i_d  => {:text => 'calendar:UID', :writable => true},
        :recurrence_id  => {:text => 'calendar:RecurrenceId', :writable => true},
        :date_time_stamp  => {:text => 'calendar:DateTimeStamp', :writable => true},
        :start_time_zone  => {:text => 'calendar:StartTimeZone', :writable => true},
        :end_time_zone  => {:text => 'calendar:EndTimeZone', :writable => true},
        :actual_work  => {:text => 'task:ActualWork', :writable => true},
        :assigned_time  => {:text => 'task:AssignedTime', :writable => true},
        :billing_information  => {:text => 'task:BillingInformation', :writable => true},
        :change_count  => {:text => 'task:ChangeCount', :writable => true},
        :companies  => {:text => 'task:Companies', :writable => true},
        :complete_date  => {:text => 'task:CompleteDate', :writable => true},
        :contacts  => {:text => 'task:Contacts', :writable => true},
        :delegation_state  => {:text => 'task:DelegationState', :writable => true},
        :delegator  => {:text => 'task:Delegator', :writable => true},
        :due_date  => {:text => 'task:DueDate', :writable => true},
        :is_assignment_editable  => {:text => 'task:IsAssignmentEditable', :writable => true},
        :is_complete  => {:text => 'task:IsComplete', :writable => true},
        :is_recurring  => {:text => 'task:IsRecurring', :writable => true},
        :is_team_task  => {:text => 'task:IsTeamTask', :writable => true},
        :mileage  => {:text => 'task:Mileage', :writable => true},
        :owner  => {:text => 'task:Owner', :writable => true},
        :percent_complete  => {:text => 'task:PercentComplete', :writable => true},
        #:recurrence  => {:text => 'task:Recurrence', :writable => true},
        :start_date  => {:text => 'task:StartDate', :writable => true},
        :status  => {:text => 'task:Status', :writable => true},
        :status_description  => {:text => 'task:StatusDescription', :writable => true},
        :total_work  => {:text => 'task:TotalWork', :writable => true},
        :assistant_name  => {:text => 'contacts:AssistantName', :writable => true},
        :birthday  => {:text => 'contacts:Birthday', :writable => true},
        :business_home_page  => {:text => 'contacts:BusinessHomePage', :writable => true},
        :children  => {:text => 'contacts:Children', :writable => true},
        :companies  => {:text => 'contacts:Companies', :writable => true},
        :company_name  => {:text => 'contacts:CompanyName', :writable => true},
        :complete_name  => {:text => 'contacts:CompleteName', :writable => true},
        :contact_source  => {:text => 'contacts:ContactSource', :writable => true},
        :culture  => {:text => 'contacts:Culture', :writable => true},
        :department  => {:text => 'contacts:Department', :writable => true},
        :display_name  => {:text => 'contacts:DisplayName', :writable => true},
        :email_addresses  => {:ftype => :indexed_field_uRI, :text => 'contacts:EmailAddress', :writable => true},
        :file_as  => {:text => 'contacts:FileAs', :writable => true},
        :file_as_mapping  => {:text => 'contacts:FileAsMapping', :writable => true},
        :generation  => {:text => 'contacts:Generation', :writable => true},
        :given_name  => {:text => 'contacts:GivenName', :writable => true},
        :has_picture  => {:text => 'contacts:HasPicture', :writable => true},
        :im_addresses  => {:text => 'contacts:ImAddresses', :writable => true},
        :initials  => {:text => 'contacts:Initials', :writable => true},
        :job_title  => {:text => 'contacts:JobTitle', :writable => true},
        :manager  => {:text => 'contacts:Manager', :writable => true},
        :middle_name  => {:text => 'contacts:MiddleName', :writable => true},
        :mileage  => {:text => 'contacts:Mileage', :writable => true},
        :nickname  => {:text => 'contacts:Nickname', :writable => true},
        :office_location  => {:text => 'contacts:OfficeLocation', :writable => true},
        :phone_numbers  => {:ftype => :indexed_field_uRI, :text => 'contacts:PhoneNumber', :writable => true},
        :physical_addresses  => {:text => 'contacts:PhysicalAddresses', :writable => true},
        :postal_address_index  => {:text => 'contacts:PostalAddressIndex', :writable => true},
        :profession  => {:text => 'contacts:Profession', :writable => true},
        :spouse_name  => {:text => 'contacts:SpouseName', :writable => true},
        :surname  => {:text => 'contacts:Surname', :writable => true},
        :wedding_anniversary  => {:text => 'contacts:WeddingAnniversary', :writable => true},
        :members  => {:text => 'distributionlist:Members', :writable => true},
        :posted_time  => {:text => 'postitem:PostedTime', :writable => true},
        :conversation_id  => {:text => 'conversation:ConversationId', :writable => true},
        :conversation_topic  => {:text => 'conversation:ConversationTopic', :writable => true},
        :unique_recipients  => {:text => 'conversation:UniqueRecipients', :writable => true},
        :global_unique_recipients  => {:text => 'conversation:GlobalUniqueRecipients', :writable => true},
        :unique_unread_senders  => {:text => 'conversation:UniqueUnreadSenders', :writable => true},
        :global_unique_unread_senders  => {:text => 'conversation:GlobalUniqueUnreadSenders', :writable => true},
        :unique_senders  => {:text => 'conversation:UniqueSenders', :writable => true},
        :global_unique_senders  => {:text => 'conversation:GlobalUniqueSenders', :writable => true},
        :last_delivery_time  => {:text => 'conversation:LastDeliveryTime', :writable => true},
        :global_last_delivery_time  => {:text => 'conversation:GlobalLastDeliveryTime', :writable => true},
        :categories  => {:text => 'conversation:Categories', :writable => true},
        :global_categories  => {:text => 'conversation:GlobalCategories', :writable => true},
        :flag_status  => {:text => 'conversation:FlagStatus', :writable => true},
        :global_flag_status  => {:text => 'conversation:GlobalFlagStatus', :writable => true},
        :has_attachments  => {:text => 'conversation:HasAttachments', :writable => true},
        :global_has_attachments  => {:text => 'conversation:GlobalHasAttachments', :writable => true},
        :message_count  => {:text => 'conversation:MessageCount', :writable => true},
        :global_message_count  => {:text => 'conversation:GlobalMessageCount', :writable => true},
        :unread_count  => {:text => 'conversation:UnreadCount', :writable => true},
        :global_unread_count  => {:text => 'conversation:GlobalUnreadCount', :writable => true},
        :size  => {:text => 'conversation:Size', :writable => true},
        :global_size  => {:text => 'conversation:GlobalSize', :writable => true},
        :item_classes  => {:text => 'conversation:ItemClasses', :writable => true},
        :global_item_classes  => {:text => 'conversation:GlobalItemClasses', :writable => true},
        :importance  => {:text => 'conversation:Importance', :writable => true},
        :global_importance  => {:text => 'conversation:GlobalImportance', :writable => true},
        :item_ids  => {:text => 'conversation:ItemIds', :writable => true},
        :global_item_ids  => {:text => 'conversation:GlobalItemIds', :writable => true}
      }
    end
  end
end

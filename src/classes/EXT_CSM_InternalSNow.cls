public class EXT_CSM_InternalSNow {

    public class insertElement {
        public String records_casenumber;
        public String records_contactid;
        public String records_description;
        public String records_id;
        public String records_origin;
        public String records_ownerid;
        public String records_priority;
        public String records_status;
        public String records_subject;
        public String u_records_case_categorizationid_r;
        public String u_records_category_c;
        public String u_records_cmdb_c;
        public String u_records_cmdb_r;
        public String u_records_contact_name;
        public String u_records_customer_requested_date_c;
        public String u_records_product_line_c;
        public String u_records_product_offering_c;
        public String u_records_productname_c;
        public String u_records_recordtypename_c;
        public String u_records_service_now_incident_number_c;
        public String u_records_service_now_type_c;
        public String u_records_servicenow_group_c;
        public String u_records_sn_category_c;
        public String u_records_sn_prod_line_c;
        public String u_records_sn_product_offering_c;
        public String u_records_sn_sub_categrory_c;
        public String u_records_sub_category_c;
        public String u_records_subtype1_c;
        public String u_records_subtype2_c;
        public String u_records_subtype3_c;
        public String u_records_suppliedemail;
        public String u_records_type;
        public String u_sf_to_snc_create;
    }
    
    public class insertResponse {
        public String import_set;
        public String staging_table;
        public List<insertResult> result;
    }
    public class insertResult {
        public String sys_id;
        public String table;
        public String display_name;
        public String display_value;
        public String status;
        public String status_message;
        public String error_message;
        public String map_x;
    }
    public class insertQ2Details {
        public String sysparm_quantity; 
        public String sysparm_item_guid;
        public String get_portal_messages;
        public String sysparm_no_validation;
        public insertVariables variables;
     }    
    public class insertVariables{
            public String q_unique_short_description;
            public String my_short_description_for_this_ticket;
            public String sga_import_conroller;
            public String q_site;
            public String sga_case_id;
            public String attachment;
            public String caller_id;
            public String sga_case_number;
            public String q_contact_information;
            public String sga_attachment_review_group;
            public String q_requested_for_information;
            public String q_attachment;
        }
}
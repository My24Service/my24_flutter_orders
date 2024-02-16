const String tokenData = '{"token": "hkjhkjhkl.ghhhjgjhg.675765jhkjh"}';
const String order = '{"id":506,"uuid":"f194abef-04dc-4874-ac79-38b6c1204849","customer_id":"1263","order_id":"10603","service_number":null,'
    '"order_reference":"","order_type":"Onderhoud","customer_remarks":"","description":null,"start_date":"17/03/2023","start_time":null,'
    '"end_date":"17/03/2023","end_time":null,"order_date":"17/03/2023","last_status":"Workorder signed",'
    '"last_status_full":"17/03/2023 11:52 Workorder signed","remarks":null,"order_name":"Fictie B.V.","order_address":"Metaalweg 4",'
    '"order_postal":"3751LS","order_city":"Bunschoten-Spakenburg","order_country_code":"NL","order_tel":"0650008","order_mobile":"+31610344871",'
    '"order_email":null,"order_contact":"L. Welling","created":"15/03/2023 11:44","documents":[],"statusses":[{"id":1590,"order":506,'
    '"status":"Aangemaakt door planning","modified":"15/03/2023 11:44","created":"15/03/2023 11:44"},{"id":1594,"order":506,'
    '"status":"Opdracht toegewezen aan mv","modified":"17/03/2023 11:40","created":"17/03/2023 11:40"},{"id":1595,"order":506,'
    '"status":"Begin opdracht gemeld door mv","modified":"17/03/2023 11:40","created":"17/03/2023 11:40"},{"id":1596,"order":506,'
    '"status":"Opdracht klaar gemeld door mv","modified":"17/03/2023 11:43","created":"17/03/2023 11:43"},{"id":1597,"order":506,'
    '"status":"Workorder signed","modified":"17/03/2023 11:52","created":"17/03/2023 11:52"}],"orderlines":[{"id":1311,"product":"df",'
    '"location":"df","remarks":"df","price_purchase":"0.00","price_selling":"0.00","amount":0,"material_relation":null,'
    '"location_relation_inventory":null,"purchase_order_material":null}],'
    '"workorder_pdf_url":"https://demo.my24service-dev.com/media/workorders/demo/workorder-demo-10603.pdf","total_price_purchase":"0.00",'
    '"total_price_selling":"0.00","customer_relation":1167,"customer_rate_avg":null,"required_assigned":"1/1 (100.00%)","required_users":1,'
    '"user_order_available_set_count":0,"assigned_count":1,'
    '"workorder_url":"https://demo.my24service-dev.com/#/orders/orders/workorder/f194abef-04dc-4874-ac79-38b6c1204849",'
    '"workorder_pdf_url_partner":"","customer_order_accepted":true,"workorder_documents":[],"workorder_documents_partners":[],'
    '"infolines":[{"id":66,"info":"sd"}],"assigned_user_info":[{"full_name":"Melissa Vedder","license_plate":""}],'
    '"maintenance_product_lines":[],"reported_codes_extra_data":[],"branch":null}';
const String orderDocument = '{"id": 1, "order": 1, "name": "grappig.png", "description": "", "document": "grappig.png"}';
const String orderTypes = '["Storing","Reparatie","Onderhoud","Klein onderhoud","Groot onderhoud","2 verdiepingen","Trap mal"]';
const String memberSettings = '{"equipment_location_quick_create":false, "equipment_quick_create": false, "equipment_location_employee_quick_create": true, "equipment_location_planning_quick_create": true, "equipment_employee_quick_create": true, "equipment_planning_quick_create": true, "countries":["NL","BE","DE","LU","FR"],"customer_id_autoincrement":true,"customer_id_start":1000,"date_format":"%d/%m/%Y","dispatch_assign_status":"assigned to {{ active_user_username }}","equipment_employee_quick_create":true,"equipment_location_employee_quick_create":true,"equipment_location_planning_quick_create":true,"equipment_planning_quick_create":true,"leave_accepted_status":"leave accepted by {{ username }}","leave_change_status":"leave updated by {{ username }}","leave_entry_status":"leave created by {{ username }}","leave_rejected_status":"leave rejected by {{ username }}","order_accepted_status":"order accepted","order_change_status":"order updated by {{ username }}"}';

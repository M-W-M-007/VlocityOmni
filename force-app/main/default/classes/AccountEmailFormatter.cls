global class AccountEmailFormatter implements Callable {
    
    global Object call(String action, Map<String, Object> args) {
        System.debug('[CALL] START');
        
        try {
            Map<String, Object> input = args.containsKey('input') ? 
                (Map<String, Object>) args.get('input') : args;
            
            Map<String, Object> output = args.containsKey('output') ? 
                (Map<String, Object>) args.get('output') : new Map<String, Object>();
            
            if (!input.containsKey('InfoAccount')) {
                output.put('EmailBodyHTML', 'ERROR: No InfoAccount');
                output.put('EmailSubject', 'ERROR');
                output.put('RecipientEmail', '');
                return true;
            }
            
            Map<String, Object> infoAccount = (Map<String, Object>) input.get('InfoAccount');
            Map<String, Object> block1 = (Map<String, Object>) infoAccount.get('Block1');
            
            // Build comprehensive email
            List<String> parts = new List<String>();
            
            // CSS and Header
            parts.add('<html><head><style>');
            parts.add('body{font-family:Arial,sans-serif;padding:20px;}');
            parts.add('table{border-collapse:collapse;width:100%;margin:20px 0;}');
            parts.add('th{background-color:#0070d2;color:white;padding:12px;text-align:left;}');
            parts.add('td{border:1px solid #ddd;padding:10px;}');
            parts.add('tr:nth-child(even){background-color:#f9f9f9;}');
            parts.add('.section{margin-top:30px;color:#0070d2;font-size:18px;font-weight:bold;border-bottom:2px solid #0070d2;padding-bottom:5px;}');
            parts.add('.info-box{background-color:#e8f4ff;padding:15px;border-radius:5px;margin:15px 0;}');
            parts.add('</style></head><body>');
            
            // Title
            parts.add('<h2 style="color:#0070d2;">Account Information Report</h2>');
            
            // Account Details
            parts.add('<div class="section">Account Details</div>');
            parts.add('<div class="info-box">');
            parts.add('<p><b>Account Name:</b> ');
            parts.add(String.valueOf(block1.get('Name')));
            parts.add('</p><p><b>City:</b> ');
            parts.add(String.valueOf(block1.get('BillingCity')));
            parts.add('</p><p><b>Type:</b> ');
            parts.add(String.valueOf(block1.get('AccountType')));
            parts.add('</p><p><b>Industry:</b> ');
            parts.add(String.valueOf(block1.get('Industry')));
            parts.add('</p><p><b>Employees:</b> ');
            parts.add(String.valueOf(infoAccount.get('AccountEmployees')));
            parts.add('</p><p><b>Phone:</b> ');
            parts.add(String.valueOf(infoAccount.get('AccountPhone')));
            parts.add('</p><p><b>Email:</b> ');
            parts.add(String.valueOf(infoAccount.get('AccEmail')));
            parts.add('</p></div>');
            
            // Contact Information
            parts.add('<div class="section">Contact Information</div>');
            Object contactInfoObj = infoAccount.get('ContactInfo');
            
            if (contactInfoObj instanceof Map<String, Object>) {
                // Single contact (as a Map)
                Map<String, Object> contact = (Map<String, Object>) contactInfoObj;
                parts.add('<table><thead><tr><th>Title</th><th>Name</th><th>Email</th><th>Phone</th></tr></thead><tbody>');
                parts.add('<tr><td>');
                parts.add(String.valueOf(contact.get('ContactTitle')));
                parts.add('</td><td>');
                parts.add(String.valueOf(contact.get('ContactName')));
                parts.add('</td><td>');
                parts.add(String.valueOf(contact.get('ContactEmail')));
                parts.add('</td><td>');
                parts.add(String.valueOf(contact.get('ContactPhone')));
                parts.add('</td></tr></tbody></table>');
            } else if (contactInfoObj instanceof List<Object>) {
                // Multiple contacts (as a List)
                List<Object> contacts = (List<Object>) contactInfoObj;
                if (!contacts.isEmpty()) {
                    parts.add('<table><thead><tr><th>Title</th><th>Name</th><th>Email</th><th>Phone</th></tr></thead><tbody>');
                    for (Object contactObj : contacts) {
                        Map<String, Object> contact = (Map<String, Object>) contactObj;
                        parts.add('<tr><td>');
                        parts.add(String.valueOf(contact.get('ContactTitle')));
                        parts.add('</td><td>');
                        parts.add(String.valueOf(contact.get('ContactName')));
                        parts.add('</td><td>');
                        parts.add(String.valueOf(contact.get('ContactEmail')));
                        parts.add('</td><td>');
                        parts.add(String.valueOf(contact.get('ContactPhone')));
                        parts.add('</td></tr>');
                    }
                    parts.add('</tbody></table>');
                }
            } else {
                parts.add('<p>No contact information available.</p>');
            }
            
            // Case Information
            parts.add('<div class="section">Cases (');
            Object caseInfoObj = infoAccount.get('CaseInfo');
            Integer caseCount = 0;
            
            if (caseInfoObj instanceof List<Object>) {
                List<Object> cases = (List<Object>) caseInfoObj;
                caseCount = cases.size();
                parts.add(String.valueOf(caseCount));
                parts.add(')</div>');
                
                if (!cases.isEmpty()) {
                    parts.add('<table><thead><tr><th>Case #</th><th>Subject</th><th>Status</th><th>Type</th><th>Priority</th><th>Date</th></tr></thead><tbody>');
                    for (Object caseObj : cases) {
                        Map<String, Object> caseRec = (Map<String, Object>) caseObj;
                        parts.add('<tr><td>');
                        parts.add(String.valueOf(caseRec.get('CaseNumber')));
                        parts.add('</td><td>');
                        parts.add(String.valueOf(caseRec.get('CaseSubject')));
                        parts.add('</td><td>');
                        parts.add(String.valueOf(caseRec.get('CaseStatus')));
                        parts.add('</td><td>');
                        parts.add(String.valueOf(caseRec.get('CaseType')));
                        parts.add('</td><td>');
                        parts.add(String.valueOf(caseRec.get('CasePriority')));
                        parts.add('</td><td>');
                        
                        // Format date
                        String dateStr = String.valueOf(caseRec.get('CaseOpenDate'));
                        if (dateStr != null && dateStr.length() >= 10) {
                            parts.add(dateStr.substring(0, 10));
                        }
                        
                        parts.add('</td></tr>');
                    }
                    parts.add('</tbody></table>');
                } else {
                    parts.add('<p>No cases found.</p>');
                }
            } else {
                parts.add('0)</div><p>No cases found.</p>');
            }
            
            // Footer
            parts.add('<hr style="margin-top:30px;"/><p style="color:#666;font-size:12px;">Automated email from OmniScript</p>');
            parts.add('</body></html>');
            
            String html = String.join(parts, '');
            
            System.debug('[CALL] HTML length: ' + html.length());
            
            output.put('EmailBodyHTML', html);
            output.put('EmailSubject', 'Account Information - ' + block1.get('Name'));
            output.put('RecipientEmail', String.valueOf(infoAccount.get('AccEmail')));
            output.put('success', true);
            
            System.debug('[CALL] SUCCESS');
            
            return true;
            
        } catch (Exception e) {
            System.debug('[CALL] ERROR: ' + e.getMessage());
            
            Map<String, Object> output = args.containsKey('output') ? 
                (Map<String, Object>) args.get('output') : new Map<String, Object>();
            
            output.put('EmailBodyHTML', 'ERROR: ' + e.getMessage());
            output.put('EmailSubject', 'ERROR');
            output.put('RecipientEmail', '');
            output.put('error', e.getMessage());
            
            return false;
        }
    }
    
    public Boolean invokeMethod(String methodName, Map<String, Object> input, 
                               Map<String, Object> output, Map<String, Object> options) {
        return true;
    }
}
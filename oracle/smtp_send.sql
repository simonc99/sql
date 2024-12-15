DECLARE
  v_From      VARCHAR2(80) := 'email.address@somewhere.com';
  v_Recipient VARCHAR2(80) := 'email.address@somewhere.com';
  v_Subject   VARCHAR2(80) := 'SMTP email test';
  v_Mail_Host VARCHAR2(30) := 'smtpserver.somewhere.uk';
  v_Mail_Conn utl_smtp.Connection;
  crlf        VARCHAR2(2)  := chr(13)||chr(10);
  v_This_Inst VARCHAR2(40);
BEGIN
 select global_name into v_This_Inst from global_name;
 v_Mail_Conn := utl_smtp.Open_Connection(v_Mail_Host, 25);
 utl_smtp.Helo(v_Mail_Conn, v_Mail_Host);
 utl_smtp.Mail(v_Mail_Conn, v_From);
 utl_smtp.Rcpt(v_Mail_Conn, v_Recipient);
 utl_smtp.Data(v_Mail_Conn,
   'Date: '   || to_char(sysdate, 'Dy, DD Mon YYYY hh24:mi:ss') || crlf ||
   'From: '   || v_From || crlf ||
   'Subject: '|| v_Subject || crlf ||
   'To: '     || v_Recipient || crlf ||
   crlf ||
   'This is an email from '|| v_This_Inst || crlf
 );
 utl_smtp.Quit(v_mail_conn);
EXCEPTION
 WHEN utl_smtp.Transient_Error OR utl_smtp.Permanent_Error then
   raise_application_error(-20000, 'Unable to send mail: '||sqlerrm);
END;
/


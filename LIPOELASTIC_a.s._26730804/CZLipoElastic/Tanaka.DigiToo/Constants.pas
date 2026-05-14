const
  cScriptVersion='25.06.02.1';
  WINHTTPREQ_OPTION_SslErrorIgnoreFlags=4;
  WINHTTP_OPTION_SSERRIALL        =$3300;
  cProgressMax=5;
  ccDigitooReservedFieldCode = '9990001';

  cAgentHeader='User-Agent: cz.digitoo.agent.abragen.cs/';
  DIGITOO_CLSID='NL1LNFC1PP44HH1B3WTGIKOSH4';
  URL_ACCOUNT_TOKEN='https://api.digitoo.cz/api/workspace/service-account-token';
  URL_READY_TO_EXPORT='https://api.digitoo.cz/api/v2/documents?include=document-url&filters[status]=ready-to-export';
  URL_READY_TO_EXPORT_QUEUE='https://api.digitoo.cz/api/v2/queues/%QUEUE_ID%/documents?include=document-url&filters[status]=ready-to-export';
  URL_MARK_AS_EXPORTED='https://api.digitoo.cz/api/v2/documents/%DOCUMENT_ID%/status';
  URL_UPLOAD_REGISTERS='https://api.digitoo.cz/api/v2/registers';
  URL_DOWNLOAD_FILE='https://api.digitoo.cz/api/v2/documents/%DOCUMENT_ID%/original-file';
//  URL_DOWNLOAD_FILE_QUEUE='https://api.digitoo.cz/api/v2/queues/%QUEUE_ID%/documents/%DOCUMENT_ID%/original-file';
  URL_LOGIN_V2='https://api.digitoo.cz/api/v2/auth/login';
  URL_DOWNLOAD_ATTACHMENTS_V2='https://api.digitoo.cz/api/v2/documents/%DOCUMENT_ID%/attachments';
  URL_DOWNLOAD_FILE_V2='https://api.digitoo.cz/api/v2/documents/%DOCUMENT_ID%/original-file';
  URL_AUDIT_LOG_V2 ='https://api.digitoo.cz/api/v2/documents/%DOCUMENT_ID%/audit-log?page[size]=1000';
  URL_CHANGE_PAYMENT_STATUS = 'https://api.digitoo.cz/api/v2/documents/%DOCUMENT_ID%/payment-status';
  URL_QUEUES = 'https://api.digitoo.cz/api/v2/queues/%QUEUE_ID%';
begin
end.
@echo off

set DNSSERVICE=PRST-TEST-RU
set ZONE=test.ru
set HOST=*.test.ru

set CREDENTIALS=~nic-test.txt
set ARGUMENTS={Identifier} {RecordName} {Token} %CREDENTIALS% %DNSSERVICE% %ZONE%

set WACS=D:\wacs\wacs.exe

%WACS% --verbose --source manual --host %HOST% --validationmode dns-01 --validation script --dnscreatescript .\ValidateDNS_NicRu.ps1 --dnscreatescriptarguments "create %ARGUMENTS%" --dnsdeletescript .\ValidateDNS_NicRu.ps1 --dnsdeletescriptarguments "delete %ARGUMENTS%" --store pfxfile --pfxfilepath .\ --pfxpassword ""

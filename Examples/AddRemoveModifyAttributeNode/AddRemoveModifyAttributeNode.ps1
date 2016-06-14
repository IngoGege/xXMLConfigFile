configuration AddRemoveModifyAttributeNode
{
    param
    (
        [string[]]$NodeName = 'localhost'
    )

    Import-DscResource -Module xXMLConfigFile

    Node $NodeName
    {
        #ensure node with attribute SmtpSendLogFlushInterval exists and has specified value
        XMLConfigFile SMTPSendFlush
        {
            ConfigPath = "C:\Temp\Test.config"
            XPath      = '//appSettings/add'
            Name       = 'SmtpSendLogFlushInterval'
            Value      = '0:00:30'
            isAttribute= $false
            Ensure     = 'Present'
        }

        #make sure node with attribute SmtpRecvLogFlushInterval doesn't exists
        XMLConfigFile SMTPRecvFlush
        {
            ConfigPath = "C:\Temp\Test.config"
            XPath      = '//appSettings/add'
            Name       = 'SmtpRecvLogFlushInterval'
            isAttribute= $false
            Ensure     = 'Absent'        
        }

    }
}

AddRemoveModifyAttributeNode -Verbose
Start-DscConfiguration -Path .\AddRemoveModifyAttributeNode -Verbose -Wait -Force
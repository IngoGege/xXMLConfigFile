configuration AddRemoveModifySingleAttributeValue
{
    param
    (
        [string[]]$NodeName = 'localhost'
    )

    Import-DscResource -Module xXMLConfigFile

    Node $NodeName
    {
        #ensure attribute exists and has specified value
        XMLConfigFile MaxRetries
        {
            ConfigPath = "C:\Temp\Test.config"
            XPath      = '//MRSConfiguration'
            Name       = 'MaxRetries'
            Value      = '40'
            isAttribute= $true
            Ensure     = 'Present'
        }

        #ensure attribute exists and has specified value
        XMLConfigFile MaxPerSourceDB
        {
            ConfigPath = "C:\Temp\Test.config"
            XPath      = '//MRSConfiguration'
            Name       = 'MaxActiveMovesPerSourceMDB'
            Value      = '20'
            isAttribute= $true
            Ensure     = 'Present'        
        }

        #make sure attribute FoolMe doesn't exists
        XMLConfigFile FoolMe
        {
            ConfigPath = "C:\Temp\Test.config"
            XPath      = '//MRSConfiguration'
            Name       = 'FoolMe'
            isAttribute= $true
            Ensure     = 'Absent'        
        }

    }
}

AddRemoveModifySingleAttributeValue -Verbose
Start-DscConfiguration -Path .\AddRemoveModifySingleAttributeValue -Verbose -Wait -Force
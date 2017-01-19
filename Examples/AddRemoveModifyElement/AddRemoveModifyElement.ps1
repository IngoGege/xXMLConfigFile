configuration AddElement
{
    param
    (
        [string[]]$NodeName = 'localhost'
    )

    Import-DscResource -Name xXMLConfigFile

    Node $NodeName
    {
        XMLConfigFile Element
        {
            ConfigPath = 'C:\temp\Test.config'
            XPath      = '/*'
            Name       = 'ElementA'
            Value      = 'Root'
            isElementTextValue = $true
            Ensure = 'present'
        }

        XMLConfigFile ChildElement
        {
            ConfigPath = 'C:\temp\Test.config'
            XPath      = '//appSettings'
            Name       = 'ElementB'
            Value      = 'ChildElement'
            isElementTextValue = $true
            Ensure = 'present'
        }
    }
}

AddElement -Verbose
Start-DscConfiguration -Path .\AddElement -Verbose -Wait -Force


configuration RemoveElement
{
    param
    (
        [string[]]$NodeName = 'localhost'
    )

    Import-DscResource -Name xXMLConfigFile

    Node $NodeName
    {
        XMLConfigFile Element
        {
            ConfigPath = 'C:\temp\Test.config'
            XPath      = '/*'
            Name       = 'ElementA'
            isElementTextValue = $true
            Ensure = 'absent'
        }

        XMLConfigFile ChildElement
        {
            ConfigPath = 'C:\temp\Test.config'
            XPath      = '//appSettings'
            Name       = 'ElementB'
            isElementTextValue = $true
            Ensure = 'absent'
        }
    }
}

RemoveElement -Verbose
Start-DscConfiguration -Path .\RemoveElement -Verbose -Wait -Force

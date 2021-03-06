﻿Import-Module $PSScriptRoot\..\DSCResources\xXMLConfigFile\xXMLConfigFile.psm1 -Force
#this function was taken from xExchange module
function Test-AllTargetResourceFunctions
{
    [CmdletBinding()]
    param([Hashtable]$Params, [string]$ContextLabel, [Hashtable]$ExpectedGetResults, [bool]$ExpectedTestResult = $true)

    Context $ContextLabel {
        Set-TargetResource @Params -Verbose

        [Hashtable]$getResult = Get-TargetResource @Params -Verbose
        [bool]$testResult = Test-TargetResource @Params -Verbose

        #The ExpectedGetResults are $null, so let's check that what we got back is $null
        if ($ExpectedGetResults -eq $null)
        {
            It "Get-TargetResource: Should Be Null" {
                $getResult | Should BeNullOrEmpty
            }
        }
        else
        {
            #Test each individual key in $ExpectedGetResult to see if they exist, and if the expected value matches
            foreach ($key in $ExpectedGetResults.Keys)
            {
                It "Get-TargetResource: Contains Key: $($key)" {
                    $getResult | Should Be ($getResult.ContainsKey($key))
                }

                if ($getResult.ContainsKey($key))
                {
                    It "Get-TargetResource: Value Matches for Key: $($key)" {
                        $getResult | Should Be ($getResult.ContainsKey($key) -and $getResult[$key] -eq $ExpectedGetResults[$key])
                    }
                }
            }
        }

        #Test the Test-TargetResource results
        It "Test-TargetResource" {
            $testResult | Should Be $ExpectedTestResult
        }
    }
}

Describe "Test modify an attribute value" {
    $testparams = @{
        ConfigPath = "$($PSScriptRoot)\Data\Test.config"
        XPath      = '//MRSConfiguration'
        Name       = 'MaxRetries'
        Value      = '40'
        isAttribute= $true
        Ensure     = 'Present'
    }

    $expectedResult = @{
        Value      = '40'
    }

    Test-AllTargetResourceFunctions -Params $testparams -ExpectedGetResults $expectedResult -ContextLabel "Set value for MaxRetries" -Verbose

    $testparams.Value = '60'
    $expectedResult.Value = '60'

    Test-AllTargetResourceFunctions -Params $testparams -ExpectedGetResults $expectedResult -ContextLabel "Change value for MaxRetries" -Verbose

    $testparams.Value = '40'
    $expectedResult.Value = '40'
    
    Test-AllTargetResourceFunctions -Params $testparams -ExpectedGetResults $expectedResult -ContextLabel "Reset value for MaxRetries" -Verbose

    $testparams.Name = 'FoolMe'
    $testparams.Value = 'really'

    $expectedResult.Value = 'really'
    Test-AllTargetResourceFunctions -Params $testparams -ExpectedGetResults $expectedResult -ContextLabel "Add attribute FoolMe with value really" -Verbose

    $testparams.Ensure = 'Absent'

    $expectedResult.Value = $null

    Test-AllTargetResourceFunctions -Params $testparams -ExpectedGetResults $expectedResult -ContextLabel "Remove attribute FoolMe with value really" -Verbose

}

Describe "Test modify an attributenode" {
    $testparams = @{
        ConfigPath = "$($PSScriptRoot)\Data\Test.config"
        XPath      = '//appSettings/add'
        Name       = 'LogEnabled'
        Value      = 'true'
        isAttribute= $false
        Ensure     = 'Present'
    }

    $expectedResult = @{
        Value      = 'true'
    }

    Test-AllTargetResourceFunctions -Params $testparams -ExpectedGetResults $expectedResult -ContextLabel "Set value for LogEnabled in appSettings/add" -Verbose

    $testparams.Name = 'FoolMe'
    $testparams.Value = 'really'

    $expectedResult.Value = 'really'

    Test-AllTargetResourceFunctions -Params $testparams -ExpectedGetResults $expectedResult -ContextLabel "Add item FoolMe with value really in appSettings/add" -Verbose
    $testparams.Ensure = 'Absent'
    $expectedResult.Value = $null

    Test-AllTargetResourceFunctions -Params $testparams -ExpectedGetResults $expectedResult -ContextLabel "Remove item FoolMe with value really in appSettings/add" -Verbose

}

Describe "Test modify an attribute value in config with XML Namespace" {
    $testparams = @{
        ConfigPath = "$($PSScriptRoot)\Data\Test_withXMLNS.config"
        XPath      = '//MRSConfiguration'
        Name       = 'MaxRetries'
        Value      = '40'
        isAttribute= $true
        Ensure     = 'Present'
    }

    $expectedResult = @{
        Value      = '40'
    }

    Test-AllTargetResourceFunctions -Params $testparams -ExpectedGetResults $expectedResult -ContextLabel "Set value for MaxRetries" -Verbose

    $testparams.Value = '60'
    $expectedResult.Value = '60'

    Test-AllTargetResourceFunctions -Params $testparams -ExpectedGetResults $expectedResult -ContextLabel "Change value for MaxRetries" -Verbose
    
    $testparams.Value = '40'
    $expectedResult.Value = '40'
    
    Test-AllTargetResourceFunctions -Params $testparams -ExpectedGetResults $expectedResult -ContextLabel "Reset value for MaxRetries" -Verbose

    $testparams.Name = 'FoolMe'
    $testparams.Value = 'really'

    $expectedResult.Value = 'really'
    Test-AllTargetResourceFunctions -Params $testparams -ExpectedGetResults $expectedResult -ContextLabel "Add attribute FoolMe with value really" -Verbose

    $testparams.Ensure = 'Absent'

    $expectedResult.Value = $null

    Test-AllTargetResourceFunctions -Params $testparams -ExpectedGetResults $expectedResult -ContextLabel "Remove attribute FoolMe with value really" -Verbose

}

Describe "Test modify an attributenode in config with XML Namespace" {
    $testparams = @{
        ConfigPath = "$($PSScriptRoot)\Data\Test_withXMLNS.config"
        XPath      = '//appSettings/add'
        Name       = 'LogEnabled'
        Value      = 'true'
        isAttribute= $false
        Ensure     = 'Present'
    }

    $expectedResult = @{
        Value      = 'true'
    }

    Test-AllTargetResourceFunctions -Params $testparams -ExpectedGetResults $expectedResult -ContextLabel "Set value for LogEnabled in appSettings/add" -Verbose

    $testparams.Name = 'FoolMe'
    $testparams.Value = 'really'

    $expectedResult.Value = 'really'

    Test-AllTargetResourceFunctions -Params $testparams -ExpectedGetResults $expectedResult -ContextLabel "Add item FoolMe with value really in appSettings/add" -Verbose
    $testparams.Ensure = 'Absent'
    $expectedResult.Value = $null

    Test-AllTargetResourceFunctions -Params $testparams -ExpectedGetResults $expectedResult -ContextLabel "Remove item FoolMe with value really in appSettings/add" -Verbose

}

Describe "Test add an element with textvalue in config with XML Namespace" {
    $testparams = @{
        ConfigPath = "$($PSScriptRoot)\Data\Test_withXMLNS.config"
        XPath      = '/*'
        Name       = 'ElementA'
        Value      = 'Root'
        isElementTextValue= $true
        Ensure     = 'Present'
    }

    $expectedResult = @{
        Value      = 'Root'
    }

    Test-AllTargetResourceFunctions -Params $testparams -ExpectedGetResults $expectedResult -ContextLabel "Add an element with textvalue under root" -Verbose

    $testparams.Value = 'NewRoot'
    $expectedResult.Value = 'NewRoot'

    Test-AllTargetResourceFunctions -Params $testparams -ExpectedGetResults $expectedResult -ContextLabel "Modify textvalue of element" -Verbose

    $testparams.Ensure = 'Absent'
    $expectedResult.Value = $null

    Test-AllTargetResourceFunctions -Params $testparams -ExpectedGetResults $expectedResult -ContextLabel "Remove element" -Verbose

}

Describe "Test modify an attributenode where element node doesn't exist" {
    $testparams = @{
        ConfigPath = "$($PSScriptRoot)\Data\Test.config"
        XPath      = '//appSettings/remove'
        Name       = 'Application Name'
        Value      = $null
        Attribute2 = $null
        isAttribute= $false
        Ensure     = 'Present'
    }

    $expectedResult = @{
        Value      = $null
    }

    Test-AllTargetResourceFunctions -Params $testparams -ExpectedGetResults $expectedResult -ContextLabel "Create key Application Name in appSettings/remove" -Verbose

    $testparams.Ensure = 'Absent'

    Test-AllTargetResourceFunctions -Params $testparams -ExpectedGetResults $expectedResult -ContextLabel "Remove key Application Name in appSettings/remove" -Verbose

}

Describe "Test set an element with textvalue in config enforcing NULL XML Namespace" {
    $testparams = @{
        ConfigPath          = "$($PSScriptRoot)\Data\Test_with_NULL_XMLNS.config"
        XPath               = "//string[@id='HeadingRDWA']"
        Name                = $null
        Value               = 'Password Reset Portal3'
        isElementTextValue  = $true
        Ensure              = 'Present'
        EnforceNullXMLNS    = $true
    }

    $expectedResult = @{
        Value = 'Password Reset Portal3'
    }

    Test-AllTargetResourceFunctions -Params $testparams -ExpectedGetResults $expectedResult -ContextLabel "Set the value of an element and enforcing EnforceNullXMLNS" -Verbose

    $testparams.Value = 'Password Reset Portal2'
    $expectedResult.Value = 'Password Reset Portal2'

    Test-AllTargetResourceFunctions -Params $testparams -ExpectedGetResults $expectedResult -ContextLabel "Reset the value of an element and enforcing EnforceNullXMLNS" -Verbose

}

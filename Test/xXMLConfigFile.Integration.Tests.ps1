Import-Module $PSScriptRoot\..\DSCResources\xXMLConfigFile\xXMLConfigFile.psm1
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
        ConfigPath = "$($PSScriptRoot)\Test.config"
        XPath      = '//MRSConfiguration'
        Name       = 'MaxRetries'
        Value      = '40'
        isAttribute= $true
        #Attribute1 = 'key'
        #Attribute2 = 'value'
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
        ConfigPath = "$($PSScriptRoot)\Test.config"
        XPath      = '//appSettings/add'
        Name       = 'LogEnabled'
        Value      = 'true'
        isAttribute= $false
        #Attribute1 = 'key'
        #Attribute2 = 'value'
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

    <#
    $testparams.Value = '60'
    $expectedResult.Value = '60'

    Test-AllTargetResourceFunctions -Params $testparams -ExpectedGetResults $expectedResult -ContextLabel "Change value for MaxRetries" -Verbose
    
    $testparams.Value = '40'
    $expectedResult.Value = '40'
    
    Test-AllTargetResourceFunctions -Params $testparams -ExpectedGetResults $expectedResult -ContextLabel "Reset value for MaxRetries" -Verbose
    #>
}
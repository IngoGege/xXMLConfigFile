[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCDscTestsPresent", "")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCDscExamplesPresent", "")]
[CmdletBinding()]
param()

function Get-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $ConfigPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $XPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.String]
        $Value,

        [System.Boolean]
        $isAttribute,

        [System.Boolean]
        $isElementTextValue,

        [System.String]
        $Attribute1 = 'key',

        [System.String]
        $Attribute2 = 'value',

        [System.String]
        $XMLNS,

        [System.String]
        $NSPrefix = 'ns',

        [System.Boolean]
        $DoBackup,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = 'Present',

        [System.Boolean]
        $EnforceNullXMLNS
    )

    #Load helper module
    Import-Module -Name "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xXMLConfigFileCommonFunctions.psm1" -Verbose:0
    #remove unnecessary parameters
    [void]$PSBoundParameters.Remove('Ensure')
    $CurrentValue = Get-XMLItem @PSBoundParameters

    $returnValue = @{
        ConfigPath          = $ConfigPath
        XPath               = $XPath
        Name                = $Name
        Value               = $CurrentValue
        isAttribute         = $isAttribute
        Attribute1          = $Attribute1
        Attribute2          = $Attribute2
        XMLNS               = $XMLNS
        NSPrefix            = $NSPrefix
        DoBackup            = $DoBackup
        EnforceNullXMLNS    = $EnforceNullXMLNS
    }

    $returnValue
}


function Set-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $ConfigPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $XPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.String]
        $Value,

        [System.Boolean]
        $isAttribute,

        [System.Boolean]
        $isElementTextValue,

        [System.String]
        $Attribute1 = 'key',

        [System.String]
        $Attribute2 = 'value',

        [System.String]
        $XMLNS,

        [System.String]
        $NSPrefix = 'ns',

        [System.Boolean]
        $DoBackup,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = 'Present',

        [System.Boolean]
        $EnforceNullXMLNS
    )

    #Load helper module
    Import-Module -Name "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xXMLConfigFileCommonFunctions.psm1" -Verbose:0

    if($Ensure -eq 'Present')
    {
        #remove unnecessary parameters
        [void]$PSBoundParameters.Remove('Ensure')
        #if item has not expected value set
        $exists = Test-XMLItemExist @PSBoundParameters
        if ($exists)
        {
            Set-XMLItem @PSBoundParameters
        }
        #if item not exist add
        elseif (!$exists)
        {
            Add-XMLItem @PSBoundParameters
        }
        else
        {
            Write-Verbose -Message "Could not determine if exists!"
        }
    }
    elseif($Ensure -eq 'Absent')
    {
        #remove unnecessary parameters
        [void]$PSBoundParameters.Remove('Ensure')
        $exists = Test-XMLItemExist @PSBoundParameters
        if ($exists)
        {
            Write-Verbose "Item exists!"
            Remove-XMLItem @PSBoundParameters
        }
    }
    else
    {
        Write-Verbose -Message "Neither Present nor Absent was set!"
    }
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $ConfigPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $XPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.String]
        $Value,

        [System.Boolean]
        $isAttribute,

        [System.Boolean]
        $isElementTextValue,

        [System.String]
        $Attribute1 = 'key',

        [System.String]
        $Attribute2 = 'value',

        [System.String]
        $XMLNS,

        [System.String]
        $NSPrefix = 'ns',

        [System.Boolean]
        $DoBackup,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = 'Present',

        [System.Boolean]
        $EnforceNullXMLNS
    )

    #Load helper module
    Import-Module -Name "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xXMLConfigFileCommonFunctions.psm1" -Verbose:0
    try
    {
        #$CurrentValue = Get-XMLItem -ConfigPath $ConfigPath -XPath $XPath -Name $Name -isAttribute $isAttribute -isElementTextValue $isElementTextValue -Attribute1 $Attribute1 -Attribute2 $Attribute2 -XMLNS $XMLNS -NSPrefix $NSPrefix -VerbosePreference $VerbosePreference -EnforceNullXMLNS $EnforceNullXMLNS
        $GetParams = $PSBoundParameters
        [void]$GetParams.Remove('Ensure')
        $CurrentValue = Get-XMLItem @GetParams
    }
    catch
    {
        Write-Verbose -Message $_
    }

    if($Ensure -eq 'Present')
    {
    Write-Verbose -Message "Values for $($Name):Current=$($CurrentValue). Expected=$($Value)"
        if ([System.String]::IsNullOrEmpty($Attribute2))
        {
            #remove unnecessary parameters
            [void]$PSBoundParameters.Remove('Ensure')
            #check if element exist when $Attribute2 is NULL
            $exists = Test-XMLItemExist @PSBoundParameters
            Write-Verbose "Attribute2 is IsNullOrEmpty"

            if($exists -and ([System.String]::IsNullOrEmpty($CurrentValue) -and [System.String]::IsNullOrEmpty($Value)))
            {
                $result = $true
            }
        }
        elseif ($CurrentValue -eq $Value)
        {
            $result = $true
        }
        else
        {
            $result = $false
        }
    }
    elseif($Ensure -eq 'Absent')
    {
        if ([System.String]::IsNullOrEmpty($Attribute2))
        {
            #remove unnecessary parameters
            [void]$PSBoundParameters.Remove('Ensure')
            #check if element exist when $Attribute2 is NULL
            $exists = Test-XMLItemExist @PSBoundParameters
            if(!$exists)
            {
                Write-Verbose "Attribute2 is IsNullOrEmpty, but element exists"
                $result = $true
            }
        }
        elseif ($null -eq $CurrentValue)
        {
            $result = $true
        }
        else
        {
            Write-Verbose -Message "Ensure is set to $($Ensure), but there was an item found!"
            $result = $false
        }
    }
    else
    {
        $result = $false
    }

    return $result

}


Export-ModuleMember -Function *-TargetResource

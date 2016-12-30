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

        [parameter(Mandatory = $true)]
        [System.String]
        $Value,

        [System.Boolean]
        $isAttribute,

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
        $Ensure
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xXMLConfigFileCommonFunctions.psm1" -Verbose:0
    #remove unnecessary parameters
    $PSBoundParameters.Remove('Ensure') | Out-Null
    $CurrentValue = Get-XMLItem @PSBoundParameters

    $returnValue = @{
        ConfigPath  = $ConfigPath
        XPath       = $XPath
        Name        = $Name
        Value       = $CurrentValue
        isAttribute = $isAttribute
        Attribute1  = $Attribute1
        Attribute2  = $Attribute2
        XMLNS       = $XMLNS
        NSPrefix    = $NSPrefix
        DoBackup    = $DoBackup
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
        $Ensure
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xXMLConfigFileCommonFunctions.psm1" -Verbose:0

    try {
        $CurrentValue = Get-XMLItem -ConfigPath $ConfigPath -XPath $XPath -Name $Name -isAttribute $isAttribute -Attribute1 $Attribute1 -Attribute2 $Attribute2 -XMLNS $XMLNS -NSPrefix $NSPrefix
    }
    catch {
        Write-Verbose "Exception occured:$($_)"
    }

    if($Ensure -eq 'Present') {
        #remove unnecessary parameters
        $PSBoundParameters.Remove('Ensure') | Out-Null
        #if item has not expected value set
        $exists = Test-XMLItemExist @PSBoundParameters
        if ($exists) {
            Set-XMLItem @PSBoundParameters
        }
        #if item not exist add
        elseif (!$exists) {
            Add-XMLItem @PSBoundParameters
        }
        else {
            Write-Verbose -Message "Could not determine if exists!"
        }
    }
    elseif($Ensure -eq 'Absent') {
        #if item exist remove
        if ($null -ne $CurrentValue) {
            #remove unnecessary parameters
            $PSBoundParameters.Remove('Ensure')
            Remove-XMLItem @PSBoundParameters
        }
    }
    else {
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
        $Ensure
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xXMLConfigFileCommonFunctions.psm1" -Verbose:0
    try {
        $CurrentValue = Get-XMLItem -ConfigPath $ConfigPath -XPath $XPath -Name $Name -isAttribute $isAttribute -Attribute1 $Attribute1 -Attribute2 $Attribute2 -XMLNS $XMLNS -NSPrefix $NSPrefix -VerbosePreference $VerbosePreference
    }
    catch {
        Write-Verbose "Exception occured:$($_)"
    }

    if($Ensure -eq 'Present') {
    Write-Verbose "Values for $($Name):Current=$($CurrentValue). Expected=$($Value)"
        if ($CurrentValue -eq $Value) {
            $result = $true
        }
        else {
            $result = $false
         }
    }
    elseif($Ensure -eq 'Absent') {
        if ($null -eq $CurrentValue) {
            $result = $true
        }
        else {
            Write-Verbose "Ensure is set to $($Ensure), but there was an item found!"
            $result = $false
        }
    }
    else {
        $result = $false
    }
    return $result

}

Export-ModuleMember -Function *-TargetResource

function Get-XMLItem
{
    [CmdletBinding()]
    param
    (
        [string]$ConfigPath,
        [string]$XPath,
        [string]$Name,
        [string]$Value,
        [Boolean]$isAttribute,
        [Boolean]$isElementTextValue,
        [string]$Attribute1 = 'key',
        [string]$Attribute2 = 'value',
        [string]$XMLNS,
        [string]$NSPrefix = 'ns',
        [Boolean]$DoBackup,
        [Boolean]$EnforceNullXMLNS,
        $VerbosePreference
    )

    if ($isAttribute -and $isElementTextValue)
    {
        Write-Verbose -Message "AmbiguousParameterSet! isAttribute and isElementTextValue cannot be used simultaneous."
        break
    }

    #read XML
    $xml = [xml](Get-Content $ConfigPath -ErrorAction Stop)
    $root = $xml.get_DocumentElement()

    if (-not $EnforceNullXMLNS)
    {
        if (-not $XMLNS)
        {
            $NamespaceURI = $xml.DocumentElement.NamespaceURI
        }
        else
        {
            $NamespaceURI = $XMLNS
        }

        #create XML namespacemanager from document
        $ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
        $ns.AddNameSpace("$NSPrefix",$NamespaceURI)
        #add XMLNameSpaceManager to XPath
        $XPath = $XPath -replace "/(?!/)", "/$($NSPrefix):"
    }

    Write-Verbose -Message "XPath:$($Xpath)"
    Write-Verbose -Message "NamespaceURI:$($NamespaceURI)"

    if ($isAttribute)
    {
        if (-not $EnforceNullXMLNS)
        {
            if ($root.SelectSingleNode($XPath,$ns).HasAttribute($Name))
            {
                $Item = $root.SelectSingleNode($XPath,$ns).GetAttribute($Name)
            }
        }
        else
        {
            if ($root.SelectSingleNode($XPath).HasAttribute($Name))
            {
                $Item = $root.SelectSingleNode($XPath).GetAttribute($Name)
            }
        }
    }
    elseif ($isElementTextValue)
    {
        if (-not $EnforceNullXMLNS)
        {
            $Node = $root.SelectSingleNode($XPath + "/$($NSPrefix):$($Name)",$ns)
        }
        else
        {
            $Node = $root.SelectSingleNode($XPath + "$($Name)")
        }
        if ($Node)
        {
            $Item = $Node.get_InnerText()
        }
    }
    else
    {
        if (-not [System.String]::IsNullOrEmpty($Attribute2))
        {
            Write-Verbose -Message "`$Attribute2 is not NullOrEmpty"
            if (-not $EnforceNullXMLNS)
            {
                $Item = $root.SelectSingleNode("$XPath[@$Attribute1=`'$Name`']",$ns).$Attribute2
            }
            else{
                $Item = $root.SelectSingleNode("$XPath[@$Attribute1=`'$Name`']").$Attribute2
            }
        }
        else
        {
            if (-not $EnforceNullXMLNS)
            {
                $Item = $root.SelectSingleNode("$XPath[@$Attribute1=`'$Name`']",$ns).$Attribute2
            }
            else{
                $Item = $root.SelectSingleNode("$XPath[@$Attribute1=`'$Name`']").$Attribute2
            }
        }
    }

    return $Item
}

function Set-XMLItem
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding()]
    param
    (
        [string]$ConfigPath,
        [string]$XPath,
        [string]$Name,
        [string]$Value,
        [Boolean]$isAttribute,
        [Boolean]$isElementTextValue,
        [string]$Attribute1 = 'key',
        [string]$Attribute2 = 'value',
        [string]$XMLNS,
        [string]$NSPrefix = 'ns',
        [Boolean]$DoBackup,
        [Boolean]$EnforceNullXMLNS,
        $VerbosePreference
    )

    if ($isAttribute -and $isElementTextValue)
    {
        Write-Verbose -Message "AmbiguousParameterSet! isAttribute and isElementTextValue cannot be used simultaneous."
        break
    }

    try
    {
        #read XML
        $xml = [xml](Get-Content $ConfigPath -ErrorAction Stop)
        $root = $xml.get_DocumentElement()

        if ($DoBackup)
        {
            $CurrentDate = (Get-Date).tostring("MMddyyyy-HHmmssffffff")
            $Backup = $ConfigPath + "_$CurrentDate" + ".bak" 

            try
            {
                #save XML
                $xml.Save($Backup)
            }
            catch
            {
                Write-Verbose -Message $_
                break
            }
        }

        if (-not $EnforceNullXMLNS)
        {
            if (-not $XMLNS)
            {
                $NamespaceURI = $xml.DocumentElement.NamespaceURI
            }
            else
            {
                $NamespaceURI = $XMLNS
            }

            #create XML namespacemanager from document
            $ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
            $ns.AddNameSpace("$NSPrefix",$NamespaceURI)
            #add XMLNameSpaceManager to XPath
            $XPath = $XPath -replace "/(?!/)", "/$($NSPrefix):"
            Write-Verbose -Message "XPath:$($Xpath)"
            Write-Verbose -Message "NamespaceURI:$($NamespaceURI)"
        }

        if ($isAttribute)
        {
            if (-not $EnforceNullXMLNS)
            {
                if ($root.SelectSingleNode($XPath,$ns).HasAttribute($Name))
                {
                    Write-Verbose -Message "$($Name) found and will be set to $($Value)!"
                    $root.SelectSingleNode($XPath,$ns).SetAttribute($Name,$Value)
                }
                else {
                    Write-Verbose -Message "$($Name) could not be found!"
                    break
                }
            }
            else
            {
                if ($root.SelectSingleNode($XPath).HasAttribute($Name))
                {
                    Write-Verbose -Message "$($Name) found and will be set to $($Value)!"
                    $root.SelectSingleNode($XPath).SetAttribute($Name,$Value)
                }
                else {
                    Write-Verbose -Message "$($Name) could not be found!"
                    break
                }
            }
        }
        elseif ($isElementTextValue)
        {
            Write-Verbose "Element!"
            if (-not $EnforceNullXMLNS)
            {
                if ($null -ne $root.SelectSingleNode($XPath + "/$($NSPrefix):$($Name)",$ns))
                {
                    Write-Verbose -Message "$($Name) found and will be set to $($Value)!"
                    ($root.SelectSingleNode($XPath + "/$($NSPrefix):$($Name)",$ns)).set_InnerText($Value)
                }
                else
                {
                    Write-Verbose -Message "$($Name) could not be found!"
                    break
                }
            }
            else{
                if ($null -ne $root.SelectSingleNode($XPath + "$($Name)"))
                {
                    Write-Verbose -Message "Element found and will be set to $($Value)!"
                    ($root.SelectSingleNode($XPath + "$($Name)")).set_InnerText($Value)
                }
                else
                {
                    Write-Verbose -Message "Element could not be found!"
                    break
                }
            }
        }
        else{
            if (-not $EnforceNullXMLNS)
            {
                if ($null -ne $root.SelectSingleNode("$XPath[@$Attribute1=`'$Name`']",$ns))
                {
                    if([System.String]::IsNullOrEmpty($Attribute2))
                    {
                        Write-Verbose -Message "$($Name) found, but `$Attribute2 is NullOrEmtpy!"
                    }
                    else
                    {
                        Write-Verbose -Message "$($Name) found and will be set to $($Value)!"
                        $root.SelectSingleNode("$XPath[@$Attribute1=`'$Name`']",$ns).SetAttribute($Attribute2,$Value)
                    }
                }
                else
                {
                    Write-Verbose -Message "$($Name) could not be found!"
                    break
                }
            }
            else{
                if ($null -ne $root.SelectSingleNode("$XPath[@$Attribute1=`'$Name`']"))
                {
                    if([System.String]::IsNullOrEmpty($Attribute2))
                    {
                        Write-Verbose -Message "$($Name) found, but `$Attribute2 is NullOrEmtpy!"
                    }
                    else
                    {
                        Write-Verbose -Message "$($Name) found and will be set to $($Value)!"
                        $root.SelectSingleNode("$XPath[@$Attribute1=`'$Name`']").SetAttribute($Attribute2,$Value)
                    }
                }
                else
                {
                    Write-Verbose -Message "$($Name) could not be found!"
                    break
                }
            }
        }

        #save XML
        $xml.Save($ConfigPath)

    }
    catch
    {
        Write-Verbose -Message $_
    }
}

function Add-XMLItem
{
    [CmdletBinding()]
    param
    (
        [string]$ConfigPath,
        [string]$XPath,
        [string]$Name,
        [string]$Value,
        [Boolean]$isAttribute,
        [Boolean]$isElementTextValue,
        [string]$Attribute1 = 'key',
        [string]$Attribute2 = 'value',
        [string]$XMLNS,
        [string]$NSPrefix = 'ns',
        [Boolean]$DoBackup,
        [Boolean]$EnforceNullXMLNS,
        $VerbosePreference
    )

    if ($isAttribute -and $isElementTextValue)
    {
        Write-Verbose -Message "AmbiguousParameterSet! isAttribute and isElementTextValue cannot be used simultaneous."
        break
    }

    try
    {
        #read XML
        $xml = [xml](Get-Content $ConfigPath -ErrorAction Stop)
        $root = $xml.get_DocumentElement()

        if ($DoBackup)
        {
            $CurrentDate = (get-date).tostring("MMddyyyy-HHmmssffffff")
            $Backup = $ConfigPath + "_$CurrentDate" + ".bak" 

            try
            {
                #save XML
                $xml.Save($Backup)
            }
            catch
            {
                Write-Verbose -Message $_
                break
            }
        }

        if (-not $EnforceNullXMLNS)
        {
            if (-not $XMLNS)
            {
                $NamespaceURI = $xml.DocumentElement.NamespaceURI
            }
            else
            {
                $NamespaceURI = $XMLNS
            }

            #create XML namespacemanager from document
            $ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
            $ns.AddNameSpace("$NSPrefix",$NamespaceURI)
            #add XMLNameSpaceManager to XPath
            $XPath = $XPath -replace "/(?!/)", "/$($NSPrefix):"
            Write-Verbose -Message "XPath:$($Xpath)"
            Write-Verbose -Message "NamespaceURI:$($NamespaceURI)"
        }

        if ($isAttribute)
        {
            if (-not $EnforceNullXMLNS)
            {
                if (-not $null -eq $root.SelectSingleNode($XPath,$ns))
                {
                    if ($root.SelectSingleNode($XPath,$ns).HasAttribute($Name))
                    {
                        Write-Verbose -Message "Attribute already exist!"
                        break
                    }
                    else
                    {
                        $root.SelectSingleNode($Xpath,$ns).SetAttribute($Name,$Value)
                    }
                }
                else
                {
                    Write-Verbose -Message "Nothing found!"
                }
            }
            else{
                if (-not $null -eq $root.SelectSingleNode($XPath))
                {
                    if ($root.SelectSingleNode($XPath).HasAttribute($Name))
                    {
                        Write-Verbose -Message "Attribute already exist!"
                        break
                    }
                    else
                    {
                        $root.SelectSingleNode($Xpath).SetAttribute($Name,$Value)
                    }
                }
                else
                {
                    Write-Verbose -Message "Nothing found!"
                }
            }
        }
        elseif ($isElementTextValue)
        {
            if (-not $EnforceNullXMLNS)
            {
                if ($null -ne ($root.SelectSingleNode($XPath + "/$($NSPrefix):$($Name)",$ns)))
                {
                    Write-Verbose -Message "Element $($Name) already exist!"
                    break
                }
                else
                {
                    #create element
                    $Element = $xml.CreateElement($Name,$NamespaceURI)
    
                    #set value
                    if ($PSBoundParameters.ContainsKey("Value"))
                    {
                        $Element.set_InnerText($Value)
                    }
    
                    #append element
                    $root.SelectSingleNode($XPath,$ns).AppendChild($Element) | Out-Null
                }
            }
            else
            {
                if ($null -ne ($root.SelectSingleNode($XPath + "/$($Name)")))
                {
                    Write-Verbose -Message "Element $($Name) already exist!"
                    break
                }
                else
                {
                    #create element
                    $Element = $xml.CreateElement($Name)
    
                    #set value
                    if ($PSBoundParameters.ContainsKey("Value"))
                    {
                        $Element.set_InnerText($Value)
                    }
    
                    #append element
                    $root.SelectSingleNode($XPath).AppendChild($Element) | Out-Null
                }
            }
        }
        else
        {
            if (-not $EnforceNullXMLNS)
            {
                if ($root.SelectSingleNode("$XPath[@$Attribute1=`'$Name`']",$ns))
                {
                    Write-Verbose -Message "Element already exist!"
                    break
                }
                else
                {
    
                    #get parent node
                    if ($null -eq $root.SelectSingleNode($XPath,$ns))
                    {
                        # Take one step back in XPath to add first element  
                        $Parent=$root.SelectSingleNode(($XPath.SubString(0, $XPath.LastIndexOf('/'))),$ns)
                    }
                    else
                    {
                        $Parent=$root.SelectSingleNode($XPath,$ns).get_ParentNode()
                    }
    
                    #create element
                    $Element = $xml.CreateElement($($XPath.Split('/')[-1] -replace ("$($NSPrefix):","")),$NamespaceURI)
    
                    if (-not $null -eq $Attribute1)
                    {
                        #create attributes
                        $Attr1=$xml.CreateAttribute($Attribute1)
                        #set attributes
                        $Attr1.set_Value($Name)
                        #add attributes to element
                        $Element.SetAttributeNode($Attr1) | Out-Null
                    }
    
                    if (-not $null -eq $Attribute2)
                    {
                        #create attributes
                        $Attr2=$xml.CreateAttribute($Attribute2)
                        #set attributes
                        $Attr2.set_Value($Value)
                        #add attributes to element
                        $Element.SetAttributeNode($Attr2) | Out-Null
                    }
    
                    #append element
                    $Parent.AppendChild($Element) | Out-Null
                }
            }
            else{
                if ($root.SelectSingleNode("$XPath[@$Attribute1=`'$Name`']"))
                {
                    Write-Verbose -Message "Element already exist!"
                    break
                }
                else
                {
    
                    #get parent node
                    if ($null -eq $root.SelectSingleNode($XPath))
                    {
                        # Take one step back in XPath to add first element  
                        $Parent=$root.SelectSingleNode(($XPath.SubString(0, $XPath.LastIndexOf('/'))))
                    }
                    else
                    {
                        $Parent=$root.SelectSingleNode($XPath).get_ParentNode()
                    }
    
                    #create element
                    $Element = $xml.CreateElement($($XPath.Split('/')[-1]))
    
                    if (-not $null -eq $Attribute1)
                    {
                        #create attributes
                        $Attr1=$xml.CreateAttribute($Attribute1)
                        #set attributes
                        $Attr1.set_Value($Name)
                        #add attributes to element
                        $Element.SetAttributeNode($Attr1) | Out-Null
                    }
    
                    if (-not $null -eq $Attribute2)
                    {
                        #create attributes
                        $Attr2=$xml.CreateAttribute($Attribute2)
                        #set attributes
                        $Attr2.set_Value($Value)
                        #add attributes to element
                        $Element.SetAttributeNode($Attr2) | Out-Null
                    }
    
                    #append element
                    $Parent.AppendChild($Element) | Out-Null
                }
            }
        }

        #save XML
        $xml.Save($ConfigPath)
    }

    catch
    {
        Write-Verbose -Message $_
    }
}

function Remove-XMLItem
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding()]
    param
    (
        [string]$ConfigPath,
        [string]$XPath,
        [string]$Name,
        [string]$Value,
        [Boolean]$isAttribute,
        [Boolean]$isElementTextValue,
        [string]$Attribute1 = 'key',
        [string]$Attribute2 = 'value',
        [string]$XMLNS,
        [string]$NSPrefix = 'ns',
        [Boolean]$DoBackup,
        [Boolean]$EnforceNullXMLNS,
        $VerbosePreference
    )

    if ($isAttribute -and $isElementTextValue)
    {
        Write-Verbose -Message "AmbiguousParameterSet! isAttribute and isElementTextValue cannot be used simultaneous."
        break
    }

    try
    {
        #read XML
        $xml = [xml](Get-Content $ConfigPath -ErrorAction Stop)
        $root = $xml.get_DocumentElement()

        if ($DoBackup)
        {
            $CurrentDate = (get-date).tostring("MMddyyyy-HHmmssffffff")
            $Backup = $ConfigPath + "_$CurrentDate" + ".bak" 

            try
            {
                #save XML
                $xml.Save($Backup)
            }
            catch
            {
                Write-Verbose -Message $_
                break
            }
        }

        if (-not $EnforceNullXMLNS)
        {
            if (-not $XMLNS)
            {
                $NamespaceURI = $xml.DocumentElement.NamespaceURI
            }
            else
            {
                $NamespaceURI = $XMLNS
            }

            #create XML namespacemanager from document
            $ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
            $ns.AddNameSpace("$NSPrefix",$NamespaceURI)
            #add XMLNameSpaceManager to XPath
            $XPath = $XPath -replace "/(?!/)", "/$($NSPrefix):"
            Write-Verbose -Message "XPath:$($Xpath)"
            Write-Verbose -Message "NamespaceURI:$($NamespaceURI)"
        }

        if ($isAttribute)
        {
            if (-not $EnforceNullXMLNS)
            {
                if (-not $null -eq $root.SelectSingleNode($XPath,$ns))
                {
                    if ($root.SelectSingleNode($XPath,$ns).HasAttribute($Name))
                    {
                        $root.SelectSingleNode($Xpath,$ns).RemoveAttribute($Name)
                    }
                    else
                    {
                        Write-Verbose "Nothing found!"
                        break
                    }
                }
                else
                {
                    Write-Verbose "Nothing found!"
                }
            }
            else{
                if (-not $null -eq $root.SelectSingleNode($XPath))
                {
                    if ($root.SelectSingleNode($XPath).HasAttribute($Name))
                    {
                        $root.SelectSingleNode($Xpath).RemoveAttribute($Name)
                    }
                    else
                    {
                        Write-Verbose "Nothing found!"
                        break
                    }
                }
                else
                {
                    Write-Verbose "Nothing found!"
                }
            }
        }
        elseif ($isElementTextValue)
        {
            if (-not $EnforceNullXMLNS)
            {
                #get node
                $Node = $root.SelectSingleNode($XPath + "/$($NSPrefix):$($Name)",$ns)
            }
            else{
                #get node
                $Node = $root.SelectSingleNode($XPath + "/$($Name)")
            }
            #get parent node and remove node
            $Node.get_ParentNode().RemoveChild($Node) | Out-Null
        }
        else
        {
            if (-not $EnforceNullXMLNS)
            {
                if (-not $root.SelectSingleNode("$XPath[@$Attribute1=`'$Name`']",$ns))
                {
                    Write-Verbose "Nothing found!"
                    break
                }
                else
                {
                    #get node
                    $Node = $root.SelectSingleNode("$XPath[@$Attribute1=`'$Name`']",$ns)
                    #get parent node and remove node
                    $Node.get_ParentNode().RemoveChild($Node) | Out-Null
                }
            }
            else{
                if (-not $root.SelectSingleNode("$XPath[@$Attribute1=`'$Name`']"))
                {
                    Write-Verbose "Nothing found!"
                    break
                }
                else
                {
                    #get node
                    $Node = $root.SelectSingleNode("$XPath[@$Attribute1=`'$Name`']")
                    #get parent node and remove node
                    $Node.get_ParentNode().RemoveChild($Node) | Out-Null
                }
            }
        }

        #save XML
        $xml.Save($ConfigPath)
    }
    catch
    {
        Write-Verbose -Message $_
    }
}

function Test-XMLItemExist
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [string]$ConfigPath,
        [string]$XPath,
        [string]$Name,
        [string]$Value,
        [Boolean]$isAttribute,
        [Boolean]$isElementTextValue,
        [string]$Attribute1 = 'key',
        [string]$Attribute2 = 'value',
        [string]$XMLNS,
        [string]$NSPrefix = 'ns',
        [Boolean]$DoBackup,
        [Boolean]$EnforceNullXMLNS,
        $VerbosePreference
    )

    if ($isAttribute -and $isElementTextValue)
    {
        Write-Verbose -Message "AmbiguousParameterSet! isAttribute and isElementTextValue cannot be used simultaneous."
        break
    }

    [boolean]$result = $false
    #read XML
    $xml = [xml](Get-Content $ConfigPath -ErrorAction Stop)
    $root = $xml.get_DocumentElement()

    if (-not $EnforceNullXMLNS)
    {
        if (-not $XMLNS)
        {
            $NamespaceURI = $xml.DocumentElement.NamespaceURI
        }
        else
        {
            $NamespaceURI = $XMLNS
        }

        #create XML namespacemanager from document
        $ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
        $ns.AddNameSpace("$NSPrefix",$NamespaceURI)
        #add XMLNameSpaceManager to XPath
        $XPath = $XPath -replace "/(?!/)", "/$($NSPrefix):"
        Write-Verbose -Message "XPath:$($Xpath)"
        Write-Verbose -Message "NamespaceURI:$($NamespaceURI)"
    }

    if ($isAttribute)
    {
        if (-not $EnforceNullXMLNS)
        {
            if ($root.SelectSingleNode($XPath,$ns).HasAttribute($Name))
            {
                $result = $true
            }
        }
        else{
            if ($root.SelectSingleNode($XPath).HasAttribute($Name))
            {
                $result = $true
            }
        }
    }
    elseif ($isElementTextValue)
    {
        if (-not $EnforceNullXMLNS)
        {
            if ($null -ne ($root.SelectSingleNode($XPath + "/$($NSPrefix):$($Name)",$ns)))
            {
                $result = $true
            }
        }
        else{
            if ($null -ne ($root.SelectSingleNode($XPath + "$($Name)")))
            {
                $result = $true
            }
        }
    }
    else
    {
        if (-not $EnforceNullXMLNS)
        {
            if ($null -ne $root.SelectSingleNode("$XPath[@$Attribute1=`'$Name`']",$ns))
            {
                $result = $true
            }
        }
        else{
            if ($null -ne $root.SelectSingleNode("$XPath[@$Attribute1=`'$Name`']"))
            {
                $result = $true
            }
        }
    }

    return $result
}

Export-ModuleMember -Function *

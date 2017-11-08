using namespace Microsoft.PowerShell.SHiPS
#$VerbosePreference = 'continue'

[SHiPSProvider(UseCache=$true)]
class PEServer: ShiPSDirectory
{
    [object]$PEObject
    [String]$Model
    [String]$ServiceTag
    [String]$TimeStamp

    PEServer([string]$Name,[string]$FullName): base($Name)
    {
        try {
            $TempObject =  & "Microsoft.PowerShell.Management\Get-Content" -Path $FullName -Raw -ErrorAction Stop | ConvertFrom-Json 
            $this.PEObject = $TempObject.SystemConfiguration
            $this.Model = $this.PEObject.Model
            $this.ServiceTag = $this.PEObject.ServiceTag
        }
        catch {
            Write-Verbose -Message "Failure -> $PSItem"  -Verbose
        }
        
    }

    [Object[]] GetChildItem()
    {
        $obj = @()
        $obj += [Components]::new($this.PEObject.Components)
        return $obj
    }
}

[SHiPSProvider(UseCache=$true)]
class Components: ShiPSDirectory {
    [object[]]$PEObject

    Components([object[]]$PEObject): base($this.GetType())
    {
        $this.PEObject = $PEObject
    }

    [object[]] GetChildItem()
    {
        $obj = @()
        foreach ($Component in $this.PEObject)
        {
            $obj += [PEComponent]::new($Component.FQDD,$Component)
        }
        return $obj
    }
}

[SHiPSProvider(UseCache=$true)]
Class PEComponent: SHiPSDirectory {
    [object]$PEObject
    [String]$FQDD

    PEComponent([String]$Name,[Object]$PEObject): base($Name)
    {
        $this.PEObject = $PEObject
        $this.FQDD = $Name
    }

    [object[]] GetChildItem()
    {
        $obj = @()
        $obj += [Attributes]::new($this.PEObject.Attributes)
        return $obj
    }
}


[SHiPSProvider(UseCache=$true)]
class Attributes: ShiPSDirectory {
    [object[]]$PEObject
    
    Attributes([object[]]$PEObject): base($this.GetType())
    {
        $this.PEObject = $PEObject
    }

    [Object[]] GetChildItem()
    {
        $obj = @()
        foreach ($attribute in $this.PEObject)
        {
            $obj += [PEAttribute]::new($attribute.Name, $attribute)
        }
        return $obj
    }
}

class PEAttribute: SHiPSLeaf {
    [Object]$PEObject
    [string]$Value
    [string]$SetOnImport

    PEAttribute([String]$Name, [Object]$PEObject): base($name)
    {
        $this.Value = $PEObject.Value
        $this.SetOnImport = $PEObject.'Set On Import'
    }   

}
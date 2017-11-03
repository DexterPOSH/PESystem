using namespace Microsoft.PowerShell.SHiPS

[SHiPSProvider(UseCache=$true)]
class PEServer: ShiPSDirectory
{
    # Store the service tag
    [String]$ServiceTag
    # model of the PE System
    [String]$Model
    # total memory in GB
    [int]$TotalMemoryGB
    # BIOS version
    [version]$BIOS
    # CPLD Version
    [version]$CPLD
    # LC version
    [version]$LCVersion
    # Hidden reference to the IDRACSession
    Hidden [object]$IDRACSession
    

    PEServer([string]$name): base($name)
    {

    }

    PEServer ([object]$iDRACSession): base($IDRACSession.ComputerName)
    {
        $this.iRACSession = $iDRACSession
    }

    [object[]] GetChildItem()
    {
        # here this would return the 
        $obj = @()
        $obj += [Processor]::new($this.IDRACSession)
        $obj += [Memory]::new($this.IDRACSession)
        $obj += [Network]::new($this.IDRACSession)
        $obj += [DiskStorage]::new($this.IDRACSession)
        return $obj
    }

}

[SHiPSProvider(UseCache=$true)]
class Processor: SHiPSLeaf
{
    [String]$Model
    [int]$NumberOfProcessorCores
    [int]$CPUCount

    Processor([string]$name,[object]$iDRACSession): base($this.GetType())
    {   
        # Invoke a DellPEWSMANTools function to fetch info
        $Result = $null #& DellPEWSMANTools\Get-
        # Once the information is fetched, set the attribs on the class instance
        $this.model = $Result.model
        $this.NumberOfProcessorCores = $Result.NumberOfProcessorCores
        $this.CPUCount = $Result.CPUCount
    }

    <# This is probably a leaf item rather than a container
    [object[]]GetChildItem()
    {
        # invoke the DellPEPowerShellTools module here to get the return info
        return @()
    }
    #>
}

[SHiPSProvider(UseCache=$true)]
class Memory: ShiPSDirectory
{
    Memory([string]$name, [object]$IDRACSession): base($this.GetType())
    {

    }

    [object[]] GetChildItem()
    {
        $obj = @()
        # invoke the DellPEPowerShellTools module here to get the return info
        $results = @()#& DellPEWSMANTools\
        foreach ($memoryObject in $results)
        {
            $obj += [PEMemory]::new(
                $memoryObject.Model, 
                $memoryObject.Speed, 
                $memoryObject.Size, # TODO Refactor the attributes referenced here
                $MemoryObject.DimmCount # these values could be called something else on the object
            )
        }
        return $obj
    }
}

[SHiPSProvider(UseCache=$true)]
class PEMemory: ShiPSLeaf
{
    [String]$Model
    [int]$Speed
    [int]$Size
    [int]$DIMMCount

    PEMemory([Object]$MemoryObject)
    {
        $this.Model = $MemoryObject.Model
        $this.Speed = $MemoryObject.Speed
        $this.Size = $MemoryObject.Size
        $this.DIMMCount = $MemoryObject.DIMMCount
    }

    
}

[SHiPSProvider(UseCache=$true)]
class Network: ShiPSDirectory
{
    Network([string]$name, [object]$iDRACSession): base($this.GetType())
    {

    }

    [Object[]] GetChildItem()
    {
        $obj = @()
        $results = @()# fetch using DellPEWSMANTools
        # Fetch the info and create underlying Leaf objects
        foreach($networkInfo in $Results) {
            $obj+= [PENetwork]::new()
        }
        return $obj
    }
}

[SHiPSProvider(UseCache=$true)]
Class PENetwork: ShiPSLeaf
{
    [string]$ProductName
    [String]$FamilyVersion
    [String]$PermanentMACAddress
    [String]$Slot

    PENetwork([object]$NetworkObject ): base($this.ProductName)
    {
        $this.PorductName = $NetworkObject.ProductName
        # TODO Rest follows
    }
}

[SHiPSProvider(UseCache=$true)]
class DiskStorage: ShiPSDirectory
{
    DiskStorage([String]$Name): base($this.GetType())
    {

    }

    [object[]]GetChildItem()
    {
        # Call PE function and instantiate leaf objects
        $obj = @()
        $results = @()# fetch using DellPEWSMANTools
        # Fetch the info and create underlying Leaf objects
        foreach($networkInfo in $Results) {
            $obj+= [PEDisk]::new()
        }
        return $obj
    }
}

[SHiPSProvider(UseCache=$true)]
class PEDiskController: SHiPSDirectory
{
    [String]$ProductName
    [string]$ControllerFirmwareVersion
    [string]$PSLogUserData
    [int]$DiskCount

    PEDiskController([string]$name) : base($name)
    {

    }

    [object[]]GetChildItem()
    {
        $obj = @()
        $results = @()
        foreach ($PEDisk in $results)
        {
            $obj += [PEDisk]::new()
        }
        return $obj
    }
}

[SHiPSProvider(UseCache=$true)]
class PEDisk: SHiPSLeaf
{
    [String]$Model
    [string]$Revision
    [string]$SerialNumber
    [string]$Slot
    [string]$ConnectedTo

    PEDisk([object]$DiskObject ): base($this.Model)
    {
        $this.Model = $DiskObject.Model
        $this.Revision = $DiskObject.Revision
        # So on
    }
}


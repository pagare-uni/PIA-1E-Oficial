# Definimos la función para la obtención de información acerca del uso de la memoria RAM
function Invoke-ResourcesSystemMemInfo {
<#
.SYNOPSIS
    Show information about the system's memory

.DESCRIPTION
    This function shows RAM information, allowing the user to specify the property to display.

.PARAMETER Option
    Specifies the property that the user can select to show.

.EXAMPLE
    Invoke-ResourcesSystemMemInfo -Option Total
    This example shows the total capacity of the RAM.

.EXAMPLE
    Invoke-ResourcesSystemMemInfo 
    This version of the command without parameters uses the default option and shows all information
    in a list format.
#>
    param(
        # Definimos el parámetro Option con un conjunto de valores válidos
        [Validateset("Total","Free","Used","All")][string]$Option = "All"
    )
    process {
        # Calculamos la memoria RAM total, libre y usada en GB
        $TotalRAM = (Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB
        $FreeRAM = (Get-CimInstance -ClassName Win32_OperatingSystem).FreePhysicalMemory / 1GB
        $UsedRAM = (Get-Process | Measure-Object -Property WorkingSet -Sum).Sum / 1GB

        # Utilizamos switch para manejar las diferentes opciones proporcionadas por el usuario
        switch($Option.ToLower()) {
            "total"{
                # Muestra la memoria total
                Write-Output "La memoria RAM total instalada es de: $TotalRAM GB"
            }
            "free"{
                # Muestra la memoria libre
                Write-Output "La memoria RAM disponible es de: $FreeRAM GB"
            }
            "used" {
                # Muestra la memoria usada
                Write-Output "La memoria RAM en uso es de: $UsedRAM GB"
            }
            default{
                # Si no se especifica ninguna opción, muestra todas las propiedades
                [PSCustomObject]@{
                    "Total Memory (GB)" = $TotalRAM
                    "Free Memory (GB)" = $FreeRAM
                    "Used Memory (GB)" = $UsedRAM
                } | Format-List
            }
        }
    }
}

# Definimos la función para la obtención de información acerca del uso del disco
function Invoke-ResourcesSystemDiskInfo {
<#
.SYNOPSIS
    Show information on the system disk.

.DESCRIPTION
    This function shows Disk use information, allowing the user to specify the property to display.

.PARAMETER Option
    Specifies the property that the user can select to show.

.EXAMPLE
    Invoke-ResourcesSystemDiskInfo -Option Free
    This example shows the available disk space.

.EXAMPLE
    Invoke-ResourcesSystemDiskInfo 
    This version of the command without parameters shows all information in a list format.
#>
    param(
        # Definimos el parámetro Option con un conjunto de valores válidos
        [Validateset("Total","Free","Used","All")][string]$Option = "All"
    )
    process {
        # Obtenemos información sobre los discos
        $DISK = Get-CimInstance -ClassName Win32_LogicalDisk

        # Calculamos el espacio total, libre y usado en GB
        $DISK_Total = ($DISK | Measure-Object -Property Size -Sum).Sum / 1GB
        $DISK_Free = ($DISK | Measure-Object -Property FreeSpace -Sum).Sum / 1GB
        $DISK_Used = $DISK_Total - $DISK_Free
        $DISK_UsedPercent = ($DISK_Used / $DISK_Total) * 100

        # Utilizamos switch para manejar las diferentes opciones proporcionadas por el usuario
        switch($Option.ToLower()) {
            "total"{
                # Muestra el espacio total del disco
                Write-Output "El espacio total del disco es de: $DISK_Total GB"
            }
            "free"{
                # Muestra el espacio libre en el disco
                Write-Output "Espacio disponible del disco: $DISK_Free GB"
            }
            "used" {
                # Muestra el espacio usado en el disco y el porcentaje utilizado
                Write-Output "Espacio del disco usado: $DISK_Used GB"
                Write-Output "Porcentaje del uso del disco: $DISK_UsedPercent%"
            }
            default{
                # Si no se especifica ninguna opción, muestra todas las propiedades
                [PSCustomObject]@{
                    "Disk Space (GB)" = $DISK_Total
                    "Free Space (GB)" = $DISK_Free
                    "Used Space (GB)" = $DISK_Used
                    "Used Percent (%)" = $DISK_UsedPercent
                } | Format-List
            }
        }
    }
}

# Definimos la función para la obtención de información acerca del uso del CPU
function Invoke-ResourcesSystemCPUInfo {
<#
.SYNOPSIS
    Show information about the processor.

.DESCRIPTION
    This function shows processor information, allowing the user to specify the property to display.

.PARAMETER Option
    Specifies the property that the user can select to show.

.EXAMPLE
    Invoke-ResourcesSystemCPUInfo -Option Architecture
    This example shows the architecture of the processor.

.EXAMPLE
    Invoke-ResourcesSystemCPUInfo 
    This version of the command without parameters shows all information in a list format.
#>
    param(
        # Definimos el parámetro Option con un conjunto de valores válidos
        [ValidateSet("Name","NumCores","CoresEnabled","ID","Thread","Architecture","ALL")][string]$Option = "All"
    )
    process {
        # Obtenemos la información del procesador
        $CPUInfo = Get-CimInstance -ClassName Win32_Processor

        # Definimos variables para los diferentes atributos del procesador
        $PName = $CPUInfo.Name
        $PCore = $CPUInfo.NumberOfCores
        $PCoreEnabled = $CPUInfo.NumberOfEnabledCore
        $PId = $CPUInfo.ProcessorId
        $PThreads = $CPUInfo.ThreadCount
        $PArchitecture = (Get-ComputerInfo).OsArchitecture

        # Utilizamos switch para manejar las diferentes opciones proporcionadas por el usuario
        switch($Option.ToLower()) {
            "name"{
                # Muestra el nombre del procesador
                Write-Output "El nombre del procesador es $PName"
            }
            "numcores"{
                # Muestra el número de núcleos del procesador
                Write-Output "Los núcleos totales del procesador son $PCore"
            }
            "coresenabled" {
                # Muestra el número de núcleos habilitados
                Write-Output "Los núcleos en funcionamiento son $PCoreEnabled"
            }
            "id" {
                # Muestra el ID del procesador
                Write-Output "El ID del procesador es $PId"
            }
            "thread" {
                # Muestra el número de hilos del procesador
                Write-Output "El número de hilos del procesador es de $PThreads"
            }
            "architecture" {
                # Muestra la arquitectura de la CPU
                Write-Output "La arquitectura de la CPU es de $PArchitecture"
            }
            default{
                # Si no se especifica ninguna opción, muestra todas las propiedades
                [PSCustomObject]@{
                    "Processor Name" = $PName
                    "Total Cores" = $PCore
                    "Enabled Cores" = $PCoreEnabled
                    "Processor ID" = $PId
                    "Threads" = $PThreads
                    "Architecture" = $PArchitecture
                } | Format-List
            }
        }
    }
}

# Definimos la función para la obtención de información acerca de la red
function Invoke-ResourcesSystemNetInfo {
<#
.SYNOPSIS
    Show information on the net and net adapters.

.DESCRIPTION
    This function shows net information, allowing the user to specify the property to display.

.PARAMETER Option
    Specifies the property that the user can select to show.

.EXAMPLE
    Invoke-ResourcesSystemNetInfo -Option NetSpeed
    This example shows the network speed.

.EXAMPLE
    Invoke-ResourcesSystemNetInfo 
    This version of the command without parameters shows all information in a list format.
#>
    param(
        # Definimos el parámetro Option con un conjunto de valores válidos
        [ValidateSet("NetSpeed","AdapterStatus","NetStats","Full")][String]$Option = "Full"
    )
    process {
        # Obtenemos la velocidad de la red y la información de los adaptadores de red
        $NetSpeed = (Get-NetAdapter -Name Wi-Fi).LinkSpeed
        $AdaptersInfo = Get-NetAdapter | Select-Object -Property Name,Status,MacAddress
        $NetStat = Get-NetAdapterStatistics

        # Utilizamos switch para manejar las diferentes opciones proporcionadas por el usuario
        switch($Option.ToLower()) {
            "netspeed" {
                # Muestra la velocidad de la red
                Write-Output "La velocidad de la red actual es de $NetSpeed"
            }
            "adapterstatus" {
                # Muestra el estado de los adaptadores de red
                Write-Output "La información de los adaptadores de red es la siguiente:"
                $AdaptersInfo | Format-Table -AutoSize
            }
            "netstats" {
                # Muestra estadísticas de la red
                Write-Output "Información de la red actual:"
                $NetStat | Format-Table -AutoSize
            }
            default{
                # Si no se especifica ninguna opción, muestra todas las propiedades
                Write-Output "La información de la red es la siguiente:"
                $NetSpeed | Format-List
                $AdaptersInfo | Format-Table -AutoSize
            }
        }
    }
}

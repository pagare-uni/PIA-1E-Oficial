param(
    [Parameter(Mandatory)]$Hash_Check_path,  # Módulo para revisión de hashes (obligatorio)
    [Parameter(Mandatory)]$Files_List_path,  # Módulo para listado de archivos (obligatorio)
    [Parameter(Mandatory)]$Res_Check_path,   # Módulo para revisión de uso de recursos (obligatorio)
    [Parameter(Mandatory)]$Au_Fold_path,    # Módulo para auditoría de permisos de carpeta (obligatorio)
    [switch]$StrictMode  # Parámetro opcional para habilitar el modo estricto
)

# Si el usuario activó la opción -StrictMode
if ($StrictMode) {
    Set-StrictMode -Version Latest  # Habilita el modo estricto para mejorar la calidad del código
    Write-Host "`nModo estricto activado."
} else {
    Write-Host "`nModo estricto no activado."
}

# Intentar importar los módulos proporcionados y capturar errores si alguno falla
try {
    Import-Module $Hash_Check_path -ErrorAction Stop  # Importa el módulo de revisión de hashes
    Import-Module $Files_List_path -ErrorAction Stop  # Importa el módulo de listado de archivos
    Import-Module $Res_Check_path -ErrorAction Stop   # Importa el módulo de revisión de uso de recursos
    Import-Module $Au_Fold_path -ErrorAction Stop    # Importa el módulo para auditoría de permisos de carpeta
} catch {
    Write-Host "Error al importar uno o más módulos: $_"  # Muestra el error si falla la importación
    exit  # Finaliza el script si no se pueden importar los módulos
}

# Bucle principal del menú
do {
    # Presenta al usuario las opciones para ejecutar los módulos
    Write-Host "`nSeleccione el módulo que desea ejecutar:"
    Write-Host "[1] Revisión de Hashes"
    Write-Host "[2] Listado de Archivos"
    Write-Host "[3] Uso de RAM"
    Write-Host "[4] Uso de Disco"
    Write-Host "[5] Uso de CPU"
    Write-Host "[6] Información de la Red"
    Write-Host "[7] Auditoría de Permisos de Carpeta"
    Write-Host "[8] Ver ayuda de un módulo"
    Write-Host "[9] Salir"

    $op = Read-Host "`nIngrese el número de la opción deseada"  # Solicita al usuario que elija una opción

    # Ejecuta la opción seleccionada por el usuario
    try {
        switch ($op) {
            1 { 
                Write-Host "Ejecutando Revisión de Hashes..."
                Invoke-HashCheck  # Ejecuta la función para revisión de hashes
            }
            2 { 
                Write-Host "Ejecutando Listado de Archivos..."
                Invoke-FileList  # Ejecuta la función para listar archivos
            }
            3 { 
                Write-Host "Ejecutando Revisión de uso de RAM..."
                Invoke-ResourcesSystemMemInfo  # Llama a la función para mostrar el uso de la RAM
            }
            4 { 
                Write-Host "Ejecutando Revisión de uso de Disco..."
                Invoke-ResourcesSystemDiskInfo # Llama a la función para mostrar el uso del disco
            }
            5 { 
                Write-Host "Ejecutando Revisión de uso de CPU..."
                Invoke-ResourcesSystemCPUInfo  # Llama a la función para mostrar el uso del CPU
            }
            6 { 
                Write-Host "Ejecutando Revisión de la Red..."
                Invoke-ResourcesSystemNetInfo  # Llama a la función para mostrar la información de la red
            }
            7 { 
                Write-Host "Ejecutando Auditoría de Permisos de Carpeta..."
                Invoke-AuditFolPer # Ejecuta la auditoría de permisos de la carpeta
            }
            8 { 
                # Opción para ver la ayuda de las funciones
                Write-Host "`nIngrese el número correspondiente a la función para ver la ayuda:"
                Write-Host "[1] Invoke-HashCheck"
                Write-Host "[2] Invoke-FileList"
                Write-Host "[3] Invoke-ResourcesSystemMemInfo"
                Write-Host "[4] Invoke-ResourcesSystemDiskInfo"
                Write-Host "[5] Invoke-ResourcesSystemCPUInfo"
                Write-Host "[6] Invoke-ResourcesSystemNetInfo"
                Write-Host "[7] Invoke-AuditFolPer"
                $helpOption = Read-Host "Ingrese el número de la función para ver la ayuda"
                
                # Muestra la ayuda de la función seleccionada
                switch ($helpOption) {
                    1 { Get-Help Invoke-HashCheck -Full }  # Muestra ayuda completa para revisión de hashes
                    2 { Get-Help Invoke-FileList -Full }   # Muestra ayuda completa para listado de archivos
                    3 { Get-Help Invoke-ResourcesSystemMemInfo -Full }  # Muestra ayuda completa para revisión de uso de RAM
                    4 { Get-Help Invoke-ResourcesSystemDiskInfo -Full } # Muestra ayuda completa para revisión de uso de disco
                    5 { Get-Help Invoke-ResourcesSystemCPUInfo -Full }  # Muestra ayuda completa para revisión de uso de CPU
                    6 { Get-Help Invoke-ResourcesSystemNetInfo -Full }  # Muestra ayuda completa para revisión de la red
                    7 { Get-Help Invoke-AuditFolPer -Full }  # Muestra ayuda completa para auditoría de permisos de carpeta
                    default { Write-Host "Opción de ayuda no válida." -ForegroundColor Red }  # Mensaje de error si la opción no es válida
                }
            }
            9 { 
                Write-Host "Saliendo..."  # Mensaje para salir del script
                break  # Sale del bucle y finaliza el script
            }
            default { 
                Write-Host "Opción no válida. Por favor, seleccione una opción del menú." -ForegroundColor Red }  # Mensaje si la opción ingresada no es válida
        }
    } catch {
        Write-Host "Se produjo un error al ejecutar la opción seleccionada: $_"  # Maneja cualquier error que ocurra al ejecutar la opción
    } finally {
        Write-Host "Proceso completado."  # Mensaje final cuando el script termina
    }
} while ($op -ne 9)  # Continúa el bucle hasta que el usuario seleccione la opción de salir

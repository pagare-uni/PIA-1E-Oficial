function Get-InsPermissions {
<#
.SYNOPSIS
    Checks security permissions for a file or folder and alerts if insecure permissions are found.

.DESCRIPTION
    This function analyzes the access control list (ACL) of a specified file or folder and 
    checks if users like "Everyone" or "BUILTIN\Users" have excessive permissions, such as "FullControl", 
    "Modify", or "Write". If insecure permissions are found, an alert is triggered.

.PARAMETER Path
    Specifies the path of the file or folder to be audited for insecure permissions.

.EXAMPLE
    Get-InsecurePermissions -path "C:\ImportantFolder"
    Reviews permissions in the folder "C:\ImportantFolder" and alerts if insecure permissions are found.

#>
    param (
        [string]$path  # Ruta del archivo o carpeta a auditar
    )

    try {
        # Obtiene el ACL del archivo o carpeta especificado 
        # El Get-Acl  obtiene objetos que representan el descriptor de seguridad de un archivo o recurso.
        $acl = Get-Acl -Path $path

        Write-Host "Revisando permisos para: $path" -ForegroundColor Cyan

        # Recorre cada entrada de acceso en el ACL
        foreach ($access in $acl.Access) {
            # Verifica si la entrada es para 'Everyone' o 'BUILTIN\Users'
            if ($access.IdentityReference -eq "Everyone" -or $access.IdentityReference -eq "BUILTIN\Users") {

                # Verifica si los derechos de acceso incluyen 'FullControl', 'Modify', o 'Write'

                # FullControl, Modify, y Write pueden ser peligrosos porque otorgan derechos importantes sobre los archivos o carpetas
                # -FullControl: Permite a los usuarios no solo modificar o eliminar archivos, sino también cambiar los permisos
                # -Modify: Da la capacidad de cambiar o eliminar el contenido, lo cual es riesgoso en archivos importantes o críticos. 
                # - Write: Permite agregar o modificar archivos. 

                if ($access.FileSystemRights -match "FullControl" -or $access.FileSystemRights -match "Modify" -or $access.FileSystemRights -match "Write") {
                    # Muestra una alerta si se encuentran permisos inseguros
                    Write-Host "Alerta: Permisos inseguros encontrados para '$($access.IdentityReference)' en $path." -ForegroundColor Red
                    Write-Host "Permisos: $($access.FileSystemRights)" -ForegroundColor Yellow
                }
            }
        }
    }
    catch {
        # Muestra un mensaje de error si ocurre una excepción al obtener el ACL
        Write-Host "Error al obtener permisos de $path : $_" -ForegroundColor Red
    }
}

function Invoke-AuditFolPer {
<#
.SYNOPSIS
    Audits security permissions for a folder and its subdirectories.

.DESCRIPTION
    This function checks all files and subdirectories within a specified folder, 
    using the Get-InsecurePermissions function to identify insecure permissions on each file or subdirectory.

.PARAMETER FolderPath
    Specifies the path of the folder to be audited.

.EXAMPLE
    Invoke-AuditFolPer -folderPath "C:\ImportantFolder"
    Audits all files and subdirectories in the folder "C:\ImportantFolder" for insecure permissions.

#>
    param (
        [Parameter(Mandatory)]  # El parámetro 'FolderPath' es obligatorio
        [string]$folderPath  # Ruta de la carpeta a auditar
    )

    # Verifica si la ruta proporcionada existe
    if (-Not (Test-Path $folderPath)) {
        Write-Host "Error: La carpeta $folderPath no existe." -ForegroundColor Red
        return  # Sale de la función si la carpeta no existe
    }

    Write-Host "Iniciando auditoría de permisos en la carpeta: $folderPath" -ForegroundColor Green

    # Obtiene todos los archivos y subcarpetas dentro de la carpeta especificada de manera recursiva
    Get-ChildItem -Path $folderPath -Recurse | ForEach-Object {
        # Llama a Get-InsPermissions para auditar cada archivo y subcarpeta
        Get-InsPermissions -path $_.FullName
    }

    Write-Host "Auditoría completada." -ForegroundColor Green
}

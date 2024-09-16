# Define la clave de API de VirusTotal
# Esta clave es necesaria para autenticar las solicitudes a la API de VirusTotal.
$VirusTotalApiKey = "Aquí va el APIKey"

# Función para consultar VirusTotal con un hash de archivo
function Get-VirusTotalReport {
<#
    .SYNOPSIS
        Queries VirusTotal using a file hash.
    .DESCRIPTION
        Makes a request to the VirusTotal API to obtain a report based on the hash of a file.
        Requires a valid API key to authenticate the request.
    .PARAMETER FileHash
        The hash of the file to be queried on VirusTotal.
    .EXAMPLE
        Get-VirusTotalReport -FileHash "d2d2d2c3c3e3e3f3f3g3g3g4g4h4h4h5h5h5h6h6h6h"
        Queries VirusTotal to get the report for the file with the specified hash.
    .NOTES
        The VirusTotal API key must be configured in the $VirusTotalApiKey variable.
        Ensure you respect the VirusTotal API limits.
#>
    param (
        [string]$FileHash # Parámetro que toma el hash del archivo a consultar
    )

    # URL de la API de VirusTotal para consultar informes, utilizando el hash del archivo
    $url = "https://www.virustotal.com/api/v3/files/$FileHash"

    # Cabeceras de la solicitud, incluyendo la clave de API para autenticación
    $headers = @{
        "x-apikey" = $VirusTotalApiKey
    }

    try {
        # Realiza la solicitud GET a la API de VirusTotal para obtener el informe del archivo
        $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers

        # Devuelve la respuesta obtenida de la API
        return $response
    } catch {
        # En caso de error, muestra un mensaje y devuelve $null
        Write-Error "Error al consultar VirusTotal: $_"
        return $null
    }
}

# Función para generar el reporte de hashes y verificar con VirusTotal
function Invoke-HashCheck {
<#
    .SYNOPSIS
        Generates a security report for files in a folder by checking their hashes on VirusTotal.
    .DESCRIPTION
        Iterates through all files in the specified folder, calculates their hashes using the selected algorithm 
        (default is SHA256), and queries VirusTotal for reports on those hashes. The results 
        are saved in a report file.
    .PARAMETER FolderPath
        The path to the folder containing the files to be checked.
    .PARAMETER HashAlgorithm
        The hash algorithm to use for calculating file hashes (default is "SHA256").
    .PARAMETER ReportPath
        The path where the report file will be saved (default is ".\HASH_Report.txt").
    .EXAMPLE
        Invoke-HashCheck -FolderPath "C:\Files" -HashAlgorithm "SHA256" -ReportPath ".\HashReport.txt"
        Calculates the hashes for all files in "C:\Files", queries VirusTotal, and saves the report in "HashReport.txt".
    .NOTES
        The VirusTotal API key must be configured in the $VirusTotalApiKey variable.
#>
    param(
        [Parameter(Mandatory)]
        [string]$FolderPath, # Ruta de la carpeta que contiene los archivos a verificar

        [string]$HashAlgorithm = "SHA256", # Algoritmo de hash (por defecto SHA256)

        [string]$ReportPath = ".\HASH_Report.txt" # Ruta del reporte donde se guardarán los resultados
    )

    # Informar sobre los parámetros proporcionados
    Write-Output "Iniciando generación de reporte con los siguientes parámetros:"
    Write-Output "Ruta de la carpeta: $FolderPath"
    Write-Output "Algoritmo de hash: $HashAlgorithm"
    Write-Output "Ruta del reporte: $ReportPath"

    # Verificar si la ruta de la carpeta es válida
    Write-Output "Verificando la carpeta en: $FolderPath"
    if (-not (Test-Path -Path $FolderPath)) {
        # Si la carpeta no existe, se muestra un error y se detiene la ejecución
        Write-Error "La carpeta especificada no existe. Por favor, verifique la ruta proporcionada."
        return
    }

    # Obtener todos los archivos en la carpeta
    Write-Output "Obteniendo archivos de la carpeta..."
    $files = Get-ChildItem -Path $FolderPath -File

    # Si no se encuentran archivos en la carpeta, se informa al usuario y se termina
    if ($files.Count -eq 0) {
        Write-Output "No se encontraron archivos en la carpeta especificada."
        return
    }

    # Preparar el array para almacenar los resultados del reporte
    Write-Output "Calculando hashes y generando el reporte..."
    $rp = @()

    # Iterar sobre cada archivo en la carpeta
    foreach ($file in $files) {
        try {
            # Calcular el hash del archivo utilizando el algoritmo especificado
            $hash = Get-FileHash -Path $file.FullName -Algorithm $HashAlgorithm
            $hashValue = $hash.Hash

            # Consultar VirusTotal utilizando el hash del archivo
            $report = Get-VirusTotalReport -FileHash $hashValue

            # Extraer información del reporte obtenido
            if ($report) {
                # Extraer la fecha del último análisis y los resultados
                $scanDate = $report.data.attributes.last_analysis_date
                $scanResults = $report.data.attributes.last_analysis_results

                # Formatear los resultados de los análisis de diferentes proveedores
                $results = ""
                foreach ($vendor in $scanResults.PSObject.Properties) {
                    $results += "$($vendor.Name): $($vendor.Value.category); "
                }

                # Agregar el resultado al reporte
                $rp += "$($file.FullName) $($hashValue) - Analizado el: $($scanDate) - Resultados: $($results)"
            } else {
                # Si hubo un error en la consulta, agregar un mensaje de error al reporte
                $rp += "$($file.FullName) $($hashValue) - Error al consultar VirusTotal."
            }
        } catch {
            # Manejar errores al calcular el hash o consultar VirusTotal
            Write-Error "No se pudo calcular el hash o consultar VirusTotal para el archivo: $($file.FullName)"
        }
    }

    # Guardar los resultados del reporte en el archivo especificado
    $rp | Out-File -FilePath $ReportPath

    # Informar al usuario sobre la ubicación del reporte generado
    Write-Output "Reporte generado en: $ReportPath"
}

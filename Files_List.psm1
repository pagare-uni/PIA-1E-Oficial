function Invoke-FileList {
<#
.SYNOPSIS
    Show hidden files from a specified path.

    -User specifies the path to analyze.
    -User can specify the format for the report of hidden files.

    The function shows hidden files from the given path in the specified format.

.DESCRIPTION
    This function lists hidden files from a specified path.

.PARAMETER Path
    Specifies the path where hidden files will be searched.

.PARAMETER Format
    Specifies the format of the function output (Table or List).

.EXAMPLE
    Invoke-FileList -Path .\Document
    This command finds all hidden files in the Documents directory and subdirectories using the default format (List).

.EXAMPLE
    Invoke-FileList -Path .\Document -Format Table
    This example specifies that the output of the command is in table format, providing the name and full path of each file.
#>

    # Definición de parámetros de la función:
    param(
        # Parámetro obligatorio que especifica la ruta donde se buscarán los archivos ocultos.
        [Parameter(Mandatory)][String]$Path,
        
        # Parámetro que permite al usuario elegir el formato de la salida: "Table" o "List".
        # Si no se especifica, se usa "List" como valor predeterminado.
        [ValidateSet("Table","List")][String]$Format = "List"
    )

    process {
        try {
            # Obtiene todos los archivos ocultos en la ruta especificada, incluyendo subdirectorios.
            # Se utiliza la opción -Recurse para buscar recursivamente en subdirectorios.
            # Se establece -ErrorAction Stop para detenerse ante cualquier error.
            $PathFiles = Get-ChildItem -Path "$Path" -Hidden -Recurse -ErrorAction Stop

            # Verifica si se encontraron archivos ocultos
            if ($PathFiles.Count -eq 0) {
                Write-Host "No se encontraron archivos ocultos en la ruta especificada."
            } else {
                # Verifica el formato de salida solicitado por el usuario.
                if ($Format -eq "Table") {
                    # Si el formato solicitado es "Table", organiza la salida en formato de tabla.
                    # Select-Object se usa para seleccionar propiedades específicas (nombre del archivo y ruta completa).
                    $Files = $PathFiles | 
                    Select-Object -Property @{Name="File"; Expression={$_.name}}, `
                    @{Name="Full Path"; Expression={$_.fullname}} |
                    Format-Table  # Muestra los resultados en formato tabla.
                } else {
                    # Si el formato solicitado es "List" (o si no se especificó otro), organiza la salida en formato de lista.
                    $Files = $PathFiles | 
                    Select-Object -Property @{Name="File"; Expression={$_.name}}, `
                    @{Name="Full Path"; Expression={$_.fullname}} |
                    Format-List  # Muestra los resultados en formato lista.
                }

                # Imprime los resultados procesados.
                echo $Files
            }

        # Manejo de errores
        } catch {
            # Si ocurre un error durante la ejecución, se muestra un mensaje y el detalle del error.
            Write-Host "Ocurrió un error"
            $_.Exception.Message  # Muestra el mensaje de error específico.
        }
    }
}

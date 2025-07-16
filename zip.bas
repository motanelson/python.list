' Criador de ZIP simples (apenas armazenamento, sem compactação)
' Funciona no Windows sem zlib/libzip

Function AddFileToZip(ByRef zipFile As Integer, ByRef fileName As String) As Integer
    Dim As Integer fileIn, bytesRead, i
    Dim As UByte buffer(1023) ' Buffer de 1KB
    
    ' Abre o arquivo a ser adicionado
    fileIn = FreeFile()
    If Open(fileName For Binary Access Read As #fileIn) <> 0 Then
        Print "Erro ao abrir: "; fileName
        Return 0
    End If
    
    ' Escreve o cabeçalho do arquivo no ZIP (formato simplificado)
    Dim As String zipHeader
    zipHeader = "PK" & Chr(3) & Chr(4) & _  ' Assinatura ZIP
                String(14, Chr(0)) & _     ' Campos vazios (sem compressão)
                fileName & Chr(0)          ' Nome do arquivo
    
    Put #zipFile, , zipHeader
    
    ' Copia o conteúdo do arquivo
    Do
        bytesRead = 0
        Get #fileIn, , buffer()
        bytesRead = Loc(fileIn) - Loc(zipFile)
        If bytesRead > 0 Then
            Put #zipFile, , buffer()
        End If
    Loop Until EOF(fileIn)
    
    Close #fileIn
    Return 1
End Function

' Programa principal
color 0,6
cls
Print "Digite os nomes dos arquivos (separados por espacos):"
Dim As String inputFiles

Line Input inputFiles

Print "Digite o nome do ZIP de saida (ex: saida.zip):"
Dim As String zipName
Line Input zipName

' Cria o arquivo ZIP
Dim As Integer zipFile = FreeFile()
If Open(zipName For Binary Access Write As #zipFile) <> 0 Then
    Print "Erro ao criar: "; zipName
    End
End If

' Separa os arquivos e adiciona ao ZIP
Dim As Integer i, startPos = 1
For i = 1 To Len(inputFiles)
    If Mid(inputFiles, i, 1) = " " Then
        If i > startPos Then
            Dim As String fileName = Mid(inputFiles, startPos, i - startPos)
            If AddFileToZip(zipFile, fileName) Then
                Print "Adicionado: "; fileName
            End If
        End If
        startPos = i + 1
    End If
Next i

' Adiciona o último arquivo
If startPos <= Len(inputFiles) Then
    Dim As String lastName = Mid(inputFiles, startPos)
    If AddFileToZip(zipFile, lastName) Then
        Print "Adicionado: "; lastName
    End If
End If

Close #zipFile
Print "ZIP criado: "; zipName

Sleep
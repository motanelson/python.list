
#include "crt.bi"
#include "file.bi"

' === Inicializar Tabela CRC32 ===
Dim Shared crc32_table(0 To 255) As UInteger
For i As Integer = 0 To 255
    Dim c As UInteger = i
    For j As Integer = 0 To 7
        If (c And 1) Then
            c = &hEDB88320 Xor (c Shr 1)
        Else
            c = c Shr 1
        End If
    Next
    crc32_table(i) = c
Next

Function CalcCRC32(buf As UByte Ptr, length As UInteger) As UInteger
    Dim crc As UInteger = &hFFFFFFFF
    For i As UInteger = 0 To length - 1
        crc = (crc Shr 8) Xor crc32_table((crc Xor buf[i]) And &hFF)
    Next
    Return Not crc
End Function

Sub WriteU16(f As Integer, v As UShort)
    Put #f,,v
End Sub

Sub WriteU32(f As Integer, v As UInteger)
    Put #f,,v
End Sub

' === Entrada do utilizador ===
Dim As String fnames_input
Dim Shared fname(0 To 255) As String
Dim As Integer indexes = 0, startPos = 1
Dim As Integer i

Color 0, 6 : Cls
Input "Files to zip (separados por espaço): ", fnames_input

' Separar nomes
For i = 1 To Len(fnames_input)
    If Mid(fnames_input, i, 1) = " " Then
        If i > startPos Then
            fname(indexes) = Mid(fnames_input, startPos, i - startPos)
            indexes += 1
        End If
        startPos = i + 1
    End If
Next

If startPos <= Len(fnames_input) Then
    fname(indexes) = Mid(fnames_input, startPos)
    indexes += 1
End If

If indexes = 0 Then
    Print "Nenhum ficheiro fornecido."
    End
End If

Dim As String zipname = "output.zip"
Dim As Integer z = FreeFile()
Open zipname For Binary Access Write As #z

' Arrays auxiliares
Dim As UInteger offset(0 To 255)
Dim As UInteger fsize(0 To 255)
Dim As UInteger crc(0 To 255)
Dim As UByte Ptr buffer
dim nnn as UInteger=0

' === Local File Headers + Dados ===
For i = 0 To indexes - 1
    Dim As Integer f = FreeFile()
    Open fname(i) For Binary Access Read As #f
    fsize(i) = Lof(f)
    buffer = Allocate(fsize(i))
    Get #f,, *buffer, fsize(i)
    Close #f

    crc(i) = CalcCRC32(buffer, fsize(i))
    offset(i) = Seek(z) - 1

    ' --- Local Header ---
    nnn=&h04034B50
    Put #z,, nnn              ' Local file header signature
    WriteU16(z, 20)                 ' Version needed to extract
    WriteU16(z, 0)                  ' Flags
    WriteU16(z, 0)                  ' Compression method = 0 (store)
    WriteU16(z, 0) : WriteU16(z, 0) ' Time & Date
    WriteU32(z, crc(i))            ' CRC-32
    WriteU32(z, fsize(i))          ' Compressed size
    WriteU32(z, fsize(i))          ' Uncompressed size
    WriteU16(z, Len(fname(i)))     ' File name length
    WriteU16(z, 0)                 ' Extra field length
    Put #z,, fname(i)              ' File name
    Put #z,, *buffer, fsize(i)     ' File data

    Deallocate buffer
Next

' === Central Directory ===
Dim As UInteger cd_start = Seek(z) - 1

For i = 0 To indexes - 1
     nnn=&h02014B50 
    Put #z,, nnn           ' Central directory file header signature
    WriteU16(z, &h0014)            ' Version made by (FAT/Windows)
    WriteU16(z, 20)                ' Version needed to extract
    WriteU16(z, 0)                 ' Flags
    WriteU16(z, 0)                 ' Compression method
    WriteU16(z, 0) : WriteU16(z, 0) ' Time & Date
    WriteU32(z, crc(i))           ' CRC-32
    WriteU32(z, fsize(i))         ' Compressed size
    WriteU32(z, fsize(i))         ' Uncompressed size
    WriteU16(z, Len(fname(i)))    ' File name length
    WriteU16(z, 0)                ' Extra field length
    WriteU16(z, 0)                ' File comment length
    WriteU16(z, 0)                ' Disk number start
    WriteU16(z, 0)                ' Internal file attributes
    WriteU32(z, 0)                ' External file attributes
    WriteU32(z, offset(i))        ' Offset to Local Header
    Put #z,, fname(i)             ' File name
Next

Dim As UInteger cd_size = Seek(z) - 1 - cd_start

' === End of Central Directory ===
nnn=&h06054B50
Put #z,,nnn        ' End of central directory signature
WriteU16(z, 0)            ' Number of this disk
WriteU16(z, 0)            ' Disk where CD starts
WriteU16(z, indexes)      ' Entries on this disk
WriteU16(z, indexes)      ' Total entries
WriteU32(z, cd_size)      ' CD size
WriteU32(z, cd_start)     ' CD start offset
WriteU16(z, 0)            ' ZIP file comment length

Close #z

Print "ZIP criado com sucesso: "; zipname
Sleep

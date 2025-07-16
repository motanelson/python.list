#include "crt.bi"
#include "file.bi"

' Inicializa tabela CRC
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
    Dim i As Integer
    For i = 0 To length - 1
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



' === CONFIG ===
Dim As String fname = "ficheiro.txt"
Dim As String zipname = "output.zip"
color 0,6
cls
input "file to zip?";fname
' === LER O FICHEIRO ===
Dim As Integer f = FreeFile()
Open fname For Binary Access Read As #f
Dim As UInteger fsize = Lof(f)
Dim As UByte Ptr buffer = Allocate(fsize)
Get #f, , *buffer, fsize
Close #f

Dim As UInteger crc = CalcCRC32(buffer, fsize)

' === ESCREVER ZIP ===
Dim As Integer z = FreeFile()
Open zipname For Binary Access Write As #z

Dim As UInteger offset = Seek(z) - 1
dim nnn as uInteger
nnn=&h04034b50
' ---- LOCAL FILE HEADER ----
Put #z,, nnn       ' Signature
WriteU16(z, 20)           ' Version needed
WriteU16(z, 0)            ' Flags
WriteU16(z, 0)            ' Compression method (store)
WriteU16(z, 0)            ' File time
WriteU16(z, 0)            ' File date
WriteU32(z, crc)          ' CRC-32
WriteU32(z, fsize)        ' Compressed size
WriteU32(z, fsize)        ' Uncompressed size
WriteU16(z, Len(fname))   ' File name length
WriteU16(z, 0)            ' Extra field length
Put #z,, fname            ' File name
Put #z,, *buffer, fsize   ' File data

Dim As UInteger cd_offset = Seek(z) - 1

' ---- CENTRAL DIRECTORY HEADER ----
nnn=&h02014b50
Put #z,,nnn        ' Signature
WriteU16(z, &h0314)       ' Version made by (DOS, 20)
WriteU16(z, 20)           ' Version needed
WriteU16(z, 0)            ' Flags
WriteU16(z, 0)            ' Compression method
WriteU16(z, 0)            ' Time
WriteU16(z, 0)            ' Date
WriteU32(z, crc)          ' CRC
WriteU32(z, fsize)        ' Compressed size
WriteU32(z, fsize)        ' Uncompressed size
WriteU16(z, Len(fname))   ' File name length
WriteU16(z, 0)            ' Extra field length
WriteU16(z, 0)            ' File comment length
WriteU16(z, 0)            ' Disk number
WriteU16(z, 0)            ' Internal file attrs
WriteU32(z, 0)            ' External file attrs
WriteU32(z, offset)       ' Offset local header
Put #z,, fname            ' File name

Dim As UInteger cd_size = Seek(z) - 1 - cd_offset

' ---- END OF CENTRAL DIRECTORY RECORD ----
nnn=&h06054b50
Put #z,, nnn       ' Signature
WriteU16(z, 0)            ' This disk
WriteU16(z, 0)            ' Disk with CD
WriteU16(z, 1)            ' Total entries on this disk
WriteU16(z, 1)            ' Total entries total
WriteU32(z, cd_size)      ' Size of CD
WriteU32(z, cd_offset)    ' Offset of CD
WriteU16(z, 0)            ' Comment length

Close #z
Deallocate buffer

Print "Ficheiro ZIP gerado: "; zipname

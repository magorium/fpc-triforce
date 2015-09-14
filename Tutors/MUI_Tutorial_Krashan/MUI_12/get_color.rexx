/* Script for example 13a - getting color */

ADDRESS "EXAMPLE13A.1"
OPTIONS RESULTS

GetColor
PARSE VAR RESULT red " " green " " blue

Say ("Blue:  " || blue)
Say ("Red:   " || red)
Say ("Green: " || green)

EXIT

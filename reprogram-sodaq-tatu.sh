#!/bin/sh

set -e

MYDIR=$(dirname $0)
BOOTLDR_DIR="${MYDIR}/avr/bootloaders/optiboot"
BOOTLDR="${BOOTLDR_DIR}/optiboot_atmega1284p.hex"

PRGMR=avrispmkII
USB=usb
#PRGMR=stk500v2
#USB=/dev/ttySLOT1

[ -f "${BOOTLDR}" ] || { echo "ERROR: Cannot find bootloader '${BOOTLDR}'"; exit 1; }

#  http://eleccelerator.com/fusecalc/fusecalc.php?chip=atmega1284p&LOW=FF&HIGH=D6&EXTENDED=FD&LOCKBIT=2F
#
# hfuse => 0xD6
#  BOOTRST=0 => Boot Reset enabled: YES
#  BOOTSZ=11 => 512 words (i.e. 1024 bytes)
#  EESAVE=0 => Preserve EEPROM: YES
#  WDTON=1 => Watch-dog always on: NO
#  SPIEN=0 => SPI downloading enabled: YES
#  JTAGEN=1 => JTAG interface enabled: NO
#  OCDEN=1 => On-Chip Debug enabled: NO

# lfuse => 0xFF

# lockbits => 0x2F
#  Application Protection Mode 1: No lock on SPM and LPM in Application Section
#  Boot Loader Protection Mode 2: SPM prohibited in Boot Loader Section
#  Mode 1: No memory lock features enabled

EFUSE=0xFD		# same effect as 0x05
HFUSE=0xD6
LFUSE=0xFF
LOCK=0x2F
cmd="avrdude -v -patmega1284p -c $PRGMR -P $USB -e"
echo $cmd
eval $cmd
cmd="avrdude -v -patmega1284p -c $PRGMR -P $USB -Uefuse:w:${EFUSE}:m -Uhfuse:w:${HFUSE}:m -Ulfuse:w:${LFUSE}:m"
echo $cmd
eval $cmd
cmd="avrdude -v -patmega1284p -c $PRGMR -P $USB -Uflash:w:$BOOTLDR:i"
echo $cmd
eval $cmd
cmd="avrdude -v -patmega1284p -c $PRGMR -P $USB -Ulock:w:${LOCK}:m"
echo $cmd
eval $cmd

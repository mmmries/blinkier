# Blinkier

This project uses a [Sense Hat]() to display information about the envioronment around the device.

red = :binary.copy(<<0, 0xf8>>, 8)
blue = :binary.copy(<<0xf8, 0>>, 8)
green = :binary.copy(<<0xe0, 0x07>>, 8)
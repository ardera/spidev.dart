part of bindings;
// ignore_for_file: non_constant_identifier_names, camel_case_types, unnecessary_brace_in_string_interps, unused_element

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.

/// struct spi_ioc_transfer - describes a single SPI transfer
/// @tx_buf: Holds pointer to userspace buffer with transmit data, or null.
/// If no data is provided, zeroes are shifted out.
/// @rx_buf: Holds pointer to userspace buffer for receive data, or null.
/// @len: Length of tx and rx buffers, in bytes.
/// @speed_hz: Temporary override of the device's bitrate.
/// @bits_per_word: Temporary override of the device's wordsize.
/// @delay_usecs: If nonzero, how long to delay after the last bit transfer
/// before optionally deselecting the device before the next transfer.
/// @cs_change: True to deselect device before starting the next transfer.
/// @word_delay_usecs: If nonzero, how long to wait between words within one
/// transfer. This property needs explicit support in the SPI controller,
/// otherwise it is silently ignored.
///
/// This structure is mapped directly to the kernel spi_transfer structure;
/// the fields have the same meanings, except of course that the pointers
/// are in a different address space (and may be of different sizes in some
/// cases, such as 32-bit i386 userspace over a 64-bit x86_64 kernel).
/// Zero-initialize the structure, including currently unused fields, to
/// accommodate potential future updates.
///
/// SPI_IOC_MESSAGE gives userspace the equivalent of kernel spi_sync().
/// Pass it an array of related transfers, they'll execute together.
/// Each transfer may be half duplex (either direction) or full duplex.
///
/// struct spi_ioc_transfer mesg[4];
/// ...
/// status = ioctl(fd, SPI_IOC_MESSAGE(4), mesg);
///
/// So for example one transfer might send a nine bit command (right aligned
/// in a 16-bit word), the next could read a block of 8-bit data before
/// terminating that command by temporarily deselecting the chip; the next
/// could send a different nine bit command (re-selecting the chip), and the
/// last transfer might write some register values.
class spi_ioc_transfer extends ffi.Struct {
  @ffi.Uint64()
  int tx_buf;

  @ffi.Uint64()
  int rx_buf;

  @ffi.Uint32()
  int len;

  @ffi.Uint32()
  int speed_hz;

  @ffi.Uint16()
  int delay_usecs;

  @ffi.Uint8()
  int bits_per_word;

  @ffi.Uint8()
  int cs_change;

  @ffi.Uint8()
  int tx_nbits;

  @ffi.Uint8()
  int rx_nbits;

  @ffi.Uint8()
  int word_delay_usecs;

  @ffi.Uint8()
  int pad;
}

const int SPI_CPHA = 1;

const int SPI_CPOL = 2;

const int SPI_MODE_0 = 0;

const int SPI_MODE_1 = 1;

const int SPI_MODE_2 = 2;

const int SPI_MODE_3 = 3;

const int SPI_CS_HIGH = 4;

const int SPI_LSB_FIRST = 8;

const int SPI_3WIRE = 16;

const int SPI_LOOP = 32;

const int SPI_NO_CS = 64;

const int SPI_READY = 128;

const int SPI_TX_DUAL = 256;

const int SPI_TX_QUAD = 512;

const int SPI_RX_DUAL = 1024;

const int SPI_RX_QUAD = 2048;

const int SPI_CS_WORD = 4096;

const int SPI_TX_OCTAL = 8192;

const int SPI_RX_OCTAL = 16384;

const int SPI_3WIRE_HIZ = 32768;

const int SPI_IOC_MAGIC = 107;

const int SPI_IOC_RD_MODE = 2147576577;

const int SPI_IOC_WR_MODE = 1073834753;

const int SPI_IOC_RD_LSB_FIRST = 2147576578;

const int SPI_IOC_WR_LSB_FIRST = 1073834754;

const int SPI_IOC_RD_BITS_PER_WORD = 2147576579;

const int SPI_IOC_WR_BITS_PER_WORD = 1073834755;

const int SPI_IOC_RD_MAX_SPEED_HZ = 2147773188;

const int SPI_IOC_WR_MAX_SPEED_HZ = 1074031364;

const int SPI_IOC_RD_MODE32 = 2147773189;

const int SPI_IOC_WR_MODE32 = 1074031365;
